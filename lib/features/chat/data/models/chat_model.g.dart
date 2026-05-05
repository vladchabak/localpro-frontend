// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatSummaryModel _$ChatSummaryModelFromJson(Map<String, dynamic> json) =>
    ChatSummaryModel(
      id: json['id'] as String,
      otherPartyId: json['otherPartyId'] as String,
      otherPartyName: json['otherPartyName'] as String,
      otherPartyAvatarUrl: json['otherPartyAvatarUrl'] as String?,
      listingId: json['listingId'] as String?,
      listingTitle: json['listingTitle'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String),
      unreadCount: (json['unreadCount'] as num).toInt(),
    );

Map<String, dynamic> _$ChatSummaryModelToJson(ChatSummaryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'otherPartyId': instance.otherPartyId,
      'otherPartyName': instance.otherPartyName,
      'otherPartyAvatarUrl': instance.otherPartyAvatarUrl,
      'listingId': instance.listingId,
      'listingTitle': instance.listingTitle,
      'lastMessage': instance.lastMessage,
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
      'unreadCount': instance.unreadCount,
    };

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderAvatarUrl: json['senderAvatarUrl'] as String?,
      content: json['content'] as String,
      isRead: json['isRead'] as bool,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderAvatarUrl': instance.senderAvatarUrl,
      'content': instance.content,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
