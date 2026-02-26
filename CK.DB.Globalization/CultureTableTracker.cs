using CK.Core;
using CK.SqlServer;
using System.Threading;
using System.Threading.Tasks;

namespace CK.DB.Globalization;

/// <summary>
/// Tracks culture creation and persists new cultures to the database
/// via <see cref="CultureTable.RegisterAsync"/>.
/// </summary>
public sealed class CultureTableTracker : ExtendedCultureInfoTracker
{
    readonly CultureTable _cultureTable;
    readonly ISqlCallContext _ctx;

    public CultureTableTracker( CultureTable cultureTable, ISqlCallContext ctx )
    {
        _cultureTable = cultureTable;
        _ctx = ctx;
    }

    protected override async Task InitializeAsync(
        IActivityMonitor monitor,
        AllCultureSnapshot allCultures,
        CancellationToken cancellationToken )
    {
        foreach( var c in allCultures )
        {
            await _cultureTable.RegisterAsync( _ctx, c );
        }
    }

    protected override async Task OnCultureCreatedAsync(
        IActivityMonitor monitor,
        ExtendedCultureInfoCreatedEvent e,
        CancellationToken cancellationToken )
    {
        // RegisterAsync handles fallbacks and parents recursively.
        await _cultureTable.RegisterAsync( _ctx, e.NewOne );
    }
}
