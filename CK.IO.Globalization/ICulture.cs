using CK.Core;

namespace CK.IO.Globalization;

public interface ICulture : IPoco
{
    int CultureId { get; set; }
    string Name { get; set; }
    string EnglishName { get; set; }
    string NativeName { get; set; }
    string DisplayName { get; set; }
    int ParentCultureId { get; set; }
}
