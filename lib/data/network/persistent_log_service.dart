import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:aulos/domain/network/log_service.dart';

class PersistentLogService extends ChangeNotifier implements LogService {
  final File _logFile;
  final List<String> _logs = [];
  final _logController = StreamController<List<String>>.broadcast();

  PersistentLogService({required File logFile}) : _logFile = logFile {
    _initFile();
  }

  @override
  List<String> get logs => List.unmodifiable(_logs);

  @override
  Stream<List<String>> get logStream => _logController.stream;

  Future<void> _initFile() async {
    try {
      if (await _logFile.exists()) {
        await _logFile.delete();
      }
      await _logFile.create(recursive: true);
      log('SYSTEM: Log persistence initialized at ${_logFile.path}');
    } catch (e) {
      debugPrint('PersistentLogService: Failed to init file: $e');
    }
  }

  @override
  void log(String message) {
    final timestamp = DateTime.now().toString().split(' ').last.substring(0, 8);
    final logEntry = '[$timestamp] $message';
    _logs.insert(0, logEntry);

    if (_logs.length > 5000) _logs.removeLast();

    notifyListeners();
    _logController.add(_logs);

    try {
      _logFile.writeAsStringSync('$logEntry\n', mode: FileMode.append, flush: true);
    } catch (e) {
      debugPrint('PersistentLogService: Failed to write to file: $e');
    }

    debugPrint('AULOS_LOG: $logEntry');
  }

  @override
  void clear() {
    _logs.clear();
    try {
      if (_logFile.existsSync()) {
        _logFile.writeAsStringSync('');
      }
    } catch (e) {
      debugPrint('PersistentLogService: Failed to clear file: $e');
    }
    notifyListeners();
    _logController.add(_logs);
  }

  @override
  void dispose() {
    _logController.close();
    super.dispose();
  }
}
