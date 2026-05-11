import 'package:dio/dio.dart';
import '../../../core/models/page_response.dart';
import '../../catalog/data/models/search_filter.dart';
import 'models/category_model.dart';
import 'models/listing_detail_model.dart';
import 'models/listing_request_model.dart';
import 'models/nearby_listing_model.dart';

class ListingApi {
  final Dio _dio;
  ListingApi(this._dio);

  Future<PageResponse<NearbyListingModel>> getNearby({
    required double lat,
    required double lng,
    double radiusKm = 5,
    String? categoryId,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get('/api/listings/nearby', queryParameters: {
      'lat': lat,
      'lng': lng,
      'radiusKm': radiusKm,
      if (categoryId != null) 'categoryId': categoryId,
      'page': page,
      'size': size,
    });
    return PageResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => NearbyListingModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ListingDetailModel> getById(String id) async {
    final response = await _dio.get('/api/listings/$id');
    return ListingDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ListingDetailModel> createListing(ListingRequest request) async {
    final response = await _dio.post('/api/listings', data: request.toJson());
    return ListingDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ListingDetailModel> updateListing(
    String id,
    ListingRequest request,
  ) async {
    final response = await _dio.put('/api/listings/$id', data: request.toJson());
    return ListingDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteListing(String id) async {
    await _dio.delete('/api/listings/$id');
  }

  Future<void> verifyListing(String id) async {
    await _dio.post('/api/listings/$id/verify');
  }

  Future<List<ListingDetailModel>> getMyListings() async {
    final response = await _dio.get('/api/listings/my');
    final content = (response.data as Map<String, dynamic>)['content'] as List;
    return content
        .map((e) => ListingDetailModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get('/api/categories');
    return (response.data as List<dynamic>)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PageResponse<ListingDetailModel>> searchListings(
    SearchFilter filter,
  ) async {
    final response = await _dio.get(
      '/api/listings/search',
      queryParameters: filter.toQueryParams(),
    );
    return PageResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => ListingDetailModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<PageResponse<ListingDetailModel>> getPopularListings({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '/api/listings/popular',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => ListingDetailModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<PageResponse<ListingDetailModel>> getRecentListings({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '/api/listings/recent',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => ListingDetailModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<PageResponse<ListingDetailModel>> getListingsByCategory(
    String categoryId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '/api/listings/category/$categoryId',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      response.data as Map<String, dynamic>,
      (json) => ListingDetailModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
