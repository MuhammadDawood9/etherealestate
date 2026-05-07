import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/local_database_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Seller Profile Sheet
// ═══════════════════════════════════════════════════════════════════════════════

class SellerProfileSheet extends StatefulWidget {
  const SellerProfileSheet({super.key});

  @override
  State<SellerProfileSheet> createState() => _SellerProfileSheetState();
}

class _SellerProfileSheetState extends State<SellerProfileSheet> {
  late final TextEditingController _agency;
  late final TextEditingController _phone;
  late final TextEditingController _bio;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _agency = TextEditingController();
    _phone  = TextEditingController();
    _bio    = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _agency.dispose();
    _phone.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final db     = LocalDatabaseService();
    final agency = await db.getPreference('seller_agency', defaultValue: '');
    final phone  = await db.getPreference('seller_phone',  defaultValue: '');
    final bio    = await db.getPreference('seller_bio',    defaultValue: '');
    if (!mounted) return;
    setState(() {
      _agency.text = agency ?? '';
      _phone.text  = phone  ?? '';
      _bio.text    = bio    ?? '';
      _loading     = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = LocalDatabaseService();
    await db.setPreference('seller_agency', _agency.text.trim());
    await db.setPreference('seller_phone',  _phone.text.trim());
    await db.setPreference('seller_bio',    _bio.text.trim());
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(_snack('Profile saved.'));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Drag handle ───────────────────────────────────────
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // ── Title ─────────────────────────────────────────────
                  Text(
                    'Seller Profile',
                    style: GoogleFonts.manrope(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // ── Fields ────────────────────────────────────────────
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: CircularProgressIndicator(
                          color: Color(0xFF4C54B6),
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else ...[
                    _Field(
                      label: 'AGENCY NAME',
                      hint: 'e.g. Prime Properties Lahore',
                      ctrl: _agency,
                      icon: Icons.business_outlined,
                    ),
                    _Field(
                      label: 'PHONE',
                      hint: '+92 300 0000000',
                      ctrl: _phone,
                      icon: Icons.phone_outlined,
                      type: TextInputType.phone,
                    ),
                    _Field(
                      label: 'BIO / ABOUT',
                      hint: 'Tell buyers about yourself and your agency...',
                      ctrl: _bio,
                      icon: Icons.info_outline,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    _PrimaryBtn(
                      label: 'SAVE PROFILE',
                      onTap: _saving ? null : _save,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Field ────────────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController ctrl;
  final IconData icon;
  final TextInputType type;
  final int maxLines;

  const _Field({
    required this.label,
    required this.hint,
    required this.ctrl,
    required this.icon,
    this.type = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: Colors.black45,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: TextField(
              controller: ctrl,
              keyboardType: type,
              maxLines: maxLines,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.only(top: maxLines > 1 ? 12 : 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    widthFactor: 1,
                    heightFactor: maxLines > 1 ? 1 : null,
                    child: Icon(icon, color: const Color(0xFF4C54B6), size: 20),
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black26,
                ),
              ),
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _PrimaryBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.black38,
          disabledForegroundColor: Colors.white60,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ─── Snack Bar ────────────────────────────────────────────────────────────────

SnackBar _snack(String msg) => SnackBar(
      content: Text(msg, style: GoogleFonts.inter()),
      backgroundColor: const Color(0xFF4C54B6),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
