# LocalPro Mobile — Frontend Plan

> **Stack:** Flutter 3.x · Dart · Riverpod 2 · Dio + Retrofit · flutter_map (OpenStreetMap) · Firebase Auth · STOMP WebSocket
> **Repo:** `localPro-mobile`
> **Last synced:** 2026-05-17

---

## Status legend
- ✅ Complete
- 🔶 Partial / stub
- ⬜ Not started

---

## Phase 0 — Project Scaffold ✅

### Prompt 1 — Flutter project structure ✅
```
pubspec.yaml dependencies, directory layout, app_colors.dart with Airbnb palette.
Done: all directories created, app_colors.dart implemented, theme wired up.
```

### Prompt 2 — GoRouter navigation ✅
```
Routes implemented: /splash, /auth/login, HomeShell (bottom nav: Map/Catalog/Chats/Profile),
/listings/:id, /chats/:id, /provider/dashboard, /provider/listings/create,
/provider/listings/:id/edit, /profile/edit, /booking, /booking/success/:id,
/bookings, /listings/verify/:id.

Note: /auth/register and /catalog/search routes were not added — flow handled differently.
```

### Prompt 3 — Dio API client ✅
```
ApiClient with JWT interceptor (Firebase ID token + dev-token fallback), 401 retry,
timeouts, LogInterceptor in debug mode. AppEnvironment reads --dart-define=API_BASE_URL.
ApiException + DioExceptionMapper implemented.
```

---

## Phase 1 — Auth Screens ✅

### Prompt 4 — Auth feature ✅
```
AuthRepository: signInWithGoogle(), signInWithEmail(), signOut(), backend sync via POST /api/auth/register.
Riverpod providers: authStateProvider (StreamProvider<User?>), currentUserProvider (FutureProvider<UserProfile?>).

LoginScreen: email/password fields, "Continue with Google" button, test-mode section
(enter name → bypass Firebase, used during dev without real auth).
SplashScreen: checks auth + test user, navigates to /map or /auth/login.

Not done: RegisterCompletionScreen (role picker after first Google login — skipped for now).
```

---

## Phase 2 — Map Screen ✅

### Prompt 5 — Map with markers ✅
```
MapScreen: flutter_map + OpenStreetMap tiles, geolocator on first open,
custom price-tag markers (white pill), selected marker (pink + pulse animation),
tap marker → show bottom card, "My location" FAB.

NearbyListingsProvider: lat/lng/radiusKm/categoryId, calls GET /api/listings/nearby,
re-fetches on map drag (debounce).

Bottom sheet (DraggableScrollableSheet): min/max heights, horizontal PageView of listing cards,
syncs with selected marker.

Top bar: category filter chips (horizontal scroll), radius selector (bottom sheet with slider).
```

### Prompt 6 — Map/List view toggle 🔶
```
Map and Catalog are separate bottom-nav tabs rather than an IndexedStack toggle.
Both share the same Riverpod provider state.
The Airbnb-style floating pill toggle was not added — navigation via bottom bar instead.
```

---

## Phase 3 — Listing Cards + Detail ✅

### Prompt 7 — ServiceCard widget ✅
```
ServiceCard (lib/features/listing/presentation/widgets/service_card.dart):
photo carousel, category chip, distance, title, provider avatar + name + rating, price.
CatalogListingCard variant used in catalog grid.
LoadingSkeleton (shimmer-style) implemented in core/widgets/loading_skeleton.dart.
```

### Prompt 8 — Listing detail screen ✅
```
ListingDetailScreen: SliverAppBar with photo gallery, title, category chips,
provider section, price section, description (expandable), location static map preview,
reviews section (displays reviewCount + rating from listing model).
Bottom bar: price + "Contact Provider" + "Book Now" buttons.
listingDetailProvider(id) FutureProvider wired up.

Reviews: ✅
  - GET /api/listings/{id}/reviews — displays up to 3 review tiles (avatar, name, stars, comment, date)
  - "See all" stub if reviewCount > 3
  - POST /api/listings/{id}/reviews — submit form (star picker + comment) in a bottom sheet
    triggered from COMPLETED booking cards in MyBookingsScreen
```

---

## Phase 3.5 — Booking ✅ (added beyond original plan)

