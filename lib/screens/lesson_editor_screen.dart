import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/catalog.dart';
import '../core/models.dart';
import '../state/session.dart';
import '../widgets/common.dart';
import '../widgets/markdown_view.dart';

/// Create or edit a full lesson. Pops with `true` when something changed.
class LessonEditorScreen extends StatefulWidget {
  final Lesson? lesson;
  const LessonEditorScreen({super.key, this.lesson});

  @override
  State<LessonEditorScreen> createState() => _LessonEditorScreenState();
}

class _CardDraft {
  final String? id;
  CardType type;
  final TextEditingController title;
  final TextEditingController body;
  _CardDraft({this.id, this.type = CardType.idea, String title = '', String body = ''})
      : title = TextEditingController(text: title),
        body = TextEditingController(text: body);
  void dispose() {
    title.dispose();
    body.dispose();
  }
}

class _LessonEditorScreenState extends State<LessonEditorScreen> with BusyState {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.lesson?.title);
  late final _summary = TextEditingController(text: widget.lesson?.summary);
  late final _source = TextEditingController(text: widget.lesson?.source);
  late final _author = TextEditingController(text: widget.lesson?.author);
  late final _body = TextEditingController(text: widget.lesson?.body);
  late final List<TextEditingController> _takeaways =
      (widget.lesson?.takeaways ?? const ['']).map((t) => TextEditingController(text: t)).toList();
  late final List<_CardDraft> _cards = widget.lesson?.cards
          .map((c) => _CardDraft(id: c.id, type: c.type, title: c.title, body: c.body))
          .toList() ??
      [_CardDraft()];
  late String _topic = widget.lesson?.topic ?? topics.first.id;
  late bool _public = widget.lesson?.isPublic ?? false;
  bool _preview = false;

  bool get _editing => widget.lesson != null;

  @override
  void dispose() {
    for (final c in [_title, _summary, _source, _author, _body, ..._takeaways]) {
      c.dispose();
    }
    for (final c in _cards) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) {
      showSnack(context, 'Please fix the highlighted fields');
      return;
    }
    final payload = {
      'title': _title.text.trim(),
      'summary': _summary.text.trim(),
      'topic': _topic,
      'source': _source.text.trim(),
      'author': _author.text.trim(),
      'body': _body.text.trim(),
      'takeaways': _takeaways.map((t) => t.text.trim()).where((t) => t.isNotEmpty).toList(),
      'cards': [
        for (final c in _cards)
          LessonCard(id: c.id, type: c.type, title: c.title.text.trim(), body: c.body.text.trim()).toJson(),
      ],
      'visibility': _public ? 'public' : 'private',
    };
    await run(() async {
      final api = context.read<ApiClient>();
      if (_editing) {
        await api.put('/lessons/${widget.lesson!.id}', payload);
      } else {
        await api.post('/lessons', payload);
      }
      if (mounted) Navigator.of(context).pop(true);
    }, success: _editing ? 'Lesson updated' : 'Lesson created');
  }

  Future<void> _delete() async {
    final ok = await confirm(context,
        title: 'Delete this lesson?',
        message: 'It will also be removed from everyone\'s stashes. This can\'t be undone.',
        confirmLabel: 'Delete',
        destructive: true);
    if (!ok || !mounted) return;
    await run(() async {
      await context.read<ApiClient>().delete('/lessons/${widget.lesson!.id}');
      if (mounted) Navigator.of(context).pop(true);
    }, success: 'Lesson deleted');
  }

  String? _required(String? v, {int min = 1, String label = 'This field'}) =>
      (v ?? '').trim().length < min ? (min > 1 ? '$label needs at least $min characters' : '$label is required') : null;

  @override
  Widget build(BuildContext context) {
    final canPublish = context.select<Session, bool>((s) => s.user?.canPublish ?? false);
    final scheme = Theme.of(context).colorScheme;
    const border = OutlineInputBorder();

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit lesson' : 'Write a lesson'),
        actions: [
          if (_editing) IconButton(tooltip: 'Delete', onPressed: busy ? null : _delete, icon: const Icon(Icons.delete_outline_rounded)),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(onPressed: busy ? null : _save, child: Text(_editing ? 'Save' : 'Create')),
          ),
        ],
      ),
      body: Form(
        key: _form,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
              children: [
                if (busy) const LinearProgressIndicator(),
                _section('Basics'),
                TextFormField(
                  controller: _title,
                  maxLength: 120,
                  decoration: const InputDecoration(labelText: 'Title', border: border),
                  validator: (v) => _required(v, min: 3, label: 'Title'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _summary,
                  maxLength: 280,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'One-line summary', border: border),
                  validator: (v) => _required(v, label: 'Summary'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _topic,
                  decoration: const InputDecoration(labelText: 'Topic', border: border),
                  items: [
                    for (final t in topics)
                      DropdownMenuItem(
                          value: t.id, child: Row(children: [Icon(t.icon, size: 18), const SizedBox(width: 10), Text(t.name)])),
                  ],
                  onChanged: (v) => setState(() => _topic = v!),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _source,
                      maxLength: 120,
                      decoration: const InputDecoration(labelText: 'Source (book, talk...)', border: border),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _author,
                      maxLength: 120,
                      decoration: const InputDecoration(labelText: 'Author', border: border),
                    ),
                  ),
                ]),
                _section('Lesson', trailing: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: false, icon: Icon(Icons.edit_outlined, size: 18), label: Text('Write')),
                    ButtonSegment(value: true, icon: Icon(Icons.visibility_outlined, size: 18), label: Text('Preview')),
                  ],
                  selected: {_preview},
                  onSelectionChanged: (s) => setState(() => _preview = s.first),
                )),
                if (_preview)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        border: Border.all(color: scheme.outlineVariant), borderRadius: BorderRadius.circular(8)),
                    child: _body.text.trim().isEmpty
                        ? Text('Nothing to preview yet.', style: TextStyle(color: scheme.onSurfaceVariant))
                        : MarkdownView(_body.text),
                  )
                else
                  TextFormField(
                    controller: _body,
                    minLines: 12,
                    maxLines: 30,
                    maxLength: 20000,
                    decoration: const InputDecoration(
                      border: border,
                      alignLabelWithHint: true,
                      labelText: 'Body (Markdown)',
                      helperText: 'Use ## for section headings, **bold**, *italic*, - for lists, > for quotes.',
                      helperMaxLines: 2,
                    ),
                    validator: (v) => _required(v, min: 50, label: 'The lesson'),
                  ),
                _section('Key takeaways', trailing: TextButton.icon(
                  onPressed: _takeaways.length >= 8 ? null : () => setState(() => _takeaways.add(TextEditingController())),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add'),
                )),
                for (var i = 0; i < _takeaways.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextFormField(
                      controller: _takeaways[i],
                      maxLength: 200,
                      decoration: InputDecoration(
                        border: border,
                        prefixIcon: const Icon(Icons.check_rounded),
                        hintText: 'Takeaway ${i + 1}',
                        suffixIcon: IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => setState(() => _takeaways.removeAt(i).dispose()),
                        ),
                      ),
                    ),
                  ),
                _section('Key idea cards', trailing: TextButton.icon(
                  onPressed: _cards.length >= 6 ? null : () => setState(() => _cards.add(_CardDraft())),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add'),
                )),
                Text('Short cards (1 to 6) that appear in the daily feed and link back to this lesson.',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 12),
                for (var i = 0; i < _cards.length; i++) _cardEditor(i),
                _section('Visibility'),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _public,
                  onChanged: canPublish || _public ? (v) => setState(() => _public = v) : null,
                  secondary: Icon(_public ? Icons.public_rounded : Icons.lock_outline_rounded),
                  title: Text(_public ? 'Published to everyone' : 'Private (only you)'),
                  subtitle: Text(canPublish
                      ? 'Published lessons appear in Explore and in feeds.'
                      : 'Editors can publish lessons to everyone. Yours stay private to you.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardEditor(int i) {
    final c = _cards[i];
    final scheme = Theme.of(context).colorScheme;
    const border = OutlineInputBorder();
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: SegmentedButton<CardType>(
                showSelectedIcon: false,
                segments: [
                  for (final t in CardType.values)
                    ButtonSegment(value: t, icon: Icon(cardTypeIcon(t), size: 18), label: Text(t.label)),
                ],
                selected: {c.type},
                onSelectionChanged: (s) => setState(() => c.type = s.first),
              ),
            ),
            IconButton(
              tooltip: 'Remove card',
              onPressed: _cards.length <= 1 ? null : () => setState(() => _cards.removeAt(i).dispose()),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ]),
          const SizedBox(height: 12),
          TextFormField(
            controller: c.title,
            maxLength: 80,
            decoration: const InputDecoration(labelText: 'Card title', border: border),
            validator: (v) => _required(v, label: 'Card title'),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: c.body,
            maxLength: 400,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(labelText: c.type == CardType.quote ? 'Quote' : 'The idea', border: border),
            validator: (v) => _required(v, label: 'Card text'),
          ),
        ]),
      ),
    );
  }

  Widget _section(String title, {Widget? trailing}) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Row(children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
          ?trailing,
        ]),
      );
}
