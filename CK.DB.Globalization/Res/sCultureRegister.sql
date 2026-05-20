-- SetupConfig: {}
--
-- Creates a normalized culture: inserts a row in both CK.tExtendedCulture and CK.tCulture,
-- with PrimaryCultureId = self. Then:
--   - builds the new culture's fallback chain via CK.sCultureFallbackBuildChain
--     (real fallbacks from @FullName + English at the end + English's current chain);
--   - propagates @CultureId as the last fallback of every other extended culture,
--     so all existing chains "know about" the newly registered language.
--
create procedure CK.sCultureRegister
(
	@CultureId int,
	@Name varchar(20),
	@FullName varchar(512),
	@EnglishName nvarchar(255),
	@NativeName nvarchar(255),
	@DisplayName nvarchar(255),
    @ParentCultureId int = 0
)
as
begin
	if @CultureId = 0  throw 50000, 'Culture.IDMustNotBe0', 1;

     --[beginsp]

    --<PreCreate revert />

    if exists (select 1 from CK.tExtendedCulture where ExtendedCultureId = @CultureId)
        throw 50000, 'Culture.CultureIdMustBeUnique', 1;

    -- Step 1: insert the tExtendedCulture row with PrimaryCultureId temporarily NULL.
    insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId )
        values( @CultureId, @FullName, null );

    -- Step 2: insert the tCulture row (FK to tExtendedCulture is now satisfied).
    insert into CK.tCulture( CultureId, Name, EnglishName, NativeName, DisplayName, ParentCultureId )
        values( @CultureId, @Name, @EnglishName, @NativeName, @DisplayName, @ParentCultureId );

    -- Step 3: finalize PrimaryCultureId now that the tCulture row exists.
    update CK.tExtendedCulture set PrimaryCultureId = @CultureId where ExtendedCultureId = @CultureId;

    -- Step 4: build this culture's fallback chain (real + English + English's chain).
    exec CK.sCultureFallbackBuildChain @CultureId, @FullName;

    -- Step 5: propagate the new normalized culture as the last fallback of every other extended culture
    -- whose chain doesn't already contain it.
    ;with NextIdx as
    (
        select e.ExtendedCultureId,
               NextIdx = cast( isnull( max(f.Idx), -1 ) + 1 as smallint )
        from CK.tExtendedCulture e
        left join CK.tCultureFallback f on f.CultureId = e.ExtendedCultureId
        where e.ExtendedCultureId <> @CultureId
          and e.ExtendedCultureId <> 0
          and not exists (
              select 1 from CK.tCultureFallback x
              where x.CultureId = e.ExtendedCultureId and x.FallbackCultureId = @CultureId
          )
        group by e.ExtendedCultureId
    )
    insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId )
        select ExtendedCultureId, NextIdx, @CultureId from NextIdx;

    --<PostCreate />

    --[endsp]

end
