import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class InAppTimePicker {
  static Future<DateTime?> show(BuildContext context) async {
    return showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) => const _TimePickerModal(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.paper,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
    );
  }
}

class _TimePickerModal extends StatefulWidget {
  const _TimePickerModal();

  @override
  State<_TimePickerModal> createState() => _TimePickerModalState();
}

class _TimePickerModalState extends State<_TimePickerModal> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final Set<String> _bookedSlots = {'09:00', '14:30', '16:45'};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _selectedTime = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Drag handle
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          child: Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Choose time slot',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Date picker row (fixed height)
        _DateRow(
          selectedDate: _selectedDate,
          onDateSelected: (date) => setState(() => _selectedDate = date),
        ),

        const SizedBox(height: 20),

        // Time slot grid (scrollable)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _TimeSlotGrid(
              selectedTime: _selectedTime,
              bookedSlots: _bookedSlots,
              onTimeSelected: (time) => setState(() => _selectedTime = time),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Confirm button (fixed at bottom)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                final scheduledAt = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                );
                Navigator.pop(context, scheduledAt);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Select this time',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _DateRow({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index + 1));
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _DateChip(
              date: date,
              isSelected: isSelected,
              onTap: () => onDateSelected(date),
            ),
          );
        },
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateChip({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = dayNames[date.weekday % 7];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.line,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.ink3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSlotGrid extends StatelessWidget {
  final TimeOfDay selectedTime;
  final Set<String> bookedSlots;
  final ValueChanged<TimeOfDay> onTimeSelected;

  const _TimeSlotGrid({
    required this.selectedTime,
    required this.bookedSlots,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final timeSlots = _generateTimeSlots();

    return GridView.builder(
      shrinkWrap: false,
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final time = timeSlots[index];
        final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        final isBooked = bookedSlots.contains(timeString);
        final isSelected = selectedTime.hour == time.hour && selectedTime.minute == time.minute;

        return _TimeSlot(
          timeString: timeString,
          isBooked: isBooked,
          isSelected: isSelected,
          onTap: isBooked ? null : () => onTimeSelected(time),
        );
      },
    );
  }

  List<TimeOfDay> _generateTimeSlots() {
    final slots = <TimeOfDay>[];
    for (int hour = 8; hour <= 20; hour++) {
      for (int minute = 0; minute < 60; minute += 15) {
        slots.add(TimeOfDay(hour: hour, minute: minute));
      }
    }
    return slots;
  }
}

class _TimeSlot extends StatelessWidget {
  final String timeString;
  final bool isBooked;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TimeSlot({
    required this.timeString,
    required this.isBooked,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: isBooked
                ? AppColors.line
                : isSelected
                    ? AppColors.primary
                    : AppColors.ok.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isBooked
                  ? AppColors.line
                  : isSelected
                      ? AppColors.primary
                      : AppColors.ok,
            ),
          ),
          child: Center(
            child: Text(
              timeString,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isBooked
                    ? AppColors.ink3
                    : isSelected
                        ? Colors.white
                        : AppColors.ok,
                decoration: isBooked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
