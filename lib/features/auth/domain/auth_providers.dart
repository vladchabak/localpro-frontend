import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/api/api_client.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';
import '../data/models/user_model.dart';

part 'auth_providers.g.dart';

@riverpod
Dio dio(DioRef ref) => ApiClient.createDio();

@riverpod
AuthApi authApi(AuthApiRef ref) => AuthApi(ref.watch(dioProvider));

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) =>
    AuthRepository(ref.watch(authApiProvider));

@riverpod
Future<UserModel> currentUser(CurrentUserRef ref) =>
    ref.watch(authRepositoryProvider).getMe();

@riverpod
Stream<User?> authState(AuthStateRef ref) =>
    FirebaseAuth.instance.authStateChanges();

@riverpod
Future<bool> isAuthenticated(IsAuthenticatedRef ref) async {
  final user = await ref.watch(authStateProvider.future);
  return user != null;
}
