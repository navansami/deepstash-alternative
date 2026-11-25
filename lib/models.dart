import 'package:material_ui/material_ui.dart';

enum CardType { idea, quote, tip }

extension CardTypeX on CardType {
  String get label => switch (this) {
        CardType.idea => 'Idea',
        CardType.quote => 'Quote',
        CardType.tip => 'Tip',
      };

  Color color(Brightness b) {
    final dark = b == Brightness.dark;
    return switch (this) {
      CardType.idea => dark ? const Color(0xFF6F95F0) : const Color(0xFF3867D6),
      CardType.quote => dark ? const Color(0xFFB18CF0) : const Color(0xFF8854D0),
      CardType.tip => dark ? const Color(0xFF4CC98A) : const Color(0xFF20A464),
    };
  }
}

class Topic {
  final String id;
  final String name;
  final String emoji;
  const Topic(this.id, this.name, this.emoji);
}

class IdeaCard {
  final String id;
  final String topic;
  final CardType type;
  final String title;
  final String body;
  final String source;
  final String author;
  final bool isUser;

  const IdeaCard({
    required this.id,
    required this.topic,
    required this.type,
    required this.title,
    required this.body,
    this.source = '',
    this.author = '',
    this.isUser = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'type': type.name,
        'title': title,
        'body': body,
        'source': source,
        'author': author,
      };

  factory IdeaCard.fromJson(Map<String, dynamic> j) => IdeaCard(
        id: j['id'] as String,
        topic: j['topic'] as String,
        type: CardType.values.byName(j['type'] as String),
        title: j['title'] as String,
        body: j['body'] as String,
        source: (j['source'] as String?) ?? '',
        author: (j['author'] as String?) ?? '',
        isUser: true,
      );
}

class Stash {
  final String id;
  String name;
  String emoji;
  final List<String> cardIds;

  Stash({required this.id, required this.name, this.emoji = '📚', List<String>? cardIds})
      : cardIds = cardIds ?? [];

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'emoji': emoji, 'cardIds': cardIds};

  factory Stash.fromJson(Map<String, dynamic> j) => Stash(
        id: j['id'] as String,
        name: j['name'] as String,
        emoji: (j['emoji'] as String?) ?? '📚',
        cardIds: List<String>.from(j['cardIds'] as List),
      );
}
