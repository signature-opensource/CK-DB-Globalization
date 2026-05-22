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
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  223893631,  'de',               null );
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values( 2064397289,  'de-be,de',         null );

-- EN
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  221272233,  'en',               null );
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  926936865,  'en-gb,en',         null );

-- ES
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  221075630,  'es',               null );

-- FR
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  210327884,  'fr',               null );
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values( 1629332867,  'fr-fr,fr',         null );
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values( 1621862137,  'fr-ca,fr',         null );
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values( 1619961366,  'fr-be,fr',         null );

-- IT
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  227957299,  'it',               null );

-- NL
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  242178626,  'nl',               null );
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  757164360,  'nl-be,nl',         null );

-- PT
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  247290620,  'pt',               null );

-- PL
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  245717780,  'pl',               null );

-- UK
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  252009142,  'uk',               null );

-- ZH
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  266820818,  'zh',               null );
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values( 1319945796,  'zh-hant,zh',       null );
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values(  960831636,  'zh-hk,zh-hant,zh', null );
insert into CK.tExtendedCulture( ExtendedCultureId, FullName, PrimaryCultureId ) values( 1001725972,  'zh-tw,zh-hant,zh', null );

--[endscript]
