# LocalPro Mobile — Claude Code Action Plan

> **Stack:** Flutter 3.x · Dart · Riverpod 2 · Dio + Retrofit · flutter_map (OpenStreetMap) · Firebase Auth · STOMP WebSocket
> **Repo:** `localPro-mobile`
> Start this AFTER Phase 1 of the backend (Auth + Listings API) is working.

---

## Phase 0 — Project Scaffold

### Prompt 1 — Flutter project structure
```
Create a Flutter 3 project called "localpro" with the following structure and dependencies.

pubspec.yaml dependencies:
# State management
riverpod: ^2.5.0
flutter_riverpod: ^2.5.0
riverpod_annotation: ^2.3.0

# Navigation
go_router: ^13.0.0

# HTTP
dio: ^5.4.0
retrofit: ^4.1.0

# Firebase
firebase_core: ^2.27.0
firebase_auth: ^4.17.0
firebase_messaging: ^14.7.0
google_sign_in: ^6.2.0

# Maps
flutter_map: ^6.1.0
latlong2: ^0.9.0
geolocator: ^11.0.0

# Chat
stomp_dart_client: ^1.0.0

# UI
cached_network_image: ^3.3.0
flutter_secure_storage: ^9.0.0
image_picker: ^1.0.0
intl: ^0.19.0

dev_dependencies:
build_runner, riverpod_generator, retrofit_generator, json_serializable

Directory structure:
lib/
  main.dart
  app.dart                    (MaterialApp + GoRouter + ProviderScope)
  core/
    api/
      api_client.dart         (Dio instance + JWT interceptor)
      api_endpoints.dart      (all URL constants)
    models/                   (shared data models)
    widgets/                  (reusable widgets)
    theme/
      app_theme.dart
      app_colors.dart
  features/
    auth/
      data/
      domain/
      presentation/
    map/
      data/
      domain/
      presentation/
    catalog/
    listing/
    chat/
    provider_dashboard/
    profile/

Create app_colors.dart with an Airbnb-inspired palette:
  primary: #FF385C (Airbnb red-pink)
  secondary: #222222
  surface: #FFFFFF
  background: #F7F7F7
  textPrimary: #222222
  textSecondary: #717171
  border: #DDDDDD
  success: #008A05
```

### Prompt 2 — GoRouter navigation
```
Create GoRouter navigation configuration for LocalPro Flutter app.

Routes:
  /splash                     → SplashScreen (checks auth state)
  /onboarding                 → OnboardingScreen
  /auth/login                 → LoginScreen
  /auth/register              → RegisterScreen (set name + role after Firebase login)

  /                           → HomeShell (bottom nav: Map, Catalog, Chats, Profile)
  /map                        → MapScreen
  /catalog                    → CatalogScreen
  /catalog/search             → SearchScreen
  /listings/:id               → ListingDetailScreen
  /listings/:id/book          → ContactProviderScreen
  /chats                      → ChatListScreen
  /chats/:id                  → ChatScreen
  /profile                    → ProfileScreen
  /profile/edit               → EditProfileScreen

  /provider/dashboard         → ProviderDashboardScreen
  /provider/listings/create   → CreateListingScreen
  /provider/listings/:id/edit → EditListingScreen

Auth redirect: if not logged in, redirect to /auth/login (except /splash and /onboarding).
Use ShellRoute for the bottom navigation shell.

Create the router in lib/core/router/app_router.dart.
Use Riverpod authStateProvider to determine redirect.
```

### Prompt 3 — Dio API client
```
Create the API client setup for LocalPro Flutter app.

1. ApiClient (lib/core/api/api_client.dart):
   - Dio instance with baseUrl from environment (const String apiBaseUrl)
   - JwtInterceptor: before each request, get current Firebase ID token
     (await FirebaseAuth.instance.currentUser?.getIdToken()), add as Bearer token
   - Handle 401: refresh token and retry once
   - Timeout: connectTimeout 15s, receiveTimeout 30s
   - LogInterceptor in debug mode

2. Create AppEnvironment class:
   - apiBaseUrl: reads from --dart-define=API_BASE_URL=http://localhost:8080
   - Defaults to localhost for dev

3. Create base API error handling:
   - ApiException class with statusCode, message, fieldErrors
   - DioExceptionMapper: maps DioException → ApiException

Run command: flutter run --dart-define=API_BASE_URL=https://your-api.railway.app
```

