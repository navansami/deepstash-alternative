import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../models.dart';

/// Bottom sheet for adding/removing a card from stashes.
Future<void> showSaveSheet(BuildContext context, IdeaCard card) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => _SaveSheet(card: card),
  );
}

class _SaveSheet extends StatelessWidget {
  final IdeaCard card;
  const _SaveSheet({required this.card});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Save to stash', style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final s in state.stashes)
                    CheckboxListTile(
                      value: s.cardIds.contains(card.id),
                      onChanged: (_) => state.toggleInStash(s, card.id),
                      secondary: Text(s.emoji, style: const TextStyle(fontSize: 24)),
                      title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${s.cardIds.length} ideas'),
                    ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New stash'),
              onTap: () async {
                final result = await showStashDialog(context);
                if (result != null) {
                  final s = state.createStash(result.$1, emoji: result.$2);
                  state.toggleInStash(s, card.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

const stashEmojis = ['📚', '⭐', '💡', '🎯', '🧠', '🔥', '🌱', '💼', '❤️', '🧘'];

/// Name + emoji dialog. Returns (name, emoji) or null if cancelled.
Future<(String, String)?> showStashDialog(BuildContext context,
    {String initialName = '', String initialEmoji = '📚', String title = 'New stash'}) {
  final controller = TextEditingController(text: initialName);
  var emoji = initialEmoji;
  return showDialog<(String, String)>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        void submit() {
          if (controller.text.trim().isEmpty) return;
          Navigator.pop(ctx, (controller.text.trim(), emoji));
        }

        return AlertDialog(
          title: Text(title),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 40,
              decoration: const InputDecoration(hintText: 'e.g. Morning routine'),
              onSubmitted: (_) => submit(),
            ),
            Wrap(spacing: 4, children: [
              for (final e in stashEmojis)
                ChoiceChip(
                  label: Text(e, style: const TextStyle(fontSize: 18)),
                  selected: emoji == e,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => emoji = e),
                ),
            ]),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: submit, child: const Text('Save')),
          ],
        );
      },
    ),
  );
}
