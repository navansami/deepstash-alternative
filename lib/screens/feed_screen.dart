import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/catalog.dart';
import '../core/models.dart';
import '../state/session.dart';
import '../widgets/common.dart';
import '../widgets/idea_card.dart';
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

  @override
  void initState() {
    super.initState();
    _topics = context.read<Session>().me.topics;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          Tooltip(
            message: goalMet ? 'Daily goal met' : 'Read ${user.dailyGoal} ideas a day to build your streak',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(children: [
                Icon(Icons.local_fire_department_rounded,
                    color: goalMet ? const Color(0xFFF76B15) : scheme.onSurfaceVariant.withValues(alpha: 0.5)),
                const SizedBox(width: 2),
                Text('$streak', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ]),
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
            child: Row(children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(value: (read / user.dailyGoal).clamp(0.0, 1.0), minHeight: 8),
                ),
              ),
              const SizedBox(width: 12),
              if (goalMet) ...[
                Icon(Icons.verified_rounded, size: 16, color: scheme.primary),
                const SizedBox(width: 4),
              ],
              Text(goalMet ? 'Goal met' : '$read/${user.dailyGoal} today',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant)),
            ]),
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
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(children: [
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
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.swipe_up_rounded, size: 18, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text('Swipe up for the next idea',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
                        ),
                      ]),
                    ),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _end() {
    if (_loadingMore) return const LoadingView();
    return MessageView(
      icon: Icons.task_alt_rounded,
      title: "You're all caught up",
      message: _hasMore
          ? "That's today's feed. Want a few more?"
          : "You've seen every idea in your topics today. Open a full lesson from Explore, or come back tomorrow.",
      actionLabel: _hasMore ? 'Load more ideas' : null,
      onAction: _hasMore ? () => _load(more: true) : null,
    );
  }
}
