import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../listing/data/models/listing_detail_model.dart';
import '../../listing/domain/listing_providers.dart';
import '../data/models/search_filter.dart';

part 'catalog_providers.g.dart';

class CatalogSearchState {
  final String query;
  final String? categoryId;
  final String priceType; // "ALL", "PER_SERVICE", "PER_HOUR", "NEGOTIABLE"
  final double minPrice;
  final double maxPrice;
  final String? city;
  final String sortBy;
  final int page;

  const CatalogSearchState({
    this.query = '',
    this.categoryId,
    this.priceType = 'ALL',
    this.minPrice = 0,
    this.maxPrice = 500,
    this.city,
    this.sortBy = 'newest',
    this.page = 0,
  });

  CatalogSearchState copyWith({
    String? query,
    String? categoryId,
    String? priceType,
    double? minPrice,
    double? maxPrice,
    String? city,
    String? sortBy,
    int? page,
    bool clearCategory = false,
  }) =>
      CatalogSearchState(
        query: query ?? this.query,
        categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
        priceType: priceType ?? this.priceType,
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        city: city ?? this.city,
        sortBy: sortBy ?? this.sortBy,
        page: page ?? this.page,
      );
}

@riverpod
class CatalogSearch extends _$CatalogSearch {
  @override
  CatalogSearchState build() => const CatalogSearchState();

  void setQuery(String query) => state = state.copyWith(query: query);
  void setCategory(String? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(categoryId: categoryId);
    }
  }

  void setPriceType(String priceType) => state = state.copyWith(priceType: priceType);
  void setMinPrice(double minPrice) => state = state.copyWith(minPrice: minPrice);
  void setMaxPrice(double maxPrice) => state = state.copyWith(maxPrice: maxPrice);
  void setCity(String? city) => state = state.copyWith(city: city);
  void setSortBy(String sortBy) => state = state.copyWith(sortBy: sortBy);
  void setPage(int page) => state = state.copyWith(page: page);

  void resetFilters() => state = const CatalogSearchState(
    priceType: 'ALL',
    minPrice: 0,
    maxPrice: 500,
    sortBy: 'newest',
    page: 0,
  );
}

@riverpod
Future<List<ListingDetailModel>> catalogSearchResults(CatalogSearchResultsRef ref) async {
  final searchState = ref.watch(catalogSearchProvider);
  final repo = ref.watch(listingRepositoryProvider);

  final filter = SearchFilter(
    query: searchState.query.isEmpty ? null : searchState.query,
    categoryId: searchState.categoryId,
    priceType: searchState.priceType == 'ALL' ? null : searchState.priceType,
    minPrice: searchState.minPrice > 0 ? searchState.minPrice : null,
    maxPrice: searchState.maxPrice < 500 ? searchState.maxPrice : null,
    city: searchState.city,
    sortBy: searchState.sortBy,
    page: searchState.page,
  );

  final response = await repo.searchListings(filter);
  return response.content;
}

@riverpod
Future<List<ListingDetailModel>> popularListings(PopularListingsRef ref) async {
  final repo = ref.watch(listingRepositoryProvider);
  final response = await repo.getPopularListings(page: 0, size: 5);
  return response.content;
}

@riverpod
Future<List<ListingDetailModel>> recentListings(RecentListingsRef ref) async {
  final repo = ref.watch(listingRepositoryProvider);
  final response = await repo.getRecentListings(page: 0, size: 10);
  return response.content;
}
