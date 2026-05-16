import 'dart:async';
import 'package:nsd/nsd.dart' as nsd;
import 'package:localaudioplayer/domain/network/discovery_service.dart';

class NsdDiscoveryService implements DiscoveryService {
  static const String _serviceType = '_localaudio._tcp';
  nsd.Registration? _registration;
  nsd.Discovery? _discovery;

  final _deviceController =
      StreamController<List<DiscoveredDevice>>.broadcast();
  final List<DiscoveredDevice> _devices = [];

  @override
  Stream<List<DiscoveredDevice>> get deviceStream => _deviceController.stream;

  @override
  Future<void> startBroadcasting(String name) async {
    _registration = await nsd.register(
      nsd.Service(
        name: name,
        type: _serviceType,
        port: 8080, // Default port for our control socket
      ),
    );
  }

  @override
  Future<void> stopBroadcasting() async {
    if (_registration != null) {
      await nsd.unregister(_registration!);
      _registration = null;
    }
  }

  @override
  Future<List<DiscoveredDevice>> scanForDevices() async {
    _devices.clear();
    _discovery = await nsd.startDiscovery(_serviceType);

    _discovery!.addListener(() {
      for (final service in _discovery!.services) {
        if (service.name != null &&
            service.addresses != null &&
            service.addresses!.isNotEmpty) {
          final device = DiscoveredDevice(
            name: service.name!,
            ip: service.addresses!.first.address,
            port: service.port ?? 8080,
          );
          if (!_devices.contains(device)) {
            _devices.add(device);
            _deviceController.add(List.from(_devices));
          }
        }
      }
    });

    // Wait a bit for discovery to find initial devices
    await Future<void>.delayed(const Duration(seconds: 2));
    return _devices;
  }
}
