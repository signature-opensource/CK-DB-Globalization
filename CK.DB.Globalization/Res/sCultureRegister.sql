-- SetupConfig: {}
--
-- Create a culture.
--
create procedure CK.sCultureRegister
(
	@CultureId int,
	@Name varchar(20),
	@FullName varchar(20),
	@EnglishName nvarchar(255),
	@NativeName nvarchar(255),
	@DisplayName nvarchar(255),
    @IsNormalized bit,
    @ParentCultureId int = null
)
as
begin
	if @CultureId = 0  throw 50000, 'Culture.IDMustNotBe0', 1;

     --[beginsp]

    --<PreCreate revert />

    if exists (select 1 from CK.tCulture where CultureId = @CultureId)
        throw 50000, 'Culture.CultureIdMustBeUnique', 1;


    insert into CK.tCulture( CultureId, Name, FullName, EnglishName, NativeName, DisplayName, IsNormalized, ParentCultureId  )
                 values( @CultureId, @Name, @FullName, @EnglishName, @NativeName, @DisplayName, @IsNormalized, @ParentCultureId );

    --<PostCreate />

    --[endsp]

end
