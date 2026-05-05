import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../listing/data/models/category_model.dart';
import '../../listing/data/models/nearby_listing_model.dart';
import '../../listing/domain/listing_providers.dart';
import '../../listing/presentation/widgets/service_card.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  String? _selectedListingId;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      var permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (!mounted) return;
      ref
          .read(mapSearchParamsProvider.notifier)
          .updateLocation(position.latitude, position.longitude);
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        13.0,
      );
    } catch (_) {
      // Keep default Paris coordinates
    }
  }

  Future<void> _moveToMyLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (!mounted) return;
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        14.0,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final params = ref.watch(mapSearchParamsProvider);
    final listingsAsync = ref.watch(nearbyListingsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    final listings = listingsAsync.valueOrNull ?? const [];

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(params.lat, params.lng),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.localpro.app',
              ),
              MarkerLayer(
                markers: listings
                    .where((l) => l.lat != null && l.lng != null)
                    .map(
                      (l) => Marker(
                        point: LatLng(l.lat!, l.lng!),
                        width: 76,
                        height: 36,
                        child: _PriceMarker(
                          listing: l,
                          isSelected: _selectedListingId == l.id,
                          onTap: () =>
                              setState(() => _selectedListingId = l.id),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),

          // Top controls overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SearchBar(
                      radiusKm: params.radiusKm,
                      onRadiusChanged: (r) => ref
                          .read(mapSearchParamsProvider.notifier)
                          .updateRadius(r),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: categoriesAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (cats) => _CategoryChipsRow(
                        categories: cats,
                        selectedId: params.categoryId,
                        onSelected: (id) => ref
                            .read(mapSearchParamsProvider.notifier)
                            .updateCategory(id),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Draggable bottom sheet
          DraggableScrollableSheet(
            minChildSize: 0.13,
            maxChildSize: 0.6,
            initialChildSize: 0.13,
            snap: true,
            snapSizes: const [0.13, 0.4, 0.6],
            builder: (ctx, scrollController) => _BottomSheet(
              scrollController: scrollController,
              listingsAsync: listingsAsync,
              onRetry: () => ref.invalidate(nearbyListingsProvider),
            ),
          ),

          // My-location FAB above collapsed sheet
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.15,
            child: FloatingActionButton.small(
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: _moveToMyLocation,
              child: const Icon(
                Icons.my_location,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom sheet ──────────────────────────────────────────────────────────────

class _BottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final AsyncValue<List<NearbyListingModel>> listingsAsync;
  final VoidCallback onRetry;

  const _BottomSheet({
    required this.scrollController,
    required this.listingsAsync,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: listingsAsync.when(
              loading: () => _SkeletonRow(),
              error: (e, _) => AppErrorWidget(
                message: 'Failed to load listings',
                onRetry: onRetry,
              ),
              data: (listings) => _ListingsContent(listings: listings),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingsContent extends StatelessWidget {
  final List<NearbyListingModel> listings;
  const _ListingsContent({required this.listings});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${listings.length} service${listings.length == 1 ? '' : 's'} found',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (listings.isEmpty)
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Center(
              child: Text(
                'No services found in this area.\nTry increasing the search radius.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          SizedBox(
            height: 256,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: listings.length,
              itemBuilder: (_, i) => ServiceCard(listing: listings[i]),
            ),
          ),
      ],
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          LoadingSkeleton(width: 240, height: 220, borderRadius: 12),
          const SizedBox(width: 12),
          LoadingSkeleton(width: 240, height: 220, borderRadius: 12),
        ],
      ),
    );
  }
}

// ── Price marker ──────────────────────────────────────────────────────────────

class _PriceMarker extends StatelessWidget {
  final NearbyListingModel listing;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriceMarker({
    required this.listing,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = listing.price != null
        ? '\$${listing.price!.toStringAsFixed(0)}'
        : 'Free';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final double radiusKm;
  final ValueChanged<double> onRadiusChanged;

  const _SearchBar({required this.radiusKm, required this.onRadiusChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Search services...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ),
          _RadiusDropdown(
            radiusKm: radiusKm,
            onChanged: onRadiusChanged,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _RadiusDropdown extends StatelessWidget {
  final double radiusKm;
  final ValueChanged<double> onChanged;

  static const _options = [0.5, 1.0, 2.0, 5.0, 10.0, 25.0];

  const _RadiusDropdown({required this.radiusKm, required this.onChanged});

  String _label(double r) =>
      r < 1 ? '${r.toStringAsFixed(1)} km' : '${r.toStringAsFixed(0)} km';

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      initialValue: radiusKm,
      onSelected: onChanged,
      itemBuilder: (_) => _options
          .map(
            (r) => PopupMenuItem<double>(
              value: r,
              child: Text(_label(r)),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _label(radiusKm),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.expand_more,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category chips row ────────────────────────────────────────────────────────

class _CategoryChipsRow extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  const _CategoryChipsRow({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _FilterChip(
          label: 'All',
          isSelected: selectedId == null,
          onTap: () => onSelected(null),
        ),
        ...categories.map(
          (cat) => _FilterChip(
            label: cat.name,
            isSelected: selectedId == cat.id,
            onTap: () => onSelected(cat.id),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
