// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ChatPage extends StatefulWidget {
  final String? plantName;
  final String? diseaseName;

  const ChatPage({super.key, this.plantName, this.diseaseName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  final _user = const types.User(
      id: '82091008-a484-4a89-ae75-a22bf8d6f3ac', firstName: 'User');
  final _assistant = const types.User(
      id: '82091008-a484-4a89-ae75-a22bf8d6f3ab', firstName: 'Assistant');

  Future<String> askQuestion(String message) async {
    final url = Uri.parse('http://20.54.112.25/chatbot/ask-question');
    final res = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        "user_question": message,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      var data1 = utf8.decode(res.bodyBytes);
      var data = jsonDecode(data1);

      print('Response data: ${data['text']}');
      return data['text'].toString();
    } else {
      print('Failed to send POST request. Status code: ${res.statusCode}');
      return "";
    }
  }

  void getCure(plantName, diseaseName) async {
    setState(() {
      final question =
          "What is the cure for $plantName plant with $diseaseName disease?";

      final cureQuestion = types.TextMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: randomString(),
        text: question,
      );

      _messages.add(cureQuestion);
    });

    final url = Uri.parse('http://20.54.112.25/chatbot/get-cure');
    final res = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        "plantName": plantName,
        "diseaseName": diseaseName,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      var data1 = utf8.decode(res.bodyBytes);
      var data = jsonDecode(data1);
      print('Response data: ${data['text']}');
      setState(() {
        final cureAnswer = types.TextMessage(
          author: _assistant,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: randomString(),
          text: data['text'].toString(),
        );

        _messages.add(cureAnswer);
        _messages = _messages.reversed.toList();
      });
    } else {
      print('Failed to send POST request. Status code: ${res.statusCode}');
    }
  }

  void clearHistory() async {
    final url = Uri.parse('http://20.54.112.25/chatbot/clear-history');
    final res = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      setState(() {
        _messages.clear();
      });
    } else {
      print('Failed to send POST request. Status code: ${res.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.diseaseName != null && widget.plantName != null) {
      getCure(widget.plantName, widget.diseaseName);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: PreferredSize(
          preferredSize:
              const Size.fromHeight(80), // Height of the custom AppBar
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(50)),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  spreadRadius: 8,
                  blurRadius: 10,
                  offset: const Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: AppBar(
              title: const Padding(
                padding: EdgeInsets.only(top: 16.0), // Move text down
                child: Text(
                  'ChatBot', // Use the variable here
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              backgroundColor: Colors
                  .transparent, // Transparent background to show custom container
              elevation: 0, // Remove default AppBar shadow
              centerTitle: true, // Center the title
            ),
          ),
        ),
        body: Chat(
          messages: _messages,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          user: _user,
          theme: const DefaultChatTheme(),
          showUserNames: true,
        ),
      );

  void _addMessage(types.Message message) {
    setState(() {
      // print(message.toJson()['text']);
      _messages.insert(0, message);
      print('------------------');
      print(_messages);
      print('------------------');
    });
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    _addMessage(textMessage);

    String assistantRes = await askQuestion(textMessage.text);
    final textMessage2 = types.TextMessage(
      author: _assistant,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: assistantRes,
    );

    _addMessage(textMessage2);
  }
}
