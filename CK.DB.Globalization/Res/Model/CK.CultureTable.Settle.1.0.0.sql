--[beginscript]

insert into CK.tCulture values( 210333265, 'fr', 'fr', N'French', N'français', N'French', 1, null );
insert into CK.tCulture values( 221277614, 'en', 'en', N'English', N'English', N'English', 1, null );


exec CKCore.sRefBazookation 'CK','tLCID','LCID','9','221277614';
exec CKCore.sRefBazookation 'CK','tLCID','LCID','12','210333265';

--exec CKCore.sColumnBazookation
--    'CK',
--    'tLCID',
--    'LCID',
--    'CK',
--    'tCulture',
--    'CultureId',
--    'FK_CK_{SOURCETABLE}_CultureId foreign key (CultureId) references CK.tCulture(CultureId)'

--[endscript]
