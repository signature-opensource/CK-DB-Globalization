--[beginscript]

-- tExtendedCulture is the identity table of any culture (normalized or not).
-- A normalized culture has both a row in tExtendedCulture and a row in tCulture
-- with the same id (tCulture.CultureId is a PK and a FK to tExtendedCulture.ExtendedCultureId).
-- A pure extended culture (e.g. "en,jp,fr") only has a row in tExtendedCulture.
--
-- PrimaryCultureId is nullable in the schema to allow the bootstrap of normalized cultures
-- (sCultureRegister inserts the tExtendedCulture row first with NULL, then the tCulture row,
-- then updates the PrimaryCultureId). In steady-state every row has a non-null PrimaryCultureId.
-- The FK on PrimaryCultureId is added by CK.tCulture.Install after CK.tCulture exists.
create table CK.tExtendedCulture
(
    ExtendedCultureId int not null,
    FullName varchar( 512 ) not null,
    PrimaryCultureId int null,

    constraint PK_CK_tExtendedCulture primary key( ExtendedCultureId )
);

-- Seed all known cultures with PrimaryCultureId temporarily NULL.
-- CK.tCulture.Install will close the circular FK and bulk-update PrimaryCultureId
-- to point to the matching tCulture rows once they exist.

insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values( 0,           '',                 null );

-- DE
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  223899012,  'de',               null );
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  -83080978,  'de-be,de',         null );

-- EN
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  221277614,  'en',               null );
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values( -1220541402, 'en-gb,en',         null );

-- ES
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  221081011,  'es',               null );

-- FR
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  210333265,  'fr',               null );
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values( 1629338248,  'fr-fr,fr',         null );
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values( 1621867518,  'fr-ca,fr',         null );
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values( 1619966747,  'fr-be,fr',         null );

-- IT
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  227962680,  'it',               null );

-- NL
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  242184007,  'nl',               null );
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values( -1390313907, 'nl-be,nl',         null );

-- PT
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  247296001,  'pt',               null );

-- PL
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  245723161,  'pl',               null );

-- UK
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  252014523,  'uk',               null );

-- ZH
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  266826199,  'zh',               null );
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values( -827532471,  'zh-hant,zh',       null );
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  960837017,  'zh-hk,zh-hant,zh', null );
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values( 1001731353,  'zh-tw,zh-hant,zh', null );

--[endscript]