---

## Phase 1 — Auth Screens

### Prompt 4 — Auth feature
```
Create the authentication feature for LocalPro Flutter app.

1. AuthRepository (lib/features/auth/data/auth_repository.dart):
   - signInWithGoogle(): Future<UserCredential>
   - signInWithEmail(email, password): Future<UserCredential>
   - signOut(): Future<void>
   - After Firebase sign-in: call POST /api/auth/register to create/sync backend profile
   - Store firebase_uid in flutter_secure_storage

2. Riverpod providers:
   - authStateProvider: StreamProvider<User?> from FirebaseAuth.instance.authStateChanges()
   - currentUserProvider: FutureProvider<UserProfile?> fetches backend profile

3. LoginScreen:
   - "Continue with Google" button (prominent, Airbnb-style)
   - "Continue with email" collapsible section
   - LocalPro logo + tagline at top
   - No registration form — Google handles it

4. RegisterCompletionScreen (shown once after first Google login):
   - Set display name (pre-filled from Google)
   - Choose role: "I need services" (CLIENT) or "I offer services" (PROVIDER)
   - Or "Both" toggle

5. SplashScreen:
   - Checks authStateProvider
   - Navigates to /map if logged in, /auth/login if not
   - 1.5s minimum display with animated logo

Use Riverpod ConsumerWidget throughout.
```

---

## Phase 2 — Map Screen

### Prompt 5 — Map with markers
```
Create the Map screen for LocalPro Flutter app. Style inspiration: Airbnb map view.

1. MapScreen (lib/features/map/presentation/map_screen.dart):
   - flutter_map with OpenStreetMap tiles (https://tile.openstreetmap.org/{z}/{x}/{y}.png)
   - Request user location with geolocator on first open
   - Center map on user location with zoom 13
   - "My location" FAB (bottom right)

2. NearbyListingsProvider (Riverpod StateNotifierProvider):
   - Holds: lat, lng, radiusKm, categoryId (nullable)
   - Calls GET /api/listings/nearby when params change (debounce 500ms)
   - Re-fetches when map is dragged to new center (use MapController onMapEvent)

3. Markers on map:
   - Custom price tag marker: white rounded pill "from $25" with shadow
   - Selected marker: larger, pink (#FF385C) background
   - Tap marker → select it → show bottom card

4. Bottom sheet (DraggableScrollableSheet):
   - min: 120px (shows 1 card peeking)
   - max: 60% screen height
   - Horizontal PageView of ListingCard widgets when map is shown
   - Full scrollable list when expanded
   - Syncs with selected marker (PageController)

5. Top search bar (pinned):
   - Tappable → navigates to /catalog/search
   - Category filter chips (horizontal scroll): All, Cleaning, Plumbing, Tutoring, etc.
   - Radius selector button → shows bottom sheet with slider (0.5 / 1 / 2 / 5 / 10 / 25 km)
```

### Prompt 6 — Map/Catalog toggle
```
Add a Map/List view toggle to the LocalPro home screen.

In HomeShell (bottom navigation shell), add a floating toggle button centered at the top:
  [ Map ]  [ List ]
Airbnb-style: pill shape, white background, subtle shadow.

Map view → MapScreen (flutter_map)
List view → CatalogScreen (scrollable grid of cards)

Both views share the same NearbyListingsProvider state (same filters, same data).
Switching views does NOT reload data.

The toggle should be visible above the bottom navigation bar.
Implement using IndexedStack so both screens maintain their scroll position.
```

---

## Phase 3 — Listing Cards + Detail

