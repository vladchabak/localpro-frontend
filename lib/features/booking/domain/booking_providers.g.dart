// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookingApiHash() => r'6b85391307b0ee8c9fdc9c270b60326a58d03bda';

/// See also [bookingApi].
@ProviderFor(bookingApi)
final bookingApiProvider = AutoDisposeProvider<BookingApi>.internal(
  bookingApi,
  name: r'bookingApiProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$bookingApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BookingApiRef = AutoDisposeProviderRef<BookingApi>;
String _$bookingRepositoryHash() => r'2fb32c737a515dda68c495d33a4a669bc41eddad';

/// See also [bookingRepository].
@ProviderFor(bookingRepository)
final bookingRepositoryProvider =
    AutoDisposeProvider<BookingRepository>.internal(
  bookingRepository,
  name: r'bookingRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookingRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BookingRepositoryRef = AutoDisposeProviderRef<BookingRepository>;
String _$myBookingsHash() => r'bfe52dacd5b2f37406174b7d7eb7b9337bd8ed77';

/// See also [myBookings].
@ProviderFor(myBookings)
final myBookingsProvider =
    AutoDisposeFutureProvider<List<BookingResponse>>.internal(
  myBookings,
  name: r'myBookingsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myBookingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyBookingsRef = AutoDisposeFutureProviderRef<List<BookingResponse>>;
String _$bookingDetailHash() => r'ff7703b1ab0ff0748a1e6703f5b4298ede3ea22a';

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

/// See also [bookingDetail].
@ProviderFor(bookingDetail)
const bookingDetailProvider = BookingDetailFamily();

/// See also [bookingDetail].
class BookingDetailFamily extends Family<AsyncValue<BookingResponse>> {
  /// See also [bookingDetail].
  const BookingDetailFamily();

  /// See also [bookingDetail].
  BookingDetailProvider call(
    String id,
  ) {
    return BookingDetailProvider(
      id,
    );
  }

  @override
  BookingDetailProvider getProviderOverride(
    covariant BookingDetailProvider provider,
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
  String? get name => r'bookingDetailProvider';
}

/// See also [bookingDetail].
class BookingDetailProvider extends AutoDisposeFutureProvider<BookingResponse> {
  /// See also [bookingDetail].
  BookingDetailProvider(
    String id,
  ) : this._internal(
          (ref) => bookingDetail(
            ref as BookingDetailRef,
            id,
          ),
          from: bookingDetailProvider,
          name: r'bookingDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$bookingDetailHash,
          dependencies: BookingDetailFamily._dependencies,
          allTransitiveDependencies:
              BookingDetailFamily._allTransitiveDependencies,
          id: id,
        );

  BookingDetailProvider._internal(
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
    FutureOr<BookingResponse> Function(BookingDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BookingDetailProvider._internal(
        (ref) => create(ref as BookingDetailRef),
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
  AutoDisposeFutureProviderElement<BookingResponse> createElement() {
    return _BookingDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BookingDetailRef on AutoDisposeFutureProviderRef<BookingResponse> {
  /// The parameter `id` of this provider.
  String get id;
}

class _BookingDetailProviderElement
    extends AutoDisposeFutureProviderElement<BookingResponse>
    with BookingDetailRef {
  _BookingDetailProviderElement(super.provider);

  @override
  String get id => (origin as BookingDetailProvider).id;
}

String _$createBookingHash() => r'c3525d73c79986c7fee4205973fdf2f27ddac628';

/// See also [createBooking].
@ProviderFor(createBooking)
const createBookingProvider = CreateBookingFamily();

/// See also [createBooking].
class CreateBookingFamily extends Family<AsyncValue<BookingResponse>> {
  /// See also [createBooking].
  const CreateBookingFamily();

  /// See also [createBooking].
  CreateBookingProvider call(
    BookingRequest request,
  ) {
    return CreateBookingProvider(
      request,
    );
  }

  @override
  CreateBookingProvider getProviderOverride(
    covariant CreateBookingProvider provider,
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
  String? get name => r'createBookingProvider';
}

/// See also [createBooking].
class CreateBookingProvider extends AutoDisposeFutureProvider<BookingResponse> {
  /// See also [createBooking].
  CreateBookingProvider(
    BookingRequest request,
  ) : this._internal(
          (ref) => createBooking(
            ref as CreateBookingRef,
            request,
          ),
          from: createBookingProvider,
          name: r'createBookingProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$createBookingHash,
          dependencies: CreateBookingFamily._dependencies,
          allTransitiveDependencies:
              CreateBookingFamily._allTransitiveDependencies,
          request: request,
        );

  CreateBookingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.request,
  }) : super.internal();

  final BookingRequest request;

  @override
  Override overrideWith(
    FutureOr<BookingResponse> Function(CreateBookingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CreateBookingProvider._internal(
        (ref) => create(ref as CreateBookingRef),
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
  AutoDisposeFutureProviderElement<BookingResponse> createElement() {
    return _CreateBookingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CreateBookingProvider && other.request == request;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, request.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CreateBookingRef on AutoDisposeFutureProviderRef<BookingResponse> {
  /// The parameter `request` of this provider.
  BookingRequest get request;
}

class _CreateBookingProviderElement
    extends AutoDisposeFutureProviderElement<BookingResponse>
    with CreateBookingRef {
  _CreateBookingProviderElement(super.provider);

  @override
  BookingRequest get request => (origin as CreateBookingProvider).request;
}

String _$cancelBookingHash() => r'e181d4a6ccae3e8e41da0ca38f9e3d917ba1f5af';

/// See also [cancelBooking].
@ProviderFor(cancelBooking)
const cancelBookingProvider = CancelBookingFamily();

/// See also [cancelBooking].
class CancelBookingFamily extends Family<AsyncValue<BookingResponse>> {
  /// See also [cancelBooking].
  const CancelBookingFamily();

  /// See also [cancelBooking].
  CancelBookingProvider call(
    String id,
  ) {
    return CancelBookingProvider(
      id,
    );
  }

  @override
  CancelBookingProvider getProviderOverride(
    covariant CancelBookingProvider provider,
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
  String? get name => r'cancelBookingProvider';
}

/// See also [cancelBooking].
class CancelBookingProvider extends AutoDisposeFutureProvider<BookingResponse> {
  /// See also [cancelBooking].
  CancelBookingProvider(
    String id,
  ) : this._internal(
          (ref) => cancelBooking(
            ref as CancelBookingRef,
            id,
          ),
          from: cancelBookingProvider,
          name: r'cancelBookingProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$cancelBookingHash,
          dependencies: CancelBookingFamily._dependencies,
          allTransitiveDependencies:
              CancelBookingFamily._allTransitiveDependencies,
          id: id,
        );

  CancelBookingProvider._internal(
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
    FutureOr<BookingResponse> Function(CancelBookingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CancelBookingProvider._internal(
        (ref) => create(ref as CancelBookingRef),
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
  AutoDisposeFutureProviderElement<BookingResponse> createElement() {
    return _CancelBookingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CancelBookingProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CancelBookingRef on AutoDisposeFutureProviderRef<BookingResponse> {
  /// The parameter `id` of this provider.
  String get id;
}

class _CancelBookingProviderElement
    extends AutoDisposeFutureProviderElement<BookingResponse>
    with CancelBookingRef {
  _CancelBookingProviderElement(super.provider);

  @override
  String get id => (origin as CancelBookingProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
