import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/local_database_service.dart';
import '../search/search_home_screen.dart';

class PreferenceWizardScreen extends StatefulWidget {
  const PreferenceWizardScreen({super.key});

  @override
  State<PreferenceWizardScreen> createState() => _PreferenceWizardScreenState();
}

class _PreferenceWizardScreenState extends State<PreferenceWizardScreen> {
  int _step = 0;
  static const int _totalSteps = 3;

  // Step 0
  String? _intent;

  // Step 1
  String? _propertyType;
  String _bedrooms = 'Any';

  // Step 2
  RangeValues _budget = const RangeValues(5000000, 50000000);
  final Set<String> _areas = {};

  final _db = LocalDatabaseService();
  bool _isSaving = false;

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _finish() async {
    setState(() => _isSaving = true);
    await _savePreferences();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SearchHomeScreen()),
    );
  }

  Future<void> _savePreferences() async {
    if (_intent != null) await _db.setPreference('pref_intent', _intent!);
    if (_propertyType != null) await _db.setPreference('pref_property_type', _propertyType!);
    await _db.setPreference('pref_bedrooms', _bedrooms);
    await _db.setPreference('pref_budget_min', _budget.start.toStringAsFixed(0));
    await _db.setPreference('pref_budget_max', _budget.end.toStringAsFixed(0));
    if (_areas.isNotEmpty) await _db.setPreference('pref_areas', _areas.join(','));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _pkrLabel(double v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)} Cr';
    return '${(v / 100000).toStringAsFixed(0)} L';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 12),
                _buildProgressBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(32, 40, 32, 16),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.04),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(_step),
                        child: _buildStep(_step),
                      ),
                    ),
                  ),
                ),
                _buildBottomButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          if (_step > 0)
            IconButton(
              onPressed: _back,
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black54),
            )
          else
            const SizedBox(width: 48),
          const Spacer(),
          Text(
            '${_step + 1} of $_totalSteps',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.black38, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          TextButton(
            onPressed: _isSaving ? null : _finish,
            child: Text(
              'Skip',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.black38, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: List.generate(_totalSteps, (i) {
          final active = i <= _step;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: i < _totalSteps - 1 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF4C54B6)
                    : Colors.black.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0:  return _buildIntentStep();
      case 1:  return _buildPropertyStep();
      default: return _buildBudgetStep();
    }
  }

  // ── Step 0: Intent ─────────────────────────────────────────────────────────

  Widget _buildIntentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What brings\nyou here?',
          style: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1.5, height: 1.1),
        ),
        const SizedBox(height: 12),
        Text(
          "We'll personalise your feed accordingly.",
          style: GoogleFonts.inter(fontSize: 15, color: Colors.black45, height: 1.5),
        ),
        const SizedBox(height: 48),
        _IntentCard(
          label: 'Buy',
          icon: Icons.home_outlined,
          subtitle: 'Find your forever home',
          selected: _intent == 'Buy',
          onTap: () => setState(() => _intent = 'Buy'),
        ),
        _IntentCard(
          label: 'Rent',
          icon: Icons.key_outlined,
          subtitle: 'Looking for a place to stay',
          selected: _intent == 'Rent',
          onTap: () => setState(() => _intent = 'Rent'),
        ),
        _IntentCard(
          label: 'Invest',
          icon: Icons.trending_up_outlined,
          subtitle: 'Building a property portfolio',
          selected: _intent == 'Invest',
          onTap: () => setState(() => _intent = 'Invest'),
        ),
      ],
    );
  }

  // ── Step 1: Property type + bedrooms ───────────────────────────────────────

  Widget _buildPropertyStep() {
    const types = ['House', 'Flat', 'Upper Portion', 'Lower Portion', 'Farm House'];
    const beds = ['Any', '1', '2', '3', '4+'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your ideal\nproperty',
          style: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1.5, height: 1.1),
        ),
        const SizedBox(height: 12),
        Text(
          'Select the type and size you prefer.',
          style: GoogleFonts.inter(fontSize: 15, color: Colors.black45, height: 1.5),
        ),
        const SizedBox(height: 40),
        _WizLabel('PROPERTY TYPE'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: types
              .map((t) => _ChoiceChip(
                    label: t,
                    selected: _propertyType == t,
                    onTap: () => setState(() => _propertyType = _propertyType == t ? null : t),
                  ))
              .toList(),
        ),
        const SizedBox(height: 36),
        _WizLabel('BEDROOMS'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: beds
              .map((b) => _BedButton(
                    label: b,
                    selected: _bedrooms == b,
                    onTap: () => setState(() => _bedrooms = b),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ── Step 2: Budget + areas ─────────────────────────────────────────────────

  Widget _buildBudgetStep() {
    const areas = ['DHA', 'Gulberg', 'Bahria Town', 'Model Town', 'Johar Town', 'Askari', 'Valencia', 'Garden Town', 'Wapda Town', 'Canal Road'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget &\nlocation',
          style: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1.5, height: 1.1),
        ),
        const SizedBox(height: 12),
        Text(
          'Narrow down your search from the start.',
          style: GoogleFonts.inter(fontSize: 15, color: Colors.black45, height: 1.5),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _WizLabel('BUDGET RANGE'),
            Text(
              'Rs. ${_pkrLabel(_budget.start)} — Rs. ${_pkrLabel(_budget.end)}',
              style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700, color: const Color(0xFF4C54B6), fontSize: 14),
            ),
          ],
        ),
        RangeSlider(
          values: _budget,
          min: 5000000,
          max: 200000000,
          activeColor: const Color(0xFF4C54B6),
          inactiveColor: Colors.black.withValues(alpha: 0.06),
          onChanged: (v) => setState(() => _budget = v),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('50 L', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26)),
            Text('20 Cr+', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26)),
          ],
        ),
        const SizedBox(height: 36),
        _WizLabel('PREFERRED AREAS'),
        const SizedBox(height: 6),
        Text('Select all that interest you', style: GoogleFonts.inter(fontSize: 12, color: Colors.black38)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: areas
              .map((a) => _ChoiceChip(
                    label: a,
                    selected: _areas.contains(a),
                    onTap: () => setState(() {
                      if (_areas.contains(a)) {
                        _areas.remove(a);
                      } else {
                        _areas.add(a);
                      }
                    }),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ── Bottom button ──────────────────────────────────────────────────────────

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _next,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  _step == _totalSteps - 1 ? 'GET STARTED' : 'CONTINUE',
                  style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 14),
                ),
        ),
      ),
    );
  }

  // ── Background ─────────────────────────────────────────────────────────────

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(top: 0, left: 0, child: _Sphere(color: const Color(0xFFF0F4FF).withValues(alpha: 0.6))),
        Positioned(top: 0, right: 0, child: _Sphere(color: const Color(0xFFE0E0FF).withValues(alpha: 0.4))),
        Positioned(bottom: 0, left: 0, child: _Sphere(color: const Color(0xFFD6E3FF).withValues(alpha: 0.5))),
        Positioned(bottom: 0, right: 0, child: _Sphere(color: const Color(0xFFF3F4F5).withValues(alpha: 0.3))),
      ],
    );
  }
}

// ─── Reusable Widgets ──────────────────────────────────────────────────────────

class _IntentCard extends StatelessWidget {
  final String label, subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _IntentCard({
    required this.label,
    required this.icon,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4C54B6).withValues(alpha: 0.07)
              : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF4C54B6) : Colors.black.withValues(alpha: 0.06),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF4C54B6).withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: selected ? const Color(0xFF4C54B6) : Colors.black45,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: selected ? const Color(0xFF4C54B6) : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.black45),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: selected ? 1.0 : 0.0,
              child: const Icon(Icons.check_circle, color: Color(0xFF4C54B6), size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4C54B6) : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF4C54B6) : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _BedButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BedButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4C54B6) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? const Color(0xFF4C54B6) : Colors.black.withValues(alpha: 0.1),
            width: 2,
          ),
          boxShadow: selected
              ? [BoxShadow(color: const Color(0xFF4C54B6).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black45,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _WizLabel extends StatelessWidget {
  final String text;
  const _WizLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.inter(
            fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.black45),
      );
}

class _Sphere extends StatelessWidget {
  final Color color;
  const _Sphere({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 500,
      decoration: BoxDecoration(
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)], radius: 0.8),
      ),
    );
  }
}
