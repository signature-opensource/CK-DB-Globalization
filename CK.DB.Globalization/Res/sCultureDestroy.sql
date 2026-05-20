-- SetupConfig: {}
--
-- Destroys a normalized culture and all its descendants (via ParentCultureId). Cascades to:
-- - any extended culture whose PrimaryCultureId points to one of the destroyed cultures
--   (including each destroyed culture's own self-referencing tExtendedCulture row);
-- - all tCultureFallback chains owned by those destroyed extended cultures;
-- - references to destroyed cultures from chains of surviving extended cultures (with Idx reindex).
--
create procedure CK.sCultureDestroy
(
	@CultureId int
)
as
begin
	if @CultureId = 0 throw 50000, 'Culture.IDMustNotBe0', 1;

	--[beginsp]

	--<PreDestroy revert />

	if not exists (select 1 from CK.tCulture where CultureId = @CultureId)
		throw 50000, 'Culture.CultureNotFound', 1;

	if exists (select 1 from CK.tCulture where CultureId = @CultureId and Name = 'en')
		throw 50000, 'Culture.CannotDestroyEnglishCulture', 1;

	-- Collect tCulture rows to delete: the target + all its descendants via ParentCultureId.
	declare @ToDeleteCultures table( CultureId int not null primary key );
	;with Descendants as
	(
		select CultureId from CK.tCulture where CultureId = @CultureId
		union all
		select c.CultureId
		from CK.tCulture c
		inner join Descendants d on c.ParentCultureId = d.CultureId
		where c.CultureId <> 0
	)
	insert into @ToDeleteCultures( CultureId ) select CultureId from Descendants;

	-- Collect tExtendedCulture rows to delete: every extended whose PrimaryCultureId is a destroyed culture.
	-- Naturally includes the normalized self-referencing extendeds (ExtendedCultureId = CultureId).
	declare @ToDeleteExtended table( ExtendedCultureId int not null primary key );
	insert into @ToDeleteExtended( ExtendedCultureId )
		select e.ExtendedCultureId
		from CK.tExtendedCulture e
		where e.PrimaryCultureId in (select CultureId from @ToDeleteCultures);

	-- Drop the fallback chains owned by the destroyed extended cultures.
	delete f
		from CK.tCultureFallback f
		inner join @ToDeleteExtended e on e.ExtendedCultureId = f.CultureId;

	-- Reindex chains that survive but reference at least one destroyed culture in their FallbackCultureId.
	declare @Rebuild table
	(
		CultureId int not null,
		NewIdx smallint not null,
		FallbackCultureId int not null,
		primary key( CultureId, NewIdx )
	);
	insert into @Rebuild( CultureId, NewIdx, FallbackCultureId )
		select  f.CultureId,
				cast( row_number() over( partition by f.CultureId order by f.Idx ) - 1 as smallint ),
				f.FallbackCultureId
		from CK.tCultureFallback f
		where f.FallbackCultureId not in (select CultureId from @ToDeleteCultures)
		  and exists (
				select 1
				from CK.tCultureFallback fx
				where fx.CultureId = f.CultureId
				  and fx.FallbackCultureId in (select CultureId from @ToDeleteCultures)
		  );

	delete f
		from CK.tCultureFallback f
		where f.CultureId in (select CultureId from @Rebuild);

	insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId )
		select CultureId, NewIdx, FallbackCultureId from @Rebuild;

	-- Detach PrimaryCultureId for the about-to-be-deleted tExtendedCulture rows: point them to
	-- the seed 0 (always present) so the FK on PrimaryCultureId stays satisfied while we delete tCulture rows.
	update CK.tExtendedCulture
		set PrimaryCultureId = 0
		where ExtendedCultureId in (select ExtendedCultureId from @ToDeleteExtended);

	-- Delete tCulture descendants first (single set-based DELETE handles dependency ordering internally),
	-- then the target row itself.
	;with Descendants as
	(
		select CultureId
		from CK.tCulture
		where ParentCultureId = @CultureId and CultureId <> @CultureId

		union all

		select c.CultureId
		from CK.tCulture c
		inner join Descendants d on c.ParentCultureId = d.CultureId
		where c.CultureId <> 0
	)
	delete from CK.tCulture where CultureId in (select CultureId from Descendants);

	delete from CK.tCulture where CultureId = @CultureId;

	-- Finally drop the tExtendedCulture rows now that no tCulture row references them.
	delete e
		from CK.tExtendedCulture e
		inner join @ToDeleteExtended d on d.ExtendedCultureId = e.ExtendedCultureId;

	--<PostDestroy />

	--[endsp]

end
