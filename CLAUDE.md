# LocalPro Mobile — Claude Code Guide

**LocalPro** — Flutter mobile marketplace for local services (Airbnb-style).
Providers list services on a map. Clients search by location/category, chat with providers.

- **This repo:** `localpro_mobile` — Flutter 3.41.9 + Dart
- **Backend:** `localpro_backend` — Java 21 + Spring Boot 3.3.6
- **Backend URL:** `http://10.0.2.2:8080` (Android emulator) / `http://localhost:8080` (Chrome)
- **Auth header:** `Authorization: Bearer dev-token` (dev mode)

---

## Tech Stack

| Concern | Package |
|---|---|
| State management | flutter_riverpod + riverpod_annotation ^2.5.0 |
| Navigation | go_router ^13.0.0 |
| HTTP client | dio ^5.4.0 + retrofit ^4.1.0 |
| Maps | flutter_map ^6.1.0 + latlong2 ^0.9.0 |
| Location | geolocator ^11.0.0 |
| Firebase | firebase_auth ^4.17.0 + firebase_core ^2.27.0 + firebase_messaging ^14.7.0 |
| Google Sign-In | google_sign_in ^6.2.0 |
| WebSocket chat | stomp_dart_client ^1.0.0 |
| Image caching | cached_network_image ^3.3.0 |
| Secure storage | flutter_secure_storage ^9.0.0 |
| Image picker | image_picker ^1.0.0 |
| Code gen | build_runner + riverpod_generator + retrofit_generator + json_serializable |

---

## Project Structure

```
lib/
  main.dart                   — ProviderScope entry point
  app.dart                    — MaterialApp.router + GoRouter
  core/
    api/
      api_client.dart         — Dio instance + JWT interceptor
      api_endpoints.dart      — all URL constants
    theme/
      app_theme.dart
      app_colors.dart
    router/
      app_router.dart
    widgets/                  — shared widgets
    models/                   — PageResponse, etc.
  features/
    auth/data|domain|presentation
    map/data|domain|presentation
    catalog/data|domain|presentation
    listing/data|domain|presentation
    chat/data|domain|presentation
    provider_dashboard/data|domain|presentation
    profile/data|domain|presentation
```

---

## Design System

```dart
primary:       Color(0xFFFF385C)  // Airbnb red-pink
secondary:     Color(0xFF222222)
surface:       Color(0xFFFFFFFF)
background:    Color(0xFFF7F7F7)
textPrimary:   Color(0xFF222222)
textSecondary: Color(0xFF717171)
border:        Color(0xFFDDDDDD)
success:       Color(0xFF008A05)
```

- Typography: DM Sans (display) + Inter (body)
- Cards: white, borderRadius 12, subtle boxShadow
- Bottom sheets: DraggableScrollableSheet, rounded top 16px
- Buttons: filled primary = pink, outlined = white + border

---

## API Contract

Paginated response shape:
```json
{ "content": [...], "totalElements": 150, "totalPages": 8, "number": 0, "size": 20 }
```

Key endpoints:
```
GET  /api/categories
GET  /api/listings/nearby?lat=&lng=&radiusKm=&categoryId=&page=&size=
GET  /api/listings/{id}
POST /api/listings           (auth)
PUT  /api/listings/{id}      (auth, owner)
GET  /api/listings/my        (auth)
POST /api/auth/register
GET  /api/users/me           (auth)
PUT  /api/users/me           (auth)
GET  /api/users/{id}
POST /api/chats              (auth)
GET  /api/chats              (auth)
GET  /api/chats/{id}/messages (auth)
POST /api/listings/{id}/reviews (auth)
GET  /api/listings/{id}/reviews
```

---

## Phase Checklist

- [x] Phase 0 — pubspec.yaml + project structure + theme + router + Dio client
- [ ] Phase 1 — Auth screens (Login, Splash, RegisterCompletion)
- [ ] Phase 2 — Map screen (flutter_map, markers, bottom sheet, filters)
- [ ] Phase 3 — ServiceCard + ListingDetail screen
- [ ] Phase 4 — Chat (WebSocket + FCM)
- [ ] Phase 5 — Provider dashboard + CreateListing
- [ ] Phase 6 — Profile + polish + app icon

---

## Code Rules

- Riverpod 2 with `@riverpod` annotation + code gen everywhere
- `ConsumerWidget` / `ConsumerStatefulWidget` — no plain `StatefulWidget` unless necessary
- GoRouter only — never `Navigator.push()`
- Dio + Retrofit for all API calls
- Handle all AsyncValue states: loading → skeleton, error → `AppErrorWidget`, data → content
- Colors from `AppColors`, text styles from `AppTheme` only
- Run after adding `@riverpod` or `@RestApi`: `flutter pub run build_runner build --delete-conflicting-outputs`

### Riverpod pattern
```dart
@riverpod
ListingRepository listingRepository(ListingRepositoryRef ref) =>
    ListingRepository(ref.watch(apiClientProvider));

@riverpod
Future<ListingDetail> listingDetail(ListingDetailRef ref, String id) =>
    ref.watch(listingRepositoryProvider).getById(id);
```

### AsyncValue
```dart
ref.watch(someProvider).when(
  loading: () => const SomeSkeleton(),
  error: (e, _) => AppErrorWidget(onRetry: () => ref.invalidate(someProvider)),
  data: (data) => SomeContent(data: data),
);
```

---

## Running the App

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8080
flutter pub run build_runner build --delete-conflicting-outputs
flutter test
flutter build apk --dart-define=API_BASE_URL=https://localpro-api.railway.app
```
