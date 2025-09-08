using CK.Core;
using CK.SqlServer;
using Dapper;
using System.Threading.Tasks;

namespace CK.DB.Globalization;

[SqlTable( "tCulture", Package = typeof( Package ), ResourcePath = "Res" )]
[Versions( "1.0.0" )]
public abstract class CultureTable : SqlTable
{
    void StObjConstruct()
    {
    }

    /// <summary>
    /// Create an culture.
    /// </summary>
    /// <param name="ctx">The call context.</param>
    /// <param name="extendedCultureInfo">The extended culture info <see cref="ExtendedCultureInfo"/> .</param>
    /// <returns>The awaitable.</returns>
    public async Task RegisterAsync( ISqlCallContext ctx, ExtendedCultureInfo extendedCultureInfo )
    {
        if( await IsCultureRegisteredAsync( ctx, extendedCultureInfo.Id ) )
        {
            return;
        }

        if( extendedCultureInfo.Fallbacks.Length > 0 )
        {
            foreach( var fb in extendedCultureInfo.Fallbacks )
            {
                await RegisterAsync( ctx, fb );
            }
        }

        NormalizedCultureInfo? parent = null;
        if( extendedCultureInfo.PrimaryCulture.Culture.Parent.Name != "" )
        {
            parent = NormalizedCultureInfo.EnsureNormalizedCultureInfo( extendedCultureInfo.PrimaryCulture.Culture.Parent.Name );
            await RegisterAsync( ctx, parent );
        }

        await DoRegisterAsync(
            ctx,
            extendedCultureInfo.Id,
            extendedCultureInfo.Name,
            extendedCultureInfo.FullName,
            extendedCultureInfo.PrimaryCulture.Culture.EnglishName,
            extendedCultureInfo.PrimaryCulture.Culture.NativeName,
            extendedCultureInfo.PrimaryCulture.Culture.DisplayName,
            extendedCultureInfo is NormalizedCultureInfo,
            parent?.Id
        );

    }

    [SqlProcedure( "sCultureRegister" )]
    internal protected abstract Task DoRegisterAsync
    (
        ISqlCallContext ctx,
        int cultureId,
        string name,
        string fullName,
        string englishName,
        string nativeName,
        string displayName,
        bool isNormalized,
        int? parentCultureId = null
     );


    public async Task<bool> IsCultureRegisteredAsync( ISqlCallContext ctx, int cultureId )
    => await ctx.GetConnectionController( this ).QuerySingleOrDefaultAsync<bool>(
            @"select 1
              from CK.tCulture 
              where CultureId = @CultureId;",
            new { CultureId = cultureId } );

}
