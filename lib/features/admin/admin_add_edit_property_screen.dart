import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/admin_service.dart';

class AdminAddEditPropertyScreen extends StatefulWidget {
  final Map<String, dynamic>? existing;
  const AdminAddEditPropertyScreen({super.key, this.existing});

  @override
  State<AdminAddEditPropertyScreen> createState() =>
      _AdminAddEditPropertyScreenState();
}

class _AdminAddEditPropertyScreenState
    extends State<AdminAddEditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _featured = false;

  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _price;
  late final TextEditingController _imageUrl;
  late final TextEditingController _beds;
  late final TextEditingController _baths;
  late final TextEditingController _sqft;
  late final TextEditingController _category;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final d = widget.existing ?? {};
    _title    = TextEditingController(text: d['title']    as String? ?? '');
    _location = TextEditingController(text: d['location'] as String? ?? '');
    _price    = TextEditingController(text: d['price']    as String? ?? '');
    _imageUrl = TextEditingController(text: d['imageUrl'] as String? ?? '');
    _beds     = TextEditingController(text: d['beds']     as String? ?? '');
    _baths    = TextEditingController(text: d['baths']    as String? ?? '');
    _sqft     = TextEditingController(text: d['sqft']     as String? ?? '');
    _category = TextEditingController(text: d['category'] as String? ?? '');
    _featured = d['featured'] as bool? ?? false;
  }

  @override
  void dispose() {
    for (final c in [
      _title, _location, _price, _imageUrl,
      _beds, _baths, _sqft, _category,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await AdminService().saveProperty(
        {
          'title':    _title.text.trim(),
          'location': _location.text.trim(),
          'price':    _price.text.trim(),
          'imageUrl': _imageUrl.text.trim(),
          'beds':     _beds.text.trim(),
          'baths':    _baths.text.trim(),
          'sqft':     _sqft.text.trim(),
          'category': _category.text.trim(),
          'featured': _featured,
        },
        existingId: widget.existing?['id'] as String?,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060E1E),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _field('Title', _title, required: true),
                      _field('Location', _location, required: true),
                      _field('Price (e.g. \$4,250,000)', _price, required: true),
                      _field('Image URL', _imageUrl, required: true,
                          hint: 'https://...'),
                      Row(children: [
                        Expanded(child: _field('Beds', _beds, required: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _field('Baths', _baths, required: true)),
                      ]),
                      Row(children: [
                        Expanded(child: _field('Sqft', _sqft, required: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _field('Category', _category)),
                      ]),
                      const SizedBox(height: 8),
                      _buildFeaturedToggle(),
                      const SizedBox(height: 32),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white70, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _isEditing ? 'Edit Property' : 'Add Property',
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool required = false,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white38,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  GoogleFonts.inter(color: Colors.white24, fontSize: 14),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: const Color(0xFF7B84FF).withValues(alpha: 0.5)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: required
                ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _featured
                ? const Color(0xFFFFBE76).withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_outline,
              color: Color(0xFFFFBE76), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Featured Listing',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text('Shown in the Featured Curations section',
                    style: GoogleFonts.inter(
                        color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: _featured,
            onChanged: (v) => setState(() => _featured = v),
            activeThumbColor: const Color(0xFFFFBE76),
            activeTrackColor:
                const Color(0xFFFFBE76).withValues(alpha: 0.3),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            inactiveThumbColor: Colors.white38,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B84FF),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFF7B84FF).withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(
                _isEditing ? 'SAVE CHANGES' : 'ADD PROPERTY',
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800, letterSpacing: 1),
              ),
      ),
    );
  }
}
