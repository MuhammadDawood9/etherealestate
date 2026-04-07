import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingCalendarScreen extends StatelessWidget {
  const BookingCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _buildMeshGradient(),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 40),
                  _buildTitleSection(),
                  const SizedBox(height: 40),
                  _buildCalendarSection(),
                  const SizedBox(height: 32),
                  _buildTimeSlotsSection(),
                  const SizedBox(height: 32),
                  _buildCuratorCard(),
                  const SizedBox(height: 40),
                  _buildConfirmButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
        ),
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDL0Y0J2KpsnlX7GxDXYB6uYuPcirKJ8ak0IahylAMlSbuexuMRBnLXLraDkfpbX-_KtkxFyAeWa3AJHl8TDT8kiSaAdZZvPENo0It6DhD7n8WqCc8LV3NueFnOfpopf-iVFkpT4-4-eCC7p8lpYlPMGi-5HTyGRbszWrYtKqO80OjWyn-Iv32iNiVy8TvPD36Gkxm1oghLbhwjufN7GWcOkLb0pbSzS_WGONJJtr6JSXzhg4Y3DrRFCPRyVPC2TGCOzk4r6Jhl6KU'),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RESERVE YOUR TOUR',
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
            color: const Color(0xFF4C54B6),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'The Pearl Pavilion',
          style: GoogleFonts.manrope(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, size: 14, color: Colors.black38),
            const SizedBox(width: 4),
            Text(
              '102 Azure Drive, South Kensington',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('October 2024', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _buildCalendarNav(Icons.chevron_left),
                  const SizedBox(width: 8),
                  _buildCalendarNav(Icons.chevron_right),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarNav(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: Colors.black54),
    );
  }

  Widget _buildCalendarGrid() {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((d) => Expanded(
            child: Text(d, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black26, letterSpacing: 1)),
          )).toList(),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8),
          itemCount: 31,
          itemBuilder: (context, index) {
            final day = index + 1;
            final isSelected = day == 16;
            final isToday = day == 12;
            
            return Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : (isToday ? const Color(0xFF4C54B6).withOpacity(0.1) : Colors.transparent),
                  shape: BoxShape.circle,
                  border: isToday ? Border.all(color: const Color(0xFF4C54B6).withOpacity(0.2)) : null,
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : (day < 12 ? Colors.black26 : Colors.black87),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeSlotsSection() {
    final slots = ['09:00 AM', '10:30 AM', '01:00 PM', '02:30 PM', '04:00 PM'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AVAILABLE SLOTS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.black45)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: slots.map((s) => _buildTimeChip(s, s == '01:00 PM')).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeChip(String time, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF4C54B6) : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: isSelected ? Colors.transparent : Colors.black.withOpacity(0.05)),
        boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF4C54B6).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
      ),
      child: Text(
        time,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildCuratorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDMPNRdCXrVZuEFZORYiGS7Ys9gHCOTAw5g3Z0FtzoHO5f6sfPk8gUi_GdBGzBroQP7rIZP-2A8jkyl94KUhopFVyDvi1x9Ek2XVnf7rItz0WKiP5RqfPHQCBSsOqi0h48FeAsx7KMsbxCEHtJw_6HkykZACEYMcyiGHZhoq3K7pTbSptYZzAr0sWy_7VjoCWoROXgmsxman5cjNLF7R2nXodJeYrDOZYcAvFv5rp-OsJibkTmUorPoBF1-5YZZQSMaNcgmJO1UNgI'),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('YOUR CURATOR', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF4C54B6), letterSpacing: 1)),
              Text('Elara Vance', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF4C54B6).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF4C54B6), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Text(
          'CONFIRM VIEWING',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildMeshGradient() {
    return Stack(
      children: [
        Positioned(top: 0, left: 0, child: _GradientSphere(color: const Color(0xFFF3F4F5))),
        Positioned(top: 0, right: 0, child: _GradientSphere(color: const Color(0xFFE0E0FF).withOpacity(0.5))),
        Positioned(bottom: 0, right: 0, child: _GradientSphere(color: const Color(0xFFF8F9FA))),
        Positioned(bottom: 0, left: 0, child: _GradientSphere(color: const Color(0xFFDEE2ED))),
      ],
    );
  }
}

class _GradientSphere extends StatelessWidget {
  final Color color;
  const _GradientSphere({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      height: 600,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
          radius: 0.8,
        ),
      ),
    );
  }
}
