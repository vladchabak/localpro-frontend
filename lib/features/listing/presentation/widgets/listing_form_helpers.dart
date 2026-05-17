import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/listing_request_model.dart';

class ListingFormLabel extends StatelessWidget {
  final String text;
  const ListingFormLabel(this.text);

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

class ListingPriceTypeButton extends StatelessWidget {
  final String label;
  final PriceType value;
  final bool selected;
  final VoidCallback onTap;

  const ListingPriceTypeButton({
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
