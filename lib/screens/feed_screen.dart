import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/catalog.dart';
import '../core/models.dart';
import '../state/session.dart';
import '../widgets/common.dart';
import '../widgets/fx.dart';
import '../widgets/idea_card.dart';
import '../widgets/mascot.dart';
import 'topic_picker.dart';

/// Today's key ideas: swipe vertically through full-height cards.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _pages = PageController();
  final List<FeedCard> _cards = [];
  int _page = 0;
  bool _hasMore = false;
  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;
  String _date = localDate();
  List<String> _topics = const [];
  late bool _goalWasMet;

  @override
  void initState() {
    super.initState();
    final me = context.read<Session>().me;
    _topics = me.topics;
    _goalWasMet = me.goalMetOn(localDate());
    _load();
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    final api = context.read<ApiClient>();
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
        _error = null;
        _date = localDate();
      }
    });
    try {
      final page = more ? _page + 1 : 0;
      final json = await api.get('/feed', query: {'date': _date, 'page': '$page'});
      final cards = (json['cards'] as List).map((c) => FeedCard.fromJson(c as Json)).toList();
      if (!mounted) return;
      setState(() {
        if (!more) _cards.clear();
        _cards.addAll(cards);
        _page = page;
        _hasMore = json['hasMore'] as bool? ?? false;
      });
      if (!more && _cards.isNotEmpty) {
        if (_pages.hasClients) _pages.jumpToPage(0);
        _markRead(0);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = _loadingMore = false);
    }
  }

  void _markRead(int index) {
    if (index < _cards.length) context.read<Session>().recordProgress(StashKind.card, _cards[index].id);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    final user = session.me;
    final scheme = Theme.of(context).colorScheme;

    // Reload when topics change (e.g. edited from the profile) or the day rolls over.
    if (user.topics.join() != _topics.join() || (localDate() != _date && !_loading)) {
      _topics = user.topics;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }

    final today = localDate();
    final read = user.readCountOn(today);
    final goalMet = user.goalMetOn(today);
    final streak = user.currentStreak(today, yesterdayDate());

    // Celebrate the moment the daily goal is reached.
    if (goalMet && !_goalWasMet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        celebrate(
          context,
          title: 'Daily goal reached!',
          message: streak > 1
              ? "That's $streak days in a row. Your brain thanks you."
              : 'You read ${user.dailyGoal} ideas today. Come back tomorrow to start a streak.',
        );
      });
    }
    _goalWasMet = goalMet;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: Row(
          children: [
            Mascot(size: 44, mood: goalMet ? MascotMood.cheer : MascotMood.happy),
            const SizedBox(width: 6),
            const Text('Today', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
          ],
        ),
        actions: [
          Tooltip(
            message: goalMet ? 'Daily goal met' : 'Read ${user.dailyGoal} ideas a day to build your streak',
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
              decoration: BoxDecoration(
                color: goalMet ? const Color(0xFFFF8A3D).withValues(alpha: 0.14) : scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                children: [
                  StreakFlame(lit: goalMet, size: 24),
                  const SizedBox(width: 2),
                  Text('$streak', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Edit topics',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TopicPicker())),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: GradientProgressBar(value: read / user.dailyGoal, colors: flameColors.reversed.toList()),
                ),
                const SizedBox(width: 12),
                if (goalMet) ...[
                  Icon(Icons.verified_rounded, size: 16, color: scheme.primary),
                  const SizedBox(width: 4),
                ],
                Text(
                  goalMet ? 'Goal met' : '$read/${user.dailyGoal} today',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _body(user, today),
    );
  }

  Widget _body(User user, String today) {
    if (_loading) return const LoadingView();
    if (_error != null) return MessageView.error(_error!, onRetry: _load);
    if (_cards.isEmpty) {
      return const MessageView(
        icon: Icons.inbox_outlined,
        mood: MascotMood.sleepy,
        title: 'Nothing here yet',
        message: 'There are no lessons in your topics yet. Try adding more topics.',
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: _load,
      child: PageView.builder(
        controller: _pages,
        scrollDirection: Axis.vertical,
        itemCount: _cards.length + 1,
        onPageChanged: (i) {
          _markRead(i);
          if (i >= _cards.length - 2 && _hasMore && !_loadingMore) _load(more: true);
        },
        itemBuilder: (context, i) {
          if (i == _cards.length) return _end();
          final card = _cards[i];
          final page = Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    Expanded(
                      child: IdeaCardView(
                        item: card,
                        large: true,
                        read: user.progressDate == today && user.readIds.contains(card.id),
                      ),
                    ),
                    if (i == 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AmbientBuilder(
                              period: const Duration(milliseconds: 1300),
                              builder: (context, t, child) => Transform.translate(
                                offset: Offset(0, -5 * math.sin(t * 2 * math.pi).abs()),
                                child: child,
                              ),
                              child: Icon(Icons.swipe_up_rounded, size: 20, color: scheme.primary),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Swipe up for the next idea',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
          // Neighbouring cards shrink and fade a little as they slide away.
          return AnimatedBuilder(
            animation: _pages,
            child: page,
            builder: (context, child) {
              var d = 0.0;
              if (_pages.hasClients && _pages.position.haveDimensions) {
                d = ((_pages.page ?? 0) - i).abs().clamp(0.0, 1.0);
              }
              return Opacity(
                opacity: 1 - d * 0.5,
                child: Transform.scale(scale: 1 - d * 0.1, child: child),
              );
            },
          );
        },
      ),
    );
  }

  Widget _end() {
    if (_loadingMore) return const LoadingView();
    return MessageView(
      icon: Icons.task_alt_rounded,
      mood: MascotMood.cheer,
      title: "You're all caught up",
      message: _hasMore
          ? "That's today's feed. Want a few more?"
          : "You've seen every idea in your topics today. Open a full lesson from Explore, or come back tomorrow.",
      actionLabel: _hasMore ? 'Load more ideas' : null,
      onAction: _hasMore ? () => _load(more: true) : null,
    );
  }
}
