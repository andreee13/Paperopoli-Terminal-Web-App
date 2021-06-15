import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:paperopoli_terminal/core/constants/constants.dart';
import 'package:paperopoli_terminal/data/models/chat/message_model.dart';
import 'package:paperopoli_terminal/presentation/screens/home_screen.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsService {
  static WebSocketChannel? _channel;
  static final List<MessageModel> _messages = [];

  static List<MessageModel> get messages => _messages;

  static Future<void> connect(
    BuildContext context,
  ) async {
    if (_channel == null || _channel!.closeCode != null) {
      try {
        _channel = WebSocketChannel.connect(
          Uri.parse(
            TERMINAL_WS_URL,
          ),
        );
        Stream.periodic(
          Duration(
            seconds: 30,
          ),
        ).listen((event) {
          try {
            _channel!.sink.add(
              jsonEncode(
                {
                  'alive': true,
                },
              ),
            );
          } catch (_) {}
        });
        _channel!.stream.listen((event) {
          try {
            _messages.add(
              MessageModel.fromJson(
                jsonDecode(event),
              ),
            );
            // ignore: invalid_use_of_protected_member
            HomeScreen.of(context)!.setState(() {});
          } catch (_) {}
        });
      } catch (_) {}
    }
  }

  static Future<void> send(
    MessageModel messageModel,
  ) async {
    try {
      _channel!.sink.add(
        messageModel.toJson(),
      );
      _messages.add(messageModel);
    } catch (_) {}
  }
}