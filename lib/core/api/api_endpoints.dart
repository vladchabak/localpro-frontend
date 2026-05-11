class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrlAndroid = 'http://10.0.2.2:8080';
  static const String baseUrlWeb = 'https://demo-production-2680.up.railway.app';

  static const String wsUrlAndroid = 'ws://10.0.2.2:8080/ws/websocket';
  static const String wsUrlWeb = 'wss://demo-production-2680.up.railway.app/ws/websocket';

  static const String categories = '/api/categories';
  static const String listings = '/api/listings';
  static const String listingsNearby = '/api/listings/nearby';
  static const String listingsSearch = '/api/listings/search';
  static const String listingsPopular = '/api/listings/popular';
  static const String listingsRecent = '/api/listings/recent';
  static const String listingsCategory = '/api/listings/category';
  static const String myListings = '/api/listings/my';
  static const String authRegister = '/api/auth/register';
  static const String usersMe = '/api/users/me';
  static const String chats = '/api/chats';
}
