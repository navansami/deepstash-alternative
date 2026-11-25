import 'dart:async';

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/catalog.dart';
import '../core/models.dart';
import '../state/session.dart';
import '../widgets/common.dart';

/// Admin: search users, change roles, disable/enable and delete accounts.
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<AdminUser>? _users;
  int _total = 0;
  Json? _stats;
  Role? _role;
  String _query = '';
  Object? _error;
  Timer? _debounce;

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

  Future<void> _load() async {
    final api = context.read<ApiClient>();
    try {
      final results = await Future.wait([
        api.get(
          '/admin/users',
          query: {if (_query.trim().isNotEmpty) 'q': _query.trim(), if (_role != null) 'role': _role!.name},
        ),
        api.get('/admin/stats'),
      ]);
      if (!mounted) return;
      setState(() {
        _users = (results[0]['users'] as List).map((u) => AdminUser.fromJson(u as Json)).toList();
        _total = results[0]['total'] as int;
        _stats = results[1];
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _manage(AdminUser u) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _ManageUserSheet(user: u),
    );
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final meId = context.select<Session, String>((s) => s.me.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage users')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              if (_stats != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatChip(Icons.group_outlined, '${_stats!['users']} users'),
                      _StatChip(Icons.admin_panel_settings_outlined, '${_stats!['admins']} admins'),
                      _StatChip(Icons.edit_note_rounded, '${_stats!['editors']} editors'),
                      _StatChip(Icons.block_rounded, '${_stats!['disabled']} disabled'),
                      _StatChip(Icons.public_rounded, '${_stats!['publicLessons']} published lessons'),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SearchBar(
                  hintText: 'Search by name or email',
                  leading: const Icon(Icons.search_rounded),
                  elevation: const WidgetStatePropertyAll(0),
                  onChanged: (v) {
                    _query = v;
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 300), _load);
                  },
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final r in [null, ...Role.values])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(r == null ? 'All roles' : roleLabel(r)),
                          selected: _role == r,
                          onSelected: (_) {
                            setState(() => _role = r);
                            _load();
                          },
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _error != null
                    ? MessageView.error(_error!, onRetry: _load)
                    : _users == null
                    ? const LoadingView()
                    : _users!.isEmpty
                    ? const MessageView(icon: Icons.person_search_outlined, title: 'No users found')
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
                          itemCount: _users!.length + 1,
                          itemBuilder: (_, i) {
                            if (i == _users!.length) {
                              return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  'Showing ${_users!.length} of $_total',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: scheme.onSurfaceVariant),
                                ),
                              );
                            }
                            final u = _users![i];
                            final isMe = u.id == meId;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: u.disabled ? scheme.errorContainer : scheme.primaryContainer,
                                child: Icon(
                                  u.disabled
                                      ? Icons.block_rounded
                                      : switch (u.role) {
                                          Role.admin => Icons.admin_panel_settings_outlined,
                                          Role.editor => Icons.edit_note_rounded,
                                          Role.user => Icons.person_outline_rounded,
                                        },
                                  color: u.disabled ? scheme.onErrorContainer : scheme.onPrimaryContainer,
                                ),
                              ),
                              title: Text(
                                isMe ? '${u.name} (you)' : u.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(u.email),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (u.locked)
                                    Tooltip(
                                      message: 'Locked after failed sign-ins',
                                      child: Icon(Icons.lock_clock_outlined, color: scheme.error),
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    u.disabled ? 'Disabled' : roleLabel(u.role),
                                    style: TextStyle(color: u.disabled ? scheme.error : scheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              onTap: isMe ? null : () => _manage(u),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) =>
      Chip(avatar: Icon(icon, size: 16), label: Text(label), visualDensity: VisualDensity.compact);
}

class _ManageUserSheet extends StatefulWidget {
  final AdminUser user;
  const _ManageUserSheet({required this.user});

  @override
  State<_ManageUserSheet> createState() => _ManageUserSheetState();
}

class _ManageUserSheetState extends State<_ManageUserSheet> with BusyState {
  late Role _role = widget.user.role;
  late bool _disabled = widget.user.disabled;
  bool _changed = false;

  Future<void> _patch(Map<String, Object> body) => run(() async {
    final json = await context.read<ApiClient>().patch('/admin/users/${widget.user.id}', body);
    final u = AdminUser.fromJson(json['user'] as Json);
    setState(() {
      _role = u.role;
      _disabled = u.disabled;
      _changed = true;
    });
  });

  Future<void> _delete() async {
    final ok = await confirm(
      context,
      title: 'Delete ${widget.user.name}?',
      message: 'Their account, stashes, progress and private lessons will be permanently deleted.',
      confirmLabel: 'Delete user',
      destructive: true,
    );
    if (!ok || !mounted) return;
    await run(() async {
      await context.read<ApiClient>().delete('/admin/users/${widget.user.id}');
      if (mounted) Navigator.of(context).pop(true);
    }, success: 'User deleted');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final u = widget.user;
    final fmt = DateFormat.yMMMd();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(u.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              Text(u.email, style: TextStyle(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(
                [
                  if (u.createdAt != null) 'Joined ${fmt.format(u.createdAt!.toLocal())}',
                  if (u.lastLoginAt != null) 'last sign-in ${fmt.format(u.lastLoginAt!.toLocal())}',
                ].join(' · '),
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
              ),
              if (busy) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
              const SizedBox(height: 20),
              const Text('Role', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              SegmentedButton<Role>(
                segments: [for (final r in Role.values) ButtonSegment(value: r, label: Text(roleLabel(r)))],
                selected: {_role},
                onSelectionChanged: busy ? null : (s) => _patch({'role': s.first.name}),
              ),
              const SizedBox(height: 6),
              Text(switch (_role) {
                Role.user => 'Can read, save and write private lessons.',
                Role.editor => 'Can also publish lessons and edit any lesson.',
                Role.admin => 'Full access, including managing users.',
              }, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: !_disabled,
                onChanged: busy ? null : (v) => _patch({'disabled': !v}),
                secondary: Icon(_disabled ? Icons.block_rounded : Icons.check_circle_outline_rounded),
                title: Text(_disabled ? 'Account disabled' : 'Account active'),
                subtitle: const Text('Disabling signs the user out everywhere and blocks sign-in.'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: scheme.error, minimumSize: const Size.fromHeight(46)),
                onPressed: busy ? null : _delete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Delete user'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
