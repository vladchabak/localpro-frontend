# Code Review — LocalPro Mobile

**Reviewer:** Claude Sonnet 4.6  
**Date:** 2026-05-11  
**Branch:** main (commit 0feccdc)  
**Scope:** Full codebase review — all Dart source under `lib/`

---

## Summary

The architecture is clean and well-structured (Data → Domain → Presentation, Riverpod 2 throughout, GoRouter for navigation). The design system is consistent and the UI is polished. The main concerns fall into three categories: critical security bugs that would break the app in production, a handful of correctness issues where logic is simply wrong, and a larger set of code quality and consistency issues accumulated during fast-feature development.

**Severity scale used:** 🔴 Critical · 🟠 Significant · 🟡 Moderate · ⚪ Minor/Style

---

## 🔴 Critical

### 1. STOMP always sends `dev-token` — never the real JWT

**File:** `lib/features/chat/data/stomp_service.dart:43–44`

```dart
stompConnectHeaders: {'Authorization': 'Bearer dev-token'},
webSocketConnectHeaders: {'Authorization': 'Bearer dev-token'},
```

HTTP requests use an interceptor in `ApiClient` that dynamically fetches the Firebase JWT; WebSocket connections don't. In production, every chat user will authenticate as `dev-token`, which the backend will either reject or treat as the dev account. Fix: inject the token at `connect()` time:

```dart
void connect({required String userId, required String token}) {
  _client = StompClient(
    config: StompConfig(
      stompConnectHeaders: {'Authorization': 'Bearer $token'},
      webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ...
    ),
  );
}
```

Callers must pass `await FirebaseAuth.instance.currentUser?.getIdToken() ?? 'dev-token'`.

---

### 2. Sign-out doesn't sign out

**File:** `lib/features/profile/presentation/profile_screen.dart:319`

```dart
onTap: () => context.go('/auth/login'),
```

Navigating to the login screen does not invalidate the Firebase Auth session. On the next app launch, `authStateChanges()` will still emit the signed-in user and `SplashScreen` will redirect straight to `/map`. The user can never actually sign out.

Fix: call `ref.read(authRepositoryProvider).signOut()` before navigating.

---

### 3. Mutation providers use `ref.watch` instead of `ref.read`

**Files:**
- `lib/features/listing/domain/listing_providers.dart:106` (`createListing`)
- `lib/features/listing/domain/listing_providers.dart:110` (`verifyListing`)
- `lib/features/booking/domain/booking_providers.dart:26, 30` (`createBooking`, `cancelBooking`)

```dart
@riverpod
Future<ListingDetailModel> createListing(CreateListingRef ref, ListingRequest request) =>
    ref.watch(listingRepositoryProvider).createListing(request);  // ← ref.watch on a mutation!
```

Using `ref.watch` inside a parameterised `Future` provider means if `listingRepositoryProvider` ever rebuilds (e.g., Dio provider refreshes), the entire `createListing` future is re-triggered — potentially creating duplicate listings or bookings. These must use `ref.read`.

---

## 🟠 Significant

### 4. GoRouter has no authentication guard

**File:** `lib/core/router/app_router.dart`

The router has no `redirect` callback. Only the initial `/splash` route checks auth; every other route is freely accessible. A user who deep-links to `/booking` or `/provider/listings/create` bypasses authentication entirely. Add a top-level `redirect`:

```dart
final appRouter = GoRouter(
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggingIn = state.uri.path == '/auth/login';
    if (user == null && !isLoggingIn) return '/auth/login';
    return null;
  },
  ...
);
```

---

### 5. Hardcoded categories in `CatalogScreen` — will diverge from backend

**File:** `lib/features/catalog/presentation/catalog_screen.dart:25–35`

```dart
static const List<Map<String, String>> _categories = [
  {'id': 'cleaning', 'name': 'Cleaning'},
  {'id': 'plumbing', 'name': 'Plumbing'},
  ...
];
```

