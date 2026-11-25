import 'package:material_ui/material_ui.dart';

import '../core/catalog.dart';
import 'fx.dart';
import 'mascot.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Mascot(size: 88, mood: MascotMood.thinking),
        SizedBox(height: 8),
        BouncingDots(),
      ],
    ),
  );
}

class MessageView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final MascotMood mood;

  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.mood = MascotMood.happy,
  });

  factory MessageView.error(Object error, {VoidCallback? onRetry}) => MessageView(
    icon: Icons.cloud_off_rounded,
    mood: MascotMood.sad,
    title: 'Something went wrong',
    message: error.toString(),
    actionLabel: onRetry == null ? null : 'Try again',
    onAction: onRetry,
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: FadeSlideIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 150,
                height: 140,
                child: Stack(
                  children: [
                    Center(child: Mascot(size: 130, mood: mood)),
                    Positioned(
                      right: 4,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                        ),
                        child: Icon(icon, size: 20, color: scheme.onPrimaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
                ),
              ],
              if (actionLabel != null) ...[
                const SizedBox(height: 20),
                FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) async {
  final scheme = Theme.of(context).colorScheme;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError)
              : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok ?? false;
}

class TopicLabel extends StatelessWidget {
  final String topicId;
  final Color? color;
  const TopicLabel(this.topicId, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final t = topicById(topicId);
    final c = color ?? t.color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(t.icon, size: 15, color: c),
        const SizedBox(width: 4),
        Text(
          t.name,
          style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 12.5),
        ),
      ],
    );
  }
}

/// Wraps an async action with a busy flag and error snackbar.
mixin BusyState<T extends StatefulWidget> on State<T> {
  bool busy = false;

  Future<void> run(Future<void> Function() action, {String? success}) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await action();
      if (mounted && success != null) showSnack(context, success);
    } catch (e) {
      if (mounted) showSnack(context, e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
