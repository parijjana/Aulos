import 'package:permission_handler/permission_handler.dart';
import 'package:aulos/domain/core/permission_service.dart';

class PermissionServiceImpl implements PermissionService {
  @override
  Future<bool> requestAudioPermission() async {
    final status = await Permission.audio.request();
    return status.isGranted;
  }

  @override
  Future<bool> checkAudioPermission() async {
    final status = await Permission.audio.status;
    return status.isGranted;
  }
}
