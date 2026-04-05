import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'backend/supabase_service.dart';
import 'state.dart';
import 'screens/home_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseService.instance.initialize();
  runApp(const KokoSpotApp());
}

class KokoSpotApp extends StatelessWidget {
  const KokoSpotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '1st Koko Spot',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9E1B1B),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFDFDFD),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      ),
      home: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  final AppState _appState = AppState();
  bool _splashDone = false;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    // _appState.syncOrdersFromBackend(); // Commented for tests
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) return const _SplashScreen();

    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        return Scaffold(
          body: IndexedStack(
            index: _tab,
            children: [
              HomeScreen(state: _appState),
              OrdersScreen(
                orders: _appState.orders,
                syncing: _appState.syncingOrders,
                onRefresh: _appState.syncOrdersFromBackend,
              ),
              const ProfileScreen(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) {
              setState(() => _tab = i);
              if (i == 1) {
                _appState.syncOrdersFromBackend();
              }
            },
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFF9E1B1B).withOpacity( 0.12),
            surfaceTintColor: Colors.transparent,
            shadowColor: const Color(0x22000000),
            elevation: 0,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.storefront_outlined, color: Color(0xFF8D8D8D)),
                selectedIcon: const Icon(Icons.storefront, color: Color(0xFF9E1B1B)),
                label: 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined, color: Color(0xFF8D8D8D)),
                selectedIcon: const Icon(Icons.receipt_long, color: Color(0xFF9E1B1B)),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline, color: Color(0xFF8D8D8D)),
                selectedIcon: const Icon(Icons.person, color: Color(0xFF9E1B1B)),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9E1B1B), Color(0xFF7F1017)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB71C1C), Color(0xFF9E1B1B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9E1B1B).withOpacity( 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_mall_rounded,
                size: 46,
                color: Color(0xFFFFFFFF),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '1st Koko Spot',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fresh food, delivered fast',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withOpacity( 0.85),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
