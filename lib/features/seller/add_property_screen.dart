import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/local_database_service.dart';
import '../../core/services/auth_service.dart';

class AddPropertyScreen extends StatefulWidget {
  final Map<String, dynamic>? existingListing;
  const AddPropertyScreen({super.key, this.existingListing});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = LocalDatabaseService();
  final _auth = AuthService();
  final _picker = ImagePicker();

  bool _saving = false;
  String _priceHint = '';
  final List<File> _selectedImages = [];

  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _bedsCtrl = TextEditingController();
  final _bathsCtrl = TextEditingController();
  final _sqftCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _category = 'House';
  static const _categories = ['House', 'Flat', 'Upper Portion', 'Farm House', 'Plot'];

  bool get _isEditing => widget.existingListing != null;

  @override
  void initState() {
    super.initState();
    _priceCtrl.addListener(_updatePriceHint);
    if (_isEditing) _prefillFromExisting();
  }

  void _prefillFromExisting() {
    final l = widget.existingListing!;
    _titleCtrl.text = l['title'] as String? ?? '';
    _locationCtrl.text = l['location'] as String? ?? '';
    _priceCtrl.text = (l['price'] as String? ?? '').replaceFirst('PKR ', '');
    _bedsCtrl.text = l['beds'] as String? ?? '';
    _bathsCtrl.text = l['baths'] as String? ?? '';
    _sqftCtrl.text = l['sqft'] as String? ?? '';
    _descCtrl.text = l['description'] as String? ?? '';
    _category = l['category'] as String? ?? 'House';

    final paths = (l['image_paths'] as String? ?? '').split(',').where((s) => s.isNotEmpty);
    for (final path in paths) {
      final file = File(path);
      if (file.existsSync()) _selectedImages.add(file);
    }
  }

