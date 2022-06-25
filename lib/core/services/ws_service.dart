// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:paperopoli_terminal/core/constants/urls.dart';
import 'package:paperopoli_terminal/data/models/chat/message_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsService {
  static WebSocketChannel? _channel;
  static final ValueNotifier<List<MessageModel>> _messages = ValueNotifier([]);

  static ValueNotifier<List<MessageModel>> get messages => _messages;

  static Future<void> connect(
    BuildContext context,
    ScrollController scrollController,
  ) async {
    if (_channel == null || _channel!.closeCode != null) {
      try {
        _channel = WebSocketChannel.connect(
          Uri.parse(
            TERMINAL_WS_URL,
          ),
        );
        Stream.periodic(
          const Duration(
            seconds: 30,
          ),
        ).listen((event) {
          try {
            _channel!.sink.add('ping');
          } catch (_) {}
        });
        _channel!.stream.listen((event) {
          try {
            if (event == 'pong') return;
            _messages.value.add(
              MessageModel.fromJson(
                jsonDecode(event),
              ),
            );
            _messages.notifyListeners();
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
              await scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(
                  milliseconds: 200,
                ),
                curve: Curves.easeOut,
              );
            });
          } catch (_) {}
        });
      } catch (_) {}
    }
  }

  static Future<void> send(
    MessageModel messageModel,
    ScrollController scrollController,
  ) async {
    try {
      _channel!.sink.add(
        messageModel.toJson(),
      );
      _messages.value.add(messageModel);
      _messages.notifyListeners();
      await scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 200,
        ),
        curve: Curves.easeOut,
      );
    } catch (_) {}
  }
}
