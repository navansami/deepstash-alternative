import 'package:material_ui/material_ui.dart';

import 'models.dart';

class Topic {
  final String id;
  final String name;
  final IconData icon;
  const Topic(this.id, this.name, this.icon);
}

/// Mirrors server/topics.ts.
const topics = <Topic>[
  Topic('psychology', 'Psychology', Icons.psychology_outlined),
  Topic('productivity', 'Productivity', Icons.bolt_outlined),
  Topic('habits', 'Habits', Icons.repeat_rounded),
  Topic('leadership', 'Leadership', Icons.explore_outlined),
  Topic('ai', 'AI & Tech', Icons.memory_outlined),
  Topic('money', 'Money', Icons.savings_outlined),
  Topic('health', 'Health', Icons.favorite_border_rounded),
  Topic('communication', 'Communication', Icons.forum_outlined),
];

Topic topicById(String id) =>
    topics.firstWhere((t) => t.id == id, orElse: () => const Topic('other', 'Other', Icons.category_outlined));

/// Stash icon keys stored on the server, mapped to icons. Mirrors STASH_ICONS in server/topics.ts.
const stashIcons = <String, IconData>{
  'bookmark': Icons.bookmark_outline_rounded,
  'star': Icons.star_outline_rounded,
  'lightbulb': Icons.lightbulb_outline_rounded,
  'target': Icons.track_changes_rounded,
  'brain': Icons.psychology_outlined,
  'flame': Icons.local_fire_department_outlined,
  'leaf': Icons.eco_outlined,
  'briefcase': Icons.work_outline_rounded,
  'heart': Icons.favorite_border_rounded,
  'book': Icons.menu_book_outlined,
};

IconData stashIcon(String key) => stashIcons[key] ?? Icons.bookmark_outline_rounded;

IconData cardTypeIcon(CardType t) => switch (t) {
      CardType.idea => Icons.lightbulb_outline_rounded,
      CardType.quote => Icons.format_quote_rounded,
      CardType.tip => Icons.check_circle_outline_rounded,
    };

Color cardTypeColor(CardType t, Brightness b) {
  final dark = b == Brightness.dark;
  return switch (t) {
    CardType.idea => dark ? const Color(0xFF7FA2F2) : const Color(0xFF3867D6),
    CardType.quote => dark ? const Color(0xFFB79AF2) : const Color(0xFF7E4CC9),
    CardType.tip => dark ? const Color(0xFF55C993) : const Color(0xFF1E8E57),
  };
}

String roleLabel(Role r) => switch (r) { Role.user => 'Member', Role.editor => 'Editor', Role.admin => 'Admin' };

/// The user's local calendar day as YYYY-MM-DD (used for daily goals and streaks).
String localDate([DateTime? at]) {
  final d = at ?? DateTime.now();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

String yesterdayDate() => localDate(DateTime.now().subtract(const Duration(days: 1)));
