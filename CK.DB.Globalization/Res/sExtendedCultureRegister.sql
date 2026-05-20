-- SetupConfig: {}
--
-- Creates a pure extended culture (multi-culture chain that has no normalized counterpart in CK.tCulture).
-- Inserts a single row in CK.tExtendedCulture and builds its fallback chain via
-- CK.sCultureFallbackBuildChain (real fallbacks + English + English's chain).
-- Unlike sCultureRegister, this sproc does NOT propagate the new id to other chains
-- (a pure extended id cannot be a FallbackCultureId since tCultureFallback.FallbackCultureId
-- has an FK to tCulture).
--
create procedure CK.sExtendedCultureRegister
(
    @ExtendedCultureId int,
    @FullName varchar(512),
    @PrimaryCultureId int
)
as
begin
    if @ExtendedCultureId = 0 throw 50000, 'ExtendedCulture.IDMustNotBe0', 1;

    --[beginsp]

    --<PreExtendedCreate revert />

    if exists (select 1 from CK.tExtendedCulture where ExtendedCultureId = @ExtendedCultureId)
        throw 50000, 'ExtendedCulture.ExtendedCultureIdMustBeUnique', 1;

    if not exists (select 1 from CK.tCulture where CultureId = @PrimaryCultureId)
        throw 50000, 'ExtendedCulture.UnknownPrimaryCulture', 1;

    insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId )
        values( @ExtendedCultureId, @FullName, @PrimaryCultureId );

    exec CK.sCultureFallbackBuildChain @ExtendedCultureId, @FullName;

    --<PostExtendedCreate />

    --[endsp]

end
