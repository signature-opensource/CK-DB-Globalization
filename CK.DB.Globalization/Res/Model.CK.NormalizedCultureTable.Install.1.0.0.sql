--[beginscript]

create table CK.tNormalizedCulture(
    NormalizedCultureId int not null identity( 0, 1 ),
    [Name] nvarchar( 16 ) collate Latin1_General_100_CI_AI not null,


    constraint PK_CK_tNormalizedCulture primary key( NormalizedCultureId ),
);


insert into CK.tUserInvitation( [Name] ) values( N'' );


--[endscript]
