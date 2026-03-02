using CK.Cris;

namespace CK.IO.Globalization.Commands;

public interface IGetCultureHierarchyQCommand : ICommand<List<ICulture>>
{
    int CultureId { get; set; }
}
