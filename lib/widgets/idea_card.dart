import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/catalog.dart';
import '../core/models.dart';
import '../screens/lesson_screen.dart';
import '../state/session.dart';
import '../state/stashes.dart';
import 'common.dart';
import 'save_sheet.dart';

/// A key-idea card with like / save / copy and a link to its full lesson.
class IdeaCardView extends StatelessWidget {
  final FeedCard item;

  /// Feed mode: larger type and fills the available height.
  final bool large;
  final bool read;
  final bool showLessonLink;

  const IdeaCardView(
      {super.key, required this.item, this.large = false, this.read = false, this.showLessonLink = true});

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
              height: 1.45)
          : TextStyle(fontSize: large ? 19 : 16, height: 1.55),
    );

    final attribution = [item.source, item.author].where((s) => s.isNotEmpty).join(' · ');

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: typeColor, width: 6))),
        padding: EdgeInsets.fromLTRB(22, large ? 26 : 18, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: large ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(children: [
                Icon(cardTypeIcon(card.type), size: 16, color: typeColor),
                const SizedBox(width: 6),
                Text(card.type.label.toUpperCase(),
                    style: TextStyle(color: typeColor, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.1)),
                const SizedBox(width: 12),
                Flexible(child: TopicLabel(item.topic)),
                const Spacer(),
                if (read) Tooltip(message: 'Read today', child: Icon(Icons.done_all_rounded, size: 18, color: typeColor)),
              ]),
            ),
            SizedBox(height: large ? 18 : 12),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(card.title,
                  style: TextStyle(fontSize: large ? 28 : 20, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.4)),
            ),
            SizedBox(height: large ? 16 : 10),
            if (large)
              Expanded(child: SingleChildScrollView(padding: const EdgeInsets.only(right: 10), child: body))
            else
              Padding(padding: const EdgeInsets.only(right: 10), child: body),
            if (attribution.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(attribution, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
            ],
            const SizedBox(height: 8),
            const Divider(height: 1),
            Row(children: [
              IconButton(
                tooltip: liked ? 'Unlike' : 'Like',
                onPressed: () => context.read<Session>().toggleLike(item.id),
                icon: Icon(liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: liked ? const Color(0xFFE5484D) : scheme.onSurfaceVariant),
              ),
              IconButton(
                tooltip: 'Save to stash',
                onPressed: () => showSaveSheet(context, StashKind.card, item.id),
                icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: saved ? scheme.primary : scheme.onSurfaceVariant),
              ),
              IconButton(
                tooltip: 'Copy',
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                      text: '${card.title}\n\n${card.body}${attribution.isEmpty ? '' : '\n\n— $attribution'}'));
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
                      label: Text('Full lesson · ${item.readMinutes} min', maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}
