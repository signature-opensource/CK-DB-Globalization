-- SetupConfig: {}
--
-- Destroys a pure extended culture (no associated tCulture row).
-- Use CK.sCultureDestroy for normalized cultures.
--
create procedure CK.sExtendedCultureDestroy
(
    @ExtendedCultureId int
)
as
begin
    if @ExtendedCultureId = 0 throw 50000, 'ExtendedCulture.IDMustNotBe0', 1;

    --[beginsp]

    --<PreExtendedDestroy revert />

    if not exists (select 1 from CK.tExtendedCulture where ExtendedCultureId = @ExtendedCultureId)
        throw 50000, 'ExtendedCulture.NotFound', 1;

    -- This sproc only handles pure extended cultures. Normalized ones (with a row in tCulture)
    -- must go through CK.sCultureDestroy which handles cascade and PrimaryCultureId detachment.
    if exists (select 1 from CK.tCulture where CultureId = @ExtendedCultureId)
        throw 50000, 'ExtendedCulture.IsNormalizedUseSCultureDestroy', 1;

    -- Drop the fallback chain owned by this extended culture.
    delete from CK.tCultureFallback where CultureId = @ExtendedCultureId;

    -- Delete the extended row itself.
    delete from CK.tExtendedCulture where ExtendedCultureId = @ExtendedCultureId;

    --<PostExtendedDestroy />

    --[endsp]

end
