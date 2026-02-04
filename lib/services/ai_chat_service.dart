import 'package:firebase_vertexai/firebase_vertexai.dart';

class AIChatService {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  AIChatService() {
    _model = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-2.0-flash',
    );
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message, {String? context}) async {
    try {
      // If context is provided (e.g., user profile info), we can prepend it invisibly
      // or just rely on the ongoing chat session context.
      // For the first message, it might be good to inject system instructions if not done in init.

      final content = Content.text(message);
      final response = await _chat.sendMessage(content);
      return response.text ??
          "I'm having trouble thinking right now. Please try again.";
    } catch (e) {
      print('Chat Error: $e');
      return "Sorry, I encountered an error. Please check your connection.";
    }
  }
}
