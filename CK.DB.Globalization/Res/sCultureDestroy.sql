-- SetupConfig: {}
--
-- Destroy a culture and all its children recursively.
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

	-- Recursively delete all descendants (children first, then parent).
	;with Descendants as
	(
		select CultureId
		from CK.tCulture
		where ParentCultureId = @CultureId

		union all

		select c.CultureId
		from CK.tCulture c
		inner join Descendants d on c.ParentCultureId = d.CultureId
	)
	delete from CK.tCulture
	where CultureId in (select CultureId from Descendants);

	-- Delete the culture itself.
	delete from CK.tCulture
	where CultureId = @CultureId;

	--<PostDestroy />

	--[endsp]

end
