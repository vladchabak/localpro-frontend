import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/api/core_providers.dart';
import '../data/listing_api.dart';
import '../data/listing_repository.dart';
import '../data/models/category_model.dart';
import '../data/models/listing_detail_model.dart';
import '../data/models/listing_request_model.dart';
import '../data/models/nearby_listing_model.dart';

part 'listing_providers.g.dart';

@riverpod
ListingApi listingApi(ListingApiRef ref) =>
    ListingApi(ref.watch(dioProvider));

@riverpod
ListingRepository listingRepository(ListingRepositoryRef ref) =>
    ListingRepository(ref.watch(listingApiProvider));

@riverpod
Future<List<CategoryModel>> categories(CategoriesRef ref) =>
    ref.watch(listingRepositoryProvider).getCategories();

// State class — plain Dart, no freezed needed
class MapSearchParamsState {
  final double lat;
  final double lng;
  final double radiusKm;
  final String? categoryId;

  const MapSearchParamsState({
    required this.lat,
    required this.lng,
    required this.radiusKm,
    this.categoryId,
  });

  MapSearchParamsState copyWith({
    double? lat,
    double? lng,
    double? radiusKm,
    String? categoryId,
    bool clearCategory = false,
  }) => MapSearchParamsState(
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        radiusKm: radiusKm ?? this.radiusKm,
        categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      );
}

@riverpod
class MapSearchParams extends _$MapSearchParams {
  @override
  MapSearchParamsState build() => const MapSearchParamsState(
        lat: 35.1856,  // Nicosia, Cyprus
        lng: 33.3823,
        radiusKm: 5.0,
      );

  void updateLocation(double lat, double lng) {
    state = state.copyWith(lat: lat, lng: lng);
  }

  void updateRadius(double radiusKm) {
    state = state.copyWith(radiusKm: radiusKm);
  }

  void updateCategory(String? categoryId) {
    state = categoryId == null
        ? state.copyWith(clearCategory: true)
        : state.copyWith(categoryId: categoryId);
  }
}

@riverpod
Future<List<ListingDetailModel>> myListings(MyListingsRef ref) =>
    ref.watch(listingRepositoryProvider).getMyListings();

@riverpod
Future<ListingDetailModel> listingDetail(
  ListingDetailRef ref,
  String id,
) =>
    ref.watch(listingRepositoryProvider).getById(id);

@riverpod
Future<List<NearbyListingModel>> nearbyListings(NearbyListingsRef ref) {
  final params = ref.watch(mapSearchParamsProvider);
  final repo = ref.watch(listingRepositoryProvider);
  return repo
      .getNearby(
        lat: params.lat,
        lng: params.lng,
        radiusKm: params.radiusKm,
        categoryId: params.categoryId,
      )
      .then((page) => page.content);
}

@riverpod
Future<ListingDetailModel> createListing(
  CreateListingRef ref,
  ListingRequest request,
) =>
    ref.read(listingRepositoryProvider).createListing(request);

@riverpod
Future<void> verifyListing(VerifyListingRef ref, String id) =>
    ref.read(listingRepositoryProvider).verifyListing(id);
