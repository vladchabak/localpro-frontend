import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_api.dart';
import 'models/user_model.dart';

class AuthRepository {
  final AuthApi _api;
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository(this._api, this._firebaseAuth, this._googleSignIn);

  Future<UserModel> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      await _firebaseAuth.signInWithPopup(provider);
    } else {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign-in cancelled');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
    }
    return _api.registerOrGetMe();
  }

  Future<UserModel> signInWithEmail(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _api.registerOrGetMe();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<UserModel> registerOrGetMe() => _api.registerOrGetMe();
  Future<UserModel> getMe() => _api.getMe();
  Future<UserModel> updateProfile(Map<String, dynamic> data) =>
      _api.updateProfile(data);
}
