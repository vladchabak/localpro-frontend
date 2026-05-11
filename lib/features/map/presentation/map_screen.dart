import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../listing/data/models/category_model.dart';
import '../../listing/data/models/nearby_listing_model.dart';
import '../../listing/domain/listing_providers.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with SingleTickerProviderStateMixin {
  final _mapController = MapController();
  String? _selectedListingId;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _initLocation();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      var permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Location permission denied — showing default area')),
          );
        }
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
      // Keep default Nicosia coordinates on GPS failure
    }
  }

  Future<void> _moveToMyLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (!mounted) return;
      _mapController.move(LatLng(position.latitude, position.longitude), 14.0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final params = ref.watch(mapSearchParamsProvider);
    final listingsAsync = ref.watch(nearbyListingsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final listings = listingsAsync.valueOrNull ?? const [];

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Stack(
        children: [
          // ── Full-screen map ──────────────────────────────────────────────
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
                    .map((l) => Marker(
                          point: LatLng(l.lat!, l.lng!),
                          width: 82,
                          height: 40,
                          child: _PriceMarker(
                            listing: l,
                            isSelected: _selectedListingId == l.id,
                            onTap: () =>
                                setState(() => _selectedListingId = l.id),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),

          // ── Gradient bleed – bottom of map into sheet ────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 180,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.paper.withValues(alpha: 0),
                      AppColors.paper.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Top glass overlay ────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _GlassSearchBar(
                      radiusKm: params.radiusKm,
                      onRadiusChanged: (r) => ref
                          .read(mapSearchParamsProvider.notifier)
                          .updateRadius(r),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 38,
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
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),

          // ── Draggable bottom sheet ───────────────────────────────────────
          DraggableScrollableSheet(
            minChildSize: 0.14,
            maxChildSize: 0.65,
            initialChildSize: 0.14,
            snap: true,
            snapSizes: const [0.14, 0.42, 0.65],
            builder: (ctx, scrollController) => _BottomSheet(
              scrollController: scrollController,
              listingsAsync: listingsAsync,
              pulseAnim: _pulseAnim,
              onRetry: () => ref.invalidate(nearbyListingsProvider),
            ),
          ),

          // ── Action FABs ──────────────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.16 + 64,
            child: _MapFab(
              icon: Icons.add_rounded,
              color: AppColors.primary,
              iconColor: Colors.white,
              onTap: () => context.push('/provider/listings/create'),
            ),
          ),
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.16 + 12,
            child: _MapFab(
              icon: Icons.my_location_rounded,
              color: Colors.white,
              iconColor: AppColors.ink,
              onTap: _moveToMyLocation,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Glass search bar ──────────────────────────────────────────────────────────

class _GlassSearchBar extends StatelessWidget {
  final double radiusKm;
  final ValueChanged<double> onRadiusChanged;

  const _GlassSearchBar(
      {required this.radiusKm, required this.onRadiusChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/catalog'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0E1A1F).withValues(alpha: 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.search_rounded,
                      color: Colors.white, size: 17),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'What service do you need?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.ink3,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Container(width: 1, height: 20, color: AppColors.line),
                const SizedBox(width: 10),
                _RadiusDropdown(radiusKm: radiusKm, onChanged: onRadiusChanged),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
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
          .map((r) =>
              PopupMenuItem<double>(value: r, child: Text(_label(r))))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _label(radiusKm),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.expand_more_rounded,
                size: 15, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

// ── Category chips ────────────────────────────────────────────────────────────

const _kCategoryEmoji = {
  'cleaning': '🧹',
  'plumbing': '🔧',
  'tutoring': '📚',
  'beauty': '💅',
  'repairs': '🛠',
  'moving': '📦',
  'photography': '📷',
  'it': '💻',
  'cooking': '🍳',
  'fitness': '💪',
  'gardening': '🌿',
  'electrical': '⚡',
};

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
        _CategoryChip(
          label: 'All',
          emoji: '🗺',
          isSelected: selectedId == null,
          onTap: () => onSelected(null),
        ),
        ...categories.map((cat) {
          final emoji =
              _kCategoryEmoji[cat.name.toLowerCase()] ?? '✨';
          return _CategoryChip(
            label: cat.name,
            emoji: emoji,
            isSelected: selectedId == cat.id,
            onTap: () => onSelected(cat.id),
          );
        }),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.28)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet ──────────────────────────────────────────────────────────────

class _BottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final AsyncValue<List<NearbyListingModel>> listingsAsync;
  final Animation<double> pulseAnim;
  final VoidCallback onRetry;

  const _BottomSheet({
    required this.scrollController,
    required this.listingsAsync,
    required this.pulseAnim,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A0E1A1F),
            blurRadius: 40,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          // ── Drag handle ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: listingsAsync.when(
              loading: () => _SkeletonContent(),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: AppErrorWidget(
                  message: 'Failed to load listings',
                  onRetry: onRetry,
                ),
              ),
              data: (listings) => _SheetContent(
                listings: listings,
                pulseAnim: pulseAnim,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetContent extends StatelessWidget {
  final List<NearbyListingModel> listings;
  final Animation<double> pulseAnim;

  const _SheetContent({required this.listings, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Center(
          child: Column(
            children: [
              Text('🔍', style: TextStyle(fontSize: 36)),
              SizedBox(height: 12),
              Text(
                'No services in this area',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink),
              ),
              SizedBox(height: 6),
              Text(
                'Try expanding the radius or a different category.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.ink3),
              ),
            ],
          ),
        ),
      );
    }

    final hero = listings.first;
    final rest = listings.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Live availability badge ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: pulseAnim,
                          builder: (_, __) => Opacity(
                            opacity: pulseAnim.value,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.ok,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          '${listings.length} pros available now',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Sorted by distance · ready to book',
                      style: TextStyle(fontSize: 12, color: AppColors.ink3),
                    ),
                  ],
                ),
              ),
              _ViewAllButton(),
            ],
          ),
        ),

        // ── Hero card ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: _HeroServiceCard(listing: hero),
        ),

        // ── "More nearby" label + horizontal scroll ─────────────────────
        if (rest.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 0, 10),
            child: Text(
              'More nearby',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink2),
            ),
          ),
          SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: rest.length,
              itemBuilder: (_, i) => _CompactServiceCard(listing: rest[i]),
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Hero card ─────────────────────────────────────────────────────────────────

