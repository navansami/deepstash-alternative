import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'screens/auth_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/stashes_screen.dart';
import 'screens/topic_picker.dart';
import 'state/session.dart';
import 'state/stashes.dart';
import 'widgets/fx.dart';
import 'widgets/mascot.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(KernelApp(api: ApiClient()));
}

class KernelApp extends StatelessWidget {
  final ApiClient api;
  const KernelApp({super.key, required this.api});

  static const _seed = Color(0xFFE2572B);

  ThemeData _theme(Brightness b) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: b);
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: b == Brightness.light ? const Color(0xFFF7F5F0) : const Color(0xFF141311),
      appBarTheme: const AppBarTheme(centerTitle: false, scrolledUnderElevation: 0),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      ),
      chipTheme: ChipThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99))),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: scheme.primary.withValues(alpha: 0.18),
        labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: api),
        ChangeNotifierProvider(create: (_) => Session(api)..restore()),
        ChangeNotifierProvider(create: (_) => Stashes(api)),
      ],
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

/// Routes by session state: splash, sign-in, topic onboarding, or the app.
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    switch (session.status) {
      case SessionStatus.loading:
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Mascot(size: 140, mood: MascotMood.wave),
                SizedBox(height: 12),
                Text('Kernel', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                SizedBox(height: 12),
                BouncingDots(),
              ],
            ),
          ),
        );
      case SessionStatus.signedOut:
        return const AuthScreen();
      case SessionStatus.signedIn:
        if (session.me.topics.length < 3) return const TopicPicker(onboarding: true);
        return HomeShell(key: ValueKey(session.me.id));
    }
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with SingleTickerProviderStateMixin {
  int _index = 0;
  late final AnimationController _tab = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    value: 1,
  );
  late final Animation<double> _fade = CurvedAnimation(parent: _tab, curve: Curves.easeOutCubic);

  void _select(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    if (Motion.of(context)) _tab.forward(from: 0);
  }

  late final Stashes _stashes = context.read<Stashes>();

  static const _destinations = [
    (Icons.today_outlined, Icons.today_rounded, 'Today'),
    (Icons.explore_outlined, Icons.explore_rounded, 'Explore'),
    (Icons.collections_bookmark_outlined, Icons.collections_bookmark_rounded, 'Stashes'),
    (Icons.account_circle_outlined, Icons.account_circle_rounded, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _stashes.load();
  }

  @override
  void dispose() {
    _tab.dispose();
    _stashes.clear(); // don't leak one user's stashes into the next session
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pages = [FeedScreen(), ExploreScreen(), StashesScreen(), ProfileScreen()];
    final wide = MediaQuery.sizeOf(context).width >= 900;
    // Fade the newly selected tab in; IndexedStack keeps every tab's state.
    final stack = FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.015), end: Offset.zero).animate(_fade),
        child: IndexedStack(index: _index, children: pages),
      ),
    );

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: _select,
              labelType: NavigationRailLabelType.all,
              leading: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: const Mascot(size: 56)),
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: Text(d.$3)),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: stack),
          ],
        ),
      );
    }
    return Scaffold(
      body: stack,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: [
          for (final d in _destinations) NavigationDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: d.$3),
        ],
      ),
    );
  }
}
