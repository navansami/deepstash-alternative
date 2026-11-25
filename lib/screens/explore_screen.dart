import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../seed_data.dart';
import '../widgets/idea_card.dart';

/// Search the whole library and filter by topic.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _query = '';
  String? _topic;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final q = _query.toLowerCase().trim();
    final results = state.allCards.where((c) {
      if (_topic != null && c.topic != _topic) return false;
      if (q.isEmpty) return true;
      return [c.title, c.body, c.source, c.author].any((s) => s.toLowerCase().contains(q));
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Explore', style: TextStyle(fontWeight: FontWeight.w800))),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: SearchBar(
            hintText: 'Search ideas, books, authors',
            leading: const Icon(Icons.search),
            elevation: const WidgetStatePropertyAll(0),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('All'),
                  selected: _topic == null,
                  onSelected: (_) => setState(() => _topic = null),
                ),
              ),
              for (final t in topics)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${t.emoji} ${t.name}'),
                    selected: _topic == t.id,
                    onSelected: (_) => setState(() => _topic = _topic == t.id ? null : t.id),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? const Center(child: Text('No ideas match that search.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => IdeaCardView(card: results[i]),
                ),
        ),
      ]),
    );
  }
}
