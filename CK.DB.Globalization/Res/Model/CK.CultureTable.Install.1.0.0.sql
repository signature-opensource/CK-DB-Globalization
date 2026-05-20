

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
insert into CK.tCulture values( 223899012, 'de', N'German', N'Deutsch', N'German', 0 );
insert into CK.tCulture values( -83080978, 'de-be', N'German (Belgium)', N'Deutsch (Belgien)', N'German (Belgium)', 223899012 );

-- EN
insert into CK.tCulture values( 221277614, 'en', N'English', N'English', N'English', 0 );
insert into CK.tCulture values( -1220541402, 'en-gb', N'English (United Kingdom)', N'English (United Kingdom)', N'English (United Kingdom)', 221277614 );

-- ES
insert into CK.tCulture values( 221081011, 'es', N'Spanish', N'español', N'Spanish', 0 );

-- FR
insert into CK.tCulture values( 210333265, 'fr', N'French', N'français', N'French', 0 );
insert into CK.tCulture values( 1629338248, 'fr-fr', N'French (France)', N'français (France)', N'French (France)', 210333265 );
insert into CK.tCulture values( 1621867518, 'fr-ca', N'French (Canada)', N'français (Canada)', N'French (Canada)', 210333265 );
insert into CK.tCulture values( 1619966747, 'fr-be', N'French (Belgium)', N'français (Belgique)', N'French (Belgium)', 210333265 );

-- IT
insert into CK.tCulture values( 227962680, 'it', N'Italian', N'italiano', N'Italian', 0 );

-- NL
insert into CK.tCulture values( 242184007, 'nl', N'Dutch', N'Nederlands', N'Dutch', 0 );
insert into CK.tCulture values( -1390313907, 'nl-be', N'Dutch (Belgium)', N'Nederlands (België)', N'Dutch (Belgium)', 242184007 );

-- PT
insert into CK.tCulture values( 247296001, 'pt', N'Portuguese', N'português', N'Portuguese', 0 );

-- PL
insert into CK.tCulture values( 245723161, 'pl', N'Polish', N'polski', N'Polish', 0 );

-- UK
insert into CK.tCulture values( 252014523, 'uk', N'Ukrainian', N'українська', N'Ukrainian', 0 );

-- ZH
insert into CK.tCulture values( 266826199, 'zh', N'Chinese', N'中文', N'Chinese', 0 );
insert into CK.tCulture values( -827532471, 'zh-hant', N'Chinese (Traditional)', N'中文（繁體）', N'Chinese (Traditional)', 266826199 );
insert into CK.tCulture values( 960837017, 'zh-hk', N'Chinese (Hong Kong SAR)', N'中文（香港特別行政區）', N'Chinese (Hong Kong SAR)', -827532471 );
insert into CK.tCulture values( 1001731353, 'zh-tw', N'Chinese (Taiwan)', N'中文（台灣）', N'Chinese (Taiwan)', -827532471 );

-- Finalize PrimaryCultureId for every non-zero tExtendedCulture row now that its tCulture pendant exists.
update CK.tExtendedCulture
    set PrimaryCultureId = ExtendedCultureId
    where ExtendedCultureId <> 0 and PrimaryCultureId is null;

--[endscript]
