

--[beginscript]

create table CK.tCulture
(
    CultureId int,
    Name varchar( 20 ) not null,
    FullName varchar( 512 ) not null,
    EnglishName nvarchar( 255 ) not null,
    NativeName nvarchar( 255 ) not null,
    DisplayName nvarchar( 255 ) not null,
    IsNormalized bit not null,
    ParentCultureId int null,

    constraint PK_CK_tCulture primary key( CultureId ),
    constraint FK_CK_tCulture_ParentCultureId foreign key( ParentCultureId ) references CK.tCulture( CultureId ),
);

create index IX_CK_tCulture_Name on CK.tCulture( Name );
create index IX_CK_tCulture_ParentCultureId on CK.tCulture( ParentCultureId );


insert into CK.tCulture( CultureId, Name, FullName, EnglishName, NativeName, DisplayName, IsNormalized, ParentCultureId  )
                 values( 0, '', '', N'', N'', N'', 0, null );

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


--[endscript]
