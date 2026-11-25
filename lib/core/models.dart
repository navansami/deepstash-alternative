typedef Json = Map<String, dynamic>;

List<String> _strings(Object? v) => (v as List? ?? const []).map((e) => e as String).toList();
DateTime? _date(Object? v) => v == null ? null : DateTime.tryParse(v as String);

enum Role { user, editor, admin }

Role roleFrom(String? s) => Role.values.firstWhere((r) => r.name == s, orElse: () => Role.user);

class User {
  final String id;
  final String email;
  final String name;
  final Role role;
  final List<String> topics;
  final Set<String> likedCardIds;
  final Set<String> completedLessonIds;
  final String progressDate;
  final List<String> readIds;
  final int streak;
  final String lastGoalDate;
  final int dailyGoal;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.topics,
    required this.likedCardIds,
    required this.completedLessonIds,
    required this.progressDate,
    required this.readIds,
    required this.streak,
    required this.lastGoalDate,
    required this.dailyGoal,
  });

  factory User.fromJson(Json j) {
    final progress = j['progress'] as Json? ?? const {};
    return User(
      id: j['id'] as String,
      email: j['email'] as String,
      name: j['name'] as String,
      role: roleFrom(j['role'] as String?),
      topics: _strings(j['topics']),
      likedCardIds: _strings(j['likedCardIds']).toSet(),
      completedLessonIds: _strings(j['completedLessonIds']).toSet(),
      progressDate: progress['date'] as String? ?? '',
      readIds: _strings(progress['readIds']),
      streak: j['streak'] as int? ?? 0,
      lastGoalDate: j['lastGoalDate'] as String? ?? '',
      dailyGoal: j['dailyGoal'] as int? ?? 5,
    );
  }

  User copyWith({Set<String>? likedCardIds}) => User(
        id: id,
        email: email,
        name: name,
        role: role,
        topics: topics,
        likedCardIds: likedCardIds ?? this.likedCardIds,
        completedLessonIds: completedLessonIds,
        progressDate: progressDate,
        readIds: readIds,
        streak: streak,
        lastGoalDate: lastGoalDate,
        dailyGoal: dailyGoal,
      );

  bool get canPublish => role == Role.editor || role == Role.admin;
  bool get isAdmin => role == Role.admin;

  int readCountOn(String date) => progressDate == date ? readIds.length : 0;
  bool goalMetOn(String date) => lastGoalDate == date;

  /// Streak still alive if the goal was met today or yesterday.
  int currentStreak(String today, String yesterday) =>
      (lastGoalDate == today || lastGoalDate == yesterday) ? streak : 0;
}

enum CardType { idea, quote, tip }

CardType cardTypeFrom(String? s) => CardType.values.firstWhere((t) => t.name == s, orElse: () => CardType.idea);

extension CardTypeLabel on CardType {
  String get label => switch (this) { CardType.idea => 'Idea', CardType.quote => 'Quote', CardType.tip => 'Tip' };
}

class LessonCard {
  final String? id;
  final CardType type;
  final String title;
  final String body;
  const LessonCard({this.id, required this.type, required this.title, required this.body});

  factory LessonCard.fromJson(Json j) => LessonCard(
        id: j['id'] as String?,
        type: cardTypeFrom(j['type'] as String?),
        title: j['title'] as String,
        body: j['body'] as String,
      );

  Json toJson() => {if (id != null) 'id': id, 'type': type.name, 'title': title, 'body': body};
}

/// A card shown outside its lesson (feed, stashes), carrying lesson context.
class FeedCard {
  final LessonCard card;
  final String lessonId;
  final String lessonTitle;
  final String topic;
  final String source;
  final String author;
  final int readMinutes;

  const FeedCard({
    required this.card,
    required this.lessonId,
    required this.lessonTitle,
    required this.topic,
    required this.source,
    required this.author,
    required this.readMinutes,
  });

  String get id => card.id!;

  factory FeedCard.fromJson(Json j) => FeedCard(
        card: LessonCard.fromJson(j),
        lessonId: j['lessonId'] as String,
        lessonTitle: j['lessonTitle'] as String,
        topic: j['topic'] as String,
        source: j['source'] as String? ?? '',
        author: j['author'] as String? ?? '',
        readMinutes: j['readMinutes'] as int? ?? 1,
      );
}

