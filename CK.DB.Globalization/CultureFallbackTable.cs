using CK.Core;
using CK.IO.Globalization;
using CK.SqlServer;
using Dapper;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CK.DB.Globalization;

/// <summary>
/// Materializes the priority-ordered fallback chain of each extended culture.
/// The owner <c>CultureId</c> is an <see cref="ExtendedCultureTable"/> id; each fallback at <c>Idx</c>
/// points to a normalized <c>CultureId</c> in <see cref="CultureTable"/>.
/// The row at <c>Idx = 0</c> is the PrimaryCultureId of the owning extended (equal to self for a normalized culture).
/// </summary>
[SqlTable( "tCultureFallback", Package = typeof( Package ), ResourcePath = "Res" )]
[Versions( "1.0.0" )]
public abstract class CultureFallbackTable : SqlTable
{
    void StObjConstruct( CultureTable culture, ExtendedCultureTable extendedCulture )
    {
    }

    /// <summary>
    /// Replaces the fallback chain of an extended culture.
    /// The provided list must start with the <c>PrimaryCultureId</c> of <paramref name="cultureId"/>
    /// (which equals <paramref name="cultureId"/> for a normalized culture).
    /// </summary>
    /// <param name="ctx">The call context.</param>
    /// <param name="cultureId">The extended culture whose fallback chain is being set.</param>
    /// <param name="fallbackCultureIds">Ordered fallback chain (normalized CultureIds), starting with the primary.</param>
    public Task SetFallbacksAsync( ISqlCallContext ctx, int cultureId, IEnumerable<int> fallbackCultureIds )
    {
        var csv = string.Join( ",", fallbackCultureIds );
        return DoSetFallbacksAsync( ctx, cultureId, csv );
    }

    [SqlProcedure( "sCultureFallbackSet" )]
    internal protected abstract Task DoSetFallbacksAsync( ISqlCallContext ctx, int cultureId, string fallbackCultureIds );

    // Helper sproc called only from CK.sCultureRegister and CK.sExtendedCultureRegister.
    // The C# binding exists only so that the framework discovers and deploys the sproc.
    [SqlProcedure( "sCultureFallbackBuildChain" )]
    internal protected abstract Task DoBuildChainAsync( ISqlCallContext ctx, int cultureId, string fullName );

    /// <summary>
    /// Returns the fallback chain of an extended culture as an ordered list of normalized <see cref="ICulture"/>.
    /// The first element is the primary culture, followed by its fallbacks in priority order.
    /// </summary>
    /// <param name="ctx">The call context.</param>
    /// <param name="cultureId">The extended culture whose chain is requested.</param>
    /// <returns>Ordered fallback chain (empty if the culture has no chain registered).</returns>
    public async Task<IEnumerable<ICulture>> GetFallbacksAsync( ISqlCallContext ctx, int cultureId )
        => await ctx.GetConnectionController( this ).QueryAsync<ICulture>(
            @"select c.CultureId, c.Name, c.EnglishName, c.NativeName, c.DisplayName, c.ParentCultureId
              from CK.tCultureFallback f
              inner join CK.tCulture c on c.CultureId = f.FallbackCultureId
              where f.CultureId = @CultureId
              order by f.Idx;",
            new { CultureId = cultureId } );

    /// <summary>
    /// Returns the fallback chain of a culture as an ordered list of <c>CultureId</c>.
    /// </summary>
    /// <param name="ctx">The call context.</param>
    /// <param name="cultureId">The culture whose chain is requested.</param>
    /// <returns>Ordered fallback culture identifiers.</returns>
    public async Task<IEnumerable<int>> GetFallbackIdsAsync( ISqlCallContext ctx, int cultureId )
        => await ctx.GetConnectionController( this ).QueryAsync<int>(
            @"select FallbackCultureId
              from CK.tCultureFallback
              where CultureId = @CultureId
              order by Idx;",
            new { CultureId = cultureId } );
}
