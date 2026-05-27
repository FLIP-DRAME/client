class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  static ChatMessage fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'].toString(),
        roomId: json['room_id'].toString(),
        senderId: json['sender_id'].toString(),
        content: json['content'].toString(),
        isRead: json['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'].toString()).toLocal(),
      );
}

class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.jobRequestId,
    required this.clientId,
    required this.operatorId,
    required this.lastMessageAt,
    this.lastMessage,
    this.unreadCount = 0,
    this.otherPartyName = '상대방',
    this.category = '작업',
    this.otherPartyAvatarUrl,
  });

  final String id;
  final String jobRequestId;
  final String clientId;
  final String operatorId;
  final DateTime lastMessageAt;
  final String? lastMessage;
  final int unreadCount;
  final String otherPartyName;
  final String category;
  final String? otherPartyAvatarUrl;
}
