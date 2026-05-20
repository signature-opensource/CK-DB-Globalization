using CK.Core;
using CK.IO.Globalization;
using CK.SqlServer;
using Dapper;
using System.Threading.Tasks;

namespace CK.DB.Globalization;

/// <summary>
/// Identity table of any culture — normalized or pure extended.
/// A normalized culture has a matching row in <see cref="CultureTable"/> with the same id;
/// a pure extended culture only lives here.
/// </summary>
[SqlTable( "tExtendedCulture", Package = typeof( Package ), ResourcePath = "Res" )]
[Versions( "1.0.0" )]
[SqlObjectItem( "vExtendedCulture" )]
public abstract class ExtendedCultureTable : SqlTable
{
    void StObjConstruct()
    {
    }

    [SqlProcedure( "sExtendedCultureRegister" )]
    internal protected abstract Task DoRegisterAsync( ISqlCallContext ctx, int extendedCultureId, string fullName, int primaryCultureId );

    /// <summary>
    /// Destroys a pure extended culture (a row in <c>tExtendedCulture</c> with no matching row in <c>tCulture</c>).
    /// Use <see cref="CultureTable.DestroyAsync"/> for normalized cultures.
    /// </summary>
    [SqlProcedure( "sExtendedCultureDestroy" )]
    public abstract Task DestroyAsync( ISqlCallContext ctx, int extendedCultureId );

    public async Task<bool> IsExtendedCultureRegisteredAsync( ISqlCallContext ctx, int extendedCultureId )
        => await ctx.GetConnectionController( this ).QuerySingleOrDefaultAsync<bool>(
            @"select 1 from CK.tExtendedCulture where ExtendedCultureId = @Id;",
            new { Id = extendedCultureId } );

    public async Task<IExtendedCulture?> GetExtendedCultureAsync( ISqlCallContext ctx, int extendedCultureId )
        => await ctx.GetConnectionController( this ).QuerySingleOrDefaultAsync<IExtendedCulture>(
            @"select ExtendedCultureId, FullName, PrimaryCultureId
              from CK.tExtendedCulture
              where ExtendedCultureId = @Id;",
            new { Id = extendedCultureId } );
}