### Prompt 7 — ServiceCard widget
```
Create a reusable ServiceCard widget for LocalPro Flutter app. Airbnb aesthetic.

ServiceCard (used in catalog list and map bottom sheet):
  - Full-width photo carousel (PageView, dot indicators)
    → photos from listing.photos list
    → placeholder gradient if no photos
  - Favorite button (heart icon, top right of photo, no functionality in MVP)
  - Below photo:
    - Row: category chip (small, grey) + distance ("1.2 km away")
    - Title (16px, semi-bold, max 2 lines)
    - Provider: avatar (24px circle) + name + rating (★ 4.8 · 24 reviews)
    - Price: "from $25/hr" or "$120 fixed" (bold, right-aligned)
  - Tap → navigate to /listings/:id

Also create ServiceCardSkeleton (shimmer loading placeholder, same dimensions).
Use cached_network_image for all photos.
Card: white background, 12px corner radius, subtle shadow.
```

### Prompt 8 — Listing detail screen
```
Create the ListingDetailScreen for LocalPro Flutter app. Airbnb listing page style.

Route: /listings/:id

Layout (CustomScrollView with SliverAppBar):

1. SliverAppBar:
   - expandedHeight: 300px
   - Photo gallery (PageView): full-width photos with page indicator
   - Back button + Share button overlaid
   - Collapses to show listing title

2. Sliver content:
   - Title (22px bold)
   - Category + City chips
   - Divider
   - Provider section:
     - Avatar (56px) + name + "X services · ★ 4.8" + "View profile →"
   - Divider
   - Price section: big price display + price_type label
   - Divider
   - Description (expandable "Show more" after 4 lines)
   - Divider
   - Location section: small static map preview (flutter_map, non-interactive, 160px tall)
     shows approximate area (blurred exact location)
   - Reviews section: list of ReviewCard widgets (max 3, "Show all" button)

3. Bottom bar (fixed):
   - Left: price "from $25/hr"
   - Right: Button "Contact Provider" (pink, Airbnb style)
     → navigates to /chats (creates or opens existing chat with this provider)

4. Providers: listingDetailProvider(id) FutureProvider<ListingDetail>
```

---

## Phase 4 — Chat

### Prompt 9 — Chat feature
```
Create the full chat feature for LocalPro Flutter app.

1. ChatRepository:
   - getChats(): Future<List<ChatSummary>> → GET /api/chats
   - getMessages(chatId, page): Future<List<Message>> → GET /api/chats/{id}/messages
   - startChat(providerId, listingId): Future<Chat> → POST /api/chats
   - markRead(chatId): Future<void> → POST /api/chats/{id}/read

2. WebSocket setup (StompChatService):
   - Connect to wss://api/ws with Firebase JWT in header
   - Subscribe to /user/queue/messages
   - On message received: add to local message list via Riverpod state
   - Auto-reconnect on disconnect (exponential backoff)
   - Disconnect on logout

3. ChatListScreen (/chats):
   - List of ChatSummaryTile widgets
   - Each tile: provider/client avatar + name + listing title + last message preview
     + time + unread count badge (red circle)
   - Empty state: "No conversations yet" illustration + CTA button
   - Pull to refresh

4. ChatScreen (/chats/:id):
   - Bubble layout: own messages right (pink), other messages left (grey)
   - Message: content + timestamp (HH:mm) + read receipt (✓✓ for own messages)
   - Listing info card at top (listing title + photo thumbnail)
   - Auto-scroll to bottom on new message
   - Load older messages on scroll to top (pagination)
   - Text input bar: multiline, send button (disabled when empty)
   - Show typing indicator (future: STOMP /app/chat.typing)

5. FCM: handle background + foreground push notifications.
   Tap on notification → navigate to correct ChatScreen.
```

---

## Phase 5 — Provider Dashboard

