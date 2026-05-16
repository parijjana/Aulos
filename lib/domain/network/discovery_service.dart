abstract class DiscoveryService {
  Future<void> startBroadcasting(String name);
  Future<void> stopBroadcasting();
  Future<List<DiscoveredDevice>> scanForDevices();
  Stream<List<DiscoveredDevice>> get deviceStream;
}

class DiscoveredDevice {
  final String name;
  final String ip;
  final int port;

  DiscoveredDevice({required this.name, required this.ip, required this.port});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveredDevice &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          ip == other.ip &&
          port == other.port;

  @override
  int get hashCode => name.hashCode ^ ip.hashCode ^ port.hashCode;
}
