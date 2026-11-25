# Kernel

A microlearning app in Flutter that gives you short idea cards from nonfiction instead of a social-media feed.

## Features
- **Onboarding:** pick 3 or more topics (psychology, productivity, habits, leadership, AI, money, health, communication).
- **Daily feed:** swipe vertically through full-screen idea, quote and tip cards. The order is shuffled by date, so it stays the same all day and changes tomorrow.
- **Daily goal and streak:** read 5 ideas a day to keep your 🔥 streak.
- **Explore:** search all cards by text, book or author, and filter by topic.
- **Create:** write your own cards with a live preview and save them to a stash.
- **Stashes:** create, rename and delete collections. Swipe a card to remove it, with undo.
- Like, save and copy actions on every card. Light and dark themes.
- Everything is stored on the device with `shared_preferences`.

## Run
```sh
flutter pub get
flutter run -d chrome      # web
flutter run                # a connected Android/iOS device or emulator
flutter test
```
On Windows, desktop and Android builds with plugins need **Developer Mode** turned on (`start ms-settings:developers`).

## Structure
```
lib/
  main.dart            app, theme, bottom-nav shell
  app_state.dart       ChangeNotifier state + persistence + AppScope
  models.dart          IdeaCard, Stash, Topic, CardType
  seed_data.dart       topics and seed cards
  screens/             onboarding, feed, explore, create, stashes
  widgets/             idea card, save-to-stash sheet
```

## Deploy (Vercel)
Vercel doesn't build Flutter natively. `vercel.json` runs `vercel-build.sh`, which clones the pinned Flutter SDK, runs `flutter build web`, and serves `build/web`. Push to `main` to redeploy. The first build takes a few minutes while the SDK downloads.
