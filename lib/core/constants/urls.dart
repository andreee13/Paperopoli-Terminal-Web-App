// ignore_for_file: avoid_web_libraries_in_flutter
// ignore_for_file: constant_identifier_names, non_constant_identifier_names
import 'dart:html' as html;

final String TERMINAL_WS_URL = 'wss://${html.window.location.host}/api/v1/websocket';
final String TERMINAL_API_URL = 'https://${html.window.location.host}/api/v1';
