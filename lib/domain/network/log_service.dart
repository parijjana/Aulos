import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class MediaLogService extends ChangeNotifier {
  static final MediaLogService _instance = MediaLogService._internal();
  factory MediaLogService() => _instance;
  MediaLogService._internal() {
    _initFile();
  }

  final List<String> _logs = [];
  final _logController = StreamController<List<String>>.broadcast();
  File? _logFile;

  List<String> get logs => List.unmodifiable(_logs);
  Stream<List<String>> get logStream => _logController.stream;

  Future<void> _initFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _logFile = File(p.join(dir.path, 'aulos.log'));
      // Clean start for development
      if (await _logFile!.exists()) await _logFile!.delete();
      await _logFile!.create();
      log('SYSTEM: Log persistence initialized at ${_logFile!.path}');
    } catch (e) {
      debugPrint('LogService: Failed to init file: $e');
    }
  }

  void log(String message) {
    final timestamp = DateTime.now().toString().split(' ').last.substring(0, 8);
    final logEntry = '[$timestamp] $message';
    _logs.insert(0, logEntry);
    
    if (_logs.length > 5000) _logs.removeLast();
    
    notifyListeners();
    _logController.add(_logs);
    
    // Write to file
    if (_logFile != null) {
      _logFile!.writeAsStringSync('$logEntry\n', mode: FileMode.append, flush: true);
    }
    
    debugPrint('AULOS_LOG: $logEntry');
  }

  void clear() {
    _logs.clear();
    if (_logFile != null && _logFile!.existsSync()) {
      _logFile!.writeAsStringSync('');
    }
    notifyListeners();
    _logController.add(_logs);
  }
}

mixin UniversalLog {
  void log(String message) {
    MediaLogService().log(message);
  }
}
