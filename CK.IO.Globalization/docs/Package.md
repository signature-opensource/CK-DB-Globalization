The Cris (Command Responsibility Segregation) queries that read the cultures persisted by CK.DB.Globalization:
`IGetCultureQCommand`, `IGetAllCulturesQCommand` and `IGetCultureHierarchyQCommand`.

They return the `ICulture` poco (its identifier, names and parent culture); `IExtendedCulture` describes an extended
culture and its primary culture.
