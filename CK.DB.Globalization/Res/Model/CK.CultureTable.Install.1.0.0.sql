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


insert into CK.tCulture( CultureId, Name, FullName, EnglishName, NativeName, DisplayName, IsNormalized, ParentCultureId  )
                 values( 0, '', '', N'', N'', N'', 0, null );


--[endscript]
