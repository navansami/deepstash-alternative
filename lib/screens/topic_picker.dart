import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/catalog.dart';
import '../state/session.dart';
import '../widgets/common.dart';
import '../widgets/fx.dart';
import '../widgets/mascot.dart';
import '../widgets/topic_art.dart';

/// Topic selection, used for onboarding and for editing interests later.
class TopicPicker extends StatefulWidget {
  final bool onboarding;
  const TopicPicker({super.key, this.onboarding = false});

  @override
  State<TopicPicker> createState() => _TopicPickerState();
}

class _TopicPickerState extends State<TopicPicker> with BusyState {
  static const _min = 3;
  late final Set<String> _selected = {...context.read<Session>().me.topics};

  Future<void> _save() => run(() async {
    await context.read<Session>().updateProfile(topics: _selected.toList());
    if (mounted && !widget.onboarding) Navigator.of(context).pop();
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final remaining = _min - _selected.length;
    final name = context.select<Session, String>((s) => s.user?.name.split(' ').first ?? '');

    return Scaffold(
      appBar: widget.onboarding ? null : AppBar(title: const Text('Your topics')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.onboarding ? 'Hi $name. What do you want to learn?' : 'Choose what your feed covers',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pick at least $_min topics. Your daily feed of key ideas is built from these.',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  MascotSays(
                    size: 76,
                    mood: _selected.isEmpty
                        ? MascotMood.wave
                        : remaining > 0
                        ? MascotMood.happy
                        : MascotMood.cheer,
                    message: _selected.isEmpty
                        ? 'What makes you curious? Tap a few.'
                        : remaining > 0
                        ? 'Ooh, nice choice! $remaining to go.'
                        : 'Great mix! I can already feel the ideas sprouting.',
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 4 : 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.45,
                      children: [
                        for (final (i, t) in topics.indexed)
                          FadeSlideIn(
                            delay: Duration(milliseconds: 60 * i),
                            child: _TopicTile(
                              topic: t,
                              selected: _selected.contains(t.id),
                              onTap: () => setState(() {
                                if (!_selected.remove(t.id)) _selected.add(t.id);
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                    onPressed: remaining > 0 || busy ? null : _save,
                    child: busy
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                        : Text(
                            remaining > 0 ? 'Pick $remaining more' : (widget.onboarding ? 'Start reading' : 'Save'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final Topic topic;
  final bool selected;
  final VoidCallback onTap;
  const _TopicTile({required this.topic, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(22);
    return AnimatedScale(
      scale: selected ? 1.0 : 0.96,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: selected ? topic.gradient : null,
          color: selected ? null : scheme.surfaceContainerLow,
          borderRadius: radius,
          border: Border.all(color: selected ? Colors.transparent : scheme.outlineVariant, width: 1.5),
          boxShadow: selected
              ? [BoxShadow(color: topic.color.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))]
              : const [],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      selected
                          ? Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(topic.icon, color: Colors.white, size: 24),
                            )
                          : TopicBadge(topic, size: 44),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (c, a) => ScaleTransition(
                          scale: CurvedAnimation(parent: a, curve: Curves.elasticOut),
                          child: c,
                        ),
                        child: selected
                            ? const Icon(Icons.check_circle_rounded, key: ValueKey(1), color: Colors.white, size: 26)
                            : Icon(
                                Icons.add_circle_outline_rounded,
                                key: const ValueKey(0),
                                color: scheme.outline,
                                size: 26,
                              ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      topic.name,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: selected ? Colors.white : scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
