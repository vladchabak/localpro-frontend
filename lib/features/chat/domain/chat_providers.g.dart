// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatApiHash() => r'a52ed0ca978c3362988c532333b8ba48c0b08e1a';

/// See also [chatApi].
@ProviderFor(chatApi)
final chatApiProvider = AutoDisposeProvider<ChatApi>.internal(
  chatApi,
  name: r'chatApiProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$chatApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ChatApiRef = AutoDisposeProviderRef<ChatApi>;
String _$chatRepositoryHash() => r'61c0ebec15fa2c47b094b4880f585a0756dfcffa';

/// See also [chatRepository].
@ProviderFor(chatRepository)
final chatRepositoryProvider = AutoDisposeProvider<ChatRepository>.internal(
  chatRepository,
  name: r'chatRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ChatRepositoryRef = AutoDisposeProviderRef<ChatRepository>;
String _$stompServiceHash() => r'48d46372b4fb4e83923df907105f5ec5d08cd7ee';

/// See also [stompService].
@ProviderFor(stompService)
final stompServiceProvider = Provider<StompService>.internal(
  stompService,
  name: r'stompServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$stompServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StompServiceRef = ProviderRef<StompService>;
String _$chatsHash() => r'2155400de38d8373daa5e106d39cdd21dfc24818';

/// See also [chats].
@ProviderFor(chats)
final chatsProvider =
    AutoDisposeFutureProvider<List<ChatSummaryModel>>.internal(
  chats,
  name: r'chatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$chatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ChatsRef = AutoDisposeFutureProviderRef<List<ChatSummaryModel>>;
String _$chatMessagesHash() => r'613133d3597bd1ff55a594f8c8fa791b1dc9678e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [chatMessages].
@ProviderFor(chatMessages)
const chatMessagesProvider = ChatMessagesFamily();

/// See also [chatMessages].
class ChatMessagesFamily extends Family<AsyncValue<List<MessageModel>>> {
  /// See also [chatMessages].
  const ChatMessagesFamily();

  /// See also [chatMessages].
  ChatMessagesProvider call(
    String chatId,
  ) {
    return ChatMessagesProvider(
      chatId,
    );
  }

  @override
  ChatMessagesProvider getProviderOverride(
    covariant ChatMessagesProvider provider,
  ) {
    return call(
      provider.chatId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatMessagesProvider';
}

/// See also [chatMessages].
class ChatMessagesProvider
    extends AutoDisposeFutureProvider<List<MessageModel>> {
  /// See also [chatMessages].
  ChatMessagesProvider(
    String chatId,
  ) : this._internal(
          (ref) => chatMessages(
            ref as ChatMessagesRef,
            chatId,
          ),
          from: chatMessagesProvider,
          name: r'chatMessagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chatMessagesHash,
          dependencies: ChatMessagesFamily._dependencies,
          allTransitiveDependencies:
              ChatMessagesFamily._allTransitiveDependencies,
          chatId: chatId,
        );

  ChatMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatId,
  }) : super.internal();

  final String chatId;

  @override
  Override overrideWith(
    FutureOr<List<MessageModel>> Function(ChatMessagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChatMessagesProvider._internal(
        (ref) => create(ref as ChatMessagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatId: chatId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MessageModel>> createElement() {
    return _ChatMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMessagesProvider && other.chatId == chatId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChatMessagesRef on AutoDisposeFutureProviderRef<List<MessageModel>> {
  /// The parameter `chatId` of this provider.
  String get chatId;
}

class _ChatMessagesProviderElement
    extends AutoDisposeFutureProviderElement<List<MessageModel>>
    with ChatMessagesRef {
  _ChatMessagesProviderElement(super.provider);

  @override
  String get chatId => (origin as ChatMessagesProvider).chatId;
}

String _$chatMessageListHash() => r'611424fc3bee9ed08ce5cc6ebb212a47c4930d61';

abstract class _$ChatMessageList
    extends BuildlessAutoDisposeNotifier<List<MessageModel>> {
  late final String chatId;

  List<MessageModel> build(
    String chatId,
  );
}

/// See also [ChatMessageList].
@ProviderFor(ChatMessageList)
const chatMessageListProvider = ChatMessageListFamily();

/// See also [ChatMessageList].
class ChatMessageListFamily extends Family<List<MessageModel>> {
  /// See also [ChatMessageList].
  const ChatMessageListFamily();

  /// See also [ChatMessageList].
  ChatMessageListProvider call(
    String chatId,
  ) {
    return ChatMessageListProvider(
      chatId,
    );
  }

  @override
  ChatMessageListProvider getProviderOverride(
    covariant ChatMessageListProvider provider,
  ) {
    return call(
      provider.chatId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatMessageListProvider';
}

/// See also [ChatMessageList].
class ChatMessageListProvider extends AutoDisposeNotifierProviderImpl<
    ChatMessageList, List<MessageModel>> {
  /// See also [ChatMessageList].
  ChatMessageListProvider(
    String chatId,
  ) : this._internal(
          () => ChatMessageList()..chatId = chatId,
          from: chatMessageListProvider,
          name: r'chatMessageListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chatMessageListHash,
          dependencies: ChatMessageListFamily._dependencies,
          allTransitiveDependencies:
              ChatMessageListFamily._allTransitiveDependencies,
          chatId: chatId,
        );

  ChatMessageListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatId,
  }) : super.internal();

  final String chatId;

  @override
  List<MessageModel> runNotifierBuild(
    covariant ChatMessageList notifier,
  ) {
    return notifier.build(
      chatId,
    );
  }

  @override
  Override overrideWith(ChatMessageList Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatMessageListProvider._internal(
        () => create()..chatId = chatId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatId: chatId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ChatMessageList, List<MessageModel>>
      createElement() {
    return _ChatMessageListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMessageListProvider && other.chatId == chatId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChatMessageListRef on AutoDisposeNotifierProviderRef<List<MessageModel>> {
  /// The parameter `chatId` of this provider.
  String get chatId;
}

class _ChatMessageListProviderElement
    extends AutoDisposeNotifierProviderElement<ChatMessageList,
        List<MessageModel>> with ChatMessageListRef {
  _ChatMessageListProviderElement(super.provider);

  @override
  String get chatId => (origin as ChatMessageListProvider).chatId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
