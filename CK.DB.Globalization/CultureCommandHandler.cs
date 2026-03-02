using CK.Core;
using CK.Cris;
using CK.IO.Globalization;
using CK.IO.Globalization.Commands;
using CK.SqlServer;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CK.DB.Globalization;

public class CultureCommandHandler : IAutoService
{
    [CommandHandler]
    public async Task<ICulture?> GetCultureAsync( ISqlCallContext ctx, IGetCultureQCommand cmd, CultureTable cultureTable )
    {
        return await cultureTable.GetCultureAsync( ctx, cmd.CultureId );
    }

    [CommandHandler]
    public async Task<List<ICulture>> GetAllCulturesAsync( ISqlCallContext ctx, IGetAllCulturesQCommand cmd, CultureTable cultureTable )
    {
        var results = await cultureTable.GetAllCulturesAsync( ctx );
        return results.ToList();
    }

    [CommandHandler]
    public async Task<List<ICulture>> GetCultureHierarchyAsync( ISqlCallContext ctx, IGetCultureHierarchyQCommand cmd, CultureTable cultureTable )
    {
        var results = await cultureTable.GetCultureHierarchyAsync( ctx,cmd.CultureId );
        return results.ToList();
    }
}
