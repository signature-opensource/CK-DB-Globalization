using CK.Core;
using CK.SqlServer;
using CK.Testing;
using Dapper;
using Microsoft.CodeAnalysis.FlowAnalysis;
using Microsoft.Extensions.DependencyInjection;
using NUnit.Framework;
using Microsoft.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace CK.DB.Globalization.Tests;

[TestFixture]
public class CultureTests
{
    // Single entry.
    [TestCase( "jp" )]
    // Basic list.
    [TestCase( " jp, fr " )]
    [TestCase( "en, jp, fr" )]
    // Basic list (with duplicates).
    [TestCase( " jp, fr, jp, fr " )]
    [TestCase( "en, jp, fr, fr, jp, en" )]
    // A NormalizedCultureInfo expressed as its fallbacks.
    [TestCase( "FR-FR,FR" )]
    // A NormalizedCultureInfo expressed as its fallbacks (with duplicates).
    [TestCase( "FR-FR,FR,fr-fr" )]
    // Reordering leading to the NormalizedCultureInfo.
    [TestCase( "fr, fr-FR" )]
    // Simple reordering.
    [TestCase( "fr, fr-fr, en" )]
    [TestCase( "fr, en, fr-fr" )]
    // Multiple reordering.
    [TestCase( "fr, fr-fr, en, fr-ca, en-CA, fr-CH,en-BB" )]
    // 3-levels.
    [TestCase( "pa-Guru-IN,az-Cyrl-AZ" )]
    [TestCase( "pa-Guru,az-Cyrl" )]
    [TestCase( "az, pa-Guru-IN, az-Cyrl, en, pa" )]
    [TestCase( "az, pa, az-Cyrl-AZ, az-Cyrl, pa-Guru-IN" )]
    [TestCase( "pa-Guru-IN,en,pa-Guru" )]
    //
    [TestCase( "st-ls,sl-si" )]
    public async Task register_extended_culture_Async( string names )
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;

        using var ctx = new SqlStandardCallContext();
        var culture = ExtendedCultureInfo.EnsureExtendedCultureInfo( names );

        await cultureTable.RegisterAsync( ctx, culture );

        var isCulturedRegistered = await cultureTable.IsCultureRegisteredAsync( ctx, culture.Id );
        isCulturedRegistered.ShouldBe( true );

        if( culture.Fallbacks.Length > 0 )
        {
            foreach( var fb in culture.Fallbacks )
            {
                isCulturedRegistered = await cultureTable.IsCultureRegisteredAsync( ctx, fb.Id );
                isCulturedRegistered.ShouldBe( true );
            }
        }
    }

    [Test]
    public async Task destroy_culture_removes_it_from_database_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;

        using var ctx = new SqlStandardCallContext();
        var culture = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "bs" );

        await cultureTable.RegisterAsync( ctx, culture );
        (await cultureTable.IsCultureRegisteredAsync( ctx, culture.Id )).ShouldBe( true );

        await cultureTable.DestroyAsync( ctx, culture.Id );
        (await cultureTable.IsCultureRegisteredAsync( ctx, culture.Id )).ShouldBe( false );
    }

    [Test]
    public async Task destroy_culture_removes_all_children_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;

        using var ctx = new SqlStandardCallContext();
        var parent = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "sr" );
        var child = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "sr-Latn" );
        var grandChild = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "sr-Latn-RS" );

        await cultureTable.RegisterAsync( ctx, grandChild );
        (await cultureTable.IsCultureRegisteredAsync( ctx, parent.Id )).ShouldBe( true );
        (await cultureTable.IsCultureRegisteredAsync( ctx, child.Id )).ShouldBe( true );
        (await cultureTable.IsCultureRegisteredAsync( ctx, grandChild.Id )).ShouldBe( true );

        await cultureTable.DestroyAsync( ctx, parent.Id );
        (await cultureTable.IsCultureRegisteredAsync( ctx, parent.Id )).ShouldBe( false );
        (await cultureTable.IsCultureRegisteredAsync( ctx, child.Id )).ShouldBe( false );
        (await cultureTable.IsCultureRegisteredAsync( ctx, grandChild.Id )).ShouldBe( false );
    }

    [Test]
    public async Task destroy_english_culture_throws_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;

        using var ctx = new SqlStandardCallContext();
        var en = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "en" );

        Assert.ThrowsAsync<SqlDetailedException>( async () => await cultureTable.DestroyAsync( ctx, en.Id ) );
    }

    [Test]
    public async Task destroy_culture_0_throws_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;

        using var ctx = new SqlStandardCallContext();

        Assert.ThrowsAsync<SqlDetailedException> ( async () => await cultureTable.DestroyAsync( ctx, 0 ) );
    }

    [Test]
    public async Task destroy_nonexistent_culture_throws_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;

        using var ctx = new SqlStandardCallContext();

        Assert.ThrowsAsync<SqlDetailedException>( async () => await cultureTable.DestroyAsync( ctx, -999 ) );
    }
}
