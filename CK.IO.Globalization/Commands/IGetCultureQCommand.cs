using CK.Cris;

namespace CK.IO.Globalization.Commands;

public interface IGetCultureQCommand : ICommand<ICulture?>
{
    int CultureId { get; set; }
}
