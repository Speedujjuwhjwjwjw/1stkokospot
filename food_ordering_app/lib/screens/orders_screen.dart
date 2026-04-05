import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({
    super.key,
    required this.orders,
    this.syncing = false,
    this.onRefresh,
  });
  final List<Order> orders;
  final bool syncing;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF9E1B1B),
        title: Text(
          'My Orders',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF9E1B1B),
          ),
        ),
        centerTitle: false,
        actions: [
          if (syncing)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        child: orders.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.receipt_long_outlined,
                          size: 72,
                          color: Color(0xFFB0B0B0),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No orders yet',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF222222),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your placed orders will appear here.',
                          style: TextStyle(color: Color(0xFF747474)),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) => _OrderCard(order: orders[i]),
              ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    final paymentStatusColor = _paymentStatusColor(order.paymentStatus);
    final paymentStatusLabel = _paymentStatusLabel(order.paymentStatus);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID + status
            Row(
              children: [
                Text(
                  order.id,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity( 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${order.entries.length} item${order.entries.length > 1 ? 's' : ''}  ·  \$${order.total.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(order.placedAt),
              style: const TextStyle(color: Colors.black38, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: paymentStatusColor.withOpacity( 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    paymentStatusLabel,
                    style: TextStyle(
                      color: paymentStatusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            // Items
            ...order.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• ${e.item.name}  ×${e.quantity}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Address + payment
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.black45,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.address,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.payment_outlined,
                  size: 14,
                  color: Colors.black45,
                ),
                const SizedBox(width: 4),
                Text(
                  order.paymentMethod,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Preparing':
        return Colors.orange;
      case 'On the way':
        return Colors.blue;
      case 'Delivered':
        return Colors.green;
      case 'Awaiting Payment':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  Color _paymentStatusColor(String paymentStatus) {
    switch (paymentStatus) {
      case 'success':
      case 'paid':
        return Colors.green;
      case 'pending':
      case 'pending_cod':
        return Colors.orange;
      case 'failed':
      case 'abandoned':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _paymentStatusLabel(String paymentStatus) {
    switch (paymentStatus) {
      case 'success':
      case 'paid':
        return 'Payment Paid';
      case 'pending_cod':
        return 'Cash On Delivery';
      case 'pending':
        return 'Payment Pending';
      case 'failed':
        return 'Payment Failed';
      case 'abandoned':
        return 'Payment Abandoned';
      default:
        return 'Payment Unknown';
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  $h:$m';
  }
}
