import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class ChatSummaryModel {
  final String id;
  final String otherPartyId;
  final String otherPartyName;
  final String? otherPartyAvatarUrl;
  final String? listingId;
  final String? listingTitle;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ChatSummaryModel({
    required this.id,
    required this.otherPartyId,
    required this.otherPartyName,
    this.otherPartyAvatarUrl,
    this.listingId,
    this.listingTitle,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
  });

  factory ChatSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$ChatSummaryModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChatSummaryModelToJson(this);
}

@JsonSerializable()
class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String content;
  final bool isRead;
  final DateTime? createdAt;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.content,
    required this.isRead,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}
