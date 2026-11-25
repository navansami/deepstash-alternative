import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kernel/app_state.dart';
import 'package:kernel/main.dart';
import 'package:kernel/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> _state({DateTime Function()? now}) async {
  final prefs = await SharedPreferences.getInstance();
  return AppState(prefs, now: now);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('AppState', () {
    test('starts with a default stash and no onboarding', () async {
      final s = await _state();
      expect(s.onboarded, isFalse);
      expect(s.stashes.single.name, 'Saved');
    });

    test('daily feed only includes chosen topics and is stable within a day', () async {
      final s = await _state(now: () => DateTime(2026, 11, 25, 9));
      s.completeOnboarding({'habits', 'money'});
      final feed = s.dailyFeed;
      expect(feed, isNotEmpty);
      expect(feed.every((c) => {'habits', 'money'}.contains(c.topic)), isTrue);
      expect(s.dailyFeed.map((c) => c.id), feed.map((c) => c.id));
    });

    test('streak grows on consecutive days and resets after a gap', () async {
      var now = DateTime(2026, 11, 25, 9);
      final s = await _state(now: () => now);
      s.completeOnboarding({'habits', 'money', 'health'});

      void readGoal() {
        for (final c in s.dailyFeed.take(AppState.dailyGoal)) {
          s.markRead(c.id);
        }
      }

      readGoal();
      expect(s.currentStreak, 1);
      now = DateTime(2026, 11, 26, 9);
      expect(s.readTodayCount, 0);
      readGoal();
      expect(s.currentStreak, 2);
      now = DateTime(2026, 11, 29, 9); // skipped two days
      expect(s.currentStreak, 0);
      readGoal();
      expect(s.currentStreak, 1);
    });

    test('state persists across instances', () async {
      final a = await _state();
      a.completeOnboarding({'ai', 'health', 'money'});
      final card = a.addUserCard(topic: 'ai', type: CardType.tip, title: 'T', body: 'B');
      final stash = a.createStash('Reading list');
      a.toggleInStash(stash, card.id);

      final b = await _state();
      expect(b.onboarded, isTrue);
      expect(b.userCards.single.title, 'T');
      expect(b.stashes.firstWhere((s) => s.name == 'Reading list').cardIds, [card.id]);
    });

    test('deleting a user card removes it from stashes', () async {
      final s = await _state();
      final card = s.addUserCard(topic: 'ai', type: CardType.idea, title: 'T', body: 'B');
      s.toggleInStash(s.stashes.first, card.id);
      s.deleteUserCard(card.id);
      expect(s.stashes.first.cardIds, isEmpty);
      expect(s.cardById(card.id), isNull);
    });
  });

  testWidgets('onboarding → feed → save a card to a stash', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    final state = await _state();
    await tester.pumpWidget(KernelApp(state: state));

    expect(find.text('Pick 3 more'), findsOneWidget);
    for (final name in ['Psychology', 'Habits', 'Money']) {
      await tester.tap(find.text(name));
    }
    await tester.pump();
    await tester.tap(find.text('Start reading'));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(state.readTodayCount, 1); // first card counts as read

    await tester.tap(find.byTooltip('Save to stash').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(state.stashes.first.cardIds, hasLength(1));
  });
}
