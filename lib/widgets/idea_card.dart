import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/catalog.dart';
import '../core/models.dart';
import '../screens/lesson_screen.dart';
import '../state/session.dart';
import '../state/stashes.dart';
import 'common.dart';
import 'fx.dart';
import 'save_sheet.dart';
import 'topic_art.dart';

/// A key-idea card with like / save / copy and a link to its full lesson.
class IdeaCardView extends StatelessWidget {
  final FeedCard item;

  /// Feed mode: larger type and fills the available height.
  final bool large;
  final bool read;
  final bool showLessonLink;

  const IdeaCardView({
    super.key,
    required this.item,
    this.large = false,
    this.read = false,
    this.showLessonLink = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final card = item.card;
    final typeColor = cardTypeColor(card.type, theme.brightness);
    final isQuote = card.type == CardType.quote;
    final liked = context.select<Session, bool>((s) => s.user?.likedCardIds.contains(item.id) ?? false);
    final saved = context.select<Stashes, bool>((s) => s.isSaved(StashKind.card, item.id));

    final body = Text(
      isQuote ? '“${card.body}”' : card.body,
      style: isQuote
          ? TextStyle(
              fontFamily: 'Georgia',
              fontFamilyFallback: const ['serif'],
              fontStyle: FontStyle.italic,
              fontSize: large ? 24 : 19,
              height: 1.45,
            )
          : TextStyle(fontSize: large ? 19 : 16, height: 1.55),
    );

    final attribution = [item.source, item.author].where((s) => s.isNotEmpty).join(' · ');

    final topic = topicById(item.topic);
    final banner = TopicBanner(
      topic: topic,
      height: large ? 84 : 56,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 14, 0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cardTypeIcon(card.type), size: 15, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(
                    card.type.label.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Flexible(child: TopicLabel(item.topic, color: Colors.white)),
            const Spacer(),
            if (read)
              const Tooltip(
                message: 'Read today',
                child: Icon(Icons.done_all_rounded, size: 20, color: Colors.white),
              ),
          ],
        ),
      ),
    );

    final content = Padding(
      padding: EdgeInsets.fromLTRB(22, large ? 22 : 16, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: large ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5,
                  height: large ? 30 : 22,
                  margin: const EdgeInsets.only(top: 3, right: 10),
                  decoration: BoxDecoration(color: typeColor, borderRadius: BorderRadius.circular(9)),
                ),
                Expanded(
                  child: Text(
                    card.title,
                    style: TextStyle(
                      fontSize: large ? 28 : 20,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: large ? 16 : 10),
          if (large)
            Expanded(
              child: SingleChildScrollView(padding: const EdgeInsets.only(right: 10), child: body),
            )
          else
            Padding(padding: const EdgeInsets.only(right: 10), child: body),
          if (attribution.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(attribution, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
          ],
          const SizedBox(height: 8),
          const Divider(height: 1),
          Row(
            children: [
              PopIconButton(
                tooltip: liked ? 'Unlike' : 'Like',
                active: liked,
                icon: Icons.favorite_border_rounded,
                activeIcon: Icons.favorite_rounded,
                activeColor: const Color(0xFFE5484D),
                color: scheme.onSurfaceVariant,
                onPressed: () => context.read<Session>().toggleLike(item.id),
              ),
              PopIconButton(
                tooltip: 'Save to stash',
                active: saved,
                icon: Icons.bookmark_border_rounded,
                activeIcon: Icons.bookmark_rounded,
                activeColor: scheme.primary,
                color: scheme.onSurfaceVariant,
                onPressed: () => showSaveSheet(context, StashKind.card, item.id),
              ),
              IconButton(
                tooltip: 'Copy',
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: '${card.title}\n\n${card.body}${attribution.isEmpty ? '' : '\n\n— $attribution'}',
                    ),
                  );
                  showSnack(context, 'Copied to clipboard');
                },
                icon: Icon(Icons.content_copy_rounded, size: 20, color: scheme.onSurfaceVariant),
              ),
              const Spacer(),
              if (showLessonLink)
                Flexible(
                  flex: 100, // take the free space, but shrink and truncate on narrow screens
                  child: Tooltip(
                    message: 'Read the full lesson: ${item.lessonTitle}',
                    child: TextButton.icon(
                      onPressed: () => openLesson(context, item.lessonId),
                      icon: const Icon(Icons.menu_book_outlined, size: 18),
                      label: Text(
                        'Full lesson · ${item.readMinutes} min',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    return Card(
      elevation: large ? 2 : 0,
      shadowColor: topic.color.withValues(alpha: 0.4),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: large ? MainAxisSize.max : MainAxisSize.min,
        children: [
          banner,
          if (large) Expanded(child: content) else content,
        ],
      ),
    );
  }
}
