import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/nearby_listing_model.dart';

class ServiceCard extends StatelessWidget {
  final NearbyListingModel listing;

  const ServiceCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final price = listing.price;
    final priceText = price != null
        ? '€${price.toStringAsFixed(0)}'
        : 'Free';
    final priceUnit = price != null
        ? (listing.priceType == 'HOURLY' ? '/hr' : '/visit')
        : '';

    return GestureDetector(
      onTap: () => context.push('/listings/${listing.id}'),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0E1A1F).withValues(alpha: 0.04), blurRadius: 2),
            BoxShadow(color: const Color(0xFF0E1A1F).withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PhotoThumb(photoUrls: listing.photoUrls, swatch: AppColors.primarySoft),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + verified badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.providerName,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: AppColors.ink),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const _VerifiedBadge(),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      listing.title,
                      style: const TextStyle(fontSize: 13, color: AppColors.ink2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Rating + distance
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 12, color: AppColors.star),
                        const SizedBox(width: 3),
                        Text(
                          listing.providerRating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink),
                        ),
                        const SizedBox(width: 4),
                        Container(width: 3, height: 3, decoration: const BoxDecoration(color: AppColors.ink3, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.distanceLabel,
                            style: const TextStyle(fontSize: 12, color: AppColors.ink3),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Available + price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const _AvailableDot(),
                        const SizedBox(width: 4),
                        const Expanded(
                          child: Text(
                            'Available today',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: priceText,
                                style: GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: AppColors.ink),
                              ),
                              TextSpan(
                                text: priceUnit,
                                style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.ink3),
                              ),
                            ],
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

class _PhotoThumb extends StatelessWidget {
  final List<String> photoUrls;
  final Color swatch;
  const _PhotoThumb({required this.photoUrls, required this.swatch});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 84, height: 84,
        child: photoUrls.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: photoUrls.first,
                fit: BoxFit.cover,
                placeholder: (_, __) => _placeholder(),
                errorWidget: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.primarySoft,
    child: const Center(
      child: Icon(Icons.home_repair_service, size: 32, color: AppColors.primary),
    ),
  );
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) => const Icon(
    Icons.verified,
    size: 14,
    color: AppColors.primary,
  );
}

class _AvailableDot extends StatelessWidget {
  const _AvailableDot();

  @override
  Widget build(BuildContext context) => Container(
    width: 6, height: 6,
    decoration: const BoxDecoration(color: AppColors.ok, shape: BoxShape.circle),
  );
}
