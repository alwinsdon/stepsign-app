import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/sensor_data.dart';

/// Connection state for the BLE device
enum BleConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

/// Discovered StepSign device info
class DiscoveredDevice {
  final BluetoothDevice device;
  final String name;
  final int rssi;
  final DateTime discoveredAt;

  DiscoveredDevice({
    required this.device,
    required this.name,
    required this.rssi,
    DateTime? discoveredAt,
  }) : discoveredAt = discoveredAt ?? DateTime.now();

  String get id => device.remoteId.str;
}

/// Singleton BLE service for StepSign device communication
class BleService extends ChangeNotifier {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  // Connection state
  BleConnectionState _connectionState = BleConnectionState.disconnected;
  BleConnectionState get connectionState => _connectionState;

  // Connected device
  BluetoothDevice? _connectedDevice;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  String? get connectedDeviceName => _connectedDevice?.platformName;

  // Device info
  DeviceInfo? _deviceInfo;
  DeviceInfo? get deviceInfo => _deviceInfo;

  // Discovered devices during scan
  final List<DiscoveredDevice> _discoveredDevices = [];
  List<DiscoveredDevice> get discoveredDevices => List.unmodifiable(_discoveredDevices);

  // Sensor data stream
  final _sensorDataController = StreamController<SensorFrame>.broadcast();
  Stream<SensorFrame> get sensorDataStream => _sensorDataController.stream;

  // Latest sensor frame
  SensorFrame? _latestFrame;
  SensorFrame? get latestFrame => _latestFrame;

  // BLE characteristics
  BluetoothCharacteristic? _sensorDataChar;
  BluetoothCharacteristic? _deviceInfoChar;
  BluetoothCharacteristic? _hapticCmdChar;

