--[beginscript]

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