`MapScreen` fetches real category IDs from the backend via `categoriesProvider`. `CatalogScreen` uses hardcoded string slugs. If a backend category has `id: "cat-001"` instead of `"cleaning"`, the filter will silently return zero results. Both screens should consume `categoriesProvider`.

---

### 6. `_BookingCard` receives `WidgetRef` as a constructor parameter

**File:** `lib/features/booking/presentation/my_bookings_screen.dart:56, 63–65`

```dart
class _BookingCard extends StatelessWidget {
  final WidgetRef ref;
  const _BookingCard({required this.booking, required this.ref});
```

`WidgetRef` is scoped to the build cycle of its owning widget. Storing it on a child `StatelessWidget` is an anti-pattern — the ref can become stale, and calling `ref.read(...)` or `ref.invalidate(...)` from `_cancelBooking` may operate on a detached scope. Convert `_BookingCard` to a `ConsumerStatefulWidget` and get the ref normally.

---

### 7. Artificial 1.5-second delay in booking flow — mock artefact left in

**File:** `lib/features/booking/presentation/booking_screen.dart:155`

```dart
await Future.delayed(const Duration(milliseconds: 1500));
```

This blocks the booking confirmation for 1.5 seconds before the API call even starts. Combined with production API latency, users wait 3–4 seconds. This was clearly a mock animation shim that was never removed.

---

### 8. `SplashScreen` uses `Future.microtask` for navigation — causes a flicker

**File:** `lib/core/router/app_router.dart:117–120, 147–155`

```dart
data: (user) {
  Future.microtask(() {
    if (context.mounted) context.go(user != null ? '/map' : '/auth/login');
  });
  return const Scaffold(...);  // rendered for one frame before redirect
},
```

