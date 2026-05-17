import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../data/models/listing_request_model.dart';
import '../domain/listing_providers.dart';
import 'widgets/listing_form_helpers.dart';

class EditListingScreen extends ConsumerStatefulWidget {
  final String listingId;
  const EditListingScreen({super.key, required this.listingId});

  @override
  ConsumerState<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends ConsumerState<EditListingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  // Step 2
  late PriceType _priceType;
  late TextEditingController _priceController;

  // Step 3
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  double? _selectedLat;
  double? _selectedLng;

  // Step 4
  late List<String> _photoUrls;

  // Step 5
  late List<String> _customQuestions;
  late TextEditingController _questionController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _photoUrls = [];
    _customQuestions = [];
    _questionController = TextEditingController();
    _priceType = PriceType.perService;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _initializeFromListing(dynamic listing) {
    _titleController.text = listing.title;
    _descriptionController.text = listing.description ?? '';
    _selectedCategoryId = listing.categoryId;
    _selectedCategoryName = listing.categoryName;
    _priceType = listing.priceType;
    if (listing.price != null) {
      _priceController.text = listing.price.toString();
    }
    _addressController.text = listing.address ?? '';
    _cityController.text = listing.city ?? '';
    _photoUrls = List.from(listing.photoUrls);
    _customQuestions = List.from(listing.customQuestions);
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

  void _onNextStep() {
    switch (_currentStep) {
      case 0:
        _validateStep1AndNext();
      case 1:
      case 2:
      case 3:
      case 4:
        _goToPage(_currentStep + 1);
      case 5:
        _submitListing();
      default:
        break;
    }
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
    if (_priceType == PriceType.negotiable) return 'By Agreement';
    final text = _priceController.text.trim();
    if (text.isEmpty) return 'Price varies';
    final p = double.tryParse(text);
    if (p == null) return 'Price varies';
    return switch (_priceType) {
      PriceType.perHour => '€${text}/hr',
      PriceType.perService => '€$text',
      _ => '€$text',
    };
  }

  List<String> _getQuestionSuggestions() {
    if (_selectedCategoryName == null) return [];
    return switch (_selectedCategoryName!.toLowerCase()) {
      'cleaning' => [
        'How many m² is your apartment?',
        'How many rooms?',
        'Do you have cleaning supplies?',
      ],
      'plumbing' => [
        'Is it urgent?',
        'What is the issue?',
        'How old is the plumbing?',
      ],
      'tutoring' => [
        'What level? (beginner/intermediate/advanced)',
        'What subject?',
        'Student age?',
      ],
      'beauty' => [
        'At home or salon?',
        'Any allergies?',
        'Preferred time?',
      ],
      'repairs' => [
        'What needs to be repaired?',
        'How urgent?',
        'Approximate size?',
      ],
      'moving' => [
        'How many rooms?',
        'Distance in km?',
        'Do you need packing help?',
      ],
      'photography' => [
        'What type of shoot?',
        'Location preference?',
        'How many hours?',
      ],
      'it' => [
        'What device?',
        'What is the problem?',
        'Is data recovery needed?',
      ],
      _ => [],
    };
  }

  void _addQuestion() {
    final q = _questionController.text.trim();
    if (q.isEmpty) return;

    if (_customQuestions.contains(q)) {
      _showSnackBar('Question already added');
      return;
    }

    if (_customQuestions.length >= 5) {
      _showSnackBar('Maximum 5 questions allowed', color: AppColors.error);
      return;
    }

    setState(() {
      _customQuestions.add(q);
      _questionController.clear();
    });
  }

  Future<void> _deletePhoto(String photoUrl) async {
    final photoId = photoUrl.split('/').last;
    try {
      await ref
          .read(listingRepositoryProvider)
          .deletePhoto(widget.listingId, photoId);
      setState(() => _photoUrls.removeWhere((url) => url == photoUrl));
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error deleting photo: ${e.toString()}',
            color: AppColors.error);
      }
    }
  }

  Future<void> _submitListing() async {
    setState(() => _isSubmitting = true);
    try {
      final request = ListingRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
        price: _priceController.text.isEmpty
            ? null
            : double.tryParse(_priceController.text),
        priceType: _priceType,
        latitude: _selectedLat ?? 35.1856,
        longitude: _selectedLng ?? 33.3823,
        photoUrls: _photoUrls,
        customQuestions: _customQuestions,
      );
      await ref
          .read(listingRepositoryProvider)
          .updateListing(widget.listingId, request);
      if (!mounted) return;

      ref.invalidate(listingDetailProvider(widget.listingId));
      ref.invalidate(myListingsProvider);
      context.pop();
      _showSnackBar('Listing updated successfully');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error: ${e.toString()}', color: AppColors.error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.listingId));

    return listingAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Edit Service')),
        body: AppErrorWidget(
          message: 'Failed to load listing.',
          onRetry: () =>
              ref.invalidate(listingDetailProvider(widget.listingId)),
        ),
      ),
      data: (listing) {
        if (_titleController.text.isEmpty) {
          _initializeFromListing(listing);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Service'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/map'),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / 6,
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
              _buildStep4Photos(),
              _buildStep5Questions(),
              _buildStep6Review(),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => _goToPage(_currentStep - 1),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(80, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _onNextStep,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _currentStep == 5
                          ? (_isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ))
                          : const Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
            'Step 1 of 5',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          const ListingFormLabel('Service title *'),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            maxLength: 255,
            decoration: const InputDecoration(
              hintText: 'e.g. Professional Plumbing Repair',
            ),
          ),
          const SizedBox(height: 16),
          const ListingFormLabel('Category *'),
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
          const ListingFormLabel('Description'),
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
        ],
      ),
    );
  }

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
            'Step 2 of 5',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          const ListingFormLabel('Price type'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ListingPriceTypeButton(
                label: 'Per Service',
                value: PriceType.perService,
                selected: _priceType == PriceType.perService,
                onTap: () => setState(() => _priceType = PriceType.perService),
              ),
              ListingPriceTypeButton(
                label: 'Per Hour',
                value: PriceType.perHour,
                selected: _priceType == PriceType.perHour,
                onTap: () => setState(() => _priceType = PriceType.perHour),
              ),
              ListingPriceTypeButton(
                label: 'By Agreement',
                value: PriceType.negotiable,
                selected: _priceType == PriceType.negotiable,
                onTap: () =>
                    setState(() => _priceType = PriceType.negotiable),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_priceType != PriceType.negotiable) ...[
            const ListingFormLabel('Price (€)'),
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
                prefixText: '€ ',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Leave empty if price varies',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

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
            'Step 3 of 5',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          const ListingFormLabel('City'),
          const SizedBox(height: 8),
          TextField(
            controller: _cityController,
            decoration: const InputDecoration(hintText: 'e.g. Paris'),
          ),
          const SizedBox(height: 16),
          const ListingFormLabel('Address'),
          const SizedBox(height: 8),
          TextField(
            controller: _addressController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Street address (optional)',
            ),
          ),
          const SizedBox(height: 16),
          const ListingFormLabel('Pin your location on map'),
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
              child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      _selectedLat ?? 35.1856,
                      _selectedLng ?? 33.3823,
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
                  ]),
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
        ],
      ),
    );
  }

  Widget _buildStep4Photos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manage photos',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Step 4 of 6',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          if (_photoUrls.isEmpty)
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.border,
                  style: BorderStyle.solid,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF5F5F5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera,
                    size: 32,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No photos yet',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _photoUrls.map((photoUrl) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: photoUrl,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.shimmerBase,
                          width: 90,
                          height: 90,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.shimmerBase,
                          width: 90,
                          height: 90,
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -8,
                      right: -8,
                      child: GestureDetector(
                        onTap: () => _deletePhoto(photoUrl),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          if (_photoUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '${_photoUrls.length} photos',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep5Questions() {
    final suggestions = _getQuestionSuggestions();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Custom questions',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Step 5 of 6',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          const ListingFormLabel('Questions for your customers'),
          const SizedBox(height: 12),
          TextField(
            controller: _questionController,
            maxLines: 1,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _addQuestion(),
            decoration: InputDecoration(
              hintText: 'e.g. How many rooms?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: Color(0xFF1B5E63),
                ),
                onPressed: _customQuestions.length >= 5 ? null : _addQuestion,
                tooltip: 'Add question',
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_customQuestions.isNotEmpty) ...[
            const ListingFormLabel('Your questions'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _customQuestions.asMap().entries.map((e) {
                return Chip(
                  label: Text(e.value),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () =>
                      setState(() => _customQuestions.removeAt(e.key)),
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.1),
                  side: const BorderSide(color: Color(0xFF1B5E63)),
                  labelStyle: const TextStyle(color: Color(0xFF1B5E63)),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.border.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No questions added yet',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          if (suggestions.isNotEmpty) ...[
            const ListingFormLabel('Quick add'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions.map((q) {
                final alreadyAdded = _customQuestions.contains(q);
                return GestureDetector(
                  onTap: alreadyAdded
                      ? null
                      : () {
                          if (_customQuestions.length >= 5) {
                            _showSnackBar('Maximum 5 questions allowed',
                                color: AppColors.error);
                          } else {
                            setState(() => _customQuestions.add(q));
                          }
                        },
                  child: Chip(
                    label: Text(
                      q,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.08),
                    side: BorderSide(
                      color: AppColors.primary,
                      width: alreadyAdded ? 0 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: alreadyAdded
                          ? AppColors.textSecondary
                          : AppColors.primary,
                      fontWeight:
                          alreadyAdded ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${_customQuestions.length} / 5 questions added',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1B5E63),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep6Review() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review your changes',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Step 6 of 6',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
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
          if (_customQuestions.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Custom questions:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _customQuestions.map((q) {
                return Chip(
                  label: Text(q, style: const TextStyle(fontSize: 11)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