  // Subscriptions
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _sensorSubscription;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Check if Bluetooth is available and on
  Future<bool> isBluetoothAvailable() async {
    try {
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) return false;
      
      final state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      debugPrint('BLE: Error checking Bluetooth: $e');
      return false;
    }
  }

  /// Start scanning for StepSign devices
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    if (_connectionState == BleConnectionState.scanning) {
      return;
    }

    _discoveredDevices.clear();
    _errorMessage = null;
    _setConnectionState(BleConnectionState.scanning);

    try {
      // Check Bluetooth state
      final isAvailable = await isBluetoothAvailable();
      if (!isAvailable) {
        _errorMessage = 'Bluetooth is not available or turned off';
        _setConnectionState(BleConnectionState.error);
        return;
      }

      // Stop any existing scan
      await FlutterBluePlus.stopScan();

      // Listen to scan results
      _scanSubscription?.cancel();
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          final name = result.device.platformName;
          
          // Filter for StepSign devices
          if (name.isNotEmpty && name.startsWith('StepSign')) {
            // Check if already discovered
            final existingIndex = _discoveredDevices.indexWhere(
              (d) => d.id == result.device.remoteId.str,
            );

            final discovered = DiscoveredDevice(
              device: result.device,
              name: name,
              rssi: result.rssi,
            );

            if (existingIndex >= 0) {
              _discoveredDevices[existingIndex] = discovered;
            } else {
              _discoveredDevices.add(discovered);
              debugPrint('BLE: Found device: $name (${result.device.remoteId})');
            }
            notifyListeners();
          }
        }
      });

      // Start scanning with service filter
      await FlutterBluePlus.startScan(
        timeout: timeout,
        withServices: [Guid(StepSignBleUuids.serviceUuid)],
      );

      // Wait for scan to complete
      await Future.delayed(timeout);
      
      if (_connectionState == BleConnectionState.scanning) {
        _setConnectionState(BleConnectionState.disconnected);
      }
    } catch (e) {
      debugPrint('BLE: Scan error: $e');
      _errorMessage = 'Scan failed: $e';
      _setConnectionState(BleConnectionState.error);
    }
  }

  /// Stop scanning
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    _scanSubscription = null;
    
    if (_connectionState == BleConnectionState.scanning) {
      _setConnectionState(BleConnectionState.disconnected);
    }
  }

  /// Connect to a discovered device
  Future<bool> connect(DiscoveredDevice device) async {
    if (_connectionState == BleConnectionState.connected ||
        _connectionState == BleConnectionState.connecting) {
      return false;
    }

    await stopScan();
    _errorMessage = null;
    _setConnectionState(BleConnectionState.connecting);

    try {
      debugPrint('BLE: Connecting to ${device.name}...');

      // Connect to device
      await device.device.connect(
        timeout: const Duration(seconds: 10),
        autoConnect: false,
      );

      _connectedDevice = device.device;

      // Listen for disconnection
      _connectionSubscription?.cancel();
      _connectionSubscription = device.device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          debugPrint('BLE: Device disconnected');
          _handleDisconnect();
        }
      });

      // Discover services
      debugPrint('BLE: Discovering services...');
      final services = await device.device.discoverServices();

      // Find our service
      BluetoothService? stepSignService;
      for (final service in services) {
        if (service.uuid.toString().toLowerCase() == 
            StepSignBleUuids.serviceUuid.toLowerCase()) {
          stepSignService = service;
          break;
        }
      }

      if (stepSignService == null) {
        throw Exception('StepSign service not found');
      }

      // Find characteristics
      for (final char in stepSignService.characteristics) {
        final uuid = char.uuid.toString().toLowerCase();
        if (uuid == StepSignBleUuids.sensorDataUuid.toLowerCase()) {
          _sensorDataChar = char;
        } else if (uuid == StepSignBleUuids.deviceInfoUuid.toLowerCase()) {
          _deviceInfoChar = char;
        } else if (uuid == StepSignBleUuids.hapticCmdUuid.toLowerCase()) {
          _hapticCmdChar = char;
        }
      }

      if (_sensorDataChar == null) {
        throw Exception('Sensor data characteristic not found');
      }

      // Read device info
      if (_deviceInfoChar != null) {
        try {
          final infoBytes = await _deviceInfoChar!.read();
          _deviceInfo = DeviceInfo.fromBytes(infoBytes);
          debugPrint('BLE: Device info: $_deviceInfo');
        } catch (e) {
          debugPrint('BLE: Could not read device info: $e');
        }
      }

      // Subscribe to sensor data notifications
      await _sensorDataChar!.setNotifyValue(true);
      _sensorSubscription?.cancel();
      _sensorSubscription = _sensorDataChar!.onValueReceived.listen((bytes) {
        try {
          final frame = SensorFrame.fromBytes(bytes);
          _latestFrame = frame;
          _sensorDataController.add(frame);
        } catch (e) {
          debugPrint('BLE: Error parsing sensor data: $e');
        }
      });

      _setConnectionState(BleConnectionState.connected);
      debugPrint('BLE: Connected and streaming!');
      return true;

    } catch (e) {
      debugPrint('BLE: Connection error: $e');
      _errorMessage = 'Connection failed: $e';
      await _cleanup();
      _setConnectionState(BleConnectionState.error);
      return false;
    }
  }

  /// Disconnect from the current device
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (e) {
        debugPrint('BLE: Disconnect error: $e');
      }
    }
    await _cleanup();
    _setConnectionState(BleConnectionState.disconnected);
  }

  /// Send haptic command to the device
  Future<bool> sendHaptic(HapticCommand command) async {
    if (_hapticCmdChar == null || _connectionState != BleConnectionState.connected) {
      return false;
    }

    try {
      await _hapticCmdChar!.write(command.toBytes(), withoutResponse: true);
      return true;
    } catch (e) {
      debugPrint('BLE: Haptic command failed: $e');
      return false;
    }
  }

  /// Quick tap haptic feedback
  Future<bool> tapHaptic() => sendHaptic(HapticCommand.tap());

  /// Strong haptic feedback
  Future<bool> strongHaptic() => sendHaptic(HapticCommand.strong());

  void _setConnectionState(BleConnectionState state) {
    if (_connectionState != state) {
      _connectionState = state;
      notifyListeners();
    }
  }

  void _handleDisconnect() {
    _cleanup();
    _setConnectionState(BleConnectionState.disconnected);
  }

  Future<void> _cleanup() async {
    _sensorSubscription?.cancel();
    _sensorSubscription = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _sensorDataChar = null;
    _deviceInfoChar = null;
    _hapticCmdChar = null;
    _connectedDevice = null;
    _deviceInfo = null;
    _latestFrame = null;
  }

  @override
  void dispose() {
    _sensorDataController.close();
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _sensorSubscription?.cancel();
    super.dispose();
  }
}

