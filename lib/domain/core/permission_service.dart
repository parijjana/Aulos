abstract class PermissionService {
  Future<bool> requestAudioPermission();
  Future<bool> checkAudioPermission();
}
