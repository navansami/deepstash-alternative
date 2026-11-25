import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../widgets/idea_card.dart';
import 'onboarding_screen.dart';

/// Daily feed: vertical swipe through full-height idea cards.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _controller = PageController();
  bool _markedFirst = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final feed = state.dailyFeed;
    final scheme = Theme.of(context).colorScheme;

    // The first card is "read" as soon as it's on screen.
    if (!_markedFirst && feed.isNotEmpty) {
      _markedFirst = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => state.markRead(feed.first.id));
    }

    final progress = (state.readTodayCount / AppState.dailyGoal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          _StreakBadge(streak: state.currentStreak, metToday: state.goalMetToday),
          IconButton(
            tooltip: 'Edit topics',
            icon: const Icon(Icons.tune),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(),
                body: TopicPicker(
                  initial: state.selectedTopics,
                  title: 'Your topics',
                  subtitle: 'Your daily feed is built from these.',
                  buttonLabel: 'Save',
                  onDone: (t) {
                    state.setTopics(t);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            )),
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
                  child: LinearProgressIndicator(value: progress, minHeight: 8),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                state.goalMetToday
                    ? 'Daily goal done 🎉'
                    : '${state.readTodayCount}/${AppState.dailyGoal} ideas',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant),
              ),
            ]),
          ),
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        scrollDirection: Axis.vertical,
        itemCount: feed.length + 1,
        onPageChanged: (i) {
          if (i < feed.length) state.markRead(feed[i].id);
        },
        itemBuilder: (context, i) {
          if (i == feed.length) return _EndOfFeed(hasMore: state.feedHasMore, onMore: state.loadMore);
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(children: [
              Expanded(child: IdeaCardView(card: feed[i], large: true)),
              if (i == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Swipe up for the next idea',
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
                ),
            ]),
          );
        },
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;
  final bool metToday;
  const _StreakBadge({required this.streak, required this.metToday});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: metToday ? 'Streak: goal met today' : 'Read ${AppState.dailyGoal} ideas to keep your streak',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(children: [
          Opacity(opacity: metToday ? 1 : 0.4, child: const Text('🔥', style: TextStyle(fontSize: 18))),
          const SizedBox(width: 4),
          Text('$streak', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ]),
      ),
    );
  }
}

class _EndOfFeed extends StatelessWidget {
  final bool hasMore;
  final VoidCallback onMore;
  const _EndOfFeed({required this.hasMore, required this.onMore});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('✨', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text("You're all caught up",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            hasMore
                ? 'That was today\'s feed. Want a few more?'
                : 'You\'ve read everything in your topics. Add more topics, explore, or write your own idea.',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
          ),
          const SizedBox(height: 20),
          if (hasMore) FilledButton.tonal(onPressed: onMore, child: const Text('Load more ideas')),
        ]),
      ),
    );
  }
}
