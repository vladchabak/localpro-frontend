// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$catalogSearchResultsHash() =>
    r'9d8a0c6f23f1ad7bb7c7e1b8aae6730aa2b52616';

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
String _$popularListingsHash() => r'156d4a6a4bfae91bf138d1e9cb50ef7cc9baef1a';

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
String _$recentListingsHash() => r'14019dbebb88b7a918c2ef0066e260d7e8138e50';

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