```
Full booking flow implemented:

BookingScreen (/booking):
  - Date + time picker (custom InAppTimePicker widget)
  - Payment type selector: CREDIT_CARD / CASH / BONUSES
  - Calendar type: IN_APP / CALENDLY / GOOGLE_CALENDAR
  - Notes field
  - Calls POST /api/bookings

BookingSuccessScreen (/booking/success/:id):
  - Confirmation UI with booking details

MyBookingsScreen (/bookings):
  - List of client's bookings with status chips (PENDING / CONFIRMED / CANCELLED / COMPLETED)
  - Pull-to-refresh
  - Accessible from Profile screen
  - No cancel/confirm actions yet (awaiting backend steps 7–8)

BookingRepository + BookingApi wired up.
BookingResponse: flat model (id, status, paymentStatus, scheduledAt, calendlyUrl,
  googleCalendarUrl, totalPrice, listingId, listingTitle, providerId, providerName, createdAt).

VerificationPromptScreen (/listings/verify/:id):
  - Shown when a listing requires provider verification before booking.

Pending (blocked by backend improvements steps 3–10):
  - Nested DTOs (listing, provider, customer, payment, calendar, actions)
  - canCancel / canConfirm flags
  - GET /api/bookings/{id} (step 8)
  - PUT /api/bookings/{id}/complete (step 8)
  - Pagination on GET /api/bookings/my (step 9)
  - Idempotency header (step 5)
```

---

## Phase 4 — Chat ✅

### Prompt 9 — Chat feature ✅
```
ChatRepository: getChats(), getMessages(chatId, page), startChat(providerId, listingId), markRead(chatId).

StompChatService: connects to ws/wss with Firebase JWT, subscribes to /user/queue/messages,
auto-reconnect (exponential backoff), disconnects on logout.

ChatListScreen (/chats):
  - ChatSummaryTile: avatar + name + listing title + last message + time + unread badge
  - Empty state, pull-to-refresh.
  - Unread count badge shown on bottom-nav Messages tab.

ChatScreen (/chats/:id):
  - Bubble layout (own = right pink, other = left grey)
  - Listing info card at top, auto-scroll to bottom, pagination on scroll-up
  - Text input + send button, typing indicator stub.

FCM push notifications: 🔶 PARTIAL
  - FcmService (lib/core/notifications/fcm_service.dart): foreground banner, background tap,
    terminated-state tap → routes to /chats/:id or /chats.
  - FCM token uploaded to backend on login + onTokenRefresh (PUT /api/users/me/fcm-token). ✅
  - Backend FCM send on booking created: ⬜ NOT done (backend step 10).
```

---

## Phase 5 — Provider Dashboard ✅

### Prompt 10 — Provider listing management ✅
```
ProviderDashboardScreen (/provider/dashboard): ✅
  - "My Services" header + "Add" icon button
  - List of own listings (thumbnail, title, category, price, status chip, view count)
  - Edit / Pause|Activate / Delete actions
  - Pull-to-refresh ✅
  - Empty state with CTA

CreateListingScreen (/provider/listings/create): ✅
  - Step 1: title, category picker, description (1000 char)
  - Step 2: price + price type (per service / per hour / by agreement)
  - Step 3: interactive flutter_map pin placement + city + address fields
  - Step 4: photo upload (ImagePicker → POST /api/listings/{id}/photos, up to 8 photos) ✅
  - Step 5: custom questions for customers (up to 5, quick-add suggestions by category) ✅
  - Step 6: review + submit
  - Progress indicator at top

EditListingScreen (/provider/listings/:id/edit): ✅
  - Same 6-step form pre-filled from listingDetailProvider
  - Photo management: view existing, delete (DELETE /api/listings/{id}/photos/{photoId}) ✅
  - No new photo upload in edit (add photos → not wired)
  - Submits via PUT /api/listings/{id}

Draft save to SharedPreferences: ⬜ NOT implemented
```

---

## Phase 6 — Profile + Polish 🔶

### Prompt 11 — Profile screen 🔶
```
ProfileScreen (/profile): ✅
  - Avatar (initials), name, email, role chip
  - My Services section: inline list of own listings with verified status
  - Menu: Add New Service, My Chats, Payments (stub), Exit Test Mode, Sign out

EditProfileScreen (/profile/edit): ✅
  - Name (required), bio, phone fields pre-filled from currentUserProvider
  - Save calls PUT /api/users/me, invalidates currentUserProvider, pops back
  - Avatar shows initials circle; photo upload deferred (Cloudinary not wired on backend)
```

