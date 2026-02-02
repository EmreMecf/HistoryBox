// lib/services/models/chatgpt/chat_gpt_chat_response.dart
class ChatGptChatResponseModel {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<ChatGptChatChoiceModel> choices;

  ChatGptChatResponseModel({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
  });

  factory ChatGptChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatGptChatResponseModel(
      id: json['id'] as String,
      object: json['object'] as String,
      created: json['created'] as int,
      model: json['model'] as String,
      choices: (json['choices'] as List)
          .map((c) => ChatGptChatChoiceModel.fromJson(c))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object': object,
      'created': created,
      'model': model,
      'choices': choices.map((c) => c.toJson()).toList(),
    };
  }
}

class ChatGptChatChoiceModel {
  final ChatMessageModel message;
  final String? finishReason;
  final int index;

  ChatGptChatChoiceModel({
    required this.message,
    this.finishReason,
    this.index = 0,
  });

  factory ChatGptChatChoiceModel.fromJson(Map<String, dynamic> json) {
    return ChatGptChatChoiceModel(
      message: ChatMessageModel.fromJson(json['message']),
      finishReason: json['finish_reason'] as String?,
      index: json['index'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
      'finish_reason': finishReason,
      'index': index,
    };
  }
}

class ChatMessageModel {
  final String role;
  final String content;

  ChatMessageModel({
    required this.role,
    required this.content,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}