  void _updatePriceHint() {
    final raw = _priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) { if (mounted) setState(() => _priceHint = ''); return; }
    final n = int.tryParse(raw) ?? 0;
    String hint = '';
    if (n >= 10000000) {
      hint = '≈ ${(n / 10000000).toStringAsFixed(2)} Cr';
    } else if (n >= 100000) {
      hint = '≈ ${(n / 100000).toStringAsFixed(1)} L';
    }
    if (mounted) setState(() => _priceHint = hint);
  }

  @override
  void dispose() {
    _priceCtrl.removeListener(_updatePriceHint);
    _titleCtrl.dispose(); _locationCtrl.dispose(); _priceCtrl.dispose();
    _bedsCtrl.dispose(); _bathsCtrl.dispose(); _sqftCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 85, maxWidth: 1400);
    if (picked.isNotEmpty && mounted) {
      setState(() {
        for (final xf in picked) {
          if (_selectedImages.length < 5) { _selectedImages.add(File(xf.path)); }
        }
      });
    }
  }

  void _removeImage(int index) => setState(() => _selectedImages.removeAt(index));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final bedsEmpty = _bedsCtrl.text.trim().isEmpty;
    final bathsEmpty = _bathsCtrl.text.trim().isEmpty;
    final sqftEmpty = _sqftCtrl.text.trim().isEmpty;
    if (bedsEmpty || bathsEmpty || sqftEmpty) {
      final missing = [if (bedsEmpty) 'Beds', if (bathsEmpty) 'Baths', if (sqftEmpty) 'Sqft'].join(', ');
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Incomplete Details', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
          content: Text('$missing left blank. Buyers won\'t see full specs. Continue anyway?', style: GoogleFonts.inter(color: Colors.black54)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Fix it', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF4C54B6)))),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
              child: Text('Continue', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() => _saving = true);

    final priceRaw = _priceCtrl.text.trim();
    final formattedPrice = priceRaw.startsWith('PKR') ? priceRaw : 'PKR $priceRaw';
    final imagePaths = _selectedImages.map((f) => f.path).join(',');
    final coverPath = _selectedImages.isNotEmpty ? _selectedImages.first.path : '';

    final data = {
      'title': _titleCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'price': formattedPrice,
      'imageUrl': coverPath,
      'image_paths': imagePaths,
      'beds': _bedsCtrl.text.trim(),
      'baths': _bathsCtrl.text.trim(),
      'sqft': _sqftCtrl.text.trim(),
      'category': _category,
      'description': _descCtrl.text.trim(),
      'seller_uid': _auth.currentUser?.uid ?? '',
    };

    if (_isEditing) {
      await _db.updateSellerListing(widget.existingListing!['id'] as String, data);
    } else {
      await _db.addSellerListing({'id': DateTime.now().millisecondsSinceEpoch.toString(), 'status': 'available', ...data});
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                      children: [
                        _buildImagePicker(),
                        const SizedBox(height: 24),
                        _buildField('PROPERTY TITLE', 'e.g. Modern Villa DHA Phase 5', _titleCtrl, required: true),
                        const SizedBox(height: 20),
                        _buildField('LOCATION', 'e.g. DHA Phase 5, Lahore', _locationCtrl, required: true),
                        const SizedBox(height: 20),
                        _buildPriceField(),
                        const SizedBox(height: 20),
                        _buildCategoryPicker(),
                        const SizedBox(height: 20),
                        Row(children: [
                          Expanded(child: _buildField('BEDS', '3', _bedsCtrl, keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildField('BATHS', '2', _bathsCtrl, keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildField('SQFT', '2200', _sqftCtrl, keyboardType: TextInputType.number)),
                        ]),
                        const SizedBox(height: 20),
                        _buildField('DESCRIPTION (optional)', 'Describe the property...', _descCtrl, maxLines: 4),
                        const SizedBox(height: 32),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('PRICE (PKR)', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.black45)),
      const SizedBox(height: 8),
      TextFormField(
        controller: _priceCtrl,
        keyboardType: TextInputType.number,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        decoration: InputDecoration(
          hintText: 'e.g. 25000000',
          hintStyle: GoogleFonts.inter(color: Colors.black26, fontSize: 14),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.75),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: Color(0xFF4C54B6), width: 2)),
          errorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: Colors.redAccent)),
          focusedErrorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: Colors.redAccent, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          suffixIcon: _priceHint.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Chip(
                    label: Text(_priceHint, style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF4C54B6))),
                    backgroundColor: const Color(0xFF4C54B6).withValues(alpha: 0.08),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
              : null,
        ),
      ),
    ]);
  }

  Widget _buildImagePicker() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('PHOTOS', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.black45)),
        const SizedBox(width: 8),
        Text('(up to 5)', style: GoogleFonts.inter(fontSize: 9, color: Colors.black26, letterSpacing: 0.5)),
      ]),
      const SizedBox(height: 10),
      if (_selectedImages.isEmpty) _buildPickerPlaceholder() else _buildImageGrid(),
    ]);
  }

  Widget _buildPickerPlaceholder() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF4C54B6).withValues(alpha: 0.25), width: 1.5),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF4C54B6).withValues(alpha: 0.08), shape: BoxShape.circle),
            child: const Icon(Icons.add_photo_alternate_outlined, size: 32, color: Color(0xFF4C54B6)),
          ),
          const SizedBox(height: 12),
          Text('Tap to add photos', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF4C54B6))),
          const SizedBox(height: 4),
          Text('Choose from your gallery', style: GoogleFonts.inter(fontSize: 12, color: Colors.black38)),
        ]),
      ),
    );
  }

  Widget _buildImageGrid() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length + (_selectedImages.length < 5 ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == _selectedImages.length) {
            return GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 100,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF4C54B6).withValues(alpha: 0.2)),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.add_photo_alternate_outlined, size: 24, color: Color(0xFF4C54B6)),
                  const SizedBox(height: 4),
                  Text('Add more', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF4C54B6), fontWeight: FontWeight.w600)),
                ]),
              ),
            );
          }
          return Stack(children: [
            Container(
              width: 100,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: DecorationImage(image: FileImage(_selectedImages[i]), fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 4, right: 14,
              child: GestureDetector(
                onTap: () => _removeImage(i),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
              ),
            ),
            if (i == 0)
              Positioned(
                bottom: 6, left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                  child: Text('COVER', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                ),
              ),
          ]);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_back, size: 20),
          ),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_isEditing ? 'Edit Property' : 'Add Property', style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          Text(_isEditing ? 'Update listing details' : 'Fill in the details below', style: GoogleFonts.inter(fontSize: 12, color: Colors.black45)),
        ]),
      ]),
    );
  }

  Widget _buildField(
    String label, String hint, TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = false,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.black45)),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.black26, fontSize: 14),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.75),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: Color(0xFF4C54B6), width: 2)),
          errorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: Colors.redAccent)),
          focusedErrorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: Colors.redAccent, width: 2)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 14 : 13),
        ),
      ),
    ]);
  }

  Widget _buildCategoryPicker() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('CATEGORY', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.black45)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: _categories.map((cat) {
          final selected = cat == _category;
          return GestureDetector(
            onTap: () => setState(() => _category = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF4C54B6) : Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selected ? const Color(0xFF4C54B6) : Colors.black.withValues(alpha: 0.08)),
              ),
              child: Text(cat, style: GoogleFonts.inter(fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? Colors.white : Colors.black54)),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity, height: 60,
      child: ElevatedButton(
        onPressed: _saving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 0,
        ),
        child: _saving
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(
                _isEditing ? 'UPDATE LISTING' : 'LIST PROPERTY',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 14),
              ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(children: [
      Positioned(top: 0, right: 0, child: _Sphere(color: const Color(0xFFE0E0FF).withValues(alpha: 0.3))),
      Positioned(bottom: 0, left: 0, child: _Sphere(color: const Color(0xFFF3F4F5))),
    ]);
  }
}

class _Sphere extends StatelessWidget {
  final Color color;
  const _Sphere({required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: 450, height: 450,
    decoration: BoxDecoration(gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)], radius: 0.8)),
  );
}
