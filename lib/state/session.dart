import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../core/catalog.dart';
import '../core/models.dart';

enum SessionStatus { loading, signedOut, signedIn }

/// Signed-in user, authentication and account actions.
class Session extends ChangeNotifier {
  final ApiClient api;
  Session(this.api) {
    api.onSessionLost = _onLost;
  }

  SessionStatus status = SessionStatus.loading;
  User? user;
  String? notice; // e.g. "Your session expired"

  User get me => user!;

  Future<void> restore() async {
    try {
      final json = await api.restore();
      _setUser(json?['user'] as Json?);
    } on ApiException catch (e) {
      if (e.status == 0) notice = e.message; // offline: show sign-in with a hint
      _setUser(null);
    }
  }

  Future<void> login(String email, String password) async {
    final json = await api.postPublic('/auth/login', {'email': email, 'password': password});
    await api.setSession(json);
    _setUser(json['user'] as Json);
  }

  Future<void> register(String name, String email, String password) async {
    final json = await api.postPublic('/auth/register', {'name': name, 'email': email, 'password': password});
    await api.setSession(json);
    _setUser(json['user'] as Json);
  }

  Future<void> logout() async {
    final saved = api.refreshToken;
    if (saved != null) {
      try {
        await api.postPublic('/auth/logout', {'refreshToken': saved});
      } catch (_) {
        /* best effort */
      }
    }
    await api.clearSession();
    _setUser(null);
  }

  Future<void> reload() async => _setUser((await api.get('/me'))['user'] as Json);

  Future<void> updateProfile({String? name, String? email, List<String>? topics, String? currentPassword}) async {
    final json = await api.patch('/me', {
      'name': ?name,
      'email': ?email,
      'topics': ?topics,
      if (currentPassword != null && currentPassword.isNotEmpty) 'currentPassword': currentPassword,
    });
    _setUser(json['user'] as Json);
  }

  Future<void> changePassword(String current, String next) async {
    final json = await api.post('/me/password', {'currentPassword': current, 'newPassword': next});
    await api.setSession(json);
    _setUser(json['user'] as Json);
  }

  Future<void> deleteAccount(String password) async {
    await api.delete('/me', {'password': password});
    await api.clearSession();
    _setUser(null);
  }

  /// Records a read toward today's goal. Errors are swallowed: progress is best-effort.
  Future<void> recordProgress(StashKind kind, String id) async {
    final today = localDate();
    if (user != null && kind == StashKind.card && user!.progressDate == today && user!.readIds.contains(id)) return;
    try {
      final json = await api.post('/me/progress', {'kind': kind.name, 'id': id, 'date': today});
      _setUser(json['user'] as Json);
    } catch (_) {}
  }

  Future<void> toggleLike(String cardId) async {
    final u = user;
    if (u == null) return;
    final liked = {...u.likedCardIds};
    if (!liked.remove(cardId)) liked.add(cardId);
    user = u.copyWith(likedCardIds: liked); // optimistic
    notifyListeners();
    try {
      await api.post('/me/likes/${Uri.encodeComponent(cardId)}');
    } catch (_) {
      user = u;
      notifyListeners();
    }
  }

  void _setUser(Json? json) {
    user = json == null ? null : User.fromJson(json);
    status = user == null ? SessionStatus.signedOut : SessionStatus.signedIn;
    notifyListeners();
  }

  void _onLost() {
    if (status != SessionStatus.signedIn) return;
    notice = 'Your session ended. Please sign in again.';
    _setUser(null);
  }
}
