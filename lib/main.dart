import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_state.dart';
import 'screens/create_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/stashes_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(KernelApp(state: AppState(prefs)));
}

class KernelApp extends StatelessWidget {
  final AppState state;
  const KernelApp({super.key, required this.state});

  static const _seed = Color(0xFFE2572B);

  ThemeData _theme(Brightness b) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: b);
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: b == Brightness.light ? const Color(0xFFF6F4EF) : const Color(0xFF141311),
      appBarTheme: const AppBarTheme(centerTitle: false, scrolledUnderElevation: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Kernel',
        debugShowCheckedModeBanner: false,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return state.onboarded ? const HomeShell() : const OnboardingScreen();
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [FeedScreen(), ExploreScreen(), CreateScreen(), StashesScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Explore'),
          NavigationDestination(
              icon: Icon(Icons.edit_outlined), selectedIcon: Icon(Icons.edit), label: 'Create'),
          NavigationDestination(
              icon: Icon(Icons.collections_bookmark_outlined),
              selectedIcon: Icon(Icons.collections_bookmark),
              label: 'Stashes'),
        ],
      ),
    );
  }
}
