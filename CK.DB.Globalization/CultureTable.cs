using CK.Core;
using CK.Cris;
using CK.IO.Globalization;
using CK.IO.Globalization.Commands;
using CK.SqlServer;
using Dapper;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CK.DB.Globalization;

[SqlTable( "tCulture", Package = typeof( Package ), ResourcePath = "Res" )]
[Versions( "1.0.0" )]
[SqlObjectItem( "vCulture" )]
public abstract class CultureTable : SqlTable
{
    ExtendedCultureTable _extendedCultureTable = null!;

    void StObjConstruct( ExtendedCultureTable extendedCultureTable )
    {
        _extendedCultureTable = extendedCultureTable;
    }

    /// <summary>
    /// Registers a culture: dispatches between the normalized path (insert in <c>tCulture</c>+<c>tExtendedCulture</c>)
    /// and the pure extended path (insert in <c>tExtendedCulture</c> only) based on the runtime type.
    /// Idempotent: if the culture is already registered nothing happens.
    /// </summary>
    public async Task RegisterAsync( ISqlCallContext ctx, ExtendedCultureInfo extendedCultureInfo )
    {
        if( await _extendedCultureTable.IsExtendedCultureRegisteredAsync( ctx, extendedCultureInfo.Id ) )
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

        if( extendedCultureInfo is NormalizedCultureInfo norm )
        {
            NormalizedCultureInfo? parent = null;
            if( norm.Culture.Parent.Name != "" )
            {
                parent = NormalizedCultureInfo.EnsureNormalizedCultureInfo( norm.Culture.Parent.Name );
                await RegisterAsync( ctx, parent );
            }

            await DoRegisterAsync(
                ctx,
                norm.Id,
                norm.Name,
                norm.FullName,
                norm.Culture.EnglishName,
                norm.Culture.NativeName,
                norm.Culture.DisplayName,
                parent?.Id ?? 0
            );
        }
        else
        {
            // The primary normalized culture must exist in tCulture before sExtendedCultureRegister
            // validates its PrimaryCultureId. CK.Globalization does not guarantee that PrimaryCulture
            // is part of Fallbacks (see e.g. "st-ls,sl-si"), so we register it explicitly here.
            await RegisterAsync( ctx, extendedCultureInfo.PrimaryCulture );

            await _extendedCultureTable.DoRegisterAsync(
                ctx,
                extendedCultureInfo.Id,
                extendedCultureInfo.FullName,
                extendedCultureInfo.PrimaryCulture.Id
            );
        }
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
        int parentCultureId
     );


    /// <summary>
    /// Destroys a normalized culture and all its children recursively. Cascades to any pure extended
    /// culture whose primary culture is being destroyed, and cleans up <c>tCultureFallback</c>.
    /// The English culture ("en") cannot be destroyed.
    /// </summary>
    [SqlProcedure( "sCultureDestroy" )]
    public abstract Task DestroyAsync( ISqlCallContext ctx, int cultureId );


    /// <summary>
    /// Tells whether a culture id is known (covers both normalized and pure extended cultures
    /// since every registered culture has a row in <c>tExtendedCulture</c>).
    /// </summary>
    public async Task<bool> IsCultureRegisteredAsync( ISqlCallContext ctx, int cultureId )
        => await _extendedCultureTable.IsExtendedCultureRegisteredAsync( ctx, cultureId );

    public async Task<ICulture?> GetCultureAsync( ISqlCallContext ctx, int cultureId )
    => await ctx.GetConnectionController( this ).QuerySingleOrDefaultAsync<ICulture>(
            @"select CultureId, Name, EnglishName, NativeName, DisplayName, ParentCultureId
              from CK.tCulture
              where CultureId = @CultureId;",
            new { CultureId = cultureId } );

    public async Task<IEnumerable<ICulture>> GetAllCulturesAsync( ISqlCallContext ctx )
    =>await ctx.GetConnectionController( this ).QueryAsync<ICulture>(
            @"select CultureId, Name, EnglishName, NativeName, DisplayName, ParentCultureId
              from CK.tCulture
              where CultureId != 0;" );

    public async Task<IEnumerable<ICulture>> GetCultureHierarchyAsync( ISqlCallContext ctx, int cultureId )
    => await ctx.GetConnectionController( this ).QueryAsync<ICulture>(
            @";with Hierarchy as
              (
                  select CultureId, Name, EnglishName, NativeName, DisplayName, ParentCultureId
                  from CK.tCulture
                  where CultureId = @CultureId

                  union all

                  select p.CultureId, p.Name, p.EnglishName, p.NativeName, p.DisplayName, p.ParentCultureId
                  from CK.tCulture p
                  inner join Hierarchy h on p.CultureId = h.ParentCultureId
                  where p.CultureId != 0
              )
              select CultureId, Name, EnglishName, NativeName, DisplayName, ParentCultureId
              from Hierarchy;",
            new { CultureId = cultureId } );


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
        var results = await cultureTable.GetCultureHierarchyAsync( ctx, cmd.CultureId );
        return results.ToList();
    }
}
