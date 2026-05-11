// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$catalogSearchResultsHash() =>
    r'ff093902bf9b15a1cf3275c599313f4d10d01985';

/// See also [catalogSearchResults].
@ProviderFor(catalogSearchResults)
final catalogSearchResultsProvider =
    AutoDisposeFutureProvider<List<ListingDetailModel>>.internal(
  catalogSearchResults,
  name: r'catalogSearchResultsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$catalogSearchResultsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CatalogSearchResultsRef
    = AutoDisposeFutureProviderRef<List<ListingDetailModel>>;
String _$popularListingsHash() => r'1db0131be37b539e7218980071d65da627da9ffc';

/// See also [popularListings].
@ProviderFor(popularListings)
final popularListingsProvider =
    AutoDisposeFutureProvider<List<ListingDetailModel>>.internal(
  popularListings,
  name: r'popularListingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$popularListingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PopularListingsRef
    = AutoDisposeFutureProviderRef<List<ListingDetailModel>>;
String _$recentListingsHash() => r'827c191e66f623dbe7430e84400c4d7318798008';

/// See also [recentListings].
@ProviderFor(recentListings)
final recentListingsProvider =
    AutoDisposeFutureProvider<List<ListingDetailModel>>.internal(
  recentListings,
  name: r'recentListingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentListingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecentListingsRef
    = AutoDisposeFutureProviderRef<List<ListingDetailModel>>;
String _$catalogSearchHash() => r'7d4d55606e39c3070731cedda38bdfa4191b62b5';

/// See also [CatalogSearch].
@ProviderFor(CatalogSearch)
final catalogSearchProvider =
    AutoDisposeNotifierProvider<CatalogSearch, CatalogSearchState>.internal(
  CatalogSearch.new,
  name: r'catalogSearchProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$catalogSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CatalogSearch = AutoDisposeNotifier<CatalogSearchState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
