-- SetupConfig: {}
--
-- Replaces the fallback chain of an extended culture.
-- @CultureId is an ExtendedCultureId (the chain owner).
-- @FallbackCultureIds is a comma separated list of CultureId values (normalized cultures).
-- The list must start with the PrimaryCultureId of @CultureId (== @CultureId itself for a normalized culture).
-- All referenced ids must exist in CK.tCulture.
--
create procedure CK.sCultureFallbackSet
(
	@CultureId int,
	@FallbackCultureIds varchar(max)
)
as
begin
	if @CultureId = 0 throw 50000, 'CultureFallback.IDMustNotBe0', 1;
	if @FallbackCultureIds is null or len( @FallbackCultureIds ) = 0
		throw 50000, 'CultureFallback.FallbacksMustNotBeEmpty', 1;

	--[beginsp]

	declare @PrimaryCultureId int;
	select @PrimaryCultureId = PrimaryCultureId from CK.tExtendedCulture where ExtendedCultureId = @CultureId;
	if @PrimaryCultureId is null
		throw 50000, 'CultureFallback.ExtendedCultureNotFound', 1;

	declare @Fallbacks table( Idx smallint not null identity(0,1), FallbackCultureId int not null );
	declare @xml xml = cast( '<t>' + replace( @FallbackCultureIds, ',', '</t><t>' ) + '</t>' as xml );
	insert into @Fallbacks( FallbackCultureId )
		select r.value( '.', 'int' )
		from @xml.nodes( '/t' ) as records(r);

	-- First entry of the chain must be the PrimaryCultureId of the owning extended.
	if not exists (select 1 from @Fallbacks where FallbackCultureId = @PrimaryCultureId and Idx = 0)
		throw 50000, 'CultureFallback.MustStartWithPrimaryCultureId', 1;

	-- All referenced CultureIds must exist.
	if exists (
		select 1 from @Fallbacks f
		where not exists (select 1 from CK.tCulture c where c.CultureId = f.FallbackCultureId)
	)
		throw 50000, 'CultureFallback.UnknownCultureInChain', 1;

	-- Replace the chain atomically: clear then reinsert from the parsed list.
	delete from CK.tCultureFallback where CultureId = @CultureId;

	insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId )
		select @CultureId, Idx, FallbackCultureId from @Fallbacks;

	--[endsp]

end
