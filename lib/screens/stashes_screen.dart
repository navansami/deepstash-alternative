import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/catalog.dart';
import '../core/models.dart';
import '../state/stashes.dart';
import '../widgets/common.dart';
import '../widgets/idea_card.dart';
import '../widgets/lesson_tile.dart';
import '../widgets/save_sheet.dart';

class StashesScreen extends StatelessWidget {
  const StashesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stashes = context.watch<Stashes>();
    final scheme = Theme.of(context).colorScheme;

    Widget body;
    if (!stashes.loaded) {
      body = const LoadingView();
    } else if (stashes.error != null && stashes.items.isEmpty) {
      body = MessageView.error(stashes.error!, onRetry: stashes.load);
    } else {
      body = RefreshIndicator(
        onRefresh: stashes.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            for (final s in stashes.items)
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
                    decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
                    child: Icon(stashIcon(s.icon), color: scheme.onPrimaryContainer),
                  ),
                  title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${s.items.length} saved'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => StashDetailScreen(stashId: s.id))),
                ),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stashes', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'new-stash',
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('New stash'),
        onPressed: () async {
          final r = await showStashDialog(context);
          if (r == null || !context.mounted) return;
          try {
            await context.read<Stashes>().create(r.$1, r.$2);
          } catch (e) {
            if (context.mounted) showSnack(context, e.toString());
          }
        },
      ),
      body: Center(
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: body),
      ),
    );
  }
}

class StashDetailScreen extends StatefulWidget {
  final String stashId;
  const StashDetailScreen({super.key, required this.stashId});

  @override
  State<StashDetailScreen> createState() => _StashDetailScreenState();
}

class _StashDetailScreenState extends State<StashDetailScreen> {
  List<StashEntry>? _entries;
  Object? _error;

  Stash? get _stash => context.read<Stashes>().items.where((s) => s.id == widget.stashId).firstOrNull;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stash = _stash;
    if (stash == null) return;
    try {
      final entries = await context.read<Stashes>().entries(stash);
      if (mounted) {
        setState(() {
          _entries = entries;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _remove(StashEntry e) async {
    final stash = _stash!;
    final kind = e.card != null ? StashKind.card : StashKind.lesson;
    final refId = e.card?.id ?? e.lesson!.id;
    setState(() => _entries!.remove(e));
    try {
      await context.read<Stashes>().toggle(stash, kind, refId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed from ${stash.name}'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              await context.read<Stashes>().toggle(stash, kind, refId);
              _load();
            },
          ),
        ),
      );
    } catch (err) {
      if (mounted) showSnack(context, err.toString());
      _load();
    }
  }

  Future<void> _menu(String action) async {
    final stashes = context.read<Stashes>();
    final stash = _stash!;
    if (action == 'edit') {
      final r = await showStashDialog(context, title: 'Edit stash', initialName: stash.name, initialIcon: stash.icon);
      if (r != null) {
        try {
          await stashes.update(stash, name: r.$1, icon: r.$2);
        } catch (e) {
          if (mounted) showSnack(context, e.toString());
        }
      }
    } else if (action == 'delete') {
      final ok = await confirm(
        context,
        title: 'Delete "${stash.name}"?',
        message: 'The lessons and ideas stay in the library. Only this collection is removed.',
        confirmLabel: 'Delete',
        destructive: true,
      );
      if (!ok || !mounted) return;
      try {
        await stashes.remove(stash);
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) showSnack(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stashes = context.watch<Stashes>();
    final stash = stashes.items.where((s) => s.id == widget.stashId).firstOrNull;
    if (stash == null) return const Scaffold(body: SizedBox.shrink());

    Widget body;
    if (_error != null) {
      body = MessageView.error(_error!, onRetry: _load);
    } else if (_entries == null) {
      body = const LoadingView();
    } else if (_entries!.isEmpty) {
      body = const MessageView(
        icon: Icons.bookmark_add_outlined,
        title: 'Nothing saved yet',
        message: 'Tap the bookmark on any lesson or key idea to save it here.',
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          itemCount: _entries!.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final e = _entries![i];
            return Dismissible(
              key: ValueKey(e.card?.id ?? e.lesson!.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                child: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
              ),
              onDismissed: (_) => _remove(e),
              child: e.card != null ? IdeaCardView(item: e.card!) : LessonTile(lesson: e.lesson!),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(stashIcon(stash.icon)),
            const SizedBox(width: 10),
            Flexible(child: Text(stash.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _menu,
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Rename')),
              ),
              if (stashes.items.length > 1)
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(leading: Icon(Icons.delete_outline_rounded), title: Text('Delete stash')),
                ),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: body),
      ),
    );
  }
}
