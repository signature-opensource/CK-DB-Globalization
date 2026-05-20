-- SetupConfig: {}
--
-- Builds and inserts the fallback chain for @CultureId into CK.tCultureFallback.
-- The chain is composed as:
--   1) the "real" fallbacks parsed from @FullName (resolved to CultureIds via CK.tCulture.Name);
--   2) the English CultureId at the end (if not already in the chain);
--   3) all of English's current fallback CultureIds, in their existing order, that are not already in the chain.
--
-- The owner @CultureId can be a normalized id (also present in CK.tCulture) or a pure extended id
-- (only in CK.tExtendedCulture); both are valid here.
--
-- Caller must have inserted the matching CK.tExtendedCulture row (and CK.tCulture row if normalized)
-- BEFORE calling this sproc.
--
create procedure CK.sCultureFallbackBuildChain
(
    @CultureId int,
    @FullName varchar(512)
)
as
begin
    --[beginsp]

    declare @EnId int = (select CultureId from CK.tCulture where Name = 'en');

    declare @Chain table( Idx smallint not null identity(0,1), FallbackCultureId int not null );

    -- 1) Real fallbacks parsed from @FullName (comma-separated culture names).
    declare @Rest varchar(512) = isnull( @FullName, '' ) + ',';
    declare @Cut int = charindex( ',', @Rest );
    declare @Token varchar(20);
    while @Cut > 0
    begin
        set @Token = ltrim( rtrim( substring( @Rest, 1, @Cut - 1 ) ) );
        if len( @Token ) > 0
        begin
            insert into @Chain( FallbackCultureId )
                select c.CultureId
                from CK.tCulture c
                where c.Name = @Token
                  and not exists ( select 1 from @Chain x where x.FallbackCultureId = c.CultureId );
        end
        set @Rest = substring( @Rest, @Cut + 1, len( @Rest ) );
        set @Cut = charindex( ',', @Rest );
    end

    -- Defensive: if @FullName parsed to nothing usable, fall back to self at Idx = 0.
    if not exists (select 1 from @Chain)
    begin
        insert into @Chain( FallbackCultureId )
            select @CultureId
            where exists (select 1 from CK.tCulture where CultureId = @CultureId);
        if not exists (select 1 from @Chain)
            -- @CultureId is a pure extended id (no tCulture row). Use its PrimaryCultureId.
            insert into @Chain( FallbackCultureId )
                select PrimaryCultureId from CK.tExtendedCulture
                where ExtendedCultureId = @CultureId and PrimaryCultureId is not null;
    end

    -- 2) Append English (if not already present and if @EnId is known).
    if @EnId is not null and not exists (select 1 from @Chain where FallbackCultureId = @EnId)
    begin
        insert into @Chain( FallbackCultureId ) values( @EnId );
    end

    -- 3) Append English's current fallback chain entries that are not already in @Chain,
    --    preserving English's own ordering.
    if @EnId is not null
    begin
        insert into @Chain( FallbackCultureId )
            select f.FallbackCultureId
            from CK.tCultureFallback f
            where f.CultureId = @EnId
              and not exists ( select 1 from @Chain x where x.FallbackCultureId = f.FallbackCultureId )
            order by f.Idx;
    end

    -- Materialize the chain.
    insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId )
        select @CultureId, Idx, FallbackCultureId from @Chain;

    --[endsp]

end
