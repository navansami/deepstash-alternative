import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/catalog.dart';
import '../core/models.dart';
import '../state/session.dart';
import '../state/stashes.dart';
import '../widgets/common.dart';
import '../widgets/fx.dart';
import '../widgets/idea_card.dart';
import '../widgets/markdown_view.dart';
import '../widgets/mascot.dart';
import '../widgets/save_sheet.dart';
import '../widgets/topic_art.dart';
import 'lesson_editor_screen.dart';

Future<void> openLesson(BuildContext context, String idOrSlug) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => LessonScreen(idOrSlug: idOrSlug)));

/// Full lesson reader: article, takeaways and key-idea cards.
class LessonScreen extends StatefulWidget {
  final String idOrSlug;
  const LessonScreen({super.key, required this.idOrSlug});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> with BusyState {
  Lesson? _lesson;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final json = await context.read<ApiClient>().get('/lessons/${Uri.encodeComponent(widget.idOrSlug)}');
      if (mounted) setState(() => _lesson = Lesson.fromJson(json['lesson'] as Json));
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _edit() async {
    final api = context.read<ApiClient>();
    final changed = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => LessonEditorScreen(lesson: _lesson)));
    if (changed == true) {
      // Deleted lessons pop the editor with true and no longer load; close this screen too.
      try {
        await api.get('/lessons/${_lesson!.id}');
        await _load();
      } on ApiException catch (e) {
        if (e.status == 404 && mounted) Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = _lesson;
    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(),
        body: _error != null ? MessageView.error(_error!, onRetry: _load) : const LoadingView(),
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final topic = topicById(lesson.topic);
    final saved = context.select<Stashes, bool>((s) => s.isSaved(StashKind.lesson, lesson.id));
    final completed = context.select<Session, bool>((s) => s.user?.completedLessonIds.contains(lesson.id) ?? false);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Save lesson',
            onPressed: () => showSaveSheet(context, StashKind.lesson, lesson.id),
            icon: Icon(
              saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: saved ? scheme.primary : null,
            ),
          ),
          if (lesson.canEdit)
            IconButton(tooltip: 'Edit lesson', onPressed: _edit, icon: const Icon(Icons.edit_outlined)),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
            children: [
              FadeSlideIn(
                child: TopicBanner(
                  topic: topic,
                  height: 156,
                  borderRadius: BorderRadius.circular(26),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 18,
                        top: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.24),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: TopicLabel(topic.id, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 18,
                        child: Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 18, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              '${lesson.readMinutes} min read',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                            if (!lesson.isPublic) ...[
                              const SizedBox(width: 14),
                              const Icon(Icons.lock_outline_rounded, size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                              const Text(
                                'Private',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 0,
                        child: Mascot(size: 128, mood: completed ? MascotMood.cheer : MascotMood.reading),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                lesson.title,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, height: 1.15, letterSpacing: -0.6),
              ),
              const SizedBox(height: 10),
              Text(lesson.summary, style: TextStyle(fontSize: 18, height: 1.45, color: scheme.onSurfaceVariant)),
              if (lesson.source.isNotEmpty || lesson.author.isNotEmpty) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.menu_book_outlined, size: 18, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            if (lesson.source.isNotEmpty)
                              TextSpan(
                                text: lesson.source,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            if (lesson.source.isNotEmpty && lesson.author.isNotEmpty) const TextSpan(text: '  by  '),
                            if (lesson.author.isNotEmpty) TextSpan(text: lesson.author),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Divider()),
              MarkdownView(lesson.body),
              if (lesson.takeaways.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(22),
                    border: Border(left: BorderSide(color: topic.color, width: 6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.key_rounded, color: scheme.onSecondaryContainer),
                          const SizedBox(width: 8),
                          Text(
                            'Key takeaways',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: scheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (final t in lesson.takeaways)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Icon(Icons.check_rounded, size: 18, color: scheme.onSecondaryContainer),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  t,
                                  style: TextStyle(fontSize: 15.5, height: 1.45, color: scheme.onSecondaryContainer),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              Text('Key ideas', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Save the ones you want to remember.', style: TextStyle(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              for (final c in lesson.cards)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: IdeaCardView(
                    item: FeedCard(
                      card: c,
                      lessonId: lesson.id,
                      lessonTitle: lesson.title,
                      topic: lesson.topic,
                      source: lesson.source,
                      author: lesson.author,
                      readMinutes: lesson.readMinutes,
                    ),
                    showLessonLink: false,
                  ),
                ),
              const SizedBox(height: 16),
              completed
                  ? OutlinedButton.icon(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('Lesson completed'),
                    )
                  : FilledButton.icon(
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      onPressed: busy
                          ? null
                          : () => run(() async {
                              await context.read<Session>().recordProgress(StashKind.lesson, lesson.id);
                              if (context.mounted) {
                                celebrate(
                                  context,
                                  title: 'Lesson complete!',
                                  message: 'You finished "${lesson.title}". That idea is yours now.',
                                  action: 'Nice',
                                );
                              }
                            }),
                      icon: const Icon(Icons.task_alt_rounded),
                      label: const Text('Mark as complete', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
