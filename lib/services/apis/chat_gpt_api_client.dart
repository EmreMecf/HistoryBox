import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chatgpt/chat_gpt_chat_request.dart';
import '../models/chatgpt/chat_gpt_chat_response.dart';

class ChatGptApiClient{
  final Dio chatGptDio;

  ChatGptApiClient(this.chatGptDio);

  Future<ChatGptChatResponseModel> chaMessage(String message) async {
    final request = ChatGptChatRequestModel(
      model: dotenv.get("CHATGPT_MODEL"),
      messages: [ChatGptChatMessageModel(role: "user", content: message)],
    );
    print("ChatGPT isteği: ${request.toString()}");
    final response = await chatGptDio.post("/chat/completions", data: request.toJson());
    print("ChatGPT yanıtı: ${response.data}");

    return ChatGptChatResponseModel.fromJson(response.data);
  }
}