### Prompt 10 — Provider listing management
```
Create the provider dashboard feature for LocalPro Flutter app.

1. ProviderDashboardScreen (/provider/dashboard):
   - Header: "My Services" + "Add new" button
   - Stats row: total listings, total views, total chats (future data)
   - List of own service listings (ProviderListingTile):
     - First photo thumbnail (80px)
     - Title + category + price
     - Status chip: ACTIVE (green) / PAUSED (grey)
     - View count
     - Row of action buttons: Edit | Pause/Activate | Delete
   - Empty state with CTA to create first listing

2. CreateListingScreen (/provider/listings/create):
   Step 1 — Basic info:
     - Title (required)
     - Category picker (tree: tap category → shows subcategories)
     - Description (multiline, 1000 char limit with counter)
     - Price + price type selector (Fixed / Hourly / Starting from)
   Step 2 — Location:
     - Interactive flutter_map: user taps to place pin
     - Address text field (manual input for MVP, geocoding post-MVP)
   Step 3 — Photos:
     - ImagePicker: up to 8 photos
     - Reorderable grid
     - Upload to POST /api/listings/{id}/photos immediately after listing created
   Step 4 — Review + Submit:
     - Preview card (looks like ServiceCard)
     - "Publish listing" button

3. EditListingScreen: same form, pre-filled with existing data.

4. Show progress indicator (step 1/4) at top.
   Save draft locally (SharedPreferences) if user leaves midway.
```

---

## Phase 6 — Profile + Polish

### Prompt 11 — Profile screen
```
Create the Profile screen for LocalPro Flutter app.

ProfileScreen (/profile):
  - Avatar (96px circle) with edit button
  - Name + email
  - Role chips: CLIENT / PROVIDER (tappable to switch if BOTH)
  - Menu items list (Airbnb settings style):
    - "My bookings" (future)
    - "Payment methods" (stub → "Coming soon" snackbar)
    - "Notifications" → placeholder
    - "Help & Support" → opens mailto or URL
    - "Privacy Policy" → webview
  - "Switch to provider mode" button (if role is CLIENT → goes to ProviderDashboard)
  - Sign out button (bottom, red text)

EditProfileScreen (/profile/edit):
  - Avatar: tappable → ImagePicker → upload to Cloudinary → update avatarUrl
  - Name field
  - Bio field (multiline)
  - Phone field
  - Save button

```

### Prompt 12 — Loading states + error handling
```
Add consistent loading states and error handling throughout LocalPro Flutter app.

1. Create AppErrorWidget (reusable):
   - Shows error illustration + message + "Try again" button
   - Different messages for: no internet, server error, not found

2. Create ShimmerLoading utility:
   - ServiceCardSkeleton (matches ServiceCard dimensions)
   - ChatTileSkeleton
   - ListingDetailSkeleton
   Use shimmer: ^3.0.0 package.

3. Wrap all AsyncValue usages with consistent when() pattern:
   - loading: → show skeleton (not spinner)
   - error: → show AppErrorWidget
   - data: → show content

4. Network connectivity: use connectivity_plus to show "No internet" banner.

5. Pull-to-refresh on: MapScreen bottom sheet, CatalogScreen, ChatListScreen, ProviderDashboard.

6. Optimistic UI for: sending chat messages (show immediately, grey out if send fails).
```

### Prompt 13 — App icon + splash + flavors
```
Configure app identity and environments for LocalPro Flutter app.

1. flutter_launcher_icons:
   - Create app icon: simple "LP" text on pink (#FF385C) background with rounded corners
   - Generate for both Android and iOS

2. flutter_native_splash:
   - White background + centered LocalPro logo (pink)
   - 2.5s display minimum

3. Flavors (dart-define based, not Flutter flavors for simplicity):
   - dev: API = http://localhost:8080, app name = "LocalPro Dev"
   - prod: API = https://api.railway.app, app name = "LocalPro"

4. Create launch configs in .vscode/launch.json:
   {
     "name": "LocalPro Dev",
     "flutterMode": "debug",
     "args": ["--dart-define=API_BASE_URL=http://10.0.2.2:8080", "--dart-define=ENV=dev"]
   }

5. android/app/build.gradle: set applicationId to com.localpro.app
   ios/Runner/Info.plist: set CFBundleIdentifier to com.localpro.app
```

---

## Key Flutter Patterns to Follow

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

# iOS simulator
flutter run --dart-define=API_BASE_URL=http://localhost:8080

# Run tests
flutter test

# Build APK for testing
flutter build apk --dart-define=API_BASE_URL=https://your-api.railway.app
```
