import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/api/api_client.dart';
import '../../../core/providers/test_user_provider.dart';
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
Future<UserModel> currentUser(CurrentUserRef ref) async {
  final testUser = ref.watch(testUserNotifierProvider);
  if (testUser != null) {
    return UserModel(
      id: testUser.uid,
      firebaseUid: testUser.uid,
      email: testUser.email,
      name: testUser.displayName,
      role: 'CLIENT',
      rating: 0,
      reviewCount: 0,
      isActive: true,
    );
  }
  return ref.watch(authRepositoryProvider).getMe();
}

@riverpod
Stream<User?> authState(AuthStateRef ref) =>
    FirebaseAuth.instance.authStateChanges();

@riverpod
Future<bool> isAuthenticated(IsAuthenticatedRef ref) async {
  final user = await ref.watch(authStateProvider.future);
  return user != null;
}