The splash screen renders its content for at least one frame before the microtask runs. The canonical GoRouter pattern is a `redirect` callback on the router itself (see issue #4), which handles this transparently without a flash.

---

### 9. Chat search bar is a decorative dead end

**File:** `lib/features/map/presentation/map_screen.dart:422–426`

The `_SearchBar` widget renders a search-looking UI with hint text `'Try "cleaner near Ledra St."'` but it is not a `TextField` — it is an unclickable `Container` with a `Text` widget. There is no `onTap`, no `GestureDetector`, no navigation to a search screen. Users will tap it and nothing will happen.

---

### 10. `dioProvider` lives in `auth_providers.dart` — wrong ownership

**File:** `lib/features/auth/domain/auth_providers.dart:13`

```dart
@riverpod
Dio dio(DioRef ref) => ApiClient.createDio();
```

Every feature that needs HTTP (`listing_providers`, `booking_providers`, `chat_providers`) imports `auth_providers.dart` just to get `dioProvider`. This creates a cross-feature dependency on auth. `dioProvider` belongs in `lib/core/api/` and should be exported from a `core_providers.dart` or similar.

---

## 🟡 Moderate

### 11. Redundant null checks and dead code in `_confirmBooking`

**File:** `lib/features/booking/presentation/booking_screen.dart:117–200`

- Line 119: checks `widget.listing.id.isEmpty` and shows a snackbar
- Line 159: checks `validListingId.isEmpty` again for the same value and throws — unreachable
- Line 163: checks `scheduledAt == null` — but `scheduledAt` is assigned unconditionally at lines 140 or 143–149 and can never be null at that point
- Lines 177–181: five `debugPrint` statements with emoji remain in production code

---

### 12. `LoginScreen` sends empty credentials to Firebase

**File:** `lib/features/auth/presentation/login_screen.dart:104–133`

The Sign In button has no client-side validation — it fires with empty email/password and lets Firebase return a generic auth error. The UX should check for empty fields before making the network call.

---

### 13. Date formatting using string split — fragile

**File:** `lib/features/booking/presentation/my_bookings_screen.dart:167`

```dart
booking.scheduledAt.toString().split(' ')[0]
```

`DateTime.toString()` format is implementation-defined. Use `DateFormat` from `intl` (already in pubspec.yaml): `DateFormat('d MMM yyyy').format(booking.scheduledAt)`.

---

### 14. `_statusLabel` serialises enum via `toString()` — brittle

**File:** `lib/features/booking/presentation/my_bookings_screen.dart:82`

```dart
return status.toString().split('.').last.toUpperCase();
```

If enum member names are ever renamed or the Dart representation changes, this silently produces wrong output. The enum already has `@JsonValue` annotations; add an extension method or a `label` getter instead.

---

### 15. `BookingResponse.paymentStatus` is an untyped `String`

**File:** `lib/features/booking/data/models/booking_model.dart:36`

`BookingStatus` and `PaymentType` are proper enums with `@JsonValue`. `paymentStatus` is a bare `String` with no validation. If it is backend-controlled, it should be a `PaymentStatus` enum; if it's a free-form field, that should be documented.

---

### 16. Pagination state exists but is never wired up in `CatalogScreen`

**File:** `lib/features/catalog/domain/catalog_providers.dart:17`, `lib/features/catalog/presentation/catalog_screen.dart`

`CatalogSearchState` has a `page` field and `setPage` method, but there is no "load more" or infinite scroll trigger in the UI. Results beyond the first page are permanently hidden.

---

### 17. `chatMessages` provider calls `markRead` as a side effect

**File:** `lib/features/chat/domain/chat_providers.dart:33–36`

```dart
@riverpod
Future<List<MessageModel>> chatMessages(ChatMessagesRef ref, String chatId) async {
  await ref.read(chatRepositoryProvider).markRead(chatId);
  return ref.read(chatRepositoryProvider).getMessages(chatId);
}
```

Providers should not have side effects that mutate server state. If `chatMessagesProvider` is ever invalidated and re-fetched (e.g., on error retry), it will call `markRead` again. Mark-read should be an explicit action triggered from the UI layer.

---

### 18. Location permission denial is swallowed silently

**File:** `lib/features/map/presentation/map_screen.dart:38–58`

```dart
} catch (_) {
  // Keep default Nicosia coordinates
}
```

Both permission errors and genuine GPS failures land here. When permission is denied, the map silently defaults to Nicosia with no toast or visual cue. Users in, say, Berlin will see a map centred on Cyprus and not understand why.

---

### 19. Image upload is missing from `CreateListingScreen`

**File:** `lib/features/listing/presentation/create_listing_screen.dart:272`

```dart
photoUrls: [],
```

`image_picker` is in `pubspec.yaml`, but there's no step (no UI, no handler) for uploading photos. The 5-step wizard has no photo step, and every listing is submitted with an empty photo array. The listing detail screen falls back to a placeholder icon, which is correct, but providers can't showcase their work.

---

### 20. Double `ClipRRect` wrapping the map in `CreateListingScreen`

**File:** `lib/features/listing/presentation/create_listing_screen.dart:569–579`

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Container(
    ...
    child: ClipRRect(  // ← redundant
      borderRadius: BorderRadius.circular(11),
      child: FlutterMap(...)
    ),
  ),
)
```

The outer `ClipRRect` clips to `12`; the inner to `11`. The inner one is redundant; remove it.

---

## ⚪ Minor / Style

### 21. `Color(0xFF1B5E63)` hardcoded eight times in `CreateListingScreen`

**File:** `lib/features/listing/presentation/create_listing_screen.dart:348, 664, 687–689, 742–743, 774`

This value is `AppColors.primary`. Replace all occurrences. Same issue in other files: `Color(0xFFF57C00)` (test-mode orange) appears in `app.dart`, `login_screen.dart`, and `profile_screen.dart` and should be a named constant.

---

### 22. Section label style uses `.copyWith` to immediately override itself

**File:** `lib/features/booking/presentation/booking_screen.dart:266, 290, 354`

```dart
Text('Schedule', style: const TextStyle(fontSize: 13, ...).copyWith(fontSize: 11))
```

`fontSize: 13` is set then immediately overridden to `11`. The `const TextStyle(fontSize: 13, ...)` is misleading. Write `const TextStyle(fontSize: 11, ...)` directly.

---

### 23. `_NavBadge` has a hardcoded unread count

**File:** `lib/core/router/app_router.dart:221–223`

```dart
icon: _NavBadge(child: const Icon(Icons.chat_bubble_outline), count: 2),
```

The badge always shows `2` regardless of actual unread messages. This should be driven by a provider that counts unread chats.

---

### 24. `AppColors.ink` / `AppColors.ink2` / `AppColors.ink3` vs. `AppColors.textPrimary` / `AppColors.textSecondary`

Two parallel naming schemes for text colours coexist in the codebase. Some screens use `AppColors.ink`, others use `AppColors.textPrimary`, others mix both. Consolidate to one set.

---

### 25. `retrofit` is declared as a dependency but never used

**File:** `pubspec.yaml:18`

The API layer uses plain Dio with manual `fromJson`/`toJson`. The `retrofit` package adds weight without benefit. Remove it.

---

### 26. `_ExpandableText` truncates mid-word

**File:** `lib/features/listing/presentation/listing_detail_screen.dart:566`

```dart
'${widget.text.substring(0, _maxChars)}...'
```

Cutting at a fixed character count splits inside words. Use `.lastIndexOf(' ', _maxChars)` to cut at the nearest word boundary.

---

### 27. `_onNextStep` `switch` has no `default` case

**File:** `lib/features/listing/presentation/create_listing_screen.dart:155–166`

If `_currentStep` somehow exceeds 4, nothing happens. Add a `default: break` or an assertion.

---

### 28. `AuthRepository` creates Firebase and Google instances as private fields

**File:** `lib/features/auth/data/auth_repository.dart:9–10`

```dart
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();
```

This makes the repository untestable without Firebase. Inject both via constructor or use a thin interface.

---

### 29. `'JetBrains Mono'` font hardcoded as a string in `_PriceMarker`

**File:** `lib/features/map/presentation/map_screen.dart:388`

Font names should be defined in the theme or as constants, not scattered as strings. A typo here silently falls back to the default font.

---

### 30. `_SearchBar` on the map uses `try/catch` for `canLaunchUrl` but ignores the result

**File:** `lib/features/booking/presentation/booking_screen.dart:87–93`

```dart
if (await canLaunchUrl(Uri.parse(url))) {
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
```

If `canLaunchUrl` returns false, the tap is silently ignored. Show a snackbar telling the user the calendar app couldn't be opened.

---

## Architecture Notes

**What's well done:**

- Clean three-layer feature structure (data / domain / presentation) is consistently followed
- Riverpod 2 code generation (`@riverpod`) is used correctly for all providers
- `AsyncValue.when` with loading/error/data is consistently applied
- `AppErrorWidget` with retry callbacks gives uniform error UX
- `LoadingSkeleton` shimmer is used before content loads on key screens
- The test-mode bypass (`TestUserNotifier`) is a clean solution for demo flows
- GoRouter usage is idiomatic (no `Navigator.push` leaking through)
- `ChatMessageList` optimistic-update pattern (`replaceOptimistic`) is correctly implemented

**Structural suggestions for later phases:**

- Consider `freezed` for state classes (`CatalogSearchState`, `MapSearchParamsState`) — they have hand-written `copyWith` which is error-prone and adds boilerplate
- Add an `ErrorHandler` service (or Dio interceptor) that maps HTTP status codes to typed app errors (`AppException`) rather than letting raw `DioException` propagate to the UI
- The `dioProvider` → `authRepositoryProvider` dependency chain means any screen that calls an API also transitively initialises Firebase auth. Consider a `CoreModule` that owns `dioProvider` and `apiBaseUrlProvider`, separate from auth
- Add integration with `flutter_secure_storage` (already in pubspec) for caching the last auth token to reduce cold-start latency
