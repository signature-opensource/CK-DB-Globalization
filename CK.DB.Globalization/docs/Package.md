Persists the cultures of CK.Globalization in the database: the `CK.tCulture` and `CK.tExtendedCulture` tables with
the fallback chain of each culture (`CK.tCultureFallback`), and the handlers of the CK.IO.Globalization queries.

`CultureTable` registers and reads the cultures (`CultureTable.RegisterAsync`, `CultureTable.GetAllCulturesAsync`,
`CultureTable.GetCultureHierarchyAsync`); `CultureTableTracker` registers in the database the cultures created at run
time. `ExtendedCultureTable` and `CultureFallbackTable` hold the extended cultures and their fallbacks.
