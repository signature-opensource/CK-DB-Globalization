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

-- Finalize chains so they match what sCultureRegister produces dynamically: for every
-- non-zero ExtendedCulture, append English first (if missing), then every other non-zero
-- normalized Culture not already in the chain (ordered by CultureId for determinism).
declare @EnId int = 221277614; -- 'en'

-- Step A: append English at the next available Idx for every chain missing it.
;with NextIdx as
(
    select e.ExtendedCultureId,
           cast( isnull( max(f.Idx), -1 ) + 1 as smallint ) as NextIdx
    from CK.tExtendedCulture e
    left join CK.tCultureFallback f on f.CultureId = e.ExtendedCultureId
    where e.ExtendedCultureId <> 0
      and not exists (
          select 1 from CK.tCultureFallback x
          where x.CultureId = e.ExtendedCultureId and x.FallbackCultureId = @EnId
      )
    group by e.ExtendedCultureId
)
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId )
    select ExtendedCultureId, NextIdx, @EnId from NextIdx;

-- Step B: append every other non-zero normalized Culture missing from each chain,
-- continuing from the current max(Idx) per ExtendedCulture, ordered by CultureId.
;with Missing as
(
    select e.ExtendedCultureId,
           c.CultureId as MissingCultureId
    from CK.tExtendedCulture e
    cross join CK.tCulture c
    where e.ExtendedCultureId <> 0
      and c.CultureId <> 0
      and not exists (
          select 1 from CK.tCultureFallback f
          where f.CultureId = e.ExtendedCultureId and f.FallbackCultureId = c.CultureId
      )
),
WithIdx as
(
    select m.ExtendedCultureId,
           m.MissingCultureId,
           cast(
               row_number() over (partition by m.ExtendedCultureId order by m.MissingCultureId)
               + isnull( (select max(Idx) from CK.tCultureFallback where CultureId = m.ExtendedCultureId), -1 )
               as smallint
           ) as NewIdx
    from Missing m
)
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId )
    select ExtendedCultureId, NewIdx, MissingCultureId from WithIdx;

--[endscript]
