import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/catalog.dart';
import '../core/models.dart';
import '../state/session.dart';
import '../widgets/common.dart';
import 'admin_users_screen.dart';
import 'explore_screen.dart';
import 'topic_picker.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<Session>();
    final user = session.me;
    final scheme = Theme.of(context).colorScheme;
    final today = localDate();

    void push(Widget w) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));

    return Scaffold(
      appBar: AppBar(title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w800))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: scheme.primary,
                  child: Text(user.name.isEmpty ? '?' : user.name.characters.first.toUpperCase(),
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: scheme.onPrimary)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    Text(user.email, style: TextStyle(color: scheme.onSurfaceVariant)),
                    if (user.role != Role.user) ...[
                      const SizedBox(height: 6),
                      Chip(
                        avatar: Icon(user.isAdmin ? Icons.admin_panel_settings_outlined : Icons.edit_note_rounded, size: 16),
                        label: Text(roleLabel(user.role)),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ]),
                ),
              ]),
              const SizedBox(height: 20),
              Row(children: [
                _Stat(
                    icon: Icons.local_fire_department_rounded,
                    value: '${user.currentStreak(today, yesterdayDate())}',
                    label: 'Day streak'),
                const SizedBox(width: 10),
                _Stat(icon: Icons.today_rounded, value: '${user.readCountOn(today)}/${user.dailyGoal}', label: 'Read today'),
                const SizedBox(width: 10),
                _Stat(icon: Icons.school_outlined, value: '${user.completedLessonIds.length}', label: 'Lessons done'),
              ]),
              const SizedBox(height: 16),
              _Group(children: [
                ListTile(
                  leading: const Icon(Icons.interests_outlined),
                  title: const Text('Topics'),
                  subtitle: Text(user.topics.map((t) => topicById(t).name).join(', ')),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => push(const TopicPicker()),
                ),
                ListTile(
                  leading: const Icon(Icons.edit_note_rounded),
                  title: const Text('My lessons'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => push(const ExploreScreen(mine: true)),
                ),
              ]),
              if (user.isAdmin)
                _Group(children: [
                  ListTile(
                    leading: const Icon(Icons.manage_accounts_outlined),
                    title: const Text('Manage users'),
                    subtitle: const Text('Roles, access and accounts'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => push(const AdminUsersScreen()),
                  ),
                ]),
              _Group(children: [
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text('Edit profile'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => push(const EditProfileScreen()),
                ),
                ListTile(
                  leading: const Icon(Icons.password_rounded),
                  title: const Text('Change password'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => push(const ChangePasswordScreen()),
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded),
                  title: const Text('Sign out'),
                  onTap: () async {
                    if (await confirm(context, title: 'Sign out?', message: 'You can sign back in any time.', confirmLabel: 'Sign out')) {
                      await session.logout();
                    }
                  },
                ),
              ]),
              _Group(children: [
                ListTile(
                  leading: Icon(Icons.delete_forever_outlined, color: scheme.error),
                  title: Text('Delete account', style: TextStyle(color: scheme.error)),
                  onTap: () => push(const DeleteAccountScreen()),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(color: scheme.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text(label, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ]),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(children: children),
      );
}

// ---------- account forms ----------

class _FormPage extends StatelessWidget {
  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  const _FormPage({required this.title, required this.formKey, required this.children});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Form(
          key: formKey,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ListView(padding: const EdgeInsets.all(20), children: children),
            ),
          ),
        ),
      );
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with BusyState {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: context.read<Session>().me.name);
  late final _email = TextEditingController(text: context.read<Session>().me.email);
  final _password = TextEditingController();

  bool get _emailChanged => _email.text.trim().toLowerCase() != context.read<Session>().me.email;

  @override
  Widget build(BuildContext context) {
    return _FormPage(title: 'Edit profile', formKey: _form, children: [
      TextFormField(
        controller: _name,
        maxLength: 60,
        decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline_rounded), border: OutlineInputBorder()),
        validator: (v) => (v ?? '').trim().isEmpty ? 'Enter your name' : null,
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline_rounded), border: OutlineInputBorder()),
        validator: (v) =>
            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim()) ? null : 'Enter a valid email',
      ),
      if (_emailChanged) ...[
        const SizedBox(height: 16),
        TextFormField(
          controller: _password,
          obscureText: true,
          decoration: const InputDecoration(
              labelText: 'Current password',
              helperText: 'Required to change your email',
              prefixIcon: Icon(Icons.lock_outline_rounded),
              border: OutlineInputBorder()),
          validator: (v) => (v ?? '').isEmpty ? 'Enter your current password' : null,
        ),
      ],
      const SizedBox(height: 24),
      FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        onPressed: busy
            ? null
            : () {
                if (!_form.currentState!.validate()) return;
                final session = context.read<Session>();
                final nav = Navigator.of(context);
                run(() async {
                  await session.updateProfile(
                        name: _name.text.trim(),
                        email: _emailChanged ? _email.text.trim() : null,
                        currentPassword: _emailChanged ? _password.text : null,
                      );
                  nav.pop();
                }, success: 'Profile updated');
              },
        child: const Text('Save changes'),
      ),
    ]);
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> with BusyState {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _again = TextEditingController();

  @override
  Widget build(BuildContext context) {
    InputDecoration deco(String label, {String? helper}) => InputDecoration(
        labelText: label, helperText: helper, prefixIcon: const Icon(Icons.lock_outline_rounded), border: const OutlineInputBorder());
    return _FormPage(title: 'Change password', formKey: _form, children: [
      TextFormField(
        controller: _current,
        obscureText: true,
        autofillHints: const [AutofillHints.password],
        decoration: deco('Current password'),
        validator: (v) => (v ?? '').isEmpty ? 'Enter your current password' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _next,
        obscureText: true,
        autofillHints: const [AutofillHints.newPassword],
        decoration: deco('New password', helper: 'At least 8 characters'),
        validator: (v) => (v ?? '').length < 8 ? 'Use at least 8 characters' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _again,
        obscureText: true,
        decoration: deco('Confirm new password'),
        validator: (v) => v != _next.text ? "Passwords don't match" : null,
      ),
      const SizedBox(height: 12),
      Text('You will stay signed in here and be signed out on other devices.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      const SizedBox(height: 24),
      FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        onPressed: busy
            ? null
            : () {
                if (!_form.currentState!.validate()) return;
                final session = context.read<Session>();
                final nav = Navigator.of(context);
                run(() async {
                  await session.changePassword(_current.text, _next.text);
                  nav.pop();
                }, success: 'Password changed');
              },
        child: const Text('Change password'),
      ),
    ]);
  }
}

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});
  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> with BusyState {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _FormPage(title: 'Delete account', formKey: _form, children: [
      Icon(Icons.warning_amber_rounded, size: 48, color: scheme.error),
      const SizedBox(height: 12),
      const Text(
        'This permanently deletes your account, stashes, reading progress and private lessons. '
        'Lessons you wrote that were published stay in the library without your name. This can\'t be undone.',
        style: TextStyle(fontSize: 15, height: 1.5),
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _password,
        obscureText: true,
        decoration: const InputDecoration(
            labelText: 'Password', prefixIcon: Icon(Icons.lock_outline_rounded), border: OutlineInputBorder()),
        validator: (v) => (v ?? '').isEmpty ? 'Enter your password to confirm' : null,
      ),
      const SizedBox(height: 24),
      FilledButton(
        style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50), backgroundColor: scheme.error, foregroundColor: scheme.onError),
        onPressed: busy
            ? null
            : () {
                if (!_form.currentState!.validate()) return;
                run(() async {
                  final session = context.read<Session>();
                  final nav = Navigator.of(context);
                  await session.deleteAccount(_password.text);
                  nav.popUntil((r) => r.isFirst);
                });
              },
        child: const Text('Delete my account'),
      ),
    ]);
  }
}
