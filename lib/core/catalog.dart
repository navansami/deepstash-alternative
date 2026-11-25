import 'package:material_ui/material_ui.dart';

import 'models.dart';

class Topic {
  final String id;
  final String name;
  final IconData icon;

  /// Gradient colors used for this topic's artwork.
  final Color color;
  final Color color2;
  const Topic(this.id, this.name, this.icon, this.color, this.color2);

  LinearGradient get gradient =>
      LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, color2]);
}

/// Mirrors server/topics.ts.
const topics = <Topic>[
  Topic('psychology', 'Psychology', Icons.psychology_outlined, Color(0xFF8B5CF6), Color(0xFFDB2777)),
  Topic('productivity', 'Productivity', Icons.bolt_outlined, Color(0xFFF97316), Color(0xFFDC2626)),
  Topic('habits', 'Habits', Icons.repeat_rounded, Color(0xFF0D9488), Color(0xFF16A34A)),
  Topic('leadership', 'Leadership', Icons.explore_outlined, Color(0xFF2563EB), Color(0xFF7C3AED)),
  Topic('ai', 'AI & Tech', Icons.memory_outlined, Color(0xFF0891B2), Color(0xFF6D28D9)),
  Topic('money', 'Money', Icons.savings_outlined, Color(0xFF15803D), Color(0xFF0E7490)),
  Topic('health', 'Health', Icons.favorite_border_rounded, Color(0xFFE11D48), Color(0xFFEA580C)),
  Topic('communication', 'Communication', Icons.forum_outlined, Color(0xFF0284C7), Color(0xFF0D9488)),
];

Topic topicById(String id) => topics.firstWhere(
  (t) => t.id == id,
  orElse: () => const Topic('other', 'Other', Icons.category_outlined, Color(0xFF64748B), Color(0xFF475569)),
);

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

String roleLabel(Role r) => switch (r) {
  Role.user => 'Member',
  Role.editor => 'Editor',
  Role.admin => 'Admin',
};

/// The user's local calendar day as YYYY-MM-DD (used for daily goals and streaks).
String localDate([DateTime? at]) {
  final d = at ?? DateTime.now();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

String yesterdayDate() => localDate(DateTime.now().subtract(const Duration(days: 1)));
