using CK.Core;

namespace CK.IO.Globalization;

public interface ICulture : IPoco
{
    int CultureId { get; set; }
    string Name { get; set; }
    string FullName { get; set; }
    string EnglishName { get; set; }
    string NativeName { get; set; }
    string DisplayName { get; set; }
    bool IsNormalized { get; set; }
    int? ParentCultureId { get; set; }
}
