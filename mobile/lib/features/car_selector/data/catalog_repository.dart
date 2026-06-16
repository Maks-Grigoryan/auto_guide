/// Thin data-access wrapper over the catalog async providers.
///
/// The Riverpod async providers in [catalog_providers.dart] handle HTTP and
/// caching. This file exists as a named module boundary — future phases can
/// add retry logic, offline fallback, or a test double here without touching
/// the provider declarations.
///
/// Usage: prefer watching [makesProvider], [modelsProvider], [generationsProvider]
/// directly in UI widgets unless you need the repository abstraction for tests.
library;

export 'catalog_providers.dart'
    show
        dioProvider,
        makesProvider,
        modelsProvider,
        generationsProvider;
