class SearchFilter {
  final String? query;
  final String? categoryId;
  final String? priceType; // "PER_SERVICE", "PER_HOUR", "NEGOTIABLE"
  final double? minPrice;
  final double? maxPrice;
  final String? city;
  final String sortBy; // "newest", "rating", "price_asc", "price_desc", "popular"
  final int page;
  final int size;

  const SearchFilter({
    this.query,
    this.categoryId,
    this.priceType,
    this.minPrice,
    this.maxPrice,
    this.city,
    this.sortBy = 'newest',
    this.page = 0,
    this.size = 20,
  });

  Map<String, dynamic> toQueryParams() => {
    if (query != null && query!.isNotEmpty) 'query': query,
    if (categoryId != null) 'categoryId': categoryId,
    if (priceType != null) 'priceType': priceType,
    if (minPrice != null) 'minPrice': minPrice.toString(),
    if (maxPrice != null) 'maxPrice': maxPrice.toString(),
    if (city != null && city!.isNotEmpty) 'city': city,
    'sortBy': sortBy,
    'page': page.toString(),
    'size': size.toString(),
  };

  SearchFilter copyWith({
    String? query,
    String? categoryId,
    String? priceType,
    double? minPrice,
    double? maxPrice,
    String? city,
    String? sortBy,
    int? page,
    int? size,
  }) =>
      SearchFilter(
        query: query ?? this.query,
        categoryId: categoryId ?? this.categoryId,
        priceType: priceType ?? this.priceType,
        minPrice: minPrice ?? this.minPrice,
        maxPrice: maxPrice ?? this.maxPrice,
        city: city ?? this.city,
        sortBy: sortBy ?? this.sortBy,
        page: page ?? this.page,
        size: size ?? this.size,
      );
}
