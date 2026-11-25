import 'package:material_ui/material_ui.dart';

import '../core/catalog.dart';
import '../core/models.dart';
import '../screens/lesson_screen.dart';
import 'topic_art.dart';

class LessonTile extends StatelessWidget {
  final LessonSummary lesson;
  final VoidCallback? onReturn;
  const LessonTile({super.key, required this.lesson, this.onReturn});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final topic = topicById(lesson.topic);
    final meta = [
      '${lesson.readMinutes} min read',
      '${lesson.cardCount} key ideas',
      if (lesson.author.isNotEmpty) lesson.author,
    ].join(' · ');

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await openLesson(context, lesson.id);
          onReturn?.call();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopicBadge(topic, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          topic.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800,
                            color: topic.color,
                          ),
                        ),
                        if (!lesson.isPublic) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.lock_outline_rounded, size: 13, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 2),
                          Text('Private', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                        ],
                        const Spacer(),
                        if (lesson.completed)
                          Tooltip(
                            message: 'Completed',
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: cardTypeColor(CardType.tip, Theme.of(context).brightness),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(lesson.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, height: 1.25)),
                    const SizedBox(height: 4),
                    Text(
                      lesson.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Text(meta, style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
