import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum WatchStatus {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

class WatchData {
  final WatchStatus status;
  final BluetoothDevice? device;
  final String? deviceName;
  final int heartRate;
  final double temperature;
  final int steps;
  final double battery;
  final List<BluetoothDevice> availableDevices;
  final String? errorMessage;

  const WatchData({
    this.status = WatchStatus.disconnected,
    this.device,
    this.deviceName,
    this.heartRate = 0,
    this.temperature = 0,
    this.steps = 0,
    this.battery = 0,
    this.availableDevices = const [],
    this.errorMessage,
  });

  WatchData copyWith({
    WatchStatus? status,
    BluetoothDevice? device,
    String? deviceName,
    int? heartRate,
    double? temperature,
    int? steps,
    double? battery,
    List<BluetoothDevice>? availableDevices,
    String? errorMessage,
  }) {
    return WatchData(
      status: status ?? this.status,
      device: device ?? this.device,
      deviceName: deviceName ?? this.deviceName,
      heartRate: heartRate ?? this.heartRate,
      temperature: temperature ?? this.temperature,
      steps: steps ?? this.steps,
      battery: battery ?? this.battery,
      availableDevices: availableDevices ?? this.availableDevices,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class WatchService extends StateNotifier<WatchData> {
  WatchService() : super(const WatchData());

  StreamSubscription? _scanSub;
  StreamSubscription? _notifSub;
  BluetoothDevice? _connectedDevice;

  // Aikela saat UUID'leri (genel akıllı saat)
  static const String _heartRateServiceUUID = '0000180d-0000-1000-8000-00805f9b34fb';
  static const String _heartRateCharUUID = '00002a37-0000-1000-8000-00805f9b34fb';
  static const String _batteryServiceUUID = '0000180f-0000-1000-8000-00805f9b34fb';
  static const String _batteryCharUUID = '00002a19-0000-1000-8000-00805f9b34fb';
  static const String _stepServiceUUID = '0000fee0-0000-1000-8000-00805f9b34fb';

  Future<void> startScan() async {
    try {
      // Bluetooth açık mı?
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        state = state.copyWith(
          status: WatchStatus.error,
          errorMessage: 'Bluetooth kapalı. Lütfen açın.',
        );
        return;
      }

      state = state.copyWith(
        status: WatchStatus.scanning,
        availableDevices: [],
      );

      final List<BluetoothDevice> found = [];

      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (!found.any((d) => d.remoteId == r.device.remoteId)) {
            final name = r.advertisementData.advName;
            // Aikela veya akıllı saat filtrele
            if (name.isNotEmpty) {
              found.add(r.device);
              state = state.copyWith(availableDevices: List.from(found));
            }
          }
        }
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      state = state.copyWith(
        status: WatchStatus.error,
        errorMessage: 'Tarama hatası: $e',
      );
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      state = state.copyWith(status: WatchStatus.connecting);
      await FlutterBluePlus.stopScan();

      await device.connect(timeout: const Duration(seconds: 15));
      _connectedDevice = device;

      state = state.copyWith(
        status: WatchStatus.connected,
        device: device,
        deviceName: device.platformName.isNotEmpty
            ? device.platformName
            : 'Aikela Saat',
      );

      await _discoverServices(device);
    } catch (e) {
      state = state.copyWith(
        status: WatchStatus.error,
        errorMessage: 'Bağlantı hatası: $e',
      );
    }
  }

  Future<void> _discoverServices(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        // Kalp atışı
        if (service.uuid.toString().startsWith('0000180d')) {
          for (BluetoothCharacteristic char in service.characteristics) {
            if (char.uuid.toString().startsWith('00002a37')) {
              if (char.properties.notify) {
                await char.setNotifyValue(true);
                _notifSub = char.onValueReceived.listen((value) {
                  if (value.isNotEmpty) {
                    final hr = value.length > 1 ? value[1] : value[0];
                    state = state.copyWith(heartRate: hr);
                  }
                });
              }
            }
          }
        }

        // Pil seviyesi
        if (service.uuid.toString().startsWith('0000180f')) {
          for (BluetoothCharacteristic char in service.characteristics) {
            if (char.uuid.toString().startsWith('00002a19')) {
              if (char.properties.read) {
                final value = await char.read();
                if (value.isNotEmpty) {
                  state = state.copyWith(battery: value[0].toDouble());
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('Servis keşfetme hatası: $e');
    }
  }

  Future<void> disconnect() async {
    _notifSub?.cancel();
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    state = const WatchData();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _notifSub?.cancel();
    super.dispose();
  }
}

final watchServiceProvider = StateNotifierProvider<WatchService, WatchData>(
  (ref) => WatchService(),
);
