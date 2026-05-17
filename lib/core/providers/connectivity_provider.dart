import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

@riverpod
Stream<bool> isOnline(IsOnlineRef ref) =>
    Connectivity().onConnectivityChanged.map(
      (results) => results.any((r) => r != ConnectivityResult.none),
    );
