import '../menu_data.dart';
import '../state.dart';
import 'supabase_service.dart';

class OrderRepository {
  Future<void> createOrder({
    required String orderCode,
    required String address,
    required String paymentMethod,
    required String status,
    required String paymentStatus,
    required double subtotal,
    required double deliveryFee,
    required double total,
    required List<CartEntry> entries,
    String? customerEmail,
    String? paymentReference,
  }) async {
    try {
      await SupabaseService.instance.client.from('orders').insert({
        'order_code': orderCode,
        'customer_email': customerEmail,
        'address': address,
        'payment_method': paymentMethod,
        'status': status,
        'payment_status': paymentStatus,
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'total': total,
        'payment_reference': paymentReference,
        'items': entries
            .map(
              (entry) => {
                'id': entry.item.id,
                'name': entry.item.name,
                'category': entry.item.category,
                'image_url': entry.item.imageUrl,
                'price': entry.item.price,
                'quantity': entry.quantity,
              },
            )
            .toList(),
      });
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<List<Order>> fetchOrders() async {
    try {
      final rows = await SupabaseService.instance.client
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      return (rows as List<dynamic>)
          .map((row) => _mapOrder(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Order _mapOrder(Map<String, dynamic> row) {
    final rawItems = (row['items'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();

    final entries = rawItems.map((item) {
      final id = item['id']?.toString() ?? '';
      FoodItem? menuMatch;
      for (final menuItem in kMenuItems) {
        if (menuItem.id == id) {
          menuMatch = menuItem;
          break;
        }
      }

      final foodItem = menuMatch ??
          FoodItem(
            id: id.isEmpty ? DateTime.now().microsecondsSinceEpoch.toString() : id,
            name: item['name']?.toString() ?? 'Menu item',
            category: item['category']?.toString() ?? 'Other',
            price: (item['price'] as num?)?.toDouble() ?? 0,
            rating: 0,
            eta: '-',
            imageUrl: item['image_url']?.toString() ?? '',
            description: '',
          );

      return CartEntry(
        item: foodItem,
        quantity: (item['quantity'] as num?)?.toInt() ?? 1,
      );
    }).toList();

    final createdAtRaw = row['created_at']?.toString();

    return Order(
      id: row['order_code']?.toString() ?? 'KS-UNKNOWN',
      entries: entries,
      total: (row['total'] as num?)?.toDouble() ?? 0,
      placedAt: createdAtRaw == null ? DateTime.now() : DateTime.parse(createdAtRaw),
      status: row['status']?.toString() ?? 'Preparing',
      address: row['address']?.toString() ?? '-',
      paymentMethod: row['payment_method']?.toString() ?? '-',
      paymentStatus: row['payment_status']?.toString() ?? 'pending',
      paymentReference: row['payment_reference']?.toString(),
    );
  }
}
