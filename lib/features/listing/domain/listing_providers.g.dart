// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$listingApiHash() => r'13b7e8874162ccf6a09c012a76fe5e3215666dc3';

/// See also [listingApi].
@ProviderFor(listingApi)
final listingApiProvider = AutoDisposeProvider<ListingApi>.internal(
  listingApi,
  name: r'listingApiProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$listingApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ListingApiRef = AutoDisposeProviderRef<ListingApi>;
String _$listingRepositoryHash() => r'd5f4d6241af651b826effa6f3576ad53d63b1702';

/// See also [listingRepository].
@ProviderFor(listingRepository)
final listingRepositoryProvider =
    AutoDisposeProvider<ListingRepository>.internal(
  listingRepository,
  name: r'listingRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$listingRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ListingRepositoryRef = AutoDisposeProviderRef<ListingRepository>;
String _$categoriesHash() => r'a1529b08f57df3d220588d287dabe72ff9c6d6e0';

/// See also [categories].
@ProviderFor(categories)
final categoriesProvider =
    AutoDisposeFutureProvider<List<CategoryModel>>.internal(
  categories,
  name: r'categoriesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$categoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CategoriesRef = AutoDisposeFutureProviderRef<List<CategoryModel>>;
String _$myListingsHash() => r'5dae5dda2ab1f02f808a28e69fbd9ea19b737c82';

/// See also [myListings].
@ProviderFor(myListings)
final myListingsProvider =
    AutoDisposeFutureProvider<List<ListingDetailModel>>.internal(
  myListings,
  name: r'myListingsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myListingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyListingsRef = AutoDisposeFutureProviderRef<List<ListingDetailModel>>;
String _$listingDetailHash() => r'aa377412ad8f3eb44d0d2e1983c3eeb6ebda461d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [listingDetail].
@ProviderFor(listingDetail)
const listingDetailProvider = ListingDetailFamily();

/// See also [listingDetail].
class ListingDetailFamily extends Family<AsyncValue<ListingDetailModel>> {
  /// See also [listingDetail].
  const ListingDetailFamily();

  /// See also [listingDetail].
  ListingDetailProvider call(
    String id,
  ) {
    return ListingDetailProvider(
      id,
    );
  }

  @override
  ListingDetailProvider getProviderOverride(
    covariant ListingDetailProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'listingDetailProvider';
}

/// See also [listingDetail].
class ListingDetailProvider
    extends AutoDisposeFutureProvider<ListingDetailModel> {
  /// See also [listingDetail].
  ListingDetailProvider(
    String id,
  ) : this._internal(
          (ref) => listingDetail(
            ref as ListingDetailRef,
            id,
          ),
          from: listingDetailProvider,
          name: r'listingDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$listingDetailHash,
          dependencies: ListingDetailFamily._dependencies,
          allTransitiveDependencies:
              ListingDetailFamily._allTransitiveDependencies,
          id: id,
        );

  ListingDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<ListingDetailModel> Function(ListingDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ListingDetailProvider._internal(
        (ref) => create(ref as ListingDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ListingDetailModel> createElement() {
    return _ListingDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ListingDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ListingDetailRef on AutoDisposeFutureProviderRef<ListingDetailModel> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ListingDetailProviderElement
    extends AutoDisposeFutureProviderElement<ListingDetailModel>
    with ListingDetailRef {
  _ListingDetailProviderElement(super.provider);

  @override
  String get id => (origin as ListingDetailProvider).id;
}

String _$nearbyListingsHash() => r'ffe13b95a0101af5552406e794c70d876f071779';

/// See also [nearbyListings].
@ProviderFor(nearbyListings)
final nearbyListingsProvider =
    AutoDisposeFutureProvider<List<NearbyListingModel>>.internal(
  nearbyListings,
  name: r'nearbyListingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nearbyListingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NearbyListingsRef
    = AutoDisposeFutureProviderRef<List<NearbyListingModel>>;
String _$createListingHash() => r'3f94080f549d72b7731b930bd7f7edfac16395be';

/// See also [createListing].
@ProviderFor(createListing)
const createListingProvider = CreateListingFamily();

/// See also [createListing].
class CreateListingFamily extends Family<AsyncValue<ListingDetailModel>> {
  /// See also [createListing].
  const CreateListingFamily();

  /// See also [createListing].
  CreateListingProvider call(
    ListingRequest request,
  ) {
    return CreateListingProvider(
      request,
    );
  }

  @override
  CreateListingProvider getProviderOverride(
    covariant CreateListingProvider provider,
  ) {
    return call(
      provider.request,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'createListingProvider';
}

/// See also [createListing].
class CreateListingProvider
    extends AutoDisposeFutureProvider<ListingDetailModel> {
  /// See also [createListing].
  CreateListingProvider(
    ListingRequest request,
  ) : this._internal(
          (ref) => createListing(
            ref as CreateListingRef,
            request,
          ),
          from: createListingProvider,
          name: r'createListingProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$createListingHash,
          dependencies: CreateListingFamily._dependencies,
          allTransitiveDependencies:
              CreateListingFamily._allTransitiveDependencies,
          request: request,
        );

  CreateListingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.request,
  }) : super.internal();

  final ListingRequest request;

  @override
  Override overrideWith(
    FutureOr<ListingDetailModel> Function(CreateListingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CreateListingProvider._internal(
        (ref) => create(ref as CreateListingRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        request: request,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ListingDetailModel> createElement() {
    return _CreateListingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CreateListingProvider && other.request == request;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, request.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CreateListingRef on AutoDisposeFutureProviderRef<ListingDetailModel> {
  /// The parameter `request` of this provider.
  ListingRequest get request;
}

class _CreateListingProviderElement
    extends AutoDisposeFutureProviderElement<ListingDetailModel>
    with CreateListingRef {
  _CreateListingProviderElement(super.provider);

  @override
  ListingRequest get request => (origin as CreateListingProvider).request;
}

String _$verifyListingHash() => r'907c538ca19958de576612cbddd7c91e69058038';

/// See also [verifyListing].
@ProviderFor(verifyListing)
const verifyListingProvider = VerifyListingFamily();

/// See also [verifyListing].
class VerifyListingFamily extends Family<AsyncValue<void>> {
  /// See also [verifyListing].
  const VerifyListingFamily();

  /// See also [verifyListing].
  VerifyListingProvider call(
    String id,
  ) {
    return VerifyListingProvider(
      id,
    );
  }

  @override
  VerifyListingProvider getProviderOverride(
    covariant VerifyListingProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'verifyListingProvider';
}

/// See also [verifyListing].
class VerifyListingProvider extends AutoDisposeFutureProvider<void> {
  /// See also [verifyListing].
  VerifyListingProvider(
    String id,
  ) : this._internal(
          (ref) => verifyListing(
            ref as VerifyListingRef,
            id,
          ),
          from: verifyListingProvider,
          name: r'verifyListingProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$verifyListingHash,
          dependencies: VerifyListingFamily._dependencies,
          allTransitiveDependencies:
              VerifyListingFamily._allTransitiveDependencies,
          id: id,
        );

  VerifyListingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<void> Function(VerifyListingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VerifyListingProvider._internal(
        (ref) => create(ref as VerifyListingRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _VerifyListingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VerifyListingProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin VerifyListingRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `id` of this provider.
  String get id;
}

class _VerifyListingProviderElement
    extends AutoDisposeFutureProviderElement<void> with VerifyListingRef {
  _VerifyListingProviderElement(super.provider);

  @override
  String get id => (origin as VerifyListingProvider).id;
}

String _$listingReviewsHash() => r'ddd74be3d5cdc9cb00856ceb8aa77550d17f30f2';

/// See also [listingReviews].
@ProviderFor(listingReviews)
const listingReviewsProvider = ListingReviewsFamily();

/// See also [listingReviews].
class ListingReviewsFamily
    extends Family<AsyncValue<PageResponse<ReviewModel>>> {
  /// See also [listingReviews].
  const ListingReviewsFamily();

  /// See also [listingReviews].
  ListingReviewsProvider call(
    String id,
  ) {
    return ListingReviewsProvider(
      id,
    );
  }

  @override
  ListingReviewsProvider getProviderOverride(
    covariant ListingReviewsProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'listingReviewsProvider';
}

/// See also [listingReviews].
class ListingReviewsProvider
    extends AutoDisposeFutureProvider<PageResponse<ReviewModel>> {
  /// See also [listingReviews].
  ListingReviewsProvider(
    String id,
  ) : this._internal(
          (ref) => listingReviews(
            ref as ListingReviewsRef,
            id,
          ),
          from: listingReviewsProvider,
          name: r'listingReviewsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$listingReviewsHash,
          dependencies: ListingReviewsFamily._dependencies,
          allTransitiveDependencies:
              ListingReviewsFamily._allTransitiveDependencies,
          id: id,
        );

  ListingReviewsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<PageResponse<ReviewModel>> Function(ListingReviewsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ListingReviewsProvider._internal(
        (ref) => create(ref as ListingReviewsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<PageResponse<ReviewModel>> createElement() {
    return _ListingReviewsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ListingReviewsProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ListingReviewsRef
    on AutoDisposeFutureProviderRef<PageResponse<ReviewModel>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ListingReviewsProviderElement
    extends AutoDisposeFutureProviderElement<PageResponse<ReviewModel>>
    with ListingReviewsRef {
  _ListingReviewsProviderElement(super.provider);

  @override
  String get id => (origin as ListingReviewsProvider).id;
}

String _$mapSearchParamsHash() => r'376b1739628d037161b455939b1e2047c46a2967';

/// See also [MapSearchParams].
@ProviderFor(MapSearchParams)
final mapSearchParamsProvider =
    AutoDisposeNotifierProvider<MapSearchParams, MapSearchParamsState>.internal(
  MapSearchParams.new,
  name: r'mapSearchParamsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mapSearchParamsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MapSearchParams = AutoDisposeNotifier<MapSearchParamsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
