import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_routes.dart';
import '../../core/providers/admin_providers.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/local_database_service.dart';
import '../../core/services/auth_service.dart';
import '../../shared/user_avatar.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../shared/widgets/app_menu_sheet.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;
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
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 48),
                  _buildProfileHero(context, profile),
                  const SizedBox(height: 48),
                  _buildSettingsSection(
                    'Account',
                    [
                      _SettingsItem(icon: Icons.person_outline,          title: 'Personal Information', onTap: (ctx) => _showPersonalInfoSheet(ctx)),
                      _SettingsItem(icon: Icons.search,                   title: 'Saved Searches',       onTap: (ctx) => Navigator.pushReplacementNamed(ctx, '/search')),
                      _SettingsItem(icon: Icons.account_balance_outlined, title: 'Mortgage Status',      badge: 'ACTIVE', onTap: (ctx) => _showMortgageSheet(ctx)),
                    ],
                    context,
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsSection(
                    'Preferences',
                    [
                      _SettingsItem(icon: Icons.tune,                    title: 'App Preferences',  onTap: (ctx) => _showPreferencesSheet(ctx)),
                      _SettingsItem(icon: Icons.notifications_none,      title: 'Notifications',    onTap: (ctx) => _showNotificationsSheet(ctx)),
                      _SettingsItem(icon: Icons.security_outlined,       title: 'Privacy & Security', onTap: (ctx) => _showPrivacySheet(ctx)),
                    ],
                    context,
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsSection(
                    'Support',
                    [
                      _SettingsItem(icon: Icons.help_outline, title: 'Help Center', onTap: (ctx) => _showHelpSheet(ctx)),
                    ],
                    context,
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 24),
                    _buildAdminSection(context),
                  ],
                  const SizedBox(height: 48),
                  _buildLogoutButton(context),
                  const SizedBox(height: 24),
                  Text('VERSION 1.0.2', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2, color: Colors.black26)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => showAppMenu(context),
          child: const Icon(Icons.menu, color: Colors.black),
        ),
        Text('Ethereal Estate', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black)),
        CircleAvatar(
          radius: 20,
          backgroundImage: userAvatarImage(),
        ),
      ],
    );
  }

  // ── Profile Hero ─────────────────────────────────────────────────────────────

  Widget _buildProfileHero(BuildContext context, UserProfile profile) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFF4C54B6), Color(0xFFB9C7E4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 56,
                  backgroundImage: userAvatarImage(),
                ),
              ),
            ),
            Positioned(
              bottom: 0, right: 0,
              child: GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(_snack('Photo upload coming soon.')),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          profile.displayName.isNotEmpty ? profile.displayName : 'Guest',
          style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1),
        ),
        const SizedBox(height: 4),
        Text(
          'Premium Member • ${profile.location}',
          style: GoogleFonts.inter(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // ── Settings Section ─────────────────────────────────────────────────────────

  Widget _buildSettingsSection(String title, List<_SettingsItem> items, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(children: items.map((item) => _buildListTile(item, context)).toList()),
        ),
      ),
    );
  }

  Widget _buildListTile(_SettingsItem item, BuildContext context) {
    return ListTile(
      onTap: () => item.onTap(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFF4C54B6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(item.icon, color: const Color(0xFF4C54B6), size: 20),
      ),
      title: Text(item.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black87)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF4C54B6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(item.badge!, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF4C54B6), letterSpacing: 1)),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.black26),
        ],
      ),
    );
  }

  // ── Admin ─────────────────────────────────────────────────────────────────────

  Widget _buildAdminSection(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.admin),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1F6E), Color(0xFF0A192F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: const Color(0xFF7B84FF).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF7B84FF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.admin_panel_settings_outlined,
                  color: Color(0xFF7B84FF), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Admin Panel',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B84FF)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ADMIN',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF7B84FF),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Manage properties, bookings & more',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Logout ───────────────────────────────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmLogout(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout, color: Colors.redAccent, size: 20),
            const SizedBox(width: 12),
            Text('Logout', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: Colors.redAccent, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Sign Out', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to sign out of your account?', style: GoogleFonts.inter(color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.black45, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: Text('Sign Out', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Sheet Launchers ──────────────────────────────────────────────────────────

  void _showPersonalInfoSheet(BuildContext context) => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const _PersonalInfoSheet());
  void _showMortgageSheet(BuildContext context)      => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const _MortgageSheet());
  void _showPreferencesSheet(BuildContext context)   => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const _PreferencesSheet());
  void _showNotificationsSheet(BuildContext context) => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const _NotificationsSheet());
  void _showPrivacySheet(BuildContext context)       => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const _PrivacySheet());
  void _showHelpSheet(BuildContext context)          => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const _HelpSheet());

  // ── Background ───────────────────────────────────────────────────────────────

  Widget _buildMeshGradient() {
    return Stack(
      children: [
        Positioned(top: 0, left: 0, child: _GradientSphere(color: const Color(0xFFE0E0FF).withValues(alpha: 0.4))),
        Positioned(top: 0, right: 0, child: _GradientSphere(color: const Color(0xFF8F98FE).withValues(alpha: 0.2))),
        Positioned(bottom: 0, left: 0, right: 0, child: _GradientSphere(color: const Color(0xFFF3F4F5))),
      ],
    );
  }
}

