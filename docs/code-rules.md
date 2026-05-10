## Rules

- Riverpod 2 with `@riverpod` annotation + code gen everywhere
- `ConsumerWidget` / `ConsumerStatefulWidget` — no plain `StatefulWidget` unless necessary
- GoRouter only — never `Navigator.push()`
- Dio + Retrofit for all API calls
- Handle all AsyncValue states: loading → skeleton, error → `AppErrorWidget`, data → content
- Run after adding `@riverpod` or `@RestApi`: `flutter pub run build_runner build --delete-conflicting-outputs`
- Use `const` constructors everywhere possible
- Never use `BuildContext` across async gaps — check `mounted` before using context after await

## Riverpod Pattern

```dart
@riverpod
ListingRepository listingRepository(ListingRepositoryRef ref) =>
    ListingRepository(ref.watch(apiClientProvider));

@riverpod
Future<ListingDetail> listingDetail(ListingDetailRef ref, String id) =>
    ref.watch(listingRepositoryProvider).getById(id);
```

## AsyncValue Pattern

```dart
ref.watch(someProvider).when(
  loading: () => const SomeSkeleton(),      // shimmer, not CircularProgressIndicator
  error: (e, _) => AppErrorWidget(onRetry: () => ref.invalidate(someProvider)),
  data: (data) => SomeContent(data: data),
);
```

## Retrofit Pattern

```dart
@RestApi()
abstract class ListingApi {
  factory ListingApi(Dio dio) = _ListingApi;

  @GET('/api/listings/nearby')
  Future<PageResponse<NearbyListing>> getNearby({
    @Query('lat') required double lat,
    @Query('lng') required double lng,
    @Query('radiusKm') double radiusKm = 5,
    @Query('page') int page = 0,
  });
}
```

## GoRouter Navigation

```dart
context.go('/listings/$id');
context.push('/provider/listings/create');
```

GoRouter redirect based on auth:
```dart
redirect: (context, state) {
  final isLoggedIn = ref.read(authStateProvider).value != null;
  if (!isLoggedIn && !state.matchedLocation.startsWith('/auth')) return '/auth/login';
  return null;
}
```

## Async / Context Safety

Always check `context.mounted` before using context after any async gap:
```dart
// Wrong
Future.microtask(() => context.go('/map'));

// Correct
Future.microtask(() {
  if (context.mounted) context.go('/map');
});
```

## Riverpod Behavior

Double API calls in debug mode — normal. Riverpod auto-dispose re-fetches on rebuild.
Use `keepAlive: true` for rarely-changing data (categories, user profile).
Use default (`keepAlive: false`) for search results, feeds.

## Dependency Compatibility (Flutter 3.41.9 / Dart 3.11.5)

- `stomp_dart_client`: use `^3.0.1` — v1.x does not exist on pub.dev
- `retrofit_generator`: add only when creating the first `@RestApi` file (v8.x fails to precompile with Dart 3.11.5)
- `CardTheme` → `CardThemeData` in `ThemeData` — renamed in Flutter 3.22+

## Dio / Auth

JWT interceptor in dev mode:
```dart
// In onRequest interceptor:
final token = await FirebaseAuth.instance.currentUser?.getIdToken();
options.headers['Authorization'] = 'Bearer ${token ?? 'dev-token'}';
```

Android emulator uses `10.0.2.2` to reach host localhost. iOS simulator uses `localhost` directly.
