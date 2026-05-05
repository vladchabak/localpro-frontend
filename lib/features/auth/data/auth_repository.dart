import 'auth_api.dart';
import 'models/user_model.dart';

class AuthRepository {
  final AuthApi _api;
  AuthRepository(this._api);

  Future<UserModel> registerOrGetMe() => _api.registerOrGetMe();
  Future<UserModel> getMe() => _api.getMe();
  Future<UserModel> updateProfile(Map<String, dynamic> data) =>
      _api.updateProfile(data);
}
