--[beginscript]

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
