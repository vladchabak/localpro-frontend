class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrlAndroid = 'http://10.0.2.2:8080';
  static const String baseUrlWeb = 'http://localhost:8080';

  static const String categories = '/api/categories';
  static const String listingsNearby = '/api/listings/nearby';
  static const String listings = '/api/listings';
  static const String myListings = '/api/listings/my';
  static const String authRegister = '/api/auth/register';
  static const String usersMe = '/api/users/me';
  static const String chats = '/api/chats';
}
