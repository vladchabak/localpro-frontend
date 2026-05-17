# LocalPro Mobile — Frontend Dev Agent Prompts

Companion to the backend steps. Each prompt is self-contained and targets one
frontend task. Stack: Flutter 3.x · Dart · Riverpod 2 · Dio · flutter_map ·
Firebase Auth · STOMP WebSocket.

---

## Step 1 — HIGH PRIORITY: Fix Booking Flow End-to-End

The backend POST /api/bookings now returns a valid BookingResponse.
Audit and fix the Flutter booking flow so it works without errors.

Context already done:
- BookingScreen at lib/features/booking/presentation/booking_screen.dart
- BookingApi/BookingRepository at lib/features/booking/data/
- BookingResponse has calendlyUrl, googleCalendarUrl, status, paymentStatus fields
- BookingSuccessScreen at lib/features/booking/presentation/booking_success_screen.dart

Tasks:
1. Read lib/features/booking/data/models/booking_model.dart.
   Confirm BookingRequest.toJson() produces the exact field names the backend expects:
     { "listingId", "scheduledAt" (ISO-8601 string), "paymentType" (CREDIT_CARD/CASH/BONUSES),
       "calendarType" (CALENDLY/GOOGLE_CALENDAR/IN_APP), "notes" }
   If json_serializable generates wrong casing, add @JsonKey(name: 'snake_case') annotations
   and re-run: flutter pub run build_runner build --delete-conflicting-outputs

2. In booking_screen.dart, find _confirmBooking() (~line 121).
   Fix the CalendarType fallback: when _selectedCalendarType is null (no calendar button
   tapped) default to IN_APP, not GOOGLE_CALENDAR.
   Change: `final calendarType = _selectedCalendarType ?? CalendarType.googleCalendar;`
   To:     `final calendarType = _selectedCalendarType ?? CalendarType.inApp;`

3. In booking_success_screen.dart, fix _launchCalendar():
   - Currently uses hardcoded 'https://calendly.com/mock-booking' and 'https://calendar.google.com'
   - Replace with the URLs from BookingResponse (booking.calendlyUrl, booking.googleCalendarUrl)
   - Only render each calendar button if its URL is non-null:
       if (booking.calendlyUrl != null)
         ElevatedButton.icon(onPressed: () => launchUrl(Uri.parse(booking.calendlyUrl!)), ...)

4. In booking_screen.dart _confirmBooking() catch block, extract a human-readable message
   from the backend JSON error before showing the SnackBar:
     } catch (e) {
       String msg = e.toString();
       if (e is DioException) {
         final data = e.response?.data;
         if (data is Map) msg = (data['message'] as String?) ?? msg;
       }
       if (mounted) ScaffoldMessenger.of(context)
           .showSnackBar(SnackBar(content: Text('Booking failed: $msg')));
     }

5. Run: flutter analyze lib/features/booking/
   Zero errors. Do NOT add new features or fields.

---

## Step 2 — HIGH PRIORITY: Real Photo Uploads in CreateListing

The backend POST /api/listings/{id}/photos now stores real Cloudinary URLs.
Wire image picking and uploading into the CreateListing flow.

Context:
- CreateListingScreen at lib/features/listing/presentation/create_listing_screen.dart
- Has 5 steps; _submitListing() passes photoUrls: [] — no photos uploaded
- After listing created it navigates to /listings/verify/:id
- ListingApi at lib/features/listing/data/listing_api.dart — no photo upload method yet
- Backend endpoint: POST /api/listings/{id}/photos (multipart/form-data, field "file")
  Returns: { "id": "...", "url": "https://res.cloudinary.com/..." }

Tasks:
1. Check pubspec.yaml for image_picker.
   If missing, add under dependencies:
     image_picker: ^1.1.2
   Run: flutter pub get

2. Add uploadPhoto to ListingApi:
     Future<String> uploadPhoto(String listingId, XFile photo) async {
       final formData = FormData.fromMap({
         'file': await MultipartFile.fromFile(
           photo.path,
           filename: photo.name,
         ),
       });
       final response = await _dio.post(
         '/api/listings/$listingId/photos',
         data: formData,
       );
       return (response.data as Map<String, dynamic>)['url'] as String;
     }
   Add a matching uploadPhoto(String listingId, XFile photo) in ListingRepository.

3. In CreateListingScreen add field: List<XFile> _selectedPhotos = [];

