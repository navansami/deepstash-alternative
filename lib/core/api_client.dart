import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'models.dart' show Json;

/// Where the API lives.
/// - Release web build: same origin as the page (Vercel serves both).
/// - Otherwise: --dart-define=API_BASE=..., defaulting to the local dev server.
String resolveApiBase() {
  const defined = String.fromEnvironment('API_BASE');
  if (defined.isNotEmpty) return defined;
  if (kIsWeb && kReleaseMode) return '${Uri.base.origin}/api';
  return 'http://localhost:3000/api';
}

class ApiException implements Exception {
  final int status;
  final String message;
  const ApiException(this.status, this.message);

  @override
  String toString() => message;
}

/// Persists only the refresh token. The short-lived access token stays in memory.
class TokenStore {
  static const _key = 'kernel_refresh_token';

  final FlutterSecureStorage _storage;
  TokenStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> read() => _storage.read(key: _key);
  Future<void> write(String token) => _storage.write(key: _key, value: token);
  Future<void> clear() => _storage.delete(key: _key);
}

class ApiClient {
  final String baseUrl;
  final http.Client _http;
  final TokenStore _store;

  String? _accessToken;
  String? _refreshToken;
  Completer<bool>? _refreshing;

  /// Called when the session can't be renewed (expired, revoked or account disabled).
  VoidCallback? onSessionLost;

  ApiClient({String? baseUrl, http.Client? client, TokenStore? store})
    : baseUrl = baseUrl ?? resolveApiBase(),
      _http = client ?? http.Client(),
      _store = store ?? TokenStore();

  bool get hasSession => _refreshToken != null;
  String? get refreshToken => _refreshToken;

  /// Stores tokens from an auth response ({accessToken, refreshToken, ...}).
  Future<void> setSession(Json json) async {
    _accessToken = json['accessToken'] as String?;
    _refreshToken = json['refreshToken'] as String?;
    if (_refreshToken != null) await _store.write(_refreshToken!);
  }

  Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    await _store.clear();
  }

  /// Restores a saved session. Returns the auth response (with user) or null.
  Future<Json?> restore() async {
    _refreshToken = await _store.read();
    if (_refreshToken == null) return null;
    try {
      final json = await _send('POST', '/auth/refresh', body: {'refreshToken': _refreshToken}, auth: false);
      await setSession(json);
      return json;
    } on ApiException catch (e) {
      if (e.status == 401 || e.status == 403) await clearSession();
      rethrow;
    }
  }

  Future<Json> get(String path, {Map<String, String>? query}) => _send('GET', path, query: query);
  Future<Json> post(String path, [Object? body]) => _send('POST', path, body: body ?? const {});
  Future<Json> put(String path, Object body) => _send('PUT', path, body: body);
  Future<Json> patch(String path, Object body) => _send('PATCH', path, body: body);
  Future<Json> delete(String path, [Object? body]) => _send('DELETE', path, body: body);

  /// Unauthenticated call (login, register, logout).
  Future<Json> postPublic(String path, Object body) => _send('POST', path, body: body, auth: false);

  Future<Json> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool auth = true,
    bool retry = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final request = http.Request(method, uri)..headers['Content-Type'] = 'application/json';
    if (auth && _accessToken != null) request.headers['Authorization'] = 'Bearer $_accessToken';
    if (body != null) request.body = jsonEncode(body);

    final http.Response res;
    try {
      res = await http.Response.fromStream(await _http.send(request).timeout(const Duration(seconds: 30)));
    } on TimeoutException {
      throw const ApiException(0, 'The server took too long to respond');
    } catch (_) {
      throw const ApiException(0, "Can't reach the server. Check your connection.");
    }

    // Access token expired: renew once, then retry.
    if (res.statusCode == 401 && auth && retry && _refreshToken != null) {
      if (await _renew()) return _send(method, path, body: body, query: query, retry: false);
    }

    Json json;
    try {
      json = res.body.isEmpty ? <String, dynamic>{} : jsonDecode(res.body) as Json;
    } catch (_) {
      json = {'error': 'Unexpected response from server (${res.statusCode})'};
    }
    if (res.statusCode >= 400) {
      final message = json['error'] as String? ?? 'Request failed (${res.statusCode})';
      if (auth && (res.statusCode == 401 || (res.statusCode == 403 && message.contains('disabled')))) {
        await clearSession();
        onSessionLost?.call();
      }
      throw ApiException(res.statusCode, message);
    }
    return json;
  }

  /// Single-flight refresh so parallel requests don't race to rotate the token.
  Future<bool> _renew() {
    if (_refreshing != null) return _refreshing!.future;
    final completer = _refreshing = Completer<bool>();
    () async {
      try {
        final json = await _send('POST', '/auth/refresh', body: {'refreshToken': _refreshToken}, auth: false);
        await setSession(json);
        completer.complete(true);
      } catch (_) {
        await clearSession();
        onSessionLost?.call();
        completer.complete(false);
      } finally {
        _refreshing = null;
      }
    }();
    return completer.future;
  }
}
