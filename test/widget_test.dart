import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kernel/core/api_client.dart';
import 'package:kernel/core/catalog.dart';
import 'package:kernel/core/models.dart';
import 'package:kernel/main.dart';
import 'package:kernel/widgets/fx.dart';
import 'package:kernel/widgets/markdown_view.dart';
import 'package:material_ui/material_ui.dart';

class MemoryTokenStore extends TokenStore {
  String? token;
  MemoryTokenStore([this.token]);
  @override
  Future<String?> read() async => token;
  @override
  Future<void> write(String t) async => token = t;
  @override
  Future<void> clear() async => token = null;
}

http.Response _json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

Json _user({List<String> topics = const [], List<String> readIds = const []}) => {
  'id': 'u1',
  'email': 'reader@example.com',
  'name': 'Reader',
  'role': 'user',
  'topics': topics,
  'likedCardIds': <String>[],
  'completedLessonIds': <String>[],
  'progress': {'date': localDate(), 'readIds': readIds},
  'streak': 0,
  'lastGoalDate': '',
  'dailyGoal': 5,
};

void main() {
  // Looping idle animations would keep pumpAndSettle from ever settling.
  Motion.ambient = false;

  group('ApiClient', () {
    test('renews an expired access token once and retries', () async {
      final calls = <String>[];
      final client = MockClient((req) async {
        calls.add('${req.method} ${req.url.path} ${req.headers['Authorization'] ?? ''}');
        if (req.url.path == '/api/auth/refresh') {
          return _json({'user': _user(), 'accessToken': 'fresh', 'refreshToken': 'r2'});
        }
        if (req.headers['Authorization'] == 'Bearer fresh') return _json({'ok': true});
        return _json({'error': 'Session expired'}, 401);
      });
      final store = MemoryTokenStore();
      final api = ApiClient(baseUrl: 'http://x/api', client: client, store: store);
      await api.setSession({'accessToken': 'stale', 'refreshToken': 'r1'});

      expect((await api.get('/me'))['ok'], isTrue);
      expect(calls, ['GET /api/me Bearer stale', 'POST /api/auth/refresh ', 'GET /api/me Bearer fresh']);
      expect(store.token, 'r2');
    });

    test('surfaces server error messages and signals a lost session', () async {
      var lost = false;
      final client = MockClient(
        (req) async => req.url.path == '/api/auth/refresh'
            ? _json({'error': 'Session expired'}, 401)
            : _json({'error': 'Session expired'}, 401),
      );
      final store = MemoryTokenStore();
      final api = ApiClient(baseUrl: 'http://x/api', client: client, store: store)..onSessionLost = () => lost = true;
      await api.setSession({'accessToken': 'a', 'refreshToken': 'r'});

      await expectLater(api.get('/me'), throwsA(isA<ApiException>().having((e) => e.status, 'status', 401)));
      expect(lost, isTrue);
      expect(store.token, isNull);
    });

    test('reports validation errors from the server verbatim', () async {
      final api = ApiClient(
        baseUrl: 'http://x/api',
        client: MockClient((_) async => _json({'error': 'password: must be at least 8 characters'}, 400)),
        store: MemoryTokenStore(),
      );
      await expectLater(
        api.postPublic('/auth/register', {}),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('at least 8'))),
      );
    });
  });

  test('streak is only current if the goal was met today or yesterday', () {
    final u = User.fromJson({..._user(), 'streak': 4, 'lastGoalDate': '2026-11-24'});
    expect(u.currentStreak('2026-11-25', '2026-11-24'), 4);
    expect(u.currentStreak('2026-11-27', '2026-11-26'), 0);
  });

  testWidgets('MarkdownView renders headings, emphasis and lists', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MarkdownView('## Heading\n\nSome **bold** text.\n\n- First\n- Second\n\n1. One\n2. Two'),
          ),
        ),
      ),
    );
    expect(find.text('Heading'), findsOneWidget);
    expect(find.textContaining('bold', findRichText: true), findsOneWidget);
    expect(find.textContaining('Second', findRichText: true), findsOneWidget);
    expect(find.text('2.'), findsOneWidget);
  });

  testWidgets('sign in, pick topics, read the feed and open a full lesson', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    var user = _user();
    final client = MockClient((req) async {
      final path = req.url.path.replaceFirst('/api', '');
      final body = req.body.isEmpty ? <String, dynamic>{} : jsonDecode(req.body) as Json;
      switch ('${req.method} $path') {
        case 'POST /auth/login':
          if (body['password'] != 'correct horse') return _json({'error': 'Invalid email or password'}, 401);
          return _json({'user': user, 'accessToken': 'a', 'refreshToken': 'r'});
        case 'PATCH /me':
          user = _user(topics: List<String>.from(body['topics'] as List));
          return _json({'user': user});
        case 'GET /stashes':
          return _json({
            'stashes': [
              {'id': 's1', 'name': 'Saved', 'icon': 'bookmark', 'items': []},
            ],
          });
        case 'GET /feed':
          return _json({
            'cards': [
              {
                'id': 'c1',
                'type': 'idea',
                'title': 'Systems beat goals',
                'body': 'Focus on the process.',
                'lessonId': 'l1',
                'lessonTitle': 'Atomic Habits',
                'topic': 'habits',
                'source': 'Atomic Habits',
                'author': 'James Clear',
                'readMinutes': 3,
              },
            ],
            'hasMore': false,
          });
        case 'POST /me/progress':
          user = _user(topics: user['topics'] as List<String>, readIds: [body['id'] as String]);
          return _json({'user': user});
        case 'GET /lessons/l1':
          return _json({
            'lesson': {
              'id': 'l1',
              'slug': 'atomic',
              'title': 'Atomic Habits: Systems Over Goals',
              'summary': 'Small changes compound.',
              'topic': 'habits',
              'source': 'Atomic Habits',
              'author': 'James Clear',
              'readMinutes': 3,
              'visibility': 'public',
              'canEdit': false,
              'completed': false,
              'body': '## Why goals are not enough\n\nBecause systems matter.',
              'takeaways': ['Systems beat goals'],
              'cards': [
                {'id': 'c1', 'type': 'idea', 'title': 'Systems beat goals', 'body': 'Focus on the process.'},
              ],
            },
          });
      }
      return _json({'error': 'Not found: ${req.method} $path'}, 404);
    });

    await tester.pumpWidget(
      KernelApp(
        api: ApiClient(baseUrl: 'http://x/api', client: client, store: MemoryTokenStore()),
      ),
    );
    await tester.pumpAndSettle();

    // Signed out → sign-in form, with a wrong password first.
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'reader@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'wrong');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Invalid email or password'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'correct horse');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    // No topics yet → onboarding.
    expect(find.text('Pick 3 more'), findsOneWidget);
    for (final t in ['Psychology', 'Habits', 'Money']) {
      await tester.tap(find.text(t));
    }
    await tester.pump();
    await tester.tap(find.text('Start reading'));
    await tester.pumpAndSettle();

    // Feed shows the card and counts it as read.
    expect(find.text('Systems beat goals'), findsOneWidget);
    expect(find.text('1/5 today'), findsOneWidget);

    // Open the full lesson.
    await tester.tap(find.textContaining('Full lesson'));
    await tester.pumpAndSettle();
    expect(find.text('Atomic Habits: Systems Over Goals'), findsOneWidget);
    expect(find.text('Why goals are not enough'), findsOneWidget);
    expect(find.text('Key takeaways'), findsOneWidget);
  });

  test('UI source uses icons, not emoji', () {
    final emoji = RegExp(r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{1F000}-\u{1F2FF}]', unicode: true);
    final offenders = <String>[];
    for (final f in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (emoji.hasMatch(lines[i])) offenders.add('${f.path}:${i + 1}');
      }
    }
    expect(offenders, isEmpty);
  });
}
