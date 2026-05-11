import '../../../core/models/page_response.dart';
import 'listing_api.dart';
import 'models/category_model.dart';
import 'models/listing_detail_model.dart';
import 'models/listing_request_model.dart';
import 'models/nearby_listing_model.dart';

class ListingRepository {
  final ListingApi _api;
  ListingRepository(this._api);

  Future<PageResponse<NearbyListingModel>> getNearby({
    required double lat,
    required double lng,
    double radiusKm = 5,
    String? categoryId,
    int page = 0,
  }) => _api.getNearby(
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
        categoryId: categoryId,
        page: page,
      );

  Future<ListingDetailModel> getById(String id) => _api.getById(id);

  Future<ListingDetailModel> createListing(ListingRequest request) =>
      _api.createListing(request);

  Future<ListingDetailModel> updateListing(
          String id, ListingRequest request) =>
      _api.updateListing(id, request);

  Future<void> deleteListing(String id) => _api.deleteListing(id);

  Future<void> verifyListing(String id) => _api.verifyListing(id);

  Future<List<ListingDetailModel>> getMyListings() => _api.getMyListings();

  Future<List<CategoryModel>> getCategories() => _api.getCategories();
}
