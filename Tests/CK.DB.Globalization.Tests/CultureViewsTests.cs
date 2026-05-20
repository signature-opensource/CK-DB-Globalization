using CK.Core;
using CK.SqlServer;
using CK.Testing;
using Dapper;
using NUnit.Framework;
using Shouldly;
using System.Linq;
using System.Threading.Tasks;

namespace CK.DB.Globalization.Tests;

[TestFixture]
public class CultureViewsTests
{
    [Test]
    public async Task vExtendedCulture_returns_fallback_csv_in_chain_order_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;

        using var ctx = new SqlStandardCallContext();
        // zh-hk is a seeded 3-level normalized culture: [zh-hk, zh-hant, zh] (no English auto-suffix
        // because seeds bypass sCultureRegister). Other tests may have propagated extra entries
        // to the end of the chain, so we only assert the deterministic prefix.
        var zhHk = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "zh-hk" );
        var zhHant = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "zh-hant" );
        var zh = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "zh" );

        var csv = await ctx.GetConnectionController( cultureTable ).ExecuteScalarAsync<string>(
            "select FallbacksCultureId from CK.vExtendedCulture where ExtendedCultureId = @Id;",
            new { Id = zhHk.Id } );

        csv.ShouldNotBeNullOrEmpty();
        var ids = csv.Split( ',' ).Select( int.Parse ).ToList();
        ids.Count.ShouldBeGreaterThanOrEqualTo( 3 );
        ids[0].ShouldBe( zhHk.Id );
        ids[1].ShouldBe( zhHant.Id );
        ids[2].ShouldBe( zh.Id );
    }

    [Test]
    public async Task vCulture_joins_culture_with_aggregates_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;

        using var ctx = new SqlStandardCallContext();
        // Register a non-seed culture in this test so the fallback chain is deterministic:
        // sCultureRegister populates [self, en] at minimum.
        var en = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "en" );
        var ne = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "ne" );
        await cultureTable.RegisterAsync( ctx, ne );

        var row = await ctx.GetConnectionController( cultureTable )
            .QuerySingleAsync<(string Name, string EnglishName, string DisplayName, string FullName, string FallbacksNames, string FallbacksCultureId)>(
                @"select Name, EnglishName, DisplayName, FullName, FallbacksNames, FallbacksCultureId
                  from CK.vCulture
                  where CultureId = @Id;",
                new { Id = ne.Id } );

        row.Name.ShouldBe( "ne" );
        row.EnglishName.ShouldBe( "Nepali" );
        row.FullName.ShouldBe( "ne" );
        row.FallbacksNames.ShouldStartWith( "ne," );
        row.FallbacksNames.Split( ',' ).ShouldContain( "en" );
        row.FallbacksCultureId.Split( ',' ).Select( int.Parse ).First().ShouldBe( ne.Id );
        row.FallbacksCultureId.Split( ',' ).Select( int.Parse ).ShouldContain( en.Id );
    }

    [Test]
    public async Task vExtendedCulture_excludes_seed_zero_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;

        using var ctx = new SqlStandardCallContext();

        var count = await ctx.GetConnectionController( cultureTable ).ExecuteScalarAsync<int>(
            "select count(*) from CK.vExtendedCulture where ExtendedCultureId = 0;" );

        count.ShouldBe( 0 );
    }

    [Test]
    public async Task vCulture_excludes_seed_zero_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;

        using var ctx = new SqlStandardCallContext();

        var count = await ctx.GetConnectionController( cultureTable ).ExecuteScalarAsync<int>(
            "select count(*) from CK.vCulture where CultureId = 0;" );

        count.ShouldBe( 0 );
    }
}
