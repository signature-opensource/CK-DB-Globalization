--[beginscript]

create table CK.tCultureFallback
(
    CultureId int not null,
    Idx smallint not null,
    FallbackCultureId int not null,

    constraint PK_CK_tCultureFallback primary key( CultureId, Idx ),
    -- CultureId owns a chain: it can be either a normalized culture (then there's also a row in tCulture with the same id)
    -- or a pure extended culture (only in tExtendedCulture). The FK points to tExtendedCulture which is the superset.
    constraint FK_CK_tCultureFallback_CultureId foreign key( CultureId ) references CK.tExtendedCulture( ExtendedCultureId ),
    constraint FK_CK_tCultureFallback_FallbackCultureId foreign key( FallbackCultureId ) references CK.tCulture( CultureId )
);

create index IX_CK_tCultureFallback_FallbackCultureId on CK.tCultureFallback( FallbackCultureId );

-- Self-mapping for the seed culture 0 to keep the invariant "self at Idx=0".
insert into CK.tCultureFallback( CultureId, Idx, FallbackCultureId ) values( 0, 0, 0 );

--[endscript]