// ─── Data Model ───────────────────────────────────────────────────────────────

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? badge;
  final void Function(BuildContext) onTap;
  _SettingsItem({required this.icon, required this.title, this.badge, required this.onTap});
}

class _GradientSphere extends StatelessWidget {
  final Color color;
  const _GradientSphere({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600, height: 600,
      decoration: BoxDecoration(gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)], radius: 0.8)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Personal Information Sheet
// ═══════════════════════════════════════════════════════════════════════════════

class _PersonalInfoSheet extends ConsumerStatefulWidget {
  const _PersonalInfoSheet();
  @override
  ConsumerState<_PersonalInfoSheet> createState() => _PersonalInfoSheetState();
}

class _PersonalInfoSheetState extends ConsumerState<_PersonalInfoSheet> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _location;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _name = TextEditingController(text: profile.displayName);
    _email = TextEditingController(text: ref.read(currentUserProvider)?.email ?? '');
    _phone = TextEditingController(text: profile.phone);
    _location = TextEditingController(text: profile.location);
  }

  @override
  void dispose() { _name.dispose(); _email.dispose(); _phone.dispose(); _location.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Personal Information',
      child: Column(children: [
        _Field(label: 'FULL NAME',     ctrl: _name,     icon: Icons.person_outline),
        _Field(label: 'EMAIL',         ctrl: _email,    icon: Icons.mail_outline,        type: TextInputType.emailAddress),
        _Field(label: 'PHONE',         ctrl: _phone,    icon: Icons.phone_outlined,      type: TextInputType.phone),
        _Field(label: 'LOCATION',      ctrl: _location, icon: Icons.location_on_outlined),
        const SizedBox(height: 8),
        _PrimaryBtn('SAVE CHANGES', () async {
          ref.read(userProfileProvider.notifier).updateName(_name.text.trim());
          ref.read(userProfileProvider.notifier).updateLocation(_location.text.trim());
          ref.read(userProfileProvider.notifier).updatePhone(_phone.text.trim());
          
          await ref.read(authServiceProvider).updateUserProfile(name: _name.text.trim());
          
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(_snack('Profile updated successfully.'));
          }
        }),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Mortgage Status Sheet (Pakistan Region)
// ═══════════════════════════════════════════════════════════════════════════════

class _MortgageSheet extends StatelessWidget {
  const _MortgageSheet();
  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Mortgage Status',
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF4C54B6).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF4C54B6).withValues(alpha: 0.1)),
          ),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('STATUS', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black38, letterSpacing: 1.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('ACTIVE', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.green, letterSpacing: 1)),
              ),
            ]),
            const SizedBox(height: 20),
            _MRow('Loan Amount',     'PKR 45,000,000'),
            _MRow('Monthly Payment', 'PKR 385,000'),
            _MRow('Interest Rate',   '22.5% p.a. (KIBOR + 3%)'),
            _MRow('Remaining Term',  '18 years'),
            _MRow('Bank',         'HBL (House Building Finance)'),
          ]),
        ),
        const SizedBox(height: 16),
        _PrimaryBtn('CONTACT BANK', () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(_snack('Connecting to HBL Mortgage Division…'));
        }),
      ]),
    );
  }
}

class _MRow extends StatelessWidget {
  final String label, value;
  const _MRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
      Text(value,  style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700)),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// App Preferences Sheet
// ═══════════════════════════════════════════════════════════════════════════════

class _PreferencesSheet extends StatefulWidget {
  const _PreferencesSheet();
  @override
  State<_PreferencesSheet> createState() => _PreferencesSheetState();
}