### Prompt 12 — Loading states + error handling 🔶
```
AppErrorWidget: ✅ (message + "Try again" button)
LoadingSkeleton: ✅ (shimmer-style skeletons used in map and detail screens)
AsyncValue.when() pattern: ✅ used consistently throughout

connectivity_plus "No internet" banner: ✅ implemented (ConnectivityBanner widget in App builder, AnimatedSize slide-in)
Pull-to-refresh:
  - ChatListScreen: ✅
  - CatalogScreen: ✅
  - ProviderDashboard: ✅
  - MapScreen bottom sheet: ⬜ NOT implemented
Optimistic UI for chat messages: ⬜ NOT implemented
```

### Prompt 13 — App icon + splash + flavors ✅
```
flutter_launcher_icons: ✅ configured (adaptive icon, background #0E5C5C)
flutter_native_splash: ✅ configured (teal background + white LocalPro wordmark)
android applicationId / iOS bundleId set to com.localpro.app: ⬜ NOT done
```

---

## Backend-Ready APIs Not Yet Used in Frontend

These backend endpoints are live and tested but have no frontend integration:

| Endpoint | Use case | Priority |
|---|---|---|
| `GET /api/listings/popular` | "Popular near you" section on map/home | ✅ Done |
| `GET /api/listings/recent` | "Recently added" section in catalog | ✅ Done |
| `GET /api/listings/category/{id}` | Deep-link to category results | Low |
| `POST /api/listings/{id}/reviews` | Submit review after completed booking | ✅ Done |
| `GET /api/listings/{id}/reviews` | Load full paginated review list | ✅ Done |
| `PUT /api/users/me` | EditProfileScreen save | ✅ Done |
| `PUT /api/users/me/fcm-token` | Upload FCM token on login | ✅ Done |
| `PUT /api/bookings/{id}/confirm` | Provider confirms booking | Medium |

---

## Remaining Work (priority order)

1. ~~**FCM token upload**~~ ✅ Done
2. ~~**EditProfileScreen**~~ ✅ Done
3. ~~**Submit review**~~ ✅ Done
4. **Booking improvements sync** — update `BookingResponse` model + `MyBookingsScreen` once backend ships nested DTOs + `canCancel`/`canConfirm` flags (steps 6–9)
5. ~~**App icon + splash**~~ ✅ Done
6. ~~**"No internet" banner**~~ ✅ Done
7. ~~**Popular/Recent sections**~~ ✅ Done
8. **Draft save** — SharedPreferences for half-filled CreateListing form
9. **RegisterCompletionScreen** — role picker shown once after first Google sign-in
10. **Photo upload in EditListing** — wire ImagePicker → `POST /api/listings/{id}/photos` in step 4

---

## Key Flutter Patterns

### Riverpod provider structure (per feature)
```dart
// 1. Repository (data layer)
@riverpod
ListingRepository listingRepository(ListingRepositoryRef ref) {
  return ListingRepository(ref.watch(apiClientProvider));
}

// 2. State provider (domain layer)
@riverpod
Future<ListingDetail> listingDetail(ListingDetailRef ref, String id) {
  return ref.watch(listingRepositoryProvider).getById(id);
}

// 3. In widget (presentation layer)
class ListingDetailScreen extends ConsumerWidget {
  build(context, ref) {
    final listing = ref.watch(listingDetailProvider(id));
    return listing.when(
      loading: () => ListingDetailSkeleton(),
      error: (e, _) => AppErrorWidget(onRetry: () => ref.refresh(listingDetailProvider(id))),
      data: (l) => ListingDetailContent(listing: l),
    );
  }
}
```

### API call pattern (Retrofit)
```dart
@RestApi()
abstract class ListingApi {
  @GET('/api/listings/nearby')
  Future<PageResponse<NearbyListing>> getNearby({
    @Query('lat') required double lat,
    @Query('lng') required double lng,
    @Query('radiusKm') double radiusKm = 5,
    @Query('categoryId') String? categoryId,
    @Query('page') int page = 0,
  });
}
```

---

## Running Locally

```bash
# Android emulator (API URL uses 10.0.2.2 for localhost)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080

# Chrome (web)
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080

# Run tests
flutter test

# Build APK for testing
flutter build apk --dart-define=API_BASE_URL=https://demo-production-2680.up.railway.app
```
