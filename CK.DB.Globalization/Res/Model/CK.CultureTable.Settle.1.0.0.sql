--[beginscript]

-- DE
insert into CK.tCulture values( 223899012, 'de', 'de', N'German', N'Deutsch', N'German', 1, null );
insert into CK.tCulture values( -83080978, 'de-be', 'de-be,de', N'German (Belgium)', N'Deutsch (Belgien)', N'German (Belgium)', 1, 223899012 );

-- EN
insert into CK.tCulture values( 221277614, 'en', 'en', N'English', N'English', N'English', 1, null );
insert into CK.tCulture values( -1220541402, 'en-gb', 'en-gb,en', N'English (United Kingdom)', N'English (United Kingdom)', N'English (United Kingdom)', 1, 221277614 );

-- ES
insert into CK.tCulture values( 221081011, 'es', 'es', N'Spanish', N'español', N'Spanish', 1, null );

-- FR
insert into CK.tCulture values( 210333265, 'fr', 'fr', N'French', N'français', N'French', 1, null );
insert into CK.tCulture values( 1629338248, 'fr-fr', 'fr-fr,fr', N'French (France)', N'français (France)', N'French (France)', 1, 210333265 );
insert into CK.tCulture values( 1621867518, 'fr-ca', 'fr-ca,fr', N'French (Canada)', N'français (Canada)', N'French (Canada)', 1, 210333265 );
insert into CK.tCulture values( 1619966747, 'fr-be', 'fr-be,fr', N'French (Belgium)', N'français (Belgique)', N'French (Belgium)', 1, 210333265 );

-- IT
insert into CK.tCulture values( 227962680, 'it', 'it', N'Italian', N'italiano', N'Italian', 1, null );

-- NL
insert into CK.tCulture values( 242184007, 'nl', 'nl', N'Dutch', N'Nederlands', N'Dutch', 1, null );
insert into CK.tCulture values( -1390313907, 'nl-be', 'nl-be,nl', N'Dutch (Belgium)', N'Nederlands (België)', N'Dutch (Belgium)', 1, 242184007 );

-- PT
insert into CK.tCulture values( 247296001, 'pt', 'pt', N'Portuguese', N'português', N'Portuguese', 1, null );

-- PL
insert into CK.tCulture values( 245723161, 'pl', 'pl', N'Polish', N'polski', N'Polish', 1, null );

-- UK
insert into CK.tCulture values( 252014523, 'uk', 'uk', N'Ukrainian', N'українська', N'Ukrainian', 1, null );

-- ZH
insert into CK.tCulture values( 266826199, 'zh', 'zh', N'Chinese', N'中文', N'Chinese', 1, null );
insert into CK.tCulture values( -827532471, 'zh-hant', 'zh-hant,zh', N'Chinese (Traditional)', N'中文（繁體）', N'Chinese (Traditional)', 1, 266826199 );
insert into CK.tCulture values( 960837017, 'zh-hk', 'zh-hk,zh-hant,zh', N'Chinese (Hong Kong SAR)', N'中文（香港特別行政區）', N'Chinese (Hong Kong SAR)', 1, -827532471 );
insert into CK.tCulture values( 1001731353, 'zh-tw', 'zh-tw,zh-hant,zh', N'Chinese (Taiwan)', N'中文（台灣）', N'Chinese (Taiwan)', 1, -827532471 );


-- BAZOOKA
-- DE
exec CKCore.sRefBazookation 'CK','tLCID','LCID','7','223899012',0;
exec CKCore.sRefBazookation 'CK','tLCID','LCID','4096','-83080978',0;

-- EN
exec CKCore.sRefBazookation 'CK','tLCID','LCID','9','221277614',0;
exec CKCore.sRefBazookation 'CK','tLCID','LCID','2057','-1220541402',0;

-- ES
exec CKCore.sRefBazookation 'CK','tLCID','LCID','10','221081011',0;

-- FR
exec CKCore.sRefBazookation 'CK','tLCID','LCID','12','210333265',0;
exec CKCore.sRefBazookation 'CK','tLCID','LCID','1036','1629338248',0;
exec CKCore.sRefBazookation 'CK','tLCID','LCID','3084','1621867518',0;
exec CKCore.sRefBazookation 'CK','tLCID','LCID','2060','1619966747',0;

-- IT
exec CKCore.sRefBazookation 'CK','tLCID','LCID','16','227962680',0;

-- NL
exec CKCore.sRefBazookation 'CK','tLCID','LCID','19','242184007',0;
exec CKCore.sRefBazookation 'CK','tLCID','LCID','2067','-1390313907',0;

-- PL
exec CKCore.sRefBazookation 'CK','tLCID','LCID','21','245723161',0;

-- PT
exec CKCore.sRefBazookation 'CK','tLCID','LCID','22','247296001',0;

-- UK
exec CKCore.sRefBazookation 'CK','tLCID','LCID','34','252014523',0;

-- ZH
exec CKCore.sRefBazookation 'CK','tLCID','LCID','30724','266826199',0;
exec CKCore.sRefBazookation 'CK','tLCID','LCID','31748','-827532471',0;
exec CKCore.sRefBazookation 'CK','tLCID','LCID','3076','960837017',0;
exec CKCore.sRefBazookation 'CK','tLCID','LCID','1028','1001731353',0;

exec CKCore.sColumnBazookation
    'CK',
    'tLCID',
    'LCID',
    'CK',
    'tCulture',
    'CultureId',
    'FK_CK_{SOURCETABLE}_CultureId foreign key (CultureId) references CK.tCulture(CultureId)'

--[endscript]
