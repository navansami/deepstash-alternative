import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../models.dart';
import '../widgets/idea_card.dart';
import '../widgets/save_sheet.dart';

class StashesScreen extends StatelessWidget {
  const StashesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Stashes', style: TextStyle(fontWeight: FontWeight.w800))),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New stash'),
        onPressed: () async {
          final r = await showStashDialog(context);
          if (r != null) state.createStash(r.$1, emoji: r.$2);
        },
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          for (final s in state.stashes)
            Card(
              elevation: 0,
              color: scheme.surfaceContainerLow,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(s.emoji, style: const TextStyle(fontSize: 24)),
                ),
                title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${s.cardIds.length} ${s.cardIds.length == 1 ? 'idea' : 'ideas'}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => StashDetailScreen(stash: s))),
              ),
            ),
          const SizedBox(height: 16),
          _Stat(label: 'Ideas read today', value: '${state.readTodayCount}'),
          _Stat(label: 'Current streak', value: '${state.currentStreak} 🔥'),
          _Stat(label: 'Ideas you created', value: '${state.userCards.length}'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => ListTile(
        dense: true,
        title: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      );
}

class StashDetailScreen extends StatelessWidget {
  final Stash stash;
  const StashDetailScreen({super.key, required this.stash});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final cards = stash.cardIds.map(state.cardById).whereType<IdeaCard>().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${stash.emoji}  ${stash.name}', style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'rename') {
                final r = await showStashDialog(context,
                    title: 'Edit stash', initialName: stash.name, initialEmoji: stash.emoji);
                if (r != null) state.renameStash(stash, r.$1, r.$2);
              } else if (v == 'delete') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Delete "${stash.name}"?'),
                    content: const Text('The ideas stay in your library; only this collection is removed.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  Navigator.of(context).pop();
                  state.deleteStash(stash);
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'rename', child: Text('Rename')),
              if (state.stashes.length > 1) const PopupMenuItem(value: 'delete', child: Text('Delete stash')),
            ],
          ),
        ],
      ),
      body: cards.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('🗂️', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text('Nothing here yet.\nTap the bookmark on any idea to save it.', textAlign: TextAlign.center),
                ]),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: cards.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final card = cards[i];
                return Dismissible(
                  key: ValueKey(card.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Text('Remove'),
                  ),
                  onDismissed: (_) {
                    state.toggleInStash(stash, card.id);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Removed from ${stash.name}'),
                      action: SnackBarAction(label: 'Undo', onPressed: () => state.toggleInStash(stash, card.id)),
                    ));
                  },
                  child: IdeaCardView(
                    card: card,
                    onDelete: card.isUser ? () => state.deleteUserCard(card.id) : null,
                  ),
                );
              },
            ),
    );
  }
}
