import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SyncBotPage extends StatefulWidget {
  const SyncBotPage({super.key});

  @override
  _SyncBotPageState createState() => _SyncBotPageState();
}

class _SyncBotPageState extends State<SyncBotPage> {
  final TextEditingController _inputController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      "role": "bot",
      "text": "Hello! You can ask me anything about Thyroid and Diabetes 🤗"
    },
  ];
  final String _apiUrl =
      "https://payload.vextapp.com/hook/J1460Z18NT/catch/\$(nandiniNShealth)";
  final String _apiKey = "aoxRWadT.BTsbRkr94z4wgPgbtgnJ7XFx4ldCJlMo";
  bool _isLoading = false;

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeechToText();
    _initTextToSpeech();
  }

  Future<void> _initSpeechToText() async {
    await _speechToText.initialize();
  }

  Future<void> _initTextToSpeech() async {
    await _flutterTts.setSharedInstance(true);
  }

  Future<void> _startListening() async {
    if (await _speechToText.hasPermission && !_isListening) {
      setState(() => _isListening = true);
      await _speechToText.listen(onResult: _onSpeechResult);
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      setState(() => _isListening = false);
      await _speechToText.stop();
      if (_lastWords.isNotEmpty) {
        _sendMessage(_lastWords);
      }
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  Future<void> _systemSpeak(String content) async {
    await _flutterTts.speak(content);
  }

  Future<void> _sendMessage(String userMessage) async {
    setState(() {
      _messages.add({"role": "user", "text": userMessage});
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Apikey": "Api-Key $_apiKey",
        },
        body: jsonEncode({"payload": userMessage}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final botResponse =
            responseBody["text"] ?? "No response text available.";
        setState(() {
          _messages.add({"role": "bot", "text": botResponse});
        });
        _systemSpeak(botResponse);
      } else {
        setState(() {
          _messages
              .add({"role": "bot", "text": "Error: Unable to fetch response."});
        });
      }
    } catch (error) {
      setState(() {
        _messages.add({
          "role": "bot",
          "text": "Error communicating with the API: $error"
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildMessageBubble(String text, String role) {
    final isUser = role == "user";
    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser)
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(
                'assets/images/bot_avatar.png'), // Add bot avatar image in assets
          ),
        if (!isUser) const SizedBox(width: 8),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF00A0B0) : const Color(0xFFEFF8FA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(isUser ? 12 : 0),
                bottomRight: Radius.circular(isUser ? 0 : 12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isUser ? Colors.white : const Color(0xFF006E7F),
              ),
            ),
          ),
        ),
        if (isUser) const SizedBox(width: 8),
        if (isUser)
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(
                'assets/images/user_avatar.png'), // Add user avatar image in assets
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SyncBot 👩🏻‍⚕"),
        backgroundColor: const Color(0xFF006E7F),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isListening ? _stopListening : _startListening,
            icon: Image.asset(
              _isListening
                  ? 'assets/icons/mic.png'
                  : 'assets/icons/mic_none.png',
              width: 28,
              height: 28,
              color: const Color.fromARGB(255, 5, 6, 6),
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 217, 240, 244),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(
                      message["text"]!, message["role"]!);
                },
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF006E7F)), // Use app's theme color
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: "Ask about Thyroid and Diabetes...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide:
                              BorderSide(color: Color(0xFF006E7F), width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      final userMessage = _inputController.text.trim();
                      if (userMessage.isNotEmpty) {
                        _inputController.clear();
                        _sendMessage(userMessage);
                      }
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00A0B0), Color(0xFF006E7F)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/icons/send_icon.png',
                        height: 24,
                        width: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
