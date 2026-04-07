import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  RangeValues _currentRangeValues = const RangeValues(1200000, 5800000);
  String _selectedType = 'All';
  String _selectedBedrooms = '1';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 16),
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
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
                        Text(
                          'Search Filters',
                          style: GoogleFonts.manrope(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _currentRangeValues = const RangeValues(1200000, 5800000);
                              _selectedType = 'All';
                              _selectedBedrooms = '1';
                            });
                          },
                          child: Text(
                            'Reset All',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF4C54B6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Property Type
                    _buildSectionLabel('PROPERTY TYPE'),
                    const SizedBox(height: 16),
                    _buildSegmentedControl(['All', 'House', 'Villa', 'Condo']),
                    const SizedBox(height: 40),

                    // Price Range
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionLabel('PRICE RANGE'),
                        Text(
                          '\$${(_currentRangeValues.start / 1000000).toStringAsFixed(1)}M - \$${(_currentRangeValues.end / 1000000).toStringAsFixed(1)}M',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4C54B6),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: _currentRangeValues,
                      min: 500000,
                      max: 10000000,
                      activeColor: const Color(0xFF4C54B6),
                      inactiveColor: Colors.black.withOpacity(0.05),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _currentRangeValues = values;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$500K', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26)),
                        Text('\$10M+', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26)),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Bedrooms
                    _buildSectionLabel('BEDROOMS'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ['Any', '1', '2', '3', '4+'].map((type) => _buildBedroomButton(type)).toList(),
                    ),
                    const SizedBox(height: 48),

                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: Text(
                          'APPLY FILTERS',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            fontSize: 14,
                          ),
                        ),
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

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: Colors.black45,
      ),
    );
  }

  Widget _buildSegmentedControl(List<String> options) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = _selectedType == option;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : [],
                ),
                child: Text(
                  option,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.black : Colors.black45,
                  ),
                ),
              ),
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
          border: Border.all(color: isSelected ? const Color(0xFF4C54B6) : Colors.black.withOpacity(0.1), width: 2),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF4C54B6).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))] : [],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black45,
            ),
          ),
        ),
      ),
    );
  }
}
