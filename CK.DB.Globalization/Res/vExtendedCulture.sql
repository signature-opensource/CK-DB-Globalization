-- SetupConfig: {}
alter view CK.vExtendedCulture
as
    select  c.ExtendedCultureId,
            c.PrimaryCultureId,
            c.FullName,
            FallbacksCultureId = Stuff(
                (select ',' + convert(varchar(11), FallbackCultureId)
                    from CK.tCultureFallback
                    where CultureId = c.ExtendedCultureId
                    order by Idx for xml path(''),TYPE).value('text()[1]','varchar(max)'),1,1,N''),
            Fallbacks = Stuff(
                (select N',' + convert(varchar(11), m.FallbackCultureId) + '|' + n.Name + '|' + n.EnglishName + '|' + n.NativeName
                    from CK.tCultureFallback m
                    inner join CK.tCulture n on n.CultureId = m.FallbackCultureId
                    where m.CultureId = c.ExtendedCultureId
                    order by m.Idx for xml path(''),TYPE).value('text()[1]','nvarchar(max)'),1,1,N''),
            FallbacksNames = Stuff(
                (select ',' + n.Name
                    from CK.tCultureFallback m
                    inner join CK.tCulture n on n.CultureId = m.FallbackCultureId
                    where m.CultureId = c.ExtendedCultureId
                    order by m.Idx for xml path(''),TYPE).value('text()[1]','varchar(max)'),1,1,N''),
            FallbacksEnglishNames = Stuff(
                (select N',' + n.EnglishName
                    from CK.tCultureFallback m
                    inner join CK.tCulture n on n.CultureId = m.FallbackCultureId
                    where m.CultureId = c.ExtendedCultureId
                    order by m.Idx for xml path(''),TYPE).value('text()[1]','nvarchar(max)'),1,1,N''),
            FallbacksNativeNames = Stuff(
                (select N',' + n.NativeName
                    from CK.tCultureFallback m
                    inner join CK.tCulture n on n.CultureId = m.FallbackCultureId
                    where m.CultureId = c.ExtendedCultureId
                    order by m.Idx for xml path(''),TYPE).value('text()[1]','nvarchar(max)'),1,1,N'')
        from CK.tExtendedCulture c
        where c.ExtendedCultureId <> 0;
