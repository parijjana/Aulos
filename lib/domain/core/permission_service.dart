import 'package:permission_handler/permission_handler.dart';

abstract class PermissionService {
  Future<bool> requestAudioPermission();
  Future<PermissionStatus> checkAudioPermission();
}

class PermissionServiceImpl implements PermissionService {
  @override
  Future<bool> requestAudioPermission() async {
    final status = await Permission.audio.request();
    return status.isGranted;
  }

  @override
  Future<PermissionStatus> checkAudioPermission() async {
    return await Permission.audio.status;
  }
}
