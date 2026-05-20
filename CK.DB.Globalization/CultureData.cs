namespace CK.DB.Globalization;

public sealed record CultureData( int CultureId, string Name, string EnglishName, string NativeName, string DisplayName, int ParentCultureId );