4. Insert a photo step between the location step and the custom questions step.
   Rename the existing _buildStep4() to _buildStep5Questions(), and _buildStep5() to
   _buildStep6Review(). Add new _buildStep4Photos() widget:
   - Title: "Add photos" / "Step 4 of 6"
   - ElevatedButton "Pick Photos" → ImagePicker().pickMultiImage(limit: 8)
     → setState(() => _selectedPhotos = picked)
   - Show selected photos as a Wrap: each is a 90×90 Stack (thumbnail + X button)
   - X button: setState(() => _selectedPhotos.removeAt(i))
   - If empty: a grey dashed Container(height:120) with Icon(Icons.photo_camera)
     and Text("Tap to add photos (optional)")
   Update PageView children list and progress bar: value: (_currentStep+1)/6.
   Update _onNextStep() case indices accordingly.

5. In _submitListing(), after the listing is created and before navigating:
     for (final photo in _selectedPhotos) {
       try {
         await ref.read(listingRepositoryProvider).uploadPhoto(listing.id, photo);
       } catch (e) {
         debugPrint('Photo upload failed: $e');
       }
     }
   A photo upload failure must NOT block navigation — show a SnackBar warning but
   continue to context.push('/listings/verify/${listing.id}').

6. Run: flutter analyze lib/features/listing/
   Zero errors.

---

## Step 3 — HIGH PRIORITY: Fix WebSocket Chat Authentication & Subscription

The backend STOMP endpoint is now audited and correctly wired. Fix the Flutter
StompService to authenticate with the real Firebase JWT and subscribe correctly.

Context:
- StompService at lib/features/chat/data/stomp_service.dart
- connect() currently hardcodes 'Bearer dev-token' (line ~43) — does not use Firebase JWT
- Reconnect uses a fixed Duration(seconds: 5) — no exponential backoff
- Backend user-destination broker path: /user/{userId}/queue/messages (correct)
- Backend room broadcast path: /topic/chats/{chatId}

Tasks:
1. Read lib/features/chat/data/stomp_service.dart fully.
   Read lib/core/api/api_client.dart to understand how Firebase tokens are obtained.

2. Change connect() signature to accept a Firebase token:
     void connect({required String userId, required String token})
   Replace the hardcoded header values:
     stompConnectHeaders: {'Authorization': 'Bearer $token'},
     webSocketConnectHeaders: {'Authorization': 'Bearer $token'},

3. Find all call sites of stompService.connect() (grep for '.connect(').
   Obtain the real token before calling connect:
     final token = await FirebaseAuth.instance.currentUser
         ?.getIdToken(true) ?? 'dev-token';
     stompService.connect(userId: userId, token: token);

4. Add subscribeToChat(String chatId) and unsubscribeFromChat(String chatId) methods:
     StompUnsubscribe? _roomSubscription;

     void subscribeToChat(String chatId) {
       _roomSubscription = _client?.subscribe(
         destination: '/topic/chats/$chatId',
         callback: (frame) {
           if (frame.body == null) return;
           try {
             final msg = MessageModel.fromJson(
                 jsonDecode(frame.body!) as Map<String, dynamic>);
             _messageController.add(msg);
           } catch (e) { debugPrint('parse error: $e'); }
         },
       );
     }

     void unsubscribeFromChat(String chatId) {
       _roomSubscription?.call(); // calls the unsubscribe callback
       _roomSubscription = null;
     }

5. Replace the fixed reconnectDelay with exponential backoff:
   - Remove reconnectDelay from StompConfig (set it to Duration.zero)
   - Add int _reconnectAttempts = 0 field to StompService
   - In onDisconnect: schedule reconnect after
       Duration(seconds: min(5 * (1 << _reconnectAttempts), 60))
     using Future.delayed, then increment _reconnectAttempts
   - In onConnect: reset _reconnectAttempts = 0

6. In lib/features/chat/presentation/chat_screen.dart initState:
   Call stompService.subscribeToChat(widget.chatId) after the service is connected.
   In dispose(): call stompService.unsubscribeFromChat(widget.chatId).

7. Run: flutter analyze lib/features/chat/
   Zero errors.

---

## Step 4 — MEDIUM: Widget Tests for Booking Flow

Add Flutter widget tests for the booking screen and booking success screen.
The backend integration test covers the API; these tests cover the Flutter UI.

Context:
- BookingScreen takes a ListingDetailModel via router extra
- BookingSuccessScreen reads bookingDetailProvider(id)
- No test files exist under test/features/booking/

Tasks:
1. Check pubspec.yaml dev_dependencies for mocktail.
   If missing, add: mocktail: ^0.3.0
   Run: flutter pub get

