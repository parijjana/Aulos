import 'dart:async';
import 'package:flutter/foundation.dart';

class MediaLogService extends ChangeNotifier {
  final List<String> _logs = [];
  final _logController = StreamController<List<String>>.broadcast();

  List<String> get logs => List.unmodifiable(_logs);
  Stream<List<String>> get logStream => _logController.stream;

  void log(String message) {
    final timestamp = DateTime.now().toString().split(' ').last.substring(0, 8);
    final logEntry = '[$timestamp] $message';
    _logs.insert(0, logEntry);
    if (_logs.length > 50) _logs.removeLast();
    notifyListeners();
    _logController.add(_logs);
    debugPrint('MEDIA_LOG: $logEntry');
  }

  void clear() {
    _logs.clear();
    notifyListeners();
    _logController.add(_logs);
  }
}
