import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'seed_data.dart';

/// All app state, persisted to device storage as one JSON blob.
class AppState extends ChangeNotifier {
  static const _key = 'kernel_state_v1';
  static const dailyGoal = 5;
  static const feedPageSize = 8;

  final SharedPreferences _prefs;
  final DateTime Function() _now;

  AppState(this._prefs, {DateTime Function()? now}) : _now = now ?? DateTime.now {
    _load();
  }

  bool onboarded = false;
  Set<String> selectedTopics = {};
  final List<IdeaCard> userCards = [];
  final List<Stash> stashes = [];
  final Set<String> liked = {};

  // Daily progress
  String _readDate = '';
  final Set<String> readToday = {};
  int streak = 0;
  String _lastGoalDate = '';
  int _extraPages = 0;

  // ---------- derived ----------

  List<IdeaCard> get allCards => [...userCards, ...seedCards];

  IdeaCard? cardById(String id) {
    for (final c in allCards) {
      if (c.id == id) return c;
    }
    return null;
  }

  String get _today => _dateKey(_now());
  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int get readTodayCount {
    _rollDay();
    return readToday.length;
  }

  bool get goalMetToday => _lastGoalDate == _today;

  /// Streak shown to the user: drops to 0 if a whole day was missed.
  int get currentStreak {
    final yesterday = _dateKey(_now().subtract(const Duration(days: 1)));
    return (_lastGoalDate == _today || _lastGoalDate == yesterday) ? streak : 0;
  }

  /// Today's feed: a date-seeded shuffle of cards from the chosen topics, so it
  /// stays stable through the day and refreshes tomorrow.
  List<IdeaCard> get dailyFeed {
    _rollDay();
    final pool = seedCards.where((c) => selectedTopics.contains(c.topic)).toList();
    final seed = int.parse(_today.replaceAll('-', '')); // e.g. 20261125
    pool.shuffle(Random(seed));
    final count = min(pool.length, feedPageSize * (1 + _extraPages));
    return pool.take(count).toList();
  }

  bool get feedHasMore {
    final total = seedCards.where((c) => selectedTopics.contains(c.topic)).length;
    return dailyFeed.length < total;
  }

  bool isSaved(String cardId) => stashes.any((s) => s.cardIds.contains(cardId));

  // ---------- mutations ----------

  void completeOnboarding(Set<String> topics) {
    selectedTopics = {...topics};
    onboarded = true;
    _save();
  }

  void setTopics(Set<String> topics) {
    selectedTopics = {...topics};
    _extraPages = 0;
    _save();
  }

  void loadMore() {
    _extraPages++;
    _save();
  }

  void markRead(String cardId) {
    _rollDay();
    if (!readToday.add(cardId)) return;
    if (readToday.length >= dailyGoal && _lastGoalDate != _today) {
      final yesterday = _dateKey(_now().subtract(const Duration(days: 1)));
      streak = _lastGoalDate == yesterday ? streak + 1 : 1;
      _lastGoalDate = _today;
    }
    _save();
  }

  void toggleLike(String cardId) {
    if (!liked.remove(cardId)) liked.add(cardId);
    _save();
  }

  Stash createStash(String name, {String emoji = '📚'}) {
    final s = Stash(id: 's${_now().microsecondsSinceEpoch}', name: name.trim(), emoji: emoji);
    stashes.add(s);
    _save();
    return s;
  }

  void renameStash(Stash s, String name, String emoji) {
    s
      ..name = name.trim()
      ..emoji = emoji;
    _save();
  }

  void deleteStash(Stash s) {
    stashes.remove(s);
    _save();
  }

  void toggleInStash(Stash s, String cardId) {
    if (!s.cardIds.remove(cardId)) s.cardIds.insert(0, cardId);
    _save();
  }

  IdeaCard addUserCard({
    required String topic,
    required CardType type,
    required String title,
    required String body,
    String source = '',
    String author = '',
  }) {
    final card = IdeaCard(
      id: 'u${_now().microsecondsSinceEpoch}',
      topic: topic,
      type: type,
      title: title.trim(),
      body: body.trim(),
      source: source.trim(),
      author: author.trim(),
      isUser: true,
    );
    userCards.insert(0, card);
    _save();
    return card;
  }

  void deleteUserCard(String id) {
    userCards.removeWhere((c) => c.id == id);
    for (final s in stashes) {
      s.cardIds.remove(id);
    }
    liked.remove(id);
    _save();
  }

  // ---------- persistence ----------

  void _rollDay() {
    if (_readDate != _today) {
      _readDate = _today;
      readToday.clear();
      _extraPages = 0;
    }
  }

  void _load() {
    final raw = _prefs.getString(_key);
    if (raw != null) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        onboarded = j['onboarded'] as bool? ?? false;
        selectedTopics = Set<String>.from(j['topics'] as List? ?? const []);
        userCards.addAll((j['userCards'] as List? ?? const [])
            .map((e) => IdeaCard.fromJson(e as Map<String, dynamic>)));
        stashes.addAll((j['stashes'] as List? ?? const [])
            .map((e) => Stash.fromJson(e as Map<String, dynamic>)));
        liked.addAll(List<String>.from(j['liked'] as List? ?? const []));
        _readDate = j['readDate'] as String? ?? '';
        readToday.addAll(List<String>.from(j['readToday'] as List? ?? const []));
        streak = j['streak'] as int? ?? 0;
        _lastGoalDate = j['lastGoalDate'] as String? ?? '';
        _extraPages = j['extraPages'] as int? ?? 0;
      } catch (_) {
        // Corrupt state: start fresh rather than crash.
      }
    }
    if (stashes.isEmpty) stashes.add(Stash(id: 'default', name: 'Saved', emoji: '⭐'));
    _rollDay();
  }

  void _save() {
    _prefs.setString(
      _key,
      jsonEncode({
        'onboarded': onboarded,
        'topics': selectedTopics.toList(),
        'userCards': userCards.map((c) => c.toJson()).toList(),
        'stashes': stashes.map((s) => s.toJson()).toList(),
        'liked': liked.toList(),
        'readDate': _readDate,
        'readToday': readToday.toList(),
        'streak': streak,
        'lastGoalDate': _lastGoalDate,
        'extraPages': _extraPages,
      }),
    );
    notifyListeners();
  }
}

/// Makes [AppState] available to the widget tree and rebuilds dependents on change.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
