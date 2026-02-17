import 'dart:async';
import 'package:meta/meta.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket channel wrapper for managing WebSocket connections.
@immutable
class StreamClient {
  /// The underlying WebSocket channel
  final WebSocketChannel channel;

  /// The stream of messages from the server
  final Stream<dynamic> stream;

  /// The sink for sending messages to the server
  final StreamSink<dynamic> sink;

  /// Internal connection state tracker
  bool _isConnected = false;

  /// Creates a new StreamClient instance.
  factory StreamClient.connect(String url) {
    final channel = WebSocketChannel.connect(Uri.parse(url));
    return StreamClient._(channel: channel);
  }

  /// Private constructor
  StreamClient._({required this.channel})
    : stream = channel.stream,
      sink = channel.sink {
    _isConnected = true;
  }

  /// Sends a message through the WebSocket.
  void send(dynamic message) {
    if (_isConnected) {
      sink.add(message);
    }
  }

  /// Closes the WebSocket connection.
  Future<void> close() async {
    _isConnected = false;
    await sink.close();
  }

  /// Returns true if the connection is open.
  bool get isConnected => _isConnected;

  /// Returns true if the connection is closed.
  bool get isClosed => !_isConnected;
}