class _HeroServiceCard extends StatelessWidget {
  final NearbyListingModel listing;
  const _HeroServiceCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final priceText =
        listing.price != null ? '€${listing.price!.toStringAsFixed(0)}' : 'Free';
    final priceUnit = listing.price != null
        ? (listing.priceType == 'PER_HOUR' ? '/hr' : '')
        : '';

    return GestureDetector(
      onTap: () => context.push('/listings/${listing.id}'),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0E1A1F).withValues(alpha: 0.05),
              blurRadius: 4,
            ),
            BoxShadow(
              color: const Color(0xFF0E1A1F).withValues(alpha: 0.07),
              blurRadius: 32,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Photo
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(22)),
              child: SizedBox(
                width: 120,
                height: double.infinity,
                child: listing.photoUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: listing.photoUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _heroPlaceholder(),
                        errorWidget: (_, __, ___) => _heroPlaceholder(),
                      )
                    : _heroPlaceholder(),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top row: name + verified
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.providerName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: AppColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '✓ Verified',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Service title
                    Text(
                      listing.title,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.ink2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Rating + distance
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 13, color: AppColors.star),
                        const SizedBox(width: 3),
                        Text(
                          listing.providerRating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                              color: AppColors.ink3,
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            listing.distanceLabel,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.ink3),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Price + book button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: priceText,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: AppColors.ink,
                                ),
                              ),
                              TextSpan(
                                text: priceUnit,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.ink3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Book',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroPlaceholder() => Container(
        color: AppColors.primarySoft,
        child: const Center(
          child: Icon(Icons.home_repair_service,
              size: 36, color: AppColors.primary),
        ),
      );
}

// ── Compact card (horizontal scroll) ─────────────────────────────────────────

class _CompactServiceCard extends StatelessWidget {
  final NearbyListingModel listing;
  const _CompactServiceCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final priceText = listing.price != null
        ? '€${listing.price!.toStringAsFixed(0)}'
        : 'Free';

    return GestureDetector(
      onTap: () => context.push('/listings/${listing.id}'),
      child: Container(
        width: 190,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0E1A1F).withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 52,
                  height: 52,
                  color: AppColors.primarySoft,
                  child: listing.photoUrls.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: listing.photoUrls.first,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Icon(
                              Icons.home_repair_service,
                              color: AppColors.primary),
                          errorWidget: (_, __, ___) => const Icon(
                              Icons.home_repair_service,
                              color: AppColors.primary),
                        )
                      : const Icon(Icons.home_repair_service,
                          color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      listing.providerName,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      listing.title,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.ink3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 11, color: AppColors.star),
                        const SizedBox(width: 2),
                        Text(
                          listing.providerRating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink),
                        ),
                        const Spacer(),
                        Text(
                          priceText,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── View all button ───────────────────────────────────────────────────────────

class _ViewAllButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/catalog'),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'See all',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 3),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 11, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _SkeletonContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadingSkeleton(width: 180, height: 22, borderRadius: 6),
          SizedBox(height: 8),
          LoadingSkeleton(width: double.infinity, height: 140, borderRadius: 22),
          SizedBox(height: 12),
          LoadingSkeleton(width: 100, height: 16, borderRadius: 6),
          SizedBox(height: 10),
          Row(
            children: [
              LoadingSkeleton(width: 190, height: 112, borderRadius: 18),
              SizedBox(width: 10),
              LoadingSkeleton(width: 190, height: 112, borderRadius: 18),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Price marker ──────────────────────────────────────────────────────────────

const _kMonoFont = 'JetBrains Mono';

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
        ? '€${listing.price!.toStringAsFixed(0)}'
        : 'Free';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 11,
          vertical: isSelected ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: isSelected
              ? null
              : Border.all(color: AppColors.primary, width: 1.3),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.40)
                  : Colors.black.withValues(alpha: 0.12),
              blurRadius: isSelected ? 18 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: _kMonoFont,
            fontSize: isSelected ? 13 : 11,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ── Map FAB ───────────────────────────────────────────────────────────────────

class _MapFab extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _MapFab({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}
