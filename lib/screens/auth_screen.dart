import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../state/session.dart';
import '../widgets/common.dart';
import '../widgets/fx.dart';
import '../widgets/mascot.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with BusyState {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _obscure = true;
  bool _failed = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final session = context.read<Session>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _failed = false);
    await run(
      () => _register
          ? session.register(_name.text.trim(), _email.text.trim(), _password.text)
          : session.login(_email.text.trim(), _password.text),
    );
    if (mounted && session.status != SessionStatus.signedIn) setState(() => _failed = true);
    // Don't let an earlier "wrong password" message linger over the next screen.
    if (session.status == SessionStatus.signedIn) {
      messenger.clearSnackBars();
      session.notice = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final notice = context.select<Session, String?>((s) => s.notice);

    final (mood, line) = busy
        ? (MascotMood.thinking, 'Hang on, checking...')
        : _failed
        ? (MascotMood.sad, "Hmm, that didn't work. Give it another go?")
        : _register
        ? (MascotMood.wave, "Hi, I'm Kip! Let's grow your brain a little every day.")
        : (MascotMood.happy, 'Good to see you again. Your ideas are waiting!');

    return Scaffold(
      body: BlobBackground(
        colors: const [Color(0xFFFF8A3D), Color(0xFFDB2777), Color(0xFF8B5CF6)],
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _form,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFFFFB547), Color(0xFFE2572B)]),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFE2572B).withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Kernel',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        MascotSays(mood: mood, message: line, size: 96),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                          decoration: BoxDecoration(
                            color: scheme.surface.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _register ? 'Create your account' : 'Welcome back',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _register
                                    ? 'Swap a few minutes of scrolling for real ideas from great books.'
                                    : 'Sign in to pick up where you left off.',
                                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
                              ),
                              if (notice != null && !_register) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: scheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline_rounded, color: scheme.onSecondaryContainer, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(notice, style: TextStyle(color: scheme.onSecondaryContainer)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              if (_register) ...[
                                TextFormField(
                                  controller: _name,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.name],
                                  decoration: const InputDecoration(
                                    labelText: 'Name',
                                    prefixIcon: Icon(Icons.person_outline_rounded),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) => (v ?? '').trim().isEmpty ? 'Enter your name' : null,
                                ),
                                const SizedBox(height: 14),
                              ],
                              TextFormField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim())
                                    ? null
                                    : 'Enter a valid email',
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _password,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                autofillHints: [_register ? AutofillHints.newPassword : AutofillHints.password],
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  helperText: _register ? 'At least 8 characters' : null,
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    tooltip: _obscure ? 'Show password' : 'Hide password',
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                  ),
                                ),
                                validator: (v) {
                                  if ((v ?? '').isEmpty) return 'Enter your password';
                                  if (_register && v!.length < 8) return 'Use at least 8 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              FilledButton(
                                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                                onPressed: busy ? null : _submit,
                                child: busy
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2.5),
                                      )
                                    : Text(
                                        _register ? 'Create account' : 'Sign in',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                      ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: busy
                                    ? null
                                    : () => setState(() {
                                        _register = !_register;
                                        _failed = false;
                                      }),
                                child: Text(
                                  _register ? 'Already have an account? Sign in' : 'New here? Create an account',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
