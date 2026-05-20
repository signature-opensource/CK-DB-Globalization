using CK.Core;
using CK.SqlServer;
using CK.Testing;
using Dapper;
using Microsoft.Data.SqlClient;
using NUnit.Framework;
using Shouldly;
using System.Linq;
using System.Threading.Tasks;

namespace CK.DB.Globalization.Tests;

[TestFixture]
public class CultureFallbackTests
{
    [Test]
    public async Task register_culture_populates_fallback_chain_with_self_at_idx_0_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;
        var fallbackTable = SharedEngine.Map.StObjs.Obtain<CultureFallbackTable>()!;

        using var ctx = new SqlStandardCallContext();
        var en = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "en" );
        var culture = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "th" );

        await cultureTable.RegisterAsync( ctx, culture );

        var chain = (await fallbackTable.GetFallbacksAsync( ctx, culture.Id )).Select( c => c.CultureId ).ToList();
        chain[0].ShouldBe( culture.Id );
        chain.ShouldContain( en.Id );
    }

    [Test]
    public async Task register_hierarchical_culture_populates_full_chain_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;
        var fallbackTable = SharedEngine.Map.StObjs.Obtain<CultureFallbackTable>()!;

        using var ctx = new SqlStandardCallContext();
        // Use a non-seed hierarchical culture: 'it-ch' has parent 'it' (in seed). Register goes through
        // the sproc which enriches the chain with the English suffix.
        var itCh = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "it-ch" );
        var it = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "it" );
        var en = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "en" );

        await cultureTable.RegisterAsync( ctx, itCh );

        // Real fallbacks come first, then English auto-suffix.
        var chain = (await fallbackTable.GetFallbacksAsync( ctx, itCh.Id )).Select( c => c.CultureId ).ToList();
        chain[0].ShouldBe( itCh.Id );
        chain[1].ShouldBe( it.Id );
        chain.ShouldContain( en.Id );
    }

    [Test]
    public async Task register_extended_culture_matches_stored_fullname_order_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;
        var extendedCultureTable = SharedEngine.Map.StObjs.Obtain<ExtendedCultureTable>()!;
        var fallbackTable = SharedEngine.Map.StObjs.Obtain<CultureFallbackTable>()!;

        using var ctx = new SqlStandardCallContext();
        var extended = ExtendedCultureInfo.EnsureExtendedCultureInfo( "en, jp, fr" );

        await cultureTable.RegisterAsync( ctx, extended );

        // The fallback chain must mirror the comma-separated FullName as stored in CK.tExtendedCulture.
        var stored = await extendedCultureTable.GetExtendedCultureAsync( ctx, extended.Id );
        stored.ShouldNotBeNull();
        var expected = stored!.FullName.Split( ',' ).Select( n => n.Trim() ).ToList();

        var actual = (await fallbackTable.GetFallbacksAsync( ctx, extended.Id )).Select( c => c.Name ).ToList();

        // The chain starts with the FullName tokens; the English auto-suffix may add more entries afterwards.
        actual.Count.ShouldBeGreaterThanOrEqualTo( expected.Count );
        for( int i = 0; i < expected.Count; i++ )
        {
            actual[i].ShouldBe( expected[i] );
        }
    }

    [Test]
    public async Task set_fallbacks_replaces_existing_chain_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;
        var fallbackTable = SharedEngine.Map.StObjs.Obtain<CultureFallbackTable>()!;

        using var ctx = new SqlStandardCallContext();
        var en = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "en" );
        var fr = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "fr" );
        var ka = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "ka" );

        await cultureTable.RegisterAsync( ctx, fr );
        await cultureTable.RegisterAsync( ctx, ka );

        await fallbackTable.SetFallbacksAsync( ctx, ka.Id, new[] { ka.Id, fr.Id, en.Id } );

        var chain = (await fallbackTable.GetFallbacksAsync( ctx, ka.Id )).ToList();
        chain.Count.ShouldBe( 3 );
        chain[0].CultureId.ShouldBe( ka.Id );
        chain[1].CultureId.ShouldBe( fr.Id );
        chain[2].CultureId.ShouldBe( en.Id );
    }

    [Test]
    public async Task set_fallbacks_chain_not_starting_with_self_throws_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;
        var fallbackTable = SharedEngine.Map.StObjs.Obtain<CultureFallbackTable>()!;

        using var ctx = new SqlStandardCallContext();
        var en = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "en" );
        var hy = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "hy" );

        await cultureTable.RegisterAsync( ctx, hy );

        Assert.ThrowsAsync<SqlDetailedException>( async () =>
            await fallbackTable.SetFallbacksAsync( ctx, hy.Id, new[] { en.Id, hy.Id } ) );
    }

    [Test]
    public async Task set_fallbacks_with_unknown_culture_throws_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;
        var fallbackTable = SharedEngine.Map.StObjs.Obtain<CultureFallbackTable>()!;

        using var ctx = new SqlStandardCallContext();
        var am = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "am" );

        await cultureTable.RegisterAsync( ctx, am );

        Assert.ThrowsAsync<SqlDetailedException>( async () =>
            await fallbackTable.SetFallbacksAsync( ctx, am.Id, new[] { am.Id, 999_999_999 } ) );
    }

    [Test]
    public async Task destroy_culture_removes_its_fallback_chain_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;
        var fallbackTable = SharedEngine.Map.StObjs.Obtain<CultureFallbackTable>()!;

        using var ctx = new SqlStandardCallContext();
        var lo = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "lo" );

        await cultureTable.RegisterAsync( ctx, lo );
        (await fallbackTable.GetFallbacksAsync( ctx, lo.Id )).Count().ShouldBeGreaterThanOrEqualTo( 1 );

        await cultureTable.DestroyAsync( ctx, lo.Id );
        (await fallbackTable.GetFallbacksAsync( ctx, lo.Id )).Count().ShouldBe( 0 );
    }

    [Test]
    public async Task destroy_culture_removes_references_in_other_chains_with_reindex_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;
        var fallbackTable = SharedEngine.Map.StObjs.Obtain<CultureFallbackTable>()!;

        using var ctx = new SqlStandardCallContext();
        var en = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "en" );
        var mi = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "mi" );
        var sw = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "sw" );

        await cultureTable.RegisterAsync( ctx, mi );
        await cultureTable.RegisterAsync( ctx, sw );

        // sw chain : [sw, mi, en]
        await fallbackTable.SetFallbacksAsync( ctx, sw.Id, new[] { sw.Id, mi.Id, en.Id } );

        // Destroying mi must remove it from sw's chain and reindex (no hole at Idx 1).
        await cultureTable.DestroyAsync( ctx, mi.Id );

        var rows = (await ctx.GetConnectionController( fallbackTable )
            .QueryAsync<(int CultureId, short Idx, int FallbackCultureId)>(
                @"select CultureId, Idx, FallbackCultureId
                  from CK.tCultureFallback
                  where CultureId = @Id
                  order by Idx;",
                new { Id = sw.Id } )).ToList();

        rows.Count.ShouldBe( 2 );
        rows[0].Idx.ShouldBe( (short)0 );
        rows[0].FallbackCultureId.ShouldBe( sw.Id );
        rows[1].Idx.ShouldBe( (short)1 );
        rows[1].FallbackCultureId.ShouldBe( en.Id );
    }

    [Test]
    public async Task destroy_culture_with_children_cascades_fallback_cleanup_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;
        var fallbackTable = SharedEngine.Map.StObjs.Obtain<CultureFallbackTable>()!;

        using var ctx = new SqlStandardCallContext();
        var sr = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "sr" );
        var srLatn = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "sr-Latn" );
        var srLatnRs = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "sr-Latn-RS" );

        await cultureTable.RegisterAsync( ctx, srLatnRs );

        (await fallbackTable.GetFallbacksAsync( ctx, sr.Id )).Count().ShouldBeGreaterThan( 0 );
        (await fallbackTable.GetFallbacksAsync( ctx, srLatn.Id )).Count().ShouldBeGreaterThan( 0 );
        (await fallbackTable.GetFallbacksAsync( ctx, srLatnRs.Id )).Count().ShouldBeGreaterThan( 0 );

        await cultureTable.DestroyAsync( ctx, sr.Id );

        (await fallbackTable.GetFallbacksAsync( ctx, sr.Id )).Count().ShouldBe( 0 );
        (await fallbackTable.GetFallbacksAsync( ctx, srLatn.Id )).Count().ShouldBe( 0 );
        (await fallbackTable.GetFallbacksAsync( ctx, srLatnRs.Id )).Count().ShouldBe( 0 );
    }

    [Test]
    public async Task seed_zh_hk_has_expected_three_level_chain_Async()
    {
        var fallbackTable = SharedEngine.Map.StObjs.Obtain<CultureFallbackTable>()!;

        using var ctx = new SqlStandardCallContext();
        var zhHk = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "zh-hk" );
        var zhHant = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "zh-hant" );
        var zh = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "zh" );

        // Seeds are inserted directly (bypassing the sproc), so zh-hk starts with the strict 3-entry chain.
        // After dynamic registrations of other cultures via Register, propagation may have appended entries.
        var chain = (await fallbackTable.GetFallbacksAsync( ctx, zhHk.Id )).ToList();

        chain.Count.ShouldBeGreaterThanOrEqualTo( 3 );
        chain[0].CultureId.ShouldBe( zhHk.Id );
        chain[1].CultureId.ShouldBe( zhHant.Id );
        chain[2].CultureId.ShouldBe( zh.Id );
    }

    [Test]
    public async Task register_culture_chain_ends_with_english_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;
        var fallbackTable = SharedEngine.Map.StObjs.Obtain<CultureFallbackTable>()!;

        using var ctx = new SqlStandardCallContext();
        var en = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "en" );
        var ja = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "ja" );

        await cultureTable.RegisterAsync( ctx, ja );

        var chain = (await fallbackTable.GetFallbacksAsync( ctx, ja.Id )).Select( c => c.CultureId ).ToList();
        chain[0].ShouldBe( ja.Id );
        chain.ShouldContain( en.Id );
        chain.IndexOf( en.Id ).ShouldBeGreaterThan( 0 );
    }

    [Test]
    public async Task register_culture_inherits_english_existing_fallbacks_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;
        var fallbackTable = SharedEngine.Map.StObjs.Obtain<CultureFallbackTable>()!;

        using var ctx = new SqlStandardCallContext();
        var qu = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "qu" );
        var ay = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "ay" );

        // Register qu first: propagation appends qu to English's chain.
        await cultureTable.RegisterAsync( ctx, qu );

        // Register ay AFTER: its chain inherits English's current fallbacks, which now include qu.
        await cultureTable.RegisterAsync( ctx, ay );

        var ayChain = (await fallbackTable.GetFallbacksAsync( ctx, ay.Id )).Select( c => c.CultureId ).ToList();
        ayChain.ShouldContain( qu.Id );
    }

    [Test]
    public async Task register_propagates_new_culture_to_all_other_chains_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;
        var fallbackTable = SharedEngine.Map.StObjs.Obtain<CultureFallbackTable>()!;

        using var ctx = new SqlStandardCallContext();
        var en = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "en" );
        var fr = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "fr" );
        var mt = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "mt" );

        await cultureTable.RegisterAsync( ctx, mt );

        var enChain = (await fallbackTable.GetFallbacksAsync( ctx, en.Id )).Select( c => c.CultureId ).ToList();
        var frChain = (await fallbackTable.GetFallbacksAsync( ctx, fr.Id )).Select( c => c.CultureId ).ToList();

        enChain.ShouldContain( mt.Id );
        frChain.ShouldContain( mt.Id );
    }

    [Test]
    public async Task register_extended_culture_does_not_propagate_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;
        var fallbackTable = SharedEngine.Map.StObjs.Obtain<CultureFallbackTable>()!;

        using var ctx = new SqlStandardCallContext();
        var en = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "en" );
        var extended = ExtendedCultureInfo.EnsureExtendedCultureInfo( "es, it" );

        await cultureTable.RegisterAsync( ctx, extended );

        // A pure extended id is never a normalized CultureId and cannot become a FallbackCultureId
        // (FK to tCulture would refuse it). Validate that English's chain does not contain the extended id.
        var enChain = (await fallbackTable.GetFallbacksAsync( ctx, en.Id )).Select( c => c.CultureId ).ToList();
        enChain.ShouldNotContain( extended.Id );
    }
}
