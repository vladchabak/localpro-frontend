import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/nearby_listing_model.dart';

class ServiceCard extends StatelessWidget {
  final NearbyListingModel listing;

  const ServiceCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final priceText = listing.price != null
        ? '\$${listing.price!.toStringAsFixed(0)}'
            '${listing.priceType == 'HOURLY' ? '/hr' : ''}'
        : 'Free';

    return GestureDetector(
      onTap: () => context.push('/listings/${listing.id}'),
      child: Container(
        width: 240,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _PhotoArea(photoUrls: listing.photoUrls),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CategoryBadge(name: listing.categoryName),
                      const Spacer(),
                      Text(
                        listing.distanceLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    listing.providerName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        priceText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Color(0xFFFFC107),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        listing.providerRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
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
    );
  }
}

class _PhotoArea extends StatelessWidget {
  final List<String> photoUrls;
  const _PhotoArea({required this.photoUrls});

  @override
  Widget build(BuildContext context) {
    if (photoUrls.isNotEmpty) {
      return SizedBox(
        height: 120,
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: photoUrls.first,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: AppColors.shimmerBase),
          errorWidget: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return SizedBox(height: 120, width: double.infinity, child: _placeholder());
  }

  Widget _placeholder() => Container(
        color: AppColors.shimmerBase,
        child: const Center(
          child: Icon(
            Icons.home_repair_service,
            size: 40,
            color: AppColors.textSecondary,
          ),
        ),
      );
}

class _CategoryBadge extends StatelessWidget {
  final String name;
  const _CategoryBadge({required this.name});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          name,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      );
}
