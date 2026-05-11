import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../chat/domain/chat_providers.dart';
import '../data/models/listing_detail_model.dart';
import '../data/models/listing_request_model.dart';
import '../domain/listing_providers.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const ListingDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  int _currentPhotoIndex = 0;

  String _priceLabel(ListingDetailModel listing) {
    if (listing.priceType == PriceType.negotiable) return 'By Agreement';
    if (listing.price == null) return 'Price varies';
    final p = listing.price!.toStringAsFixed(0);
    return switch (listing.priceType) {
      PriceType.perHour => '€$p/hr',
      PriceType.perService => '€$p',
      PriceType.negotiable => 'By Agreement',
    };
  }

  String _getPriceTypeLabel(PriceType priceType) {
    return switch (priceType) {
      PriceType.perService => 'Per Service',
      PriceType.perHour => 'Per Hour',
      PriceType.negotiable => 'By Agreement',
    };
  }

  Future<void> _startChat(
      BuildContext context, ListingDetailModel listing) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
    try {
      final chat = await ref.read(chatRepositoryProvider).startChat(
            providerId: listing.providerId,
            listingId: listing.id,
          );
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ref.invalidate(chatsProvider);
      context.push('/chats/${chat.id}', extra: listing.title);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.id));

    return listingAsync.when(
      loading: () => const _LoadingScreen(),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: 'Failed to load listing.',
          onRetry: () => ref.invalidate(listingDetailProvider(widget.id)),
        ),
      ),
      data: (listing) => _buildScreen(listing),
    );
  }

  Widget _buildScreen(ListingDetailModel listing) {
    final priceLabel = _priceLabel(listing);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(listing),
              SliverToBoxAdapter(child: _buildContent(listing, priceLabel)),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomBar(
              priceLabel: priceLabel,
              onContact: () => _startChat(context, listing),
              listing: listing,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ListingDetailModel listing) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => context.canPop() ? context.pop() : context.go('/map'),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.share_outlined,
                color: AppColors.textPrimary,
              ),
              onPressed: () {},
            ),
          ),
        ),
      ],
      title: Text(
        listing.title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _PhotoArea(
          photoUrls: listing.photoUrls,
          currentIndex: _currentPhotoIndex,
          onPageChanged: (i) => setState(() => _currentPhotoIndex = i),
        ),
      ),
    );
  }

  Widget _buildContent(ListingDetailModel listing, String priceLabel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Section 1 — Title + badges
          Text(
            listing.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Badge(listing.categoryName),
              if (listing.city != null) ...[
                const SizedBox(width: 8),
                _Badge(listing.city!),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.visibility_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${listing.viewCount} views',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const Divider(height: 32),

          // Section 2 — Provider
          Row(
            children: [
              _ProviderAvatar(
                avatarUrl: listing.providerAvatarUrl,
                name: listing.providerName,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.providerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          listing.providerRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          ' · ${listing.reviewCount} reviews',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View profile',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),

          const Divider(height: 32),

          // Section 3 — Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    priceLabel,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getPriceTypeLabel(listing.priceType),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Section 4 — Description
          if (listing.description != null) ...[
            const Divider(height: 32),
            const Text(
              'About this service',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _ExpandableText(text: listing.description!),
          ],

          // Section 5 — Location
          if (listing.address != null) ...[
            const Divider(height: 32),
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    listing.address!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const Divider(height: 32),

          // Section 6 — Reviews
          const Text(
            'Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (listing.reviewCount == 0)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No reviews yet',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            Text(
              '${listing.reviewCount} reviews  ★ ${listing.rating?.toStringAsFixed(1) ?? '-'}',
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),

          // Space for bottom bar
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// Photo area with PageView

class _PhotoArea extends StatelessWidget {
  final List<String> photoUrls;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const _PhotoArea({
    required this.photoUrls,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrls.isEmpty) {
      return Container(
        color: const Color(0xFF444444),
        child: const Center(
          child: Icon(
            Icons.home_repair_service,
            size: 64,
            color: Colors.white,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: photoUrls.length,
          onPageChanged: onPageChanged,
          itemBuilder: (_, i) => CachedNetworkImage(
            imageUrl: photoUrls[i],
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: AppColors.shimmerBase),
            errorWidget: (_, __, ___) => Container(
              color: const Color(0xFF444444),
              child: const Icon(
                Icons.broken_image_outlined,
                color: Colors.white54,
                size: 48,
              ),
            ),
          ),
        ),
        if (photoUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                photoUrls.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == currentIndex ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == currentIndex
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Provider avatar

class _ProviderAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;

  const _ProviderAvatar({required this.avatarUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: CachedNetworkImageProvider(avatarUrl!),
      );
    }
    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// Category / city badge

class _Badge extends StatelessWidget {
  final String label;
  const _Badge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// Expandable description

class _ExpandableText extends StatefulWidget {
  final String text;

  const _ExpandableText({required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  static const int _maxChars = 150;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isLong = widget.text.length > _maxChars;
    String truncateAtWord() {
      final boundary = widget.text.lastIndexOf(' ', _maxChars);
      final cutAt = boundary > 0 ? boundary : _maxChars;
      return '${widget.text.substring(0, cutAt)}...';
    }
    final displayText = _expanded || !isLong ? widget.text : truncateAtWord();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayText,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        if (isLong) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Show less' : 'Show more',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Bottom action bar

class _BottomBar extends StatelessWidget {
  final String priceLabel;
  final VoidCallback onContact;
  final ListingDetailModel listing;

  const _BottomBar({required this.priceLabel, required this.onContact, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Price', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(priceLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 140,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onContact,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.card, foregroundColor: AppColors.ink),
                      child: const Text('Contact'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => context.push('/booking', extra: listing),
                  child: const Text('Book Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Loading skeleton

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          LoadingSkeleton(
            width: double.infinity,
            height: 320,
            borderRadius: 0,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LoadingSkeleton(width: double.infinity, height: 28),
                const SizedBox(height: 12),
                const LoadingSkeleton(width: 200, height: 20),
                const SizedBox(height: 24),
                Row(
                  children: const [
                    LoadingSkeleton(width: 56, height: 56, borderRadius: 28),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LoadingSkeleton(width: 140, height: 18),
                        SizedBox(height: 6),
                        LoadingSkeleton(width: 100, height: 14),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
