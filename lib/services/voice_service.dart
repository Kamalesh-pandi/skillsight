import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isSpeaking = false;
  bool _isListening = false;

  bool get isSpeaking => _isSpeaking;
  bool get isListening => _isListening;

  Future<void> init() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
    });
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }

  Future<bool> startListening({
    required Function(String) onResult,
    required Function(String) onStatus,
  }) async {
    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      print('VoiceService: Microphone permission denied');
      return false;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        print('VoiceService Status: $status');
        onStatus(status);
        if (status == 'notListening' || status == 'done') {
          _isListening = false;
        }
      },
      onError: (errorNotification) {
        _isListening = false;
        print('VoiceService Error: $errorNotification');
        print('VoiceService Error Permanent: ${errorNotification.permanent}');
      },
      debugLogging: true,
    );

    if (available) {
      _isListening = true;
      _speech.listen(
          onResult: (result) {
            onResult(result.recognizedWords);
            if (result.finalResult) {
              _isListening = false;
              stopListening();
            }
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation);
    } else {
      print('VoiceService: Speech recognition not available');
    }
    return available;
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
  }

  // Helper to check permissions explicitly if needed
  Future<bool> checkPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }
}
