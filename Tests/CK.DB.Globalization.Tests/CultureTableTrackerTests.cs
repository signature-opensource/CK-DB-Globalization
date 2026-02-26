using CK.Core;
using CK.SqlServer;
using CK.Testing;
using NUnit.Framework;
using System.Threading.Tasks;

namespace CK.DB.Globalization.Tests;

[TestFixture]
public class CultureTableTrackerTests
{
    [SetUp]
    [TearDown]
    public void ClearCache()
    {
        typeof( NormalizedCultureInfo )
            .GetMethod( "ClearCache", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static )!
            .Invoke( null, null );
    }

    [Test]
    public async Task ExtendedCulture_tracking_registers_all_fallbacks_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;
        using var ctx = new SqlStandardCallContext();

        var tracker = new CultureTableTracker( cultureTable, ctx );
        await tracker.StartAsync();
        var culture = ExtendedCultureInfo.EnsureExtendedCultureInfo( "fr-fr, es, de-de" );
        await tracker.StopAsync();

        (await cultureTable.IsCultureRegisteredAsync( ctx, culture.Id )).ShouldBe( true );
        foreach( var fb in culture.Fallbacks )
        {
            (await cultureTable.IsCultureRegisteredAsync( ctx, fb.Id )).ShouldBe( true );
        }
    }

    [Test]
    public async Task NormalizedCulture_tracking_registers_hierarchy_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;
        using var ctx = new SqlStandardCallContext();

        var tracker = new CultureTableTracker( cultureTable, ctx );
        await tracker.StartAsync();
        var culture = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "pa-Guru-IN" );
        await tracker.StopAsync();

        (await cultureTable.IsCultureRegisteredAsync( ctx, culture.Id )).ShouldBe( true );
        // pa-Guru-IN parents: pa-Guru, pa, en, ""
        var paGuru = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "pa-Guru" );
        var pa = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "pa" );
        (await cultureTable.IsCultureRegisteredAsync( ctx, paGuru.Id )).ShouldBe( true );
        (await cultureTable.IsCultureRegisteredAsync( ctx, pa.Id )).ShouldBe( true );
    }

    [Test]
    public async Task SpecificCulture_tracking_registers_specific_Async()
    {
        var cultureTable = SharedEngine.Map.StObjs.Obtain<CultureTable>()!;
        using var ctx = new SqlStandardCallContext();

        var tracker = new CultureTableTracker( cultureTable, ctx );
        await tracker.StartAsync();
        var fr = NormalizedCultureInfo.EnsureNormalizedCultureInfo( "fr" );
        await tracker.StopAsync();

        (await cultureTable.IsCultureRegisteredAsync( ctx, fr.Id )).ShouldBe( true );

        // Accessing SpecificCulture ensures "fr-fr".
        await tracker.StartAsync();
        var frFR = fr.SpecificCulture;
        frFR.Name.ShouldBe( "fr-fr" );
        await tracker.StopAsync();

        (await cultureTable.IsCultureRegisteredAsync( ctx, frFR.Id )).ShouldBe( true );
    }
}
