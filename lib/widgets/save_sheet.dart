import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/catalog.dart';
import '../core/models.dart';
import '../state/stashes.dart';
import 'common.dart';

/// Bottom sheet to add/remove a lesson or card from the user's stashes.
Future<void> showSaveSheet(BuildContext context, StashKind kind, String refId) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _SaveSheet(kind: kind, refId: refId),
  );
}

class _SaveSheet extends StatefulWidget {
  final StashKind kind;
  final String refId;
  const _SaveSheet({required this.kind, required this.refId});

  @override
  State<_SaveSheet> createState() => _SaveSheetState();
}

class _SaveSheetState extends State<_SaveSheet> {
  String? _pending;

  Future<void> _toggle(Stash s) async {
    setState(() => _pending = s.id);
    try {
      await context.read<Stashes>().toggle(s, widget.kind, widget.refId);
    } catch (e) {
      if (mounted) showSnack(context, e.toString());
    } finally {
      if (mounted) setState(() => _pending = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stashes = context.watch<Stashes>();
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              widget.kind == StashKind.lesson ? 'Save lesson to' : 'Save idea to',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final s in stashes.items)
                  CheckboxListTile(
                    value: s.contains(widget.kind, widget.refId),
                    onChanged: _pending == null ? (_) => _toggle(s) : null,
                    secondary: _pending == s.id
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(stashIcon(s.icon)),
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${s.items.length} saved'),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_rounded),
            title: const Text('New stash'),
            onTap: () async {
              final r = await showStashDialog(context);
              if (r == null || !context.mounted) return;
              try {
                final s = await context.read<Stashes>().create(r.$1, r.$2);
                await _toggle(s);
              } catch (e) {
                if (context.mounted) showSnack(context, e.toString());
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Name + icon dialog. Returns (name, iconKey) or null.
Future<(String, String)?> showStashDialog(
  BuildContext context, {
  String title = 'New stash',
  String initialName = '',
  String initialIcon = 'bookmark',
}) {
  final controller = TextEditingController(text: initialName);
  var icon = initialIcon;
  return showDialog<(String, String)>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        void submit() {
          if (controller.text.trim().isEmpty) return;
          Navigator.pop(ctx, (controller.text.trim(), icon));
        }

        final scheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 40,
                decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Morning routine'),
                onSubmitted: (_) => submit(),
              ),
              const SizedBox(height: 8),
              Text('Icon', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in stashIcons.entries)
                    IconButton.filledTonal(
                      isSelected: icon == e.key,
                      tooltip: e.key,
                      style: IconButton.styleFrom(
                        backgroundColor: icon == e.key ? scheme.primary : null,
                        foregroundColor: icon == e.key ? scheme.onPrimary : null,
                      ),
                      onPressed: () => setState(() => icon = e.key),
                      icon: Icon(e.value),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(onPressed: submit, child: const Text('Save')),
          ],
        );
      },
    ),
  );
}
