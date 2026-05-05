import 'package:dio/dio.dart';
import 'models/user_model.dart';

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  Future<UserModel> registerOrGetMe() async {
    final response = await _dio.post('/api/auth/register');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get('/api/users/me');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/api/users/me', data: data);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
