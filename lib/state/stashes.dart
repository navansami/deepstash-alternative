import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../core/models.dart';

/// The signed-in user's stashes (collections).
class Stashes extends ChangeNotifier {
  final ApiClient api;
  Stashes(this.api);

  List<Stash> items = [];
  bool loaded = false;
  String? error;

  Future<void> load() async {
    try {
      final json = await api.get('/stashes');
      items = (json['stashes'] as List).map((s) => Stash.fromJson(s as Json)).toList();
      error = null;
    } on ApiException catch (e) {
      error = e.message;
    }
    loaded = true;
    notifyListeners();
  }

  void clear() {
    items = [];
    loaded = false;
    notifyListeners();
  }

  bool isSaved(StashKind kind, String refId) => items.any((s) => s.contains(kind, refId));

  Future<Stash> create(String name, String icon) async {
    final json = await api.post('/stashes', {'name': name, 'icon': icon});
    final stash = Stash.fromJson(json['stash'] as Json);
    items = [...items, stash];
    notifyListeners();
    return stash;
  }

  Future<void> update(Stash stash, {String? name, String? icon}) async {
    final json = await api.patch('/stashes/${stash.id}', {'name': ?name, 'icon': ?icon});
    _replace(Stash.fromJson(json['stash'] as Json));
  }

  Future<void> remove(Stash stash) async {
    await api.delete('/stashes/${stash.id}');
    items = items.where((s) => s.id != stash.id).toList();
    notifyListeners();
  }

  /// Adds or removes an item; returns true if it is now saved.
  Future<bool> toggle(Stash stash, StashKind kind, String refId) async {
    final json = await api.post('/stashes/${stash.id}/items', {'kind': kind.name, 'refId': refId});
    _replace(Stash.fromJson(json['stash'] as Json));
    return json['saved'] as bool;
  }

  Future<List<StashEntry>> entries(Stash stash) async {
    final json = await api.get('/stashes/${stash.id}');
    _replace(Stash.fromJson(json['stash'] as Json));
    return (json['items'] as List).map((e) => StashEntry.fromJson(e as Json)).toList();
  }

  void _replace(Stash s) {
    items = [for (final x in items) x.id == s.id ? s : x];
    notifyListeners();
  }
}
