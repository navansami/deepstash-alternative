import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../models.dart';
import '../seed_data.dart';
import '../widgets/idea_card.dart';

/// Write your own idea card, with a live preview, and optionally stash it.
class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  static const maxBody = 400;
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _source = TextEditingController();
  final _author = TextEditingController();
  CardType _type = CardType.idea;
  String _topic = topics.first.id;
  String? _stashId;

  @override
  void initState() {
    super.initState();
    for (final c in [_title, _body, _source, _author]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_title, _body, _source, _author]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid => _title.text.trim().isNotEmpty && _body.text.trim().isNotEmpty;

  void _save(AppState state) {
    final card = state.addUserCard(
      topic: _topic,
      type: _type,
      title: _title.text,
      body: _body.text,
      source: _source.text,
      author: _author.text,
    );
    if (_stashId != null) {
      final stash = state.stashes.where((s) => s.id == _stashId).firstOrNull;
      if (stash != null) state.toggleInStash(stash, card.id);
    }
    for (final c in [_title, _body, _source, _author]) {
      c.clear();
    }
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Idea created — find it in Explore or your stash')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final preview = IdeaCard(
      id: 'preview',
      topic: _topic,
      type: _type,
      title: _title.text.isEmpty ? 'Your idea title' : _title.text,
      body: _body.text.isEmpty ? 'Explain the idea in a few sentences, in your own words.' : _body.text,
      source: _source.text,
      author: _author.text,
      isUser: true,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Create an idea', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SegmentedButton<CardType>(
            segments: [
              for (final t in CardType.values) ButtonSegment(value: t, label: Text(t.label)),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            maxLength: 80,
            decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _body,
            maxLength: maxBody,
            minLines: 4,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: _type == CardType.quote ? 'Quote' : 'The idea',
              alignLabelWithHint: true,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _source,
                decoration: const InputDecoration(labelText: 'Source (optional)', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _author,
                decoration: const InputDecoration(labelText: 'Author (optional)', border: OutlineInputBorder()),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _topic,
            decoration: const InputDecoration(labelText: 'Topic', border: OutlineInputBorder()),
            items: [
              for (final t in topics) DropdownMenuItem(value: t.id, child: Text('${t.emoji} ${t.name}')),
            ],
            onChanged: (v) => setState(() => _topic = v!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            initialValue: _stashId,
            decoration: const InputDecoration(labelText: 'Add to stash', border: OutlineInputBorder()),
            items: [
              const DropdownMenuItem(value: null, child: Text('None')),
              for (final s in state.stashes) DropdownMenuItem(value: s.id, child: Text('${s.emoji} ${s.name}')),
            ],
            onChanged: (v) => setState(() => _stashId = v),
          ),
          const SizedBox(height: 24),
          Text('Preview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          IgnorePointer(child: IdeaCardView(card: preview)),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            onPressed: _valid ? () => _save(state) : null,
            child: const Text('Publish to my library', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
