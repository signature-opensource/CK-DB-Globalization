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

-- PK_CK_LCID est référencée par 4 FKs externes au scope du bazookage :
-- FK_CK_MCResHtml_LCID (sur tMCResHtml.LCID)
-- FK_CK_MCResString_LCID (sur tMCResString.LCID)
-- FK_CK_MCResText_LCID (sur tMCResText.LCID)
-- FK_tWorkspaceInvitation_LCID (sur tWorkspaceInvitation.LCID)
-- 
-- SQL Server refuse de drop une PK qui est encore référencée.
--Pour pouvoir drop PK_CK_LCID, il faudrait d'abord drop ces 4 FKs. Mais ces FKs ne sont pas dans rec (elles pointent vers tLCID.LCID, pas vers tXLCID.XLCID), donc le script n'en sait rien.
 alter table CK.tLCID drop constraint FK_CK_LCID_XLCID;

-- BAZOOKA: legacy XLCID -> ExtendedCultureId remapping for the XLCID identifiers.
-- DE
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','7','223893631',0;
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','4096','2064397289',0;

-- EN
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','9','221272233',0;
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','2057','926936865',0;

-- ES
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','10','221075630',0;

-- FR
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','12','210327884',0;
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','1036','1629332867',0;
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','3084','1621862137',0;
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','2060','1619961366',0;

-- IT
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','16','227957299',0;

-- NL
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','19','242178626',0;
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','2067','757164360',0;

-- PL
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','21','245717780',0;

-- PT
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','22','247290620',0;

-- UK
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','34','252009142',0;

-- ZH
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','30724','266820818',0;
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','31748','1319945796',0;
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','3076','960831636',0;
exec CKCore.sRefBazookation 'CK','tXLCID','XLCID','1028','1001725972',0;

exec CKCore.sColumnBazookation
    'CK',
    'tXLCID',
    'XLCID',
    'CK',
    'tExtendedCulture',
    'ExtendedCultureId',
    'FK_CK_{SOURCETABLE}_ExtendedCultureId foreign key (ExtendedCultureId) references CK.tExtendedCulture(ExtendedCultureId)'

--[endscript]
