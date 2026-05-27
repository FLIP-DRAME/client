import '../model/chat_model.dart';
import '../network/chat_api.dart';

class ChatViewModel {
  const ChatViewModel(this._api);

  final ChatApi _api;

  Future<String> getOrCreateRoom(String jobRequestId) {
    return _api.getOrCreateRoom(jobRequestId);
  }

  Future<void> sendMessage({
    required String roomId,
    required String content,
  }) {
    return _api.sendMessage(roomId: roomId, content: content);
  }

  Stream<List<ChatMessage>> messageStream(String roomId) {
    return _api.messageStream(roomId);
  }

  Future<List<ChatRoom>> fetchRooms() {
    return _api.fetchRooms();
  }

  Future<void> markRead(String roomId) {
    return _api.markRead(roomId);
  }
}
