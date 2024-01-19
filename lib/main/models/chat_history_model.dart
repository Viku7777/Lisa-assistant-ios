class ChatHistoryModel {
  String chatTitle;
  String ChatId;
  List<ChatModel> allChats;
  ChatHistoryModel(this.chatTitle, this.ChatId, this.allChats);

  ChatHistoryModel.fromHistory(Map<String, dynamic> history, this.ChatId)
      : chatTitle = history['question'] ?? "Not Available",
        allChats = (history['msgList'] as List)
            .map((e) => ChatModel.fromChat(e))
            .toList();
}

class ChatModel {
  String role;
  String msg;
  ChatModel(this.role, this.msg);

  ChatModel.fromChat(Map<String, dynamic> json)
      : role = json["role"] ?? "assistant",
        msg = json['content'] ?? "";
}
