import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Gideon K.';
  String _email = 'gideon@kokospot.com';
  bool _notificationsEnabled = true;
  String _language = 'English (Ghana)';

  final List<String> _addresses = <String>[
    'East Legon, Accra',
    'Airport Residential, Accra',
  ];

  final List<String> _paymentMethods = <String>[
    'Mobile Money - 024***4312',
    'Card - **** 1234',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF9E1B1B),
        title: Text(
          'Profile',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF9E1B1B),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white,
                  child: Text(
                    _name
                        .split(' ')
                        .where((part) => part.isNotEmpty)
                        .take(2)
                        .map((part) => part[0])
                        .join(),
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF9E1B1B),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _name,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF1F1F1F),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  _email,
                  style: const TextStyle(color: Color(0xFF6E6E6E), fontSize: 14),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _editProfile,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF9E1B1B),
                    side: const BorderSide(color: Color(0xFF9E1B1B)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _section(
            title: 'Account',
            children: [
              _tile(
                icon: Icons.location_on_outlined,
                label: 'Saved Addresses',
                subtitle: '${_addresses.length} saved',
                onTap: _manageAddresses,
              ),
              _tile(
                icon: Icons.payment_outlined,
                label: 'Payment Methods',
                subtitle: '${_paymentMethods.length} active',
                onTap: _managePayments,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _section(
            title: 'Preferences',
            children: [
              _switchTile(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Notifications enabled'
                            : 'Notifications disabled',
                      ),
                    ),
                  );
                },
              ),
              _tile(
                icon: Icons.language_outlined,
                label: 'Language & Region',
                subtitle: _language,
                onTap: _changeLanguage,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _section(
            title: 'Support',
            children: [
              _tile(
                icon: Icons.help_outline_rounded,
                label: 'Help & Support',
                onTap: () => _showInfo('Support', 'Reach us at support@kokospot.com.'),
              ),
              _tile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () => _showInfo(
                  'Privacy Policy',
                  'We store order data and payment references securely through Supabase.',
                ),
              ),
              _tile(
                icon: Icons.info_outline_rounded,
                label: 'About KokoSpot',
                onTap: () => _showInfo(
                  'About KokoSpot',
                  'KokoSpot is your fast food delivery app with live payment tracking.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out from this demo session.')),
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF9E1B1B),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9E1B1B),
              letterSpacing: 1,
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20, color: const Color(0xFF9E1B1B)),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
      onTap: onTap,
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, size: 20, color: const Color(0xFF9E1B1B)),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      activeColor: const Color(0xFF9E1B1B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              setState(() {
                _name = nameController.text.trim().isEmpty
                    ? _name
                    : nameController.text.trim();
                _email = emailController.text.trim().isEmpty
                    ? _email
                    : emailController.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _manageAddresses() async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Saved Addresses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ..._addresses.map((address) => ListTile(
                        title: Text(address),
                        trailing: IconButton(
                          onPressed: () {
                            setState(() => _addresses.remove(address));
                            setSheetState(() {});
                          },
                          icon: const Icon(Icons.delete_outline),
                        ),
                      )),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Add new address',
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {
                      final value = controller.text.trim();
                      if (value.isEmpty) return;
                      setState(() => _addresses.add(value));
                      controller.clear();
                      setSheetState(() {});
                    },
                    child: const Text('Add Address'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _managePayments() async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Payment Methods', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ..._paymentMethods.map((method) => ListTile(
                        title: Text(method),
                        trailing: IconButton(
                          onPressed: () {
                            setState(() => _paymentMethods.remove(method));
                            setSheetState(() {});
                          },
                          icon: const Icon(Icons.delete_outline),
                        ),
                      )),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Add payment method',
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {
                      final value = controller.text.trim();
                      if (value.isEmpty) return;
                      setState(() => _paymentMethods.add(value));
                      controller.clear();
                      setSheetState(() {});
                    },
                    child: const Text('Add Payment Method'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _changeLanguage() async {
    const choices = [
      'English (Ghana)',
      'English (US)',
      'French',
    ];
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Choose language'),
        children: choices
            .map(
              (choice) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, choice),
                child: Text(choice),
              ),
            )
            .toList(),
      ),
    );

    if (selected != null) {
      setState(() => _language = selected);
    }
  }

  Future<void> _showInfo(String title, String message) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
