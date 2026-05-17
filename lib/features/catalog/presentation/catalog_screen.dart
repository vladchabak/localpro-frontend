import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../listing/data/models/listing_detail_model.dart';
import '../../listing/domain/listing_providers.dart';
import '../domain/catalog_providers.dart';
import 'widgets/catalog_listing_card.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchController = TextEditingController();
  final _cityController = TextEditingController();
  bool _showFilters = false;
  bool _gridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(catalogSearchProvider);
    final resultsAsync = ref.watch(catalogSearchResultsProvider);
    final isDefaultSearch = searchState.query.isEmpty &&
        searchState.categoryId == null &&
        (searchState.city == null || searchState.city!.isEmpty);
    final recentListingsAsync =
        isDefaultSearch ? ref.watch(recentListingsProvider) : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar + toggle
            _buildSearchBar(),

            // Most Used Services Button
            _buildMostUsedButton(),

            // Filter chips
            _buildFilterChips(searchState),

            // Filter panel (collapsible)
            if (_showFilters)
              _buildFilterPanel(searchState),

            // Results header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: resultsAsync.when(
                      data: (data) => Text(
                        '${data.length} services found',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink2,
                        ),
                      ),
                      loading: () => const Text(
                        'Loading...',
                        style: TextStyle(fontSize: 14, color: AppColors.ink3),
                      ),
                      error: (_, __) => const Text(
                        'Error loading results',
                        style: TextStyle(fontSize: 14, color: AppColors.error),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _gridView ? Icons.view_list : Icons.grid_view,
                      color: AppColors.ink2,
                      size: 22,
                    ),
                    onPressed: () => setState(() => _gridView = !_gridView),
                  ),
                ],
              ),
            ),

            // Results
            Expanded(
              child: resultsAsync.when(
                loading: () => _buildLoadingState(),
                error: (e, _) => AppErrorWidget(
                  message: 'Failed to load results.',
                  onRetry: () => ref.invalidate(catalogSearchResultsProvider),
                ),
                data: (results) {
                  if (results.isEmpty) {
                    return _buildEmptyState();
                  }
                  return Column(
                    children: [
                      if (recentListingsAsync != null) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
                          child: Row(children: [
                            Text('Recently added',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                            Spacer(),
                          ]),
                        ),
                        SizedBox(
                          height: 110,
                          child: recentListingsAsync.when(
                            loading: () => const _HorizontalSkeletons(),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (items) => ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              itemCount: items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (_, i) =>
                                  _RecentChip(listing: items[i]),
                            ),
                          ),
                        ),
                      ],
                      Expanded(
                        child: RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () async {
                            ref.invalidate(catalogSearchProvider);
                            ref.invalidate(catalogSearchResultsProvider);
                            ref.invalidate(categoriesProvider);
                          },
                          child: _buildResultsGrid(results),
                        ),
                      ),
                      if (results.length >= 10)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: TextButton(
                            onPressed: () {
                              final current = ref.read(catalogSearchProvider).page;
                              ref.read(catalogSearchProvider.notifier).setPage(current + 1);
                            },
                            child: const Text('Load more'),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => ref
                  .read(catalogSearchProvider.notifier)
                  .setQuery(value),
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search, color: AppColors.ink3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _showFilters = !_showFilters),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.tune,
                    color: _showFilters ? AppColors.primary : AppColors.ink3,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMostUsedButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFFE85D9A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ref.read(catalogSearchProvider.notifier).setSortBy('most_used');
                ref.invalidate(catalogSearchResultsProvider);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Most Used Services',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(CatalogSearchState searchState) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? [];

    Widget chip({required String id, required String name}) {
      final isSelected = searchState.categoryId == id ||
          (searchState.categoryId == null && id.isEmpty);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilterChip(
          label: Text(name),
          selected: isSelected,
          onSelected: (_) {
            ref
                .read(catalogSearchProvider.notifier)
                .setCategory(id.isEmpty ? null : id);
          },
          backgroundColor: Colors.white,
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.ink2,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.line,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          chip(id: '', name: 'All'),
          ...categories.map((cat) => chip(id: cat.id, name: cat.name)),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(CatalogSearchState searchState) {
    return Container(
      color: AppColors.primarySoft,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price type
            const Text(
              'Price Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _priceTypeButton('ALL', searchState.priceType == 'ALL'),
                const SizedBox(width: 8),
                _priceTypeButton('PER_SERVICE', searchState.priceType == 'PER_SERVICE'),
                const SizedBox(width: 8),
                _priceTypeButton('PER_HOUR', searchState.priceType == 'PER_HOUR'),
                const SizedBox(width: 8),
                _priceTypeButton('NEGOTIABLE', searchState.priceType == 'NEGOTIABLE'),
              ],
            ),
            const SizedBox(height: 24),

            // Price range
            const Text(
              'Price Range',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '€${searchState.minPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '€${searchState.maxPrice.toStringAsFixed(0)}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RangeSlider(
              values: RangeValues(searchState.minPrice, searchState.maxPrice),
              min: 0,
              max: 1000,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.line,
              onChanged: (range) {
                ref.read(catalogSearchProvider.notifier)
                  ..setMinPrice(range.start)
                  ..setMaxPrice(range.end);
              },
            ),
            const SizedBox(height: 24),

            // Sort by
            const Text(
              'Sort By',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              isExpanded: true,
              value: searchState.sortBy,
              items: const [
                DropdownMenuItem(value: 'newest', child: Text('Newest')),
                DropdownMenuItem(value: 'rating', child: Text('Rating')),
                DropdownMenuItem(value: 'price_asc', child: Text('Price ↑')),
                DropdownMenuItem(value: 'price_desc', child: Text('Price ↓')),
                DropdownMenuItem(value: 'popular', child: Text('Popular')),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(catalogSearchProvider.notifier)
                      .setSortBy(value);
                }
              },
              underline: Container(
                height: 1,
                color: AppColors.line,
              ),
            ),
            const SizedBox(height: 24),

            // City
            const Text(
              'City',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _cityController,
              onChanged: (value) => ref
                  .read(catalogSearchProvider.notifier)
                  .setCity(value.isEmpty ? null : value),
              decoration: InputDecoration(
                hintText: 'Enter city',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      setState(() => _showFilters = false);
                      ref.invalidate(catalogSearchResultsProvider);
                    },
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    ref.read(catalogSearchProvider.notifier).resetFilters();
                    _searchController.clear();
                    _cityController.clear();
                    ref.invalidate(catalogSearchResultsProvider);
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceTypeButton(String value, bool selected) {
    final label = switch (value) {
      'ALL' => 'All',
      'PER_SERVICE' => 'Service',
      'PER_HOUR' => 'Hour',
      'NEGOTIABLE' => 'Agree',
      _ => value,
    };

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.line,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => ref
                .read(catalogSearchProvider.notifier)
                .setPriceType(value),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.ink2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsGrid(List<ListingDetailModel> results) {
    if (_gridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.5,
        ),
        itemCount: results.length,
        itemBuilder: (context, index) =>
            CatalogListingCard(listing: results[index]),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: results.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CatalogListingCard(
            listing: results[index],
            horizontal: true,
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.ink3,
          ),
          const SizedBox(height: 16),
          const Text(
            'No services found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.ink3,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.clear),
            label: const Text('Clear Filters'),
            onPressed: () {
              ref.read(catalogSearchProvider.notifier).resetFilters();
              _searchController.clear();
              _cityController.clear();
              ref.invalidate(catalogSearchResultsProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.5,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: AppColors.line,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _HorizontalSkeletons extends StatelessWidget {
  const _HorizontalSkeletons();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, __) => Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppColors.line,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _RecentChip extends StatelessWidget {
  final ListingDetailModel listing;
  const _RecentChip({required this.listing});

  @override
  Widget build(BuildContext context) {
    final photoUrl =
        listing.photoUrls.isNotEmpty ? listing.photoUrls.first : null;

    return GestureDetector(
      onTap: () => context.push('/listings/${listing.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 140,
          height: 100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (photoUrl != null)
                CachedNetworkImage(
                  imageUrl: photoUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: AppColors.primarySoft),
                  errorWidget: (_, __, ___) =>
                      Container(color: AppColors.primarySoft),
                )
              else
                Container(color: AppColors.primarySoft),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Text(
                  listing.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