class LessonSummary {
  final String id;
  final String slug;
  final String title;
  final String summary;
  final String topic;
  final String source;
  final String author;
  final int readMinutes;
  final int cardCount;
  final bool isPublic;
  final bool completed;
  final bool canEdit;

  const LessonSummary({
    required this.id,
    required this.slug,
    required this.title,
    required this.summary,
    required this.topic,
    required this.source,
    required this.author,
    required this.readMinutes,
    required this.cardCount,
    required this.isPublic,
    required this.completed,
    required this.canEdit,
  });

  factory LessonSummary.fromJson(Json j) => LessonSummary(
        id: j['id'] as String,
        slug: j['slug'] as String,
        title: j['title'] as String,
        summary: j['summary'] as String? ?? '',
        topic: j['topic'] as String,
        source: j['source'] as String? ?? '',
        author: j['author'] as String? ?? '',
        readMinutes: j['readMinutes'] as int? ?? 1,
        cardCount: j['cardCount'] as int? ?? (j['cards'] as List?)?.length ?? 0,
        isPublic: j['visibility'] == 'public',
        completed: j['completed'] as bool? ?? false,
        canEdit: j['canEdit'] as bool? ?? false,
      );
}

class Lesson extends LessonSummary {
  final String body;
  final List<String> takeaways;
  final List<LessonCard> cards;

  Lesson.fromJson(Json j)
      : body = j['body'] as String,
        takeaways = _strings(j['takeaways']),
        cards = (j['cards'] as List).map((c) => LessonCard.fromJson(c as Json)).toList(),
        super(
          id: j['id'] as String,
          slug: j['slug'] as String,
          title: j['title'] as String,
          summary: j['summary'] as String? ?? '',
          topic: j['topic'] as String,
          source: j['source'] as String? ?? '',
          author: j['author'] as String? ?? '',
          readMinutes: j['readMinutes'] as int? ?? 1,
          cardCount: (j['cards'] as List).length,
          isPublic: j['visibility'] == 'public',
          completed: j['completed'] as bool? ?? false,
          canEdit: j['canEdit'] as bool? ?? false,
        );
}

enum StashKind { lesson, card }

class StashRef {
  final StashKind kind;
  final String refId;
  const StashRef(this.kind, this.refId);
}

class Stash {
  final String id;
  final String name;
  final String icon;
  final List<StashRef> items;

  const Stash({required this.id, required this.name, required this.icon, required this.items});

  factory Stash.fromJson(Json j) => Stash(
        id: j['id'] as String,
        name: j['name'] as String,
        icon: j['icon'] as String? ?? 'bookmark',
        items: (j['items'] as List? ?? const [])
            .map((i) => StashRef(
                  (i as Json)['kind'] == 'card' ? StashKind.card : StashKind.lesson,
                  i['refId'] as String,
                ))
            .toList(),
      );

  bool contains(StashKind kind, String refId) => items.any((i) => i.kind == kind && i.refId == refId);
}

/// A stash entry resolved to its content.
class StashEntry {
  final LessonSummary? lesson;
  final FeedCard? card;
  const StashEntry({this.lesson, this.card});

  factory StashEntry.fromJson(Json j) => j['kind'] == 'card'
      ? StashEntry(card: FeedCard.fromJson(j['card'] as Json))
      : StashEntry(lesson: LessonSummary.fromJson(j['lesson'] as Json));
}

class AdminUser {
  final String id;
  final String email;
  final String name;
  final Role role;
  final bool disabled;
  final bool locked;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.disabled,
    required this.locked,
    this.createdAt,
    this.lastLoginAt,
  });

  factory AdminUser.fromJson(Json j) => AdminUser(
        id: j['id'] as String,
        email: j['email'] as String,
        name: j['name'] as String,
        role: roleFrom(j['role'] as String?),
        disabled: j['disabled'] as bool? ?? false,
        locked: j['locked'] as bool? ?? false,
        createdAt: _date(j['createdAt']),
        lastLoginAt: _date(j['lastLoginAt']),
      );
}