2. Create test/features/booking/booking_screen_test.dart.
   Write group 'BookingScreen' with three tests:

   Test 1 — 'renders listing info card':
   - Build BookingScreen(listing: fakeListing) where fakeListing has
     title="Test Plumbing", price=50.0, priceType=perHour, providerName="Alice"
   - Wrap in ProviderScope + MaterialApp
   - pump and settle
   - expect(find.text('Test Plumbing'), findsOneWidget)
   - expect(find.text('€50.00/hr'), findsOneWidget)

   Test 2 — 'Confirm Booking navigates to success screen':
   - Override createBookingProvider to return immediately with a fake
     BookingResponse(id:'booking-123', status:BookingStatus.pending, ...)
   - Build BookingScreen inside a MaterialApp(onGenerateRoute:...) or a GoRouter
     that has /booking/success/:id → BookingSuccessScreen
   - pumpAndSettle, tap ElevatedButton with text 'Confirm Booking'
   - pumpAndSettle
   - expect(find.byType(BookingSuccessScreen), findsOneWidget)

   Test 3 — 'shows error SnackBar on API failure':
   - Override createBookingProvider to throw
     DioException(type:DioExceptionType.badResponse, response:Response(data:{'message':'Slot taken'},...))
   - Tap 'Confirm Booking'
   - pumpAndSettle
   - expect(find.text('Booking failed: Slot taken'), findsOneWidget)

3. Create test/features/booking/booking_success_screen_test.dart.
   Test: 'shows booking details when loaded':
   - Override bookingDetailProvider('b-1') with a fake BookingResponse
     (listingTitle:'Test Plumbing', providerName:'Alice', totalPrice:50.0,
      status:BookingStatus.pending)
   - Build BookingSuccessScreen(bookingId:'b-1')
   - expect(find.text('Booking Confirmed!'), findsOneWidget)
   - expect(find.text('Test Plumbing'), findsOneWidget)
   - expect(find.text('€50.00'), findsOneWidget)

4. Run: flutter test test/features/booking/
   All tests must pass.

---

## Step 5 — MEDIUM: Pull-to-Refresh on Catalog + Provider Dashboard

The backend nightly rating job updates listing averages. Add pull-to-refresh so
users get fresh data without restarting the app.

Context:
- CatalogScreen at lib/features/catalog/presentation/catalog_screen.dart
- ProviderDashboardScreen at lib/features/provider_dashboard/presentation/provider_dashboard_screen.dart
- ListingDetailScreen at lib/features/listing/presentation/listing_detail_screen.dart
- ChatListScreen already has pull-to-refresh — read it as the reference pattern

Tasks:
1. Read lib/features/chat/presentation/chat_list_screen.dart.
   Note the RefreshIndicator + ref.invalidate pattern.

2. In CatalogScreen:
   - Identify every provider the screen watches (e.g. searchListingsProvider,
     catalogListingsProvider — read the actual code).
   - Wrap the outer scroll widget with RefreshIndicator.
   - onRefresh: invalidate all watched providers, then await the primary one's future.

3. In ProviderDashboardScreen:
   - Wrap the ListView (inside the listingsAsync.when data branch) with
     RefreshIndicator.
   - onRefresh:
       ref.invalidate(myListingsProvider);
       await ref.read(myListingsProvider.future);

4. In ListingDetailScreen:
   - Wrap the CustomScrollView with RefreshIndicator.
   - onRefresh:
       ref.invalidate(listingDetailProvider(widget.id));
       await ref.read(listingDetailProvider(widget.id).future);

5. Run: flutter analyze
   Zero errors. Do NOT add any new loading spinners — existing skeleton widgets
   handle the loading state.

---

## Step 6 — MEDIUM: EditListing Screen + Photo Management in Dashboard

The backend photo endpoints (DELETE, PUT /order) are wired to real Cloudinary.
Add the missing EditListingScreen and photo management actions in the provider dashboard.

Context:
- CreateListingScreen at lib/features/listing/presentation/create_listing_screen.dart
- ListingApi.updateListing(id, request) already exists at listing_api.dart:45
- No deletePhoto or reorderPhotos methods exist in ListingApi yet
- Router has no /provider/listings/:id/edit route
- ProviderDashboard Edit button currently does nothing

Tasks:
1. Add to ListingApi (listing_api.dart):
     Future<void> deletePhoto(String listingId, String photoId) =>
         _dio.delete('/api/listings/$listingId/photos/$photoId');

     Future<void> reorderPhotos(String listingId, List<String> orderedIds) =>
         _dio.put('/api/listings/$listingId/photos/order',
             data: {'photoIds': orderedIds});
   Add matching methods in ListingRepository.

