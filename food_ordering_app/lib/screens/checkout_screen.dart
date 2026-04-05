import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state.dart';
import '../menu_data.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.state});
  final AppState state;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  String _payment = 'Cash on Delivery';

  static const List<String> _paymentMethods = [
    'Cash on Delivery',
    'Mobile Money',
    'Credit / Debit Card',
  ];

  static const List<String> _savedAddresses = [
    'East Legon, Accra',
    'Airport Residential',
    'Cantonments',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final entries = state.cartEntries;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF9E1B1B),
        title: Text(
          'Checkout',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF9E1B1B),
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Order Summary ────────────────────────────────────────
          _SectionTitle('Order Summary'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFEEEEEE)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  ...entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              e.item.imageUrl,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (__, ___, ____) => Container(
                                width: 44,
                                height: 44,
                                color: const Color(0xFFFFEFE5),
                                child: Center(
                                  child: Text(
                                    categoryEmoji(e.item.category),
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e.item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            '×${e.quantity}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '\$${(e.item.price * e.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 20),
                  _TotalRow('Subtotal', state.cartSubtotal),
                  _TotalRow(
                    'Delivery',
                    state.deliveryFee,
                    subtitle: state.deliveryFee == 0
                        ? 'Free — order over \$18!'
                        : null,
                  ),
                  const SizedBox(height: 4),
                  _TotalRow('Total', state.cartTotal, bold: true),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          _SectionTitle('Contact Email'),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'you@example.com',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          // ── Delivery Address ─────────────────────────────────────
          _SectionTitle('Delivery Address'),
          TextField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Enter your full delivery address',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Icon(Icons.location_on_outlined),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _savedAddresses.map((addr) {
              return ActionChip(
                avatar: const Icon(Icons.bookmark_outline, size: 14),
                label: Text(addr, style: const TextStyle(fontSize: 12)),
                visualDensity: VisualDensity.compact,
                backgroundColor: const Color(0xFFFFF4F4),
                side: const BorderSide(color: Color(0xFFFFD9D9)),
                onPressed: () =>
                    setState(() => _addressController.text = addr),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // ── Payment Method ───────────────────────────────────────
          _SectionTitle('Payment Method'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFEEEEEE)),
            ),
            child: Column(
              children: List.generate(_paymentMethods.length, (index) {
                final method = _paymentMethods[index];
                final selected = method == _payment;
                final isLast = index == _paymentMethods.length - 1;
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(_paymentIcon(method), size: 20),
                      title: Text(method, style: const TextStyle(fontSize: 14)),
                      trailing: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF9E1B1B)
                                : Colors.black26,
                            width: selected ? 6 : 2,
                          ),
                        ),
                      ),
                      onTap: () => setState(() => _payment = method),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    if (!isLast) const Divider(height: 1, indent: 52),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),

      // ── Place Order button ───────────────────────────────────────
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton(
          onPressed: state.placingOrder ? null : _placeOrder,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: const Color(0xFF9E1B1B),
            foregroundColor: Colors.white,
          ),
          child: state.placingOrder
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Place Order  ·  \$${state.cartTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
        ),
      ),
    );
  }

  IconData _paymentIcon(String method) {
    switch (method) {
      case 'Cash on Delivery':
        return Icons.payments_outlined;
      case 'Mobile Money':
        return Icons.phone_android_outlined;
      case 'Credit / Debit Card':
        return Icons.credit_card_outlined;
      default:
        return Icons.payment_outlined;
    }
  }

  Future<void> _placeOrder() async {
    if (Supabase.instance.client.auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to place an order.'),
        ),
      );
      return;
    }

    final email = _emailController.text.trim();
    final address = _addressController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
        ),
      );
      return;
    }

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your delivery address.'),
        ),
      );
      return;
    }

    final result = await widget.state.placeOrder(
      address: address,
      payment: _payment,
      customerEmail: email,
    );

    if (!mounted) {
      return;
    }

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Failed to place order.')),
      );
      return;
    }

    Navigator.of(context).pop();

    final authorizationUrl = result.authorizationUrl;
    if (authorizationUrl != null && authorizationUrl.isNotEmpty) {
      final uri = Uri.parse(authorizationUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) {
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.message ?? 'Order placed successfully.',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow(
    this.label,
    this.amount, {
    this.bold = false,
    this.subtitle,
  });

  final String label;
  final double amount;
  final bool bold;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: bold
                    ? const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      )
                    : const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(fontSize: 11, color: Colors.green),
                ),
            ],
          ),
          const Spacer(),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: bold
                ? const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)
                : const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
