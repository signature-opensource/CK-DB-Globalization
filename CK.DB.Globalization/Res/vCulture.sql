-- SetupConfig:{ "Requires": [ "CK.vExtendedCulture" ] }
create view CK.vCulture
as
    select  c.CultureId,
            c.Name,
            c.EnglishName,
            c.NativeName,
            c.DisplayName,
            c.ParentCultureId,
            x.FullName,
            x.FallbacksCultureId,
            x.Fallbacks,
            x.FallbacksNames,
            x.FallbacksEnglishNames,
            x.FallbacksNativeNames
        from CK.tCulture c
        inner join CK.vExtendedCulture x on x.ExtendedCultureId = c.CultureId
        where c.CultureId <> 0;
