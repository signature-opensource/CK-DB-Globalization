--[beginscript]

-- Self-mapping (Idx = 0) for every seed culture in CK.tCulture (except the 0 row already seeded by Install).
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId )
    select c.CultureId, 0, c.CultureId
    from CK.tCulture c
    where c.CultureId <> 0
      and not exists ( select 1 from CK.tCultureFallback f where f.CultureId = c.CultureId and f.Idx = 0 );

-- Fallback chain for hierarchical seed cultures (FullName "child,parent" or "child,parent,grandparent").
-- DE-BE -> DE
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( -83080978, 1, 223899012 );

-- EN-GB -> EN
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( -1220541402, 1, 221277614 );

-- FR-FR -> FR
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 1629338248, 1, 210333265 );

-- FR-CA -> FR
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 1621867518, 1, 210333265 );

-- FR-BE -> FR
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 1619966747, 1, 210333265 );

-- NL-BE -> NL
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( -1390313907, 1, 242184007 );

-- ZH-HANT -> ZH
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( -827532471, 1, 266826199 );

-- ZH-HK -> ZH-HANT -> ZH
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 960837017, 1, -827532471 );
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 960837017, 2, 266826199 );

-- ZH-TW -> ZH-HANT -> ZH
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 1001731353, 1, -827532471 );
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 1001731353, 2, 266826199 );

--[endscript]
