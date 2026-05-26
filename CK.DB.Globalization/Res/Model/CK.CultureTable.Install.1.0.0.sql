

--[beginscript]

create table CK.tCulture
(
    CultureId int not null,
    Name varchar( 20 ) not null,
    EnglishName nvarchar( 255 ) not null,
    NativeName nvarchar( 255 ) not null,
    DisplayName nvarchar( 255 ) not null,
    ParentCultureId int not null,

    constraint PK_CK_tCulture primary key( CultureId ),
    constraint FK_CK_tCulture_ParentCultureId foreign key( ParentCultureId ) references CK.tCulture( CultureId ),
    constraint FK_CK_tCulture_ExtendedCultureId foreign key( CultureId ) references CK.tExtendedCulture( ExtendedCultureId )
);

create index IX_CK_tCulture_Name on CK.tCulture( Name );
create index IX_CK_tCulture_ParentCultureId on CK.tCulture( ParentCultureId );

-- Seed row 0 first: its tExtendedCulture(0) row was already inserted by ExtendedCultureTable.Install,
-- and it is its own parent.
insert into CK.tCulture( CultureId, Name, EnglishName, NativeName, DisplayName, ParentCultureId )
                 values( 0, '', N'', N'', N'', 0 );

-- Close the circular FK now that CK.tCulture exists with at least one row.
-- All existing tExtendedCulture rows have PrimaryCultureId = NULL, which is allowed by the FK.
alter table CK.tExtendedCulture
    add constraint FK_CK_tExtendedCulture_PrimaryCultureId
    foreign key( PrimaryCultureId ) references CK.tCulture( CultureId );

-- Bootstrap PrimaryCultureId for the seed row 0.
update CK.tExtendedCulture set PrimaryCultureId = 0 where ExtendedCultureId = 0;

-- Insert tCulture rows for all non-zero seed cultures. The matching tExtendedCulture rows
-- already exist (from CK.ExtendedCultureTable.Install) so the FK on CultureId is satisfied.
-- ParentCultureId uses 0 (the "no parent" sentinel) for root cultures.

-- DE
insert into CK.tCulture values( 223893631, 'de', N'German', N'Deutsch', N'German', 0 );
insert into CK.tCulture values( 2064397289, 'de-be', N'German (Belgium)', N'Deutsch (Belgien)', N'German (Belgium)', 223893631 );

-- EN
insert into CK.tCulture values( 221272233, 'en', N'English', N'English', N'English', 0 );
insert into CK.tCulture values( 926936865, 'en-gb', N'English (United Kingdom)', N'English (United Kingdom)', N'English (United Kingdom)', 221272233 );

-- ES
insert into CK.tCulture values( 221075630, 'es', N'Spanish', N'español', N'Spanish', 0 );

-- FR
insert into CK.tCulture values( 210327884, 'fr', N'French', N'français', N'French', 0 );
insert into CK.tCulture values( 1629332867, 'fr-fr', N'French (France)', N'français (France)', N'French (France)', 210327884 );
insert into CK.tCulture values( 1621862137, 'fr-ca', N'French (Canada)', N'français (Canada)', N'French (Canada)', 210327884 );
insert into CK.tCulture values( 1619961366, 'fr-be', N'French (Belgium)', N'français (Belgique)', N'French (Belgium)', 210327884 );

-- IT
insert into CK.tCulture values( 227957299, 'it', N'Italian', N'italiano', N'Italian', 0 );

-- NL
insert into CK.tCulture values( 242178626, 'nl', N'Dutch', N'Nederlands', N'Dutch', 0 );
insert into CK.tCulture values( 757164360, 'nl-be', N'Dutch (Belgium)', N'Nederlands (België)', N'Dutch (Belgium)', 242178626 );

-- PT
insert into CK.tCulture values( 247290620, 'pt', N'Portuguese', N'português', N'Portuguese', 0 );

-- PL
insert into CK.tCulture values( 245717780, 'pl', N'Polish', N'polski', N'Polish', 0 );

-- UK
insert into CK.tCulture values( 252009142, 'uk', N'Ukrainian', N'українська', N'Ukrainian', 0 );

-- ZH
insert into CK.tCulture values( 266820818, 'zh', N'Chinese', N'中文', N'Chinese', 0 );
insert into CK.tCulture values( 1319945796, 'zh-hant', N'Chinese (Traditional)', N'中文（繁體）', N'Chinese (Traditional)', 266820818 );
insert into CK.tCulture values( 960831636, 'zh-hk', N'Chinese (Hong Kong SAR)', N'中文（香港特別行政區）', N'Chinese (Hong Kong SAR)', 1319945796 );
insert into CK.tCulture values( 1001725972, 'zh-tw', N'Chinese (Taiwan)', N'中文（台灣）', N'Chinese (Taiwan)', 1319945796 );

-- Finalize PrimaryCultureId for every non-zero tExtendedCulture row now that its tCulture pendant exists.
update CK.tExtendedCulture
    set PrimaryCultureId = ExtendedCultureId
    where ExtendedCultureId <> 0 and PrimaryCultureId is null;


-- BAZOOKA: legacy LCID -> CultureId remapping for the LCID identifiers.
-- DE
exec CKCore.sRefBazookation 'CK','tLCID','LCID','7','223893631',0;
exec CKCore.sRefBazookation 'CK','tLCID','LCID','4096','2064397289',0;

-- EN
exec CKCore.sRefBazookation 'CK','tLCID','LCID','9','221272233',0;
exec CKCore.sRefBazookation 'CK','tLCID','LCID','2057','926936865',0;

-- ES
exec CKCore.sRefBazookation 'CK','tLCID','LCID','10','221075630',0;

-- FR
exec CKCore.sRefBazookation 'CK','tLCID','LCID','12','210327884',0;
exec CKCore.sRefBazookation 'CK','tLCID','LCID','1036','1629332867',0;
exec CKCore.sRefBazookation 'CK','tLCID','LCID','3084','1621862137',0;
exec CKCore.sRefBazookation 'CK','tLCID','LCID','2060','1619961366',0;

-- IT
exec CKCore.sRefBazookation 'CK','tLCID','LCID','16','227957299',0;

-- NL
exec CKCore.sRefBazookation 'CK','tLCID','LCID','19','242178626',0;
exec CKCore.sRefBazookation 'CK','tLCID','LCID','2067','757164360',0;

-- PL
exec CKCore.sRefBazookation 'CK','tLCID','LCID','21','245717780',0;

-- PT
exec CKCore.sRefBazookation 'CK','tLCID','LCID','22','247290620',0;

-- UK
exec CKCore.sRefBazookation 'CK','tLCID','LCID','34','252009142',0;

-- ZH
exec CKCore.sRefBazookation 'CK','tLCID','LCID','30724','266820818',0;
exec CKCore.sRefBazookation 'CK','tLCID','LCID','31748','1319945796',0;
exec CKCore.sRefBazookation 'CK','tLCID','LCID','3076','960831636',0;
exec CKCore.sRefBazookation 'CK','tLCID','LCID','1028','1001725972',0;

exec CKCore.sColumnBazookation
    'CK',
    'tLCID',
    'LCID',
    'CK',
    'tCulture',
    'CultureId',
    'FK_CK_{SOURCETABLE}_CultureId foreign key (CultureId) references CK.tCulture(CultureId)'

--[endscript]
