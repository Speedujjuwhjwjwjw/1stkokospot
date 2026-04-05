import 'package:flutter/foundation.dart';

import 'backend/order_repository.dart';
import 'backend/paystack_service.dart';
import 'backend/supabase_service.dart';
import 'menu_data.dart';

enum OrderStatus { preparing, awaitingPayment, completed, cancelled }

enum PaymentStatus { pending, paid, failed }

class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.eta,
    required this.imageUrl,
    required this.description,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final double rating;
  final String eta;
  final String imageUrl;
  final String description;
}

class CartEntry {
  const CartEntry({required this.item, required this.quantity});
  final FoodItem item;
  final int quantity;
}

class Order {
  Order({
    required this.id,
    required this.entries,
    required this.total,
    required this.placedAt,
    this.status = 'Preparing',
    required this.address,
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    this.paymentReference,
  });

  final String id;
  final List<CartEntry> entries;
  final double total;
  final DateTime placedAt;
  String status;
  final String address;
  final String paymentMethod;
  String paymentStatus;
  String? paymentReference;
}

class CheckoutResult {
  const CheckoutResult({
    required this.success,
    this.authorizationUrl,
    this.message,
  });

  final bool success;
  final String? authorizationUrl;
  final String? message;
}

class AppState extends ChangeNotifier {
  AppState({
    OrderRepository? orderRepository,
    PaystackService? paystackService,
  })  : _orderRepository = orderRepository ?? OrderRepository(),
        _paystackService = paystackService ?? PaystackService();

  final Map<String, int> _cart = {};
  final List<Order> _orders = [];
  final OrderRepository _orderRepository;
  final PaystackService _paystackService;

  bool _syncingOrders = false;
  bool _placingOrder = false;

  Map<String, int> get cart => Map.unmodifiable(_cart);
  List<Order> get orders => List.unmodifiable(_orders);
  bool get syncingOrders => _syncingOrders;
  bool get placingOrder => _placingOrder;
  bool get backendReady => true;

  int get cartCount => _cart.values.fold(0, (a, b) => a + b);

  double get cartSubtotal => kMenuItems.fold<double>(0.0, (sum, item) {
        final qty = _cart[item.id] ?? 0;
        return sum + (item.price * qty);
      });

  double get deliveryFee => cartSubtotal > 18.0 ? 0.0 : 1.5;
  double get cartTotal => cartSubtotal + deliveryFee;

  int quantityFor(String id) => _cart[id] ?? 0;

  List<CartEntry> get cartEntries => kMenuItems
      .where((i) => _cart.containsKey(i.id))
      .map((i) => CartEntry(item: i, quantity: _cart[i.id]!))
      .toList();

  void addToCart(String id) {
    _cart.update(id, (q) => q + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void removeFromCart(String id) {
    if (!_cart.containsKey(id)) return;
    if (_cart[id]! <= 1) {
      _cart.remove(id);
    } else {
      _cart[id] = _cart[id]! - 1;
    }
    notifyListeners();
  }

  Future<void> syncOrdersFromBackend() async {
    if (!backendReady || _syncingOrders) {
      return;
    }

    _syncingOrders = true;
    notifyListeners();

    try {
      final remoteOrders = await _orderRepository.fetchOrders();
      _orders
        ..clear()
        ..addAll(remoteOrders);
    } finally {
      _syncingOrders = false;
      notifyListeners();
    }
  }

  Future<CheckoutResult> placeOrder({
    required String address,
    required String payment,
    required String customerEmail,
  }) async {
    if (_placingOrder) {
      return const CheckoutResult(
        success: false,
        message: 'An order is already being processed.',
      );
    }

    if (_cart.isEmpty) {
      return const CheckoutResult(
        success: false,
        message: 'Your cart is empty.',
      );
    }

    _placingOrder = true;
    notifyListeners();

    final entries = cartEntries;

    try {
      final orderCode =
          'KS-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      if (!backendReady) {
        _orders.insert(
          0,
          Order(
            id: orderCode,
            entries: entries,
            total: cartTotal,
            placedAt: DateTime.now(),
            address: address,
            paymentMethod: payment,
            status: payment == 'Cash on Delivery' ? 'Preparing' : 'Pending',
            paymentStatus:
                payment == 'Cash on Delivery' ? 'pending_cod' : 'pending',
          ),
        );
        _cart.clear();
        notifyListeners();
        return const CheckoutResult(
          success: true,
          message:
              'Backend not configured, order saved locally in offline mode.',
        );
      }

      if (payment == 'Cash on Delivery') {
        await _orderRepository.createOrder(
          orderCode: orderCode,
          address: address,
          paymentMethod: payment,
          status: 'Preparing',
          paymentStatus: 'pending_cod',
          subtotal: cartSubtotal,
          deliveryFee: deliveryFee,
          total: cartTotal,
          entries: entries,
          customerEmail: customerEmail,
        );

        _orders.insert(
          0,
          Order(
            id: orderCode,
            entries: entries,
            total: cartTotal,
            placedAt: DateTime.now(),
            address: address,
            paymentMethod: payment,
            status: 'Preparing',
            paymentStatus: 'pending_cod',
          ),
        );
        _cart.clear();
        notifyListeners();

        return const CheckoutResult(
          success: true,
          message: 'Order placed successfully.',
        );
      }

      final paymentInit = await _paystackService.initializeTransaction(
        email: customerEmail,
        amountKobo: (cartTotal * 100).round(),
        orderCode: orderCode,
        paymentMethod: payment,
      );

      await _orderRepository.createOrder(
        orderCode: orderCode,
        address: address,
        paymentMethod: payment,
        status: 'Awaiting Payment',
        paymentStatus: 'pending',
        subtotal: cartSubtotal,
        deliveryFee: deliveryFee,
        total: cartTotal,
        entries: entries,
        customerEmail: customerEmail,
        paymentReference: paymentInit.reference,
      );

      _orders.insert(
        0,
        Order(
          id: orderCode,
          entries: entries,
          total: cartTotal,
          placedAt: DateTime.now(),
          address: address,
          paymentMethod: payment,
          status: 'Awaiting Payment',
          paymentStatus: 'pending',
          paymentReference: paymentInit.reference,
        ),
      );
      _cart.clear();
      notifyListeners();

      return CheckoutResult(
        success: true,
        authorizationUrl: paymentInit.authorizationUrl,
        message: 'Payment initialized. Complete payment to confirm order.',
      );
    } catch (e) {
      return CheckoutResult(
        success: false,
        message: 'Failed to place order: $e',
      );
    } finally {
      _placingOrder = false;
      notifyListeners();
    }
  }
}
