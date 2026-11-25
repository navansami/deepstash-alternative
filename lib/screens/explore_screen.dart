import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/catalog.dart';
import '../core/models.dart';
import '../widgets/common.dart';
import '../widgets/lesson_tile.dart';
import 'lesson_editor_screen.dart';

/// Browse and search full lessons. Also used for "My lessons" ([mine] = true).
class ExploreScreen extends StatefulWidget {
  final bool mine;
  const ExploreScreen({super.key, this.mine = false});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<LessonSummary> _lessons = [];
  String _query = '';
  String? _topic;
  bool _loading = true;
  bool _hasMore = false;
  Object? _error;
  Timer? _debounce;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    final id = ++_requestId;
    setState(() {
      _loading = !more;
      _error = null;
    });
    try {
      final json = await context.read<ApiClient>().get('/lessons', query: {
        'topic': ?_topic,
        if (_query.trim().isNotEmpty) 'q': _query.trim(),
        if (widget.mine) 'mine': '1',
        if (more) 'skip': '${_lessons.length}',
      });
      if (!mounted || id != _requestId) return; // a newer search superseded this one
      final items = (json['lessons'] as List).map((l) => LessonSummary.fromJson(l as Json));
      setState(() {
        if (!more) _lessons.clear();
        _lessons.addAll(items);
        _hasMore = json['hasMore'] as bool? ?? false;
      });
    } catch (e) {
      if (mounted && id == _requestId) setState(() => _error = e);
    } finally {
      if (mounted && id == _requestId) setState(() => _loading = false);
    }
  }

  void _onSearch(String v) {
    _query = v;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _load);
  }

  Future<void> _write() async {
    final created = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const LessonEditorScreen()));
    if (created == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.mine ? 'My lessons' : 'Explore', style: const TextStyle(fontWeight: FontWeight.w800))),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: widget.mine ? 'write-mine' : 'write',
        onPressed: _write,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('Write a lesson'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(children: [
            if (!widget.mine) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: SearchBar(
                  hintText: 'Search lessons, books, authors',
                  leading: const Icon(Icons.search_rounded),
                  elevation: const WidgetStatePropertyAll(0),
                  onChanged: _onSearch,
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
                        onSelected: (_) {
                          setState(() => _topic = null);
                          _load();
                        },
                      ),
                    ),
                    for (final t in topics)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: Icon(t.icon, size: 18),
                          label: Text(t.name),
                          selected: _topic == t.id,
                          onSelected: (_) {
                            setState(() => _topic = _topic == t.id ? null : t.id);
                            _load();
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
            Expanded(child: _results()),
          ]),
        ),
      ),
    );
  }

  Widget _results() {
    if (_loading) return const LoadingView();
    if (_error != null) return MessageView.error(_error!, onRetry: _load);
    if (_lessons.isEmpty) {
      return widget.mine
          ? const MessageView(
              icon: Icons.edit_note_rounded,
              title: 'No lessons yet',
              message: 'Write up an idea from a book, talk or experience. Only you can see it unless an editor publishes it.',
            )
          : const MessageView(icon: Icons.search_off_rounded, title: 'No lessons match', message: 'Try another search or topic.');
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: _lessons.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          if (i == _lessons.length) {
            return Center(child: TextButton(onPressed: () => _load(more: true), child: const Text('Load more')));
          }
          return LessonTile(lesson: _lessons[i], onReturn: _load);
        },
      ),
    );
  }
}
