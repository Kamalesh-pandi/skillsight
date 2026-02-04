import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../services/ai_chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  final AIChatService _chatService = AIChatService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatViewModel() {
    // Add initial greeting
    _messages.add(ChatMessage(
      text:
          "Hello! I'm your AI Career Mentor. I can help you with career advice, study plans, or technical concepts. What's on your mind today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate think time for realism if response is too fast
      // await Future.delayed(const Duration(milliseconds: 500));

      final responseText = await _chatService.sendMessage(text);

      _messages.add(ChatMessage(
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _messages.add(ChatMessage(
        text: "Sorry, I encountered an error. Please try again.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _messages.add(ChatMessage(
      text:
          "Hello! I'm your AI Career Mentor. I can help you with career advice, study plans, or technical concepts. What's on your mind today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}
