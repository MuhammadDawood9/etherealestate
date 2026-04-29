import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/filter_criteria.dart';

class SearchFilterScreen extends StatefulWidget {
  final FilterCriteria initial;

  // ✅ CORRECT (Remove the 'const' keyword)
  SearchFilterScreen({super.key, this.initial = FilterCriteria.defaults});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  late RangeValues _priceRange;
  late String _selectedType;
  late String _selectedBedrooms;

  @override
  void initState() {
    super.initState();
    // 1. FIX: RangeValues requires non-null doubles. We provide defaults here.
    _priceRange = RangeValues(
        widget.initial.minPrice ?? 500000.0,
        widget.initial.maxPrice ?? 10000000.0
    );

    // 2. FIX: Align UI local state with Model fields
    _selectedType = widget.initial.propertyType ?? 'All';

    // Convert int? from model to String for UI buttons
    final beds = widget.initial.minBeds;
    if (beds == null) {
      _selectedBedrooms = 'Any';
    } else if (beds >= 4) {
      _selectedBedrooms = '4+';
    } else {
      _selectedBedrooms = beds.toString();
    }
  }

  void _reset() => setState(() {
    _priceRange = const RangeValues(500000, 10000000);
    _selectedType = 'All';
    _selectedBedrooms = 'Any';
  });

  void _apply() {
    // 3. FIX: Convert UI state back to Model types before popping
    int? bedValue;
    if (_selectedBedrooms != 'Any') {
      bedValue = int.tryParse(_selectedBedrooms.replaceAll('+', ''));
    }

    Navigator.pop(
      context,
      FilterCriteria(
        propertyType: _selectedType == 'All' ? null : _selectedType,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        minBeds: bedValue,
        query: widget.initial.query, // Preserve existing search text
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 16),
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Search Filters',
                            style: GoogleFonts.manrope(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5)),
                        TextButton(
                          onPressed: _reset,
                          child: Text('Reset All',
                              style: GoogleFonts.inter(
                                  color: const Color(0xFF4C54B6),
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildLabel('PROPERTY TYPE'),
                    const SizedBox(height: 16),
                    _buildSegmentedControl(['All', 'Villa', 'Coastal', 'Penthouse', 'Off-Grid']),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('PRICE RANGE'),
                        Text(
                          'Rs. ${(_priceRange.start / 100000).toStringAsFixed(1)}L — Rs. ${(_priceRange.end / 1000000).toStringAsFixed(1)}M',
                          style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4C54B6),
                              fontSize: 16),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: _priceRange,
                      min: 500000,
                      max: 15000000,
                      activeColor: const Color(0xFF4C54B6),
                      inactiveColor: Colors.black.withValues(alpha: 0.05),
                      onChanged: (v) => setState(() => _priceRange = v),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('500K',
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black26)),
                        Text('15M+',
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black26)),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildLabel('BEDROOMS'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ['Any', '1', '2', '3', '4+']
                          .map(_buildBedroomButton)
                          .toList(),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: _apply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: Text('APPLY FILTERS',
                            style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Helpers (buildLabel, buildSegmentedControl, buildBedroomButton) remain same ---
  // Ensure you use .withOpacity() instead of .withValues() for maximum compatibility with current Windows stable.

  Widget _buildLabel(String label) => Text(label,
      style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: Colors.black45));

  Widget _buildSegmentedControl(List<String> options) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final isSelected = _selectedType == option;
          return GestureDetector(
            onTap: () => setState(() => _selectedType = option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.black.withValues(alpha: 0.08),
                ),
              ),
              child: Text(option,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black54)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBedroomButton(String text) {
    final isSelected = _selectedBedrooms == text;
    return GestureDetector(
      onTap: () => setState(() => _selectedBedrooms = text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4C54B6) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? const Color(0xFF4C54B6) : Colors.black.withValues(alpha: 0.1),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
                color: const Color(0xFF4C54B6).withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ]
              : [],
        ),
        child: Center(
          child: Text(text,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black45)),
        ),
      ),
    );
  }
}