2. Extract the shared form helper widgets from CreateListingScreen into a new file
   lib/features/listing/presentation/widgets/listing_form_helpers.dart:
   - _Label → ListingFormLabel (public)
   - _PriceTypeButton → ListingPriceTypeButton (public)
   Update CreateListingScreen to import and use them from the new file.

3. Create lib/features/listing/presentation/edit_listing_screen.dart.
   Class EditListingScreen extends ConsumerWidget, takes listingId: String.
   - Watch listingDetailProvider(listingId)
   - On loading: show CircularProgressIndicator
   - On error: show AppErrorWidget
   - On data: show a form pre-filled with listing data.
     Reuse the same step structure as CreateListingScreen (steps 1–5/6):
     pre-fill: title, description, categoryId, price, priceType, latitude, longitude
   - Submit calls listingRepository.updateListing(listingId, request)
   - On success: ref.invalidate(myListingsProvider); context.pop()

4. In edit form's photo step, display listing.photos as deletable 90×90 thumbnails
   (CachedNetworkImage). X button calls listingRepository.deletePhoto(listingId, photo.id)
   and removes the photo from local state. No undo.

5. Add route to lib/core/router/app_router.dart:
     GoRoute(
       path: '/provider/listings/:id/edit',
       builder: (context, state) => EditListingScreen(
         listingId: state.pathParameters['id']!,
       ),
     ),

6. In ProviderDashboardScreen, wire the Edit button:
   onPressed: () => context.push('/provider/listings/${listing.id}/edit')

7. Run: flutter analyze
   Zero errors.

---

## Step 7 — HIGH PRIORITY: FCM Push Notifications

The backend NotificationService retries failed FCM sends. Wire FCM on the Flutter
side so chat notifications are received and tapping navigates to the correct chat.

Context:
- firebase_messaging is already in pubspec.yaml
- No FCM handling code exists yet
- GoRouter instance is appRouter in lib/core/router/app_router.dart
- Chat routes: /chats (list), /chats/:id (single chat with listingTitle as extra)
- Backend sends data payload: { "chatId": "...", "type": "NEW_MESSAGE" }

Tasks:
1. Read lib/main.dart and lib/app.dart fully.

2. In main.dart, add a top-level background message handler BEFORE main():
     @pragma('vm:entry-point')
     Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
       await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
     }
   Register it as the first line inside main():
     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

3. Create lib/core/notifications/fcm_service.dart with class FcmService:

     class FcmService {
       static Future<void> initialize() async {
         final messaging = FirebaseMessaging.instance;

         await messaging.requestPermission(alert: true, badge: true, sound: true);

         final token = await messaging.getToken();
         debugPrint('FCM token: $token');

         // Foreground messages
         FirebaseMessaging.onMessage.listen((msg) {
           final n = msg.notification;
           if (n == null) return;
           // Use a global SnackBar key (see task 4)
           _showInAppBanner(n.title ?? 'New message', msg.data);
         });

         // Background tap
         FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

         // Terminated-state tap
         final initial = await messaging.getInitialMessage();
         if (initial != null) _handleTap(initial);
       }

       static void _handleTap(RemoteMessage msg) {
         final chatId = msg.data['chatId'] as String?;
         if (chatId != null) {
           appRouter.go('/chats/$chatId');
         } else {
           appRouter.go('/chats');
         }
       }

       static void _showInAppBanner(String title, Map<String, dynamic> data) {
         final chatId = data['chatId'] as String?;
         rootScaffoldMessengerKey.currentState?.showSnackBar(
           SnackBar(
             content: Text(title),
             action: chatId != null
                 ? SnackBarAction(
                     label: 'Open',
                     onPressed: () => appRouter.go('/chats/$chatId'))
                 : null,
             duration: const Duration(seconds: 4),
           ),
         );
       }
     }

4. In lib/app.dart, add a GlobalKey<ScaffoldMessengerState>:
     final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
         GlobalKey<ScaffoldMessengerState>();
   Pass it to MaterialApp:
     scaffoldMessengerKey: rootScaffoldMessengerKey,
   Export it so fcm_service.dart can import it.

5. Call FcmService.initialize() in main() after Firebase.initializeApp():
     await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
     await FcmService.initialize();

6. Android — confirm android/app/src/main/AndroidManifest.xml contains inside <activity>:
     <intent-filter>
       <action android:name="FLUTTER_NOTIFICATION_CLICK" />
       <category android:name="android.intent.category.DEFAULT" />
     </intent-filter>
   If missing, add it.

7. Run: flutter analyze
   Zero errors.
   Manual verification: run on Android emulator, send a test FCM via Firebase Console
   with data payload {"chatId":"test-id"} → verify SnackBar appears in foreground,
   tap navigates to /chats/test-id.
