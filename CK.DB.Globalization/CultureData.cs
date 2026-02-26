namespace CK.DB.Globalization;

public sealed record CultureData( int CultureId, string Name, string FullName, string EnglishName, string NativeName, string DisplayName, bool IsNormalized, int? ParentCultureId );
