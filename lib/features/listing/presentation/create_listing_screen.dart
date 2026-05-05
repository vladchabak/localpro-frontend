import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/listing_providers.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  // Step 2
  String _priceType = 'FROM';
  final _priceController = TextEditingController();

  // Step 3
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  double? _selectedLat;
  double? _selectedLng;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final categoriesAsync = ref.watch(categoriesProvider);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select a category',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: categoriesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(
                      child: Text('Failed to load categories')),
                  data: (categories) => ListView.builder(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    itemBuilder: (_, i) {
                      final cat = categories[i];
                      return ListTile(
                        leading: const Icon(
                          Icons.category_outlined,
                          color: AppColors.primary,
                        ),
                        title: Text(cat.name),
                        trailing: _selectedCategoryId == cat.id
                            ? const Icon(
                                Icons.check,
                                color: AppColors.primary,
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = cat.id;
                            _selectedCategoryName = cat.name;
                          });
                          Navigator.of(ctx).pop();
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  void _validateStep1AndNext() {
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Please enter a title');
      return;
    }
    if (_selectedCategoryId == null) {
      _showSnackBar('Please select a category');
      return;
    }
    _goToPage(1);
  }

  void _showSnackBar(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _buildPriceLabel() {
    final text = _priceController.text.trim();
    if (text.isEmpty) return 'Price varies';
    final p = double.tryParse(text);
    if (p == null) return 'Price varies';
    return switch (_priceType) {
      'HOURLY' => '\$${text}/hr',
      'FROM' => 'from \$$text',
      _ => '\$$text',
    };
  }

  Future<void> _submitListing() async {
    setState(() => _isSubmitting = true);
    try {
      final data = <String, dynamic>{
        'title': _titleController.text.trim(),
        if (_descriptionController.text.trim().isNotEmpty)
          'description': _descriptionController.text.trim(),
        'categoryId': _selectedCategoryId,
        'priceType': _priceType,
        if (_priceController.text.isNotEmpty)
          'price': double.tryParse(_priceController.text),
        if (_selectedLat != null) 'lat': _selectedLat,
        if (_selectedLng != null) 'lng': _selectedLng,
        if (_addressController.text.trim().isNotEmpty)
          'address': _addressController.text.trim(),
        if (_cityController.text.trim().isNotEmpty)
          'city': _cityController.text.trim(),
      };
      final listing =
          await ref.read(listingRepositoryProvider).createListing(data);
      if (!mounted) return;
      ref.invalidate(nearbyListingsProvider);
      ref.invalidate(myListingsProvider);
      _showSnackBar(
        'Listing "${listing.title}" published!',
        color: AppColors.success,
      );
      context.go('/map');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error: ${e.toString()}', color: AppColors.error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Service'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/map'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            backgroundColor: AppColors.border,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _currentStep = i),
        children: [
          _buildStep1(),
          _buildStep2(),
          _buildStep3(),
          _buildStep4(),
        ],
      ),
    );
  }

  // Step 1 — Basic Info
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about your service',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Step 1 of 4',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          const _Label('Service title *'),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            maxLength: 255,
            decoration: const InputDecoration(
              hintText: 'e.g. Professional Plumbing Repair',
            ),
          ),
          const SizedBox(height: 16),
          const _Label('Category *'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showCategoryPicker,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedCategoryName ?? 'Select a category',
                    style: TextStyle(
                      color: _selectedCategoryName != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _Label('Description'),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: 'Describe your service in detail...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _validateStep1AndNext,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  // Step 2 — Pricing
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set your price',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Step 2 of 4',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          const _Label('Price type'),
          const SizedBox(height: 8),
          Row(
            children: [
              _PriceTypeButton(
                label: 'From',
                value: 'FROM',
                selected: _priceType == 'FROM',
                onTap: () => setState(() => _priceType = 'FROM'),
              ),
              const SizedBox(width: 8),
              _PriceTypeButton(
                label: 'Per hour',
                value: 'HOURLY',
                selected: _priceType == 'HOURLY',
                onTap: () => setState(() => _priceType = 'HOURLY'),
              ),
              const SizedBox(width: 8),
              _PriceTypeButton(
                label: 'Fixed',
                value: 'FIXED',
                selected: _priceType == 'FIXED',
                onTap: () => setState(() => _priceType = 'FIXED'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _Label('Price (USD)'),
          const SizedBox(height: 8),
          TextField(
            controller: _priceController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: const InputDecoration(
              hintText: '0.00',
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Leave empty if price varies',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => _goToPage(0),
                child: const Text('Back'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _goToPage(2),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Step 3 — Location
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Where do you work?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Step 3 of 4',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          const _Label('City'),
          const SizedBox(height: 8),
          TextField(
            controller: _cityController,
            decoration: const InputDecoration(hintText: 'e.g. Paris'),
          ),
          const SizedBox(height: 16),
          const _Label('Address'),
          const SizedBox(height: 8),
          TextField(
            controller: _addressController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Street address (optional)',
            ),
          ),
          const SizedBox(height: 16),
          const _Label('Pin your location on map'),
          const SizedBox(height: 4),
          const Text(
            'Tap the map to set your service location',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      _selectedLat ?? 48.8566,
                      _selectedLng ?? 2.3522,
                    ),
                    initialZoom: 12,
                    onTap: (_, point) => setState(() {
                      _selectedLat = point.latitude;
                      _selectedLng = point.longitude;
                    }),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.localpro.app',
                    ),
                    if (_selectedLat != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_selectedLat!, _selectedLng!),
                            child: const Icon(
                              Icons.location_pin,
                              color: AppColors.primary,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (_selectedLat != null) ...[
            const SizedBox(height: 8),
            Text(
              'Location set: ${_selectedLat!.toStringAsFixed(4)}, '
              '${_selectedLng!.toStringAsFixed(4)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => _goToPage(1),
                child: const Text('Back'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _goToPage(3),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Step 4 — Review & Submit
  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review your listing',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Step 4 of 4',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Preview card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleController.text.isEmpty
                      ? '(no title)'
                      : _titleController.text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedCategoryName != null) ...[
                  const SizedBox(height: 6),
                  Chip(
                    label: Text(
                      _selectedCategoryName!,
                      style: const TextStyle(fontSize: 12),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                  ),
                ],
                if (_priceController.text.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    _buildPriceLabel(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (_cityController.text.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _cityController.text,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (_descriptionController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _descriptionController.text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Photos: coming soon (Phase 5)',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              OutlinedButton(
                onPressed: _isSubmitting ? null : () => _goToPage(2),
                child: const Text('Back'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitListing,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text('Publish listing'),
            ),
          ),
        ],
      ),
    );
  }
}

// Shared helpers

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );
}

class _PriceTypeButton extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _PriceTypeButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
