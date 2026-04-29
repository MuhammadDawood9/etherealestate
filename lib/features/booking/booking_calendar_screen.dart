import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/booking_model.dart';
import '../../core/models/property_model.dart';
import '../../core/providers/app_providers.dart';
import '../../core/utils/app_snack_bar.dart';

class BookingCalendarScreen extends ConsumerStatefulWidget {
  final PropertyModel property;

  const BookingCalendarScreen({super.key, required this.property});

  @override
  ConsumerState<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends ConsumerState<BookingCalendarScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;

  final List<String> _timeSlots = [
    '09:00 AM', '11:00 AM', '01:00 PM', '03:00 PM', '05:00 PM'
  ];

  Future<void> _handleBooking() async {
    if (_selectedTime == null) {
      AppSnackBar.show(context, 'Please select a time slot.', isError: true);
      return;
    }

    HapticFeedback.mediumImpact();

    // Format date as YYYY-MM-DD for your model's getter
    final dateString = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    final booking = BookingModel(
      id: const Uuid().v4(),
      propertyId: widget.property.id,
      propertyTitle: widget.property.title,
      date: dateString,
      timeSlot: _selectedTime!,
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      await ref.read(bookingControllerProvider.notifier).createBooking(booking);
      if (mounted) _showSuccess();
    } catch (e) {
      if (mounted) AppSnackBar.show(context, 'Booking failed. Try again.', isError: true);
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified, size: 72, color: Color(0xFF4C54B6)),
              const SizedBox(height: 24),
              Text('Booking Confirmed',
                  style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Your visit for ${widget.property.title} has been scheduled.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.black54)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Back to property details
                  },
                  child: const Text('EXCELLENT', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Schedule Visit', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Date', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: CalendarDatePicker(
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                      onDateChanged: (date) => setState(() => _selectedDate = date),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text('Select Time', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: _timeSlots.length,
                    itemBuilder: (context, index) {
                      final time = _timeSlots[index];
                      final isSelected = _selectedTime == time;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTime = time),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF4C54B6) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? const Color(0xFF4C54B6) : Colors.black12),
                          ),
                          child: Center(
                            child: Text(time,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black87)),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VISIT FOR', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38)),
                Text(widget.property.title, style: GoogleFonts.manrope(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _handleBooking,
            child: Text('BOOK NOW', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}