class _PreferencesSheetState extends State<_PreferencesSheet> {
  String _currency = 'USD';
  String _units    = 'Imperial';
  bool   _compact  = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = LocalDatabaseService();
    final currency = await db.getPreference('pref_currency', defaultValue: 'USD');
    final units    = await db.getPreference('pref_units',    defaultValue: 'Imperial');
    final compact  = await db.getPreference('pref_compact',  defaultValue: 'false');
    setState(() {
      _currency = currency!;
      _units    = units!;
      _compact  = compact == 'true';
    });
  }

  Future<void> _save(BuildContext ctx) async {
    final db = LocalDatabaseService();
    await db.setPreference('pref_currency', _currency);
    await db.setPreference('pref_units',    _units);
    await db.setPreference('pref_compact',  _compact.toString());
    if (!ctx.mounted) return;
    Navigator.pop(ctx);
    ScaffoldMessenger.of(ctx).showSnackBar(_snack('Preferences saved.'));
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'App Preferences',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Label('CURRENCY'),
        const SizedBox(height: 12),
        _Segment(options: ['USD', 'EUR', 'GBP'], selected: _currency, onChanged: (v) => setState(() => _currency = v)),
        const SizedBox(height: 28),
        _Label('MEASUREMENT UNITS'),
        const SizedBox(height: 12),
        _Segment(options: ['Imperial', 'Metric'], selected: _units, onChanged: (v) => setState(() => _units = v)),
        const SizedBox(height: 28),
        _Toggle(label: 'Compact Card View', subtitle: 'Show smaller property cards in feed', value: _compact, onChanged: (v) => setState(() => _compact = v)),
        const SizedBox(height: 16),
        _PrimaryBtn('SAVE PREFERENCES', () => _save(context)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Notifications Sheet
// ═══════════════════════════════════════════════════════════════════════════════

class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet();
  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  bool _listings   = true;
  bool _prices     = true;
  bool _viewings   = true;
  bool _messages   = false;
  bool _newsletter = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = LocalDatabaseService();
    final listings   = await db.getPreference('notif_listings',   defaultValue: 'true');
    final prices     = await db.getPreference('notif_prices',     defaultValue: 'true');
    final viewings   = await db.getPreference('notif_viewings',   defaultValue: 'true');
    final messages   = await db.getPreference('notif_messages',   defaultValue: 'false');
    final newsletter = await db.getPreference('notif_newsletter', defaultValue: 'false');
    setState(() {
      _listings   = listings   == 'true';
      _prices     = prices     == 'true';
      _viewings   = viewings   == 'true';
      _messages   = messages   == 'true';
      _newsletter = newsletter == 'true';
    });
  }

  Future<void> _save(BuildContext ctx) async {
    final db = LocalDatabaseService();
    await db.setPreference('notif_listings',   _listings.toString());
    await db.setPreference('notif_prices',     _prices.toString());
    await db.setPreference('notif_viewings',   _viewings.toString());
    await db.setPreference('notif_messages',   _messages.toString());
    await db.setPreference('notif_newsletter', _newsletter.toString());
    if (!ctx.mounted) return;
    Navigator.pop(ctx);
    ScaffoldMessenger.of(ctx).showSnackBar(_snack('Notification settings saved.'));
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Notifications',
      child: Column(children: [
        _Toggle(label: 'New Listings',      subtitle: 'Properties matching your criteria',   value: _listings,   onChanged: (v) => setState(() => _listings = v)),
        _Toggle(label: 'Price Changes',     subtitle: 'Drops on your saved properties',       value: _prices,     onChanged: (v) => setState(() => _prices = v)),
        _Toggle(label: 'Viewing Reminders', subtitle: 'Alerts before scheduled site visits',  value: _viewings,   onChanged: (v) => setState(() => _viewings = v)),
        _Toggle(label: 'Messages',          subtitle: 'New messages from your curator',        value: _messages,   onChanged: (v) => setState(() => _messages = v)),
        _Toggle(label: 'Newsletter',        subtitle: 'Weekly curated estate digest',          value: _newsletter, onChanged: (v) => setState(() => _newsletter = v)),
        const SizedBox(height: 8),
        _PrimaryBtn('SAVE', () => _save(context)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Privacy & Security Sheet
// ═══════════════════════════════════════════════════════════════════════════════

class _PrivacySheet extends StatefulWidget {
  const _PrivacySheet();
  @override
  State<_PrivacySheet> createState() => _PrivacySheetState();
}

class _PrivacySheetState extends State<_PrivacySheet> {
  bool _twoFactor  = true;
  bool _biometrics = false;
  bool _dataShare  = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = LocalDatabaseService();
    final twoFactor  = await db.getPreference('priv_2fa',         defaultValue: 'true');
    final biometrics = await db.getPreference('priv_biometrics',  defaultValue: 'false');
    final dataShare  = await db.getPreference('priv_datashare',   defaultValue: 'true');
    setState(() {
      _twoFactor  = twoFactor  == 'true';
      _biometrics = biometrics == 'true';
      _dataShare  = dataShare  == 'true';
    });
  }

  Future<void> _save(BuildContext ctx) async {
    final db = LocalDatabaseService();
    await db.setPreference('priv_2fa',        _twoFactor.toString());
    await db.setPreference('priv_biometrics', _biometrics.toString());
    await db.setPreference('priv_datashare',  _dataShare.toString());
    if (!ctx.mounted) return;
    Navigator.pop(ctx);
    ScaffoldMessenger.of(ctx).showSnackBar(_snack('Privacy settings saved.'));
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Privacy & Security',
      child: Column(children: [
        _Toggle(label: 'Two-Factor Auth',        subtitle: 'Require a code when signing in',       value: _twoFactor,  onChanged: (v) => setState(() => _twoFactor = v)),
        _Toggle(label: 'Biometric Login',        subtitle: 'Use Face ID or fingerprint to unlock', value: _biometrics, onChanged: (v) => setState(() => _biometrics = v)),
        _Toggle(label: 'Anonymous Data Sharing', subtitle: 'Help us improve the platform',          value: _dataShare,  onChanged: (v) => setState(() => _dataShare = v)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            await LocalDatabaseService().clearSearchHistory();
            if (!context.mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(_snack('Search history cleared.', dark: true));
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Center(child: Text('Clear Search History', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black54))),
          ),
        ),
        const SizedBox(height: 8),
        _PrimaryBtn('SAVE', () => _save(context)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Help Center Sheet
// ═══════════════════════════════════════════════════════════════════════════════

class _HelpSheet extends StatelessWidget {
  const _HelpSheet();

  static const _faqs = [
    ('How does the curation process work?',  'Our AI Curator analyses your lifestyle profile and search behaviour to surface estates matching your aesthetic and spatial preferences.'),
    ('Can I schedule a private viewing?',    'Yes — tap "Book Site Visit" on any property detail page to reserve a private tour with your assigned curator.'),
    ('What is Curator AI?',                  'Curator AI is our proprietary recommendation engine that learns from your interactions to refine your property feed over time.'),
    ('How do I save a property?',            'Tap the heart icon on any listing to add it to My Collection, accessible from the bottom navigation bar.'),
    ('How do I contact my curator?',         'Navigate to the Agent Profile screen and tap MESSAGE to open a direct conversation.'),
  ];

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Help Center',
      child: Column(children: [
        ..._faqs.map((f) => _FaqItem(question: f.$1, answer: f.$2)),
        const SizedBox(height: 8),
        _PrimaryBtn('CONTACT SUPPORT', () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(_snack('Opening support chat…'));
        }),
      ]),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question, answer;
  const _FaqItem({required this.question, required this.answer});
  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _open ? const Color(0xFF4C54B6).withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _open ? const Color(0xFF4C54B6).withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(widget.question, style: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 14))),
            Icon(_open ? Icons.remove : Icons.add, size: 18, color: const Color(0xFF4C54B6)),
          ]),
          if (_open) ...[
            const SizedBox(height: 10),
            Text(widget.answer, style: GoogleFonts.inter(fontSize: 13, color: Colors.black54, height: 1.5)),
          ],
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shared Components
// ═══════════════════════════════════════════════════════════════════════════════

class _SheetScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  const _SheetScaffold({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: const BorderRadius.vertical(top: Radius.circular(40))),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 48, height: 4, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 28),
                Text(title, style: GoogleFonts.manrope(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                const SizedBox(height: 28),
                child,
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final IconData icon;
  final TextInputType type;
  const _Field({required this.label, required this.ctrl, required this.icon, this.type = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.black45)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withValues(alpha: 0.06))),
          child: TextField(
            controller: ctrl,
            keyboardType: type,
            decoration: InputDecoration(prefixIcon: Icon(icon, color: const Color(0xFF4C54B6), size: 20), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 16)),
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ]),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.label, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: Colors.black38)),
          ])),
          Switch(value: value, onChanged: onChanged, activeThumbColor: const Color(0xFF4C54B6)),
        ]),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
  const _Segment({required this.options, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(16)),
      child: Row(children: options.map((opt) {
        final active = opt == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: active ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)] : [],
              ),
              child: Text(opt, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, fontWeight: active ? FontWeight.bold : FontWeight.w500, color: active ? Colors.black : Colors.black45)),
            ),
          ),
        );
      }).toList()),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.black45));
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryBtn(this.label, this.onTap);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 0),
        child: Text(label, style: GoogleFonts.manrope(fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 13)),
      ),
    );
  }
}

SnackBar _snack(String msg, {bool dark = false}) => SnackBar(
  content: Text(msg, style: GoogleFonts.inter()),
  backgroundColor: dark ? Colors.black87 : const Color(0xFF4C54B6),
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
);
