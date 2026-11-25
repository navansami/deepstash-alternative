import 'package:material_ui/material_ui.dart';

import '../app_state.dart';
import '../seed_data.dart';

/// Topic picker. Used for first-run onboarding and later for editing interests.
class TopicPicker extends StatefulWidget {
  final Set<String> initial;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final ValueChanged<Set<String>> onDone;

  const TopicPicker({
    super.key,
    required this.initial,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onDone,
  });

  @override
  State<TopicPicker> createState() => _TopicPickerState();
}

class _TopicPickerState extends State<TopicPicker> {
  late final Set<String> _selected = {...widget.initial};
  static const _min = 3;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final remaining = _min - _selected.length;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(widget.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(widget.subtitle, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 4 : 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                for (final t in topics)
                  _TopicTile(
                    emoji: t.emoji,
                    name: t.name,
                    selected: _selected.contains(t.id),
                    onTap: () => setState(() {
                      if (!_selected.remove(t.id)) _selected.add(t.id);
                    }),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
            onPressed: remaining > 0 ? null : () => widget.onDone(_selected),
            child: Text(remaining > 0 ? 'Pick $remaining more' : widget.buttonLabel,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final String emoji, name;
  final bool selected;
  final VoidCallback onTap;
  const _TopicTile({required this.emoji, required this.name, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const Spacer(),
              if (selected) Icon(Icons.check_circle, color: scheme.primary),
            ]),
            const Spacer(),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ]),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      body: TopicPicker(
        initial: const {},
        title: 'Learn something\nin the time you\'d scroll.',
        subtitle: 'Pick at least 3 topics. We\'ll build a fresh feed of short idea cards for you every day.',
        buttonLabel: 'Start reading',
        onDone: state.completeOnboarding,
      ),
    );
  }
}
