import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koko_spot/main.dart';
import 'package:koko_spot/state.dart';
import 'package:koko_spot/menu_data.dart';

void main() {
  testWidgets('Splash screen shows brand text', (WidgetTester tester) async {
    await tester.pumpWidget(const KokoSpotApp());

    expect(find.text('1st Koko Spot'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1900));
  });

  test('AppState adds item to cart', () {
    final state = AppState();
    final item = kMenuItems.first;

    state.addToCart(item.id);

    expect(state.cart[item.id], 1);
    expect(state.cartEntries.length, 1);
  });

  test('AppState calculates total correctly', () {
    final state = AppState();
    final item = kMenuItems.first;

    state.addToCart(item.id);
    state.addToCart(item.id);

    final total = state.cartTotal;
    expect(total, item.price * 2 + (item.price * 2 < 18 ? 1.5 : 0));
  });
}
