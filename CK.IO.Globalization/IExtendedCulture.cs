using CK.Core;

namespace CK.IO.Globalization;

public interface IExtendedCulture : IPoco
{
    int ExtendedCultureId { get; set; }
    string FullName { get; set; }
    int PrimaryCultureId { get; set; }
}
