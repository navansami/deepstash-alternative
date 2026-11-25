import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../models.dart';
import '../seed_data.dart';
import 'save_sheet.dart';

/// A visual idea card with like / save / copy actions.
class IdeaCardView extends StatelessWidget {
  final IdeaCard card;

  /// Feed mode: larger type, fills the available height.
  final bool large;
  final VoidCallback? onDelete;

  const IdeaCardView({super.key, required this.card, this.large = false, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final typeColor = card.type.color(theme.brightness);
    final topic = topicById(card.topic);
    final isQuote = card.type == CardType.quote;
    final liked = state.liked.contains(card.id);
    final saved = state.isSaved(card.id);

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

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: typeColor, width: 6))),
        padding: EdgeInsets.fromLTRB(22, large ? 28 : 20, 22, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: large ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Row(children: [
              Text(card.type.label.toUpperCase(),
                  style: TextStyle(color: typeColor, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.1)),
              const SizedBox(width: 8),
              Text('${topic.emoji} ${topic.name}',
                  style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 12)),
              if (card.isUser) ...[
                const SizedBox(width: 8),
                Text('· YOURS',
                    style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800, fontSize: 12)),
              ],
              const Spacer(),
              if (state.readToday.contains(card.id) && large)
                Icon(Icons.check_circle, size: 18, color: CardType.tip.color(theme.brightness)),
            ]),
            SizedBox(height: large ? 18 : 12),
            Text(card.title,
                style: TextStyle(
                    fontSize: large ? 28 : 21, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.4)),
            SizedBox(height: large ? 16 : 10),
            if (large) Expanded(child: SingleChildScrollView(child: body)) else body,
            if (card.source.isNotEmpty || card.author.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text.rich(
                TextSpan(children: [
                  if (card.source.isNotEmpty)
                    TextSpan(text: card.source, style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w600)),
                  if (card.source.isNotEmpty && card.author.isNotEmpty) const TextSpan(text: ' · '),
                  if (card.author.isNotEmpty) TextSpan(text: card.author),
                ]),
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 8),
            const Divider(height: 1),
            Row(children: [
              IconButton(
                tooltip: liked ? 'Unlike' : 'Like',
                onPressed: () => state.toggleLike(card.id),
                icon: Icon(liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.redAccent : scheme.onSurfaceVariant),
              ),
              IconButton(
                tooltip: 'Save to stash',
                onPressed: () => showSaveSheet(context, card),
                icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border,
                    color: saved ? scheme.primary : scheme.onSurfaceVariant),
              ),
              IconButton(
                tooltip: 'Copy text',
                onPressed: () {
                  final attribution = [card.source, card.author].where((s) => s.isNotEmpty).join(' — ');
                  Clipboard.setData(ClipboardData(
                      text: '${card.title}\n\n${card.body}${attribution.isEmpty ? '' : '\n\n— $attribution'}'));
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                },
                icon: Icon(Icons.copy_rounded, color: scheme.onSurfaceVariant),
              ),
              const Spacer(),
              if (onDelete != null)
                IconButton(
                  tooltip: 'Delete',
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, color: scheme.onSurfaceVariant),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}
