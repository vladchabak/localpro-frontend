import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'test_user_provider.g.dart';

class TestUserData {
  final String uid;
  final String displayName;
  final String email;

  const TestUserData({
    required this.uid,
    required this.displayName,
    required this.email,
  });
}

@Riverpod(keepAlive: true)
class TestUserNotifier extends _$TestUserNotifier {
  @override
  TestUserData? build() => null;

  void login(String name) {
    final slug = name.toLowerCase().replaceAll(' ', '-');
    state = TestUserData(
      uid: 'test-$slug',
      displayName: name,
      email: '${name.toLowerCase().replaceAll(' ', '.')}@test.com',
    );
  }

  void logout() => state = null;
}
