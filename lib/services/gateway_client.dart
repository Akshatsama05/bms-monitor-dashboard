import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/bms_telemetry.dart';

abstract interface class BmsGatewayClient {
  Stream<BmsTelemetry> get readings;
  Future<void> connect();
  Future<void> close();
}

/// Browser WebSocket adapter for a gateway that emits the documented JSON schema.
/// MQTT is intentionally left behind this interface until a browser-safe broker,
/// message contract, and authentication policy are supplied by the system owner.
class WebSocketBmsGatewayClient implements BmsGatewayClient {
  WebSocketBmsGatewayClient(this.endpoint);

  final String endpoint;
  final StreamController<BmsTelemetry> _controller =
      StreamController.broadcast();
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  bool _closed = false;

  @override
  Stream<BmsTelemetry> get readings => _controller.stream;

  @override
  Future<void> connect() async {
    final uri = Uri.tryParse(endpoint);
    if (uri == null ||
        (uri.scheme != 'wss' && uri.scheme != 'ws') ||
        uri.host.isEmpty) {
      throw FormatException('Gateway endpoint must be a ws:// or wss:// URL.');
    }
    if (kIsWeb && Uri.base.scheme == 'https' && uri.scheme != 'wss') {
      throw const FormatException(
        'HTTPS browser sessions require a wss:// gateway endpoint.',
      );
    }

    final channel = WebSocketChannel.connect(uri);
    _channel = channel;
    await channel.ready.timeout(const Duration(seconds: 8));
    _subscription = channel.stream.listen(
      (dynamic message) {
        try {
          final raw = message.toString();
          if (raw.length > 256 * 1024) {
            throw const TelemetryValidationException(
              'Telemetry message exceeds the 256 KB limit.',
            );
          }
          final decoded = jsonDecode(raw);
          if (decoded is! Map) {
            throw const FormatException(
              'Telemetry message must be a JSON object.',
            );
          }
          final telemetry = BmsTelemetry.tryFromJson(
            Map<String, dynamic>.from(decoded),
            receivedAt: DateTime.now(),
          );
          if (telemetry == null) {
            throw const TelemetryValidationException(
              'Telemetry packet failed required-field or range validation.',
            );
          }
          _controller.add(telemetry);
        } on Object catch (error, stackTrace) {
          _controller.addError(error, stackTrace);
        }
      },
      onError: _controller.addError,
      onDone: () =>
          _controller.addError(StateError('Gateway connection closed.')),
      cancelOnError: false,
    );
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _subscription?.cancel();
    await _channel?.sink.close();
    await _controller.close();
  }
}
