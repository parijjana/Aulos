import 'dart:async';
import 'package:flutter/foundation.dart' show Listenable;

abstract class LogService implements Listenable {
  List<String> get logs;
  Stream<List<String>> get logStream;
  void log(String message);
  void clear();
}

class NoOpLogService implements LogService {
  @override
  void addListener(void Function() listener) {}

  @override
  void removeListener(void Function() listener) {}

  @override
  List<String> get logs => [];
  
  @override
  Stream<List<String>> get logStream => const Stream.empty();
  
  @override
  void log(String message) {}
  
  @override
  void clear() {}
}
