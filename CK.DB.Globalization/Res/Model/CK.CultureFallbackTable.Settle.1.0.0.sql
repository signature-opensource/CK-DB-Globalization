--[beginscript]

-- Self-mapping (Idx = 0) for every seed culture in CK.tCulture (except the 0 row already seeded by Install).
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId )
    select c.CultureId, 0, c.CultureId
    from CK.tCulture c
    where c.CultureId <> 0
      and not exists ( select 1 from CK.tCultureFallback f where f.CultureId = c.CultureId and f.Idx = 0 );

-- Fallback chain for hierarchical seed cultures (FullName "child,parent" or "child,parent,grandparent").
-- DE-BE -> DE
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 2064397289, 1, 223893631 );

-- EN-GB -> EN
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 926936865, 1, 221272233 );

-- FR-FR -> FR
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 1629332867, 1, 210327884 );

-- FR-CA -> FR
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 1621862137, 1, 210327884 );

-- FR-BE -> FR
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 1619961366, 1, 210327884 );

-- NL-BE -> NL
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 757164360, 1, 242178626 );

-- ZH-HANT -> ZH
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 1319945796, 1, 266820818 );

-- ZH-HK -> ZH-HANT -> ZH
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 960831636, 1, 1319945796 );
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 960831636, 2, 266820818 );

-- ZH-TW -> ZH-HANT -> ZH
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 1001725972, 1, 1319945796 );
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 1001725972, 2, 266820818 );

-- Finalize chains so they match what sCultureRegister produces dynamically: for every
-- non-zero ExtendedCulture, append English first (if missing), then every other non-zero
-- normalized Culture not already in the chain (ordered by CultureId for determinism).
declare @EnId int = 221272233; -- 'en'

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
