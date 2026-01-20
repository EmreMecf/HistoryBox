// lib/services/models/chatgpt/chat_gpt_chat_request.dart
class ChatGptChatRequestModel {
  final String model;
  final List<ChatGptChatMessageModel> messages;
  final int maxTokens;
  final double temperature;

  ChatGptChatRequestModel({
    required this.model,
    required this.messages,
    this.maxTokens = 1000,
    this.temperature = 0.7,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages.map((m) => m.toJson()).toList(),
      'max_tokens': maxTokens,
      'temperature': temperature,
    };
  }

  factory ChatGptChatRequestModel.fromJson(Map<String, dynamic> json) {
    return ChatGptChatRequestModel(
      model: json['model'] as String,
      messages: (json['messages'] as List)
          .map((m) => ChatGptChatMessageModel.fromJson(m))
          .toList(),
      maxTokens: json['max_tokens'] as int? ?? 1000,
      temperature: json['temperature'] as double? ?? 0.7,
    );
  }
}

class ChatGptChatMessageModel {
  final String role;
  final String content;

  ChatGptChatMessageModel({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }

  factory ChatGptChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatGptChatMessageModel(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }
}
