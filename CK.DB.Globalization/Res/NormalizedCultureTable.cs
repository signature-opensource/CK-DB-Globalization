using CK.Core;

namespace CK.DB.Globalization;

[SqlTable( "tNormalizedCulture", Package = typeof( Package ), ResourcePath = "Res" )]
[Versions( "1.0.0" )]
public abstract class NormalizedCultureTable : SqlTable
{
    void StObjConstruct()
    {
    }
}
