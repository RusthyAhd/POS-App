import 'dart:async';
import 'package:flutter/foundation.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

// Mock BluetoothDevice class for when the plugin is not available
class BluetoothDevice {
  final String name;
  final String address;
  final int? type;
  final bool? bondState;

  const BluetoothDevice({
    required this.name,
    required this.address,
    this.type,
    this.bondState,
  });

  @override
  String toString() => 'BluetoothDevice{name: $name, address: $address}';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BluetoothDevice &&
          runtimeType == other.runtimeType &&
          address == other.address;

  @override
  int get hashCode => address.hashCode;
}

// Mock BluetoothConnection class
class BluetoothConnection {
  bool get isConnected => false;
  Stream<Uint8List>? get input => null;
  late final StreamSink<List<int>> output;
  
  static Future<BluetoothConnection> toAddress(String address) async {
    throw Exception('Bluetooth not available in mock mode');
  }
  
  Future<void> close() async {
    // Mock implementation
  }
}

class BluetoothService {
  // static BluetoothConnection? _connection; // Unused in mock implementation
  static BluetoothDevice? _connectedDevice;
  static final StreamController<bool> _connectionStateController = StreamController<bool>.broadcast();
  
  // Getters
  static BluetoothDevice? get connectedDevice => _connectedDevice;
  static bool get isConnected => _connectedDevice != null;
  static Stream<bool> get connectionStateStream => _connectionStateController.stream;

  /// Check and request Bluetooth permissions
  static Future<bool> checkPermissions() async {
    if (kIsWeb) {
      return false; // Bluetooth not supported on web
    }

    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();

    bool allGranted = statuses.values.every((status) => status == PermissionStatus.granted);
    
    if (!allGranted) {
      debugPrint('Bluetooth permissions not granted');
      return false;
    }

    return true;
  }

  /// Check if Bluetooth is enabled
  static Future<bool> isBluetoothEnabled() async {
    if (kIsWeb) return false;
    
    // Mock implementation - return true for testing
    debugPrint('Mock Bluetooth: isEnabled = true');
    return true;
  }

  /// Enable Bluetooth
  static Future<bool> enableBluetooth() async {
    if (kIsWeb) return false;
    
    // Mock implementation
    debugPrint('Mock Bluetooth: enableBluetooth = true');
    return true;
  }

  /// Discover available Bluetooth devices
  static Future<List<BluetoothDevice>> discoverDevices() async {
    if (kIsWeb) return [];

    // Mock implementation - return sample devices for testing UI
    debugPrint('Mock Bluetooth: discoverDevices returning sample devices');
    await Future.delayed(const Duration(seconds: 2)); // Simulate discovery delay
    return [
      const BluetoothDevice(name: 'Mock Thermal Printer', address: '00:11:22:33:44:55'),
      const BluetoothDevice(name: 'Sample POS Printer', address: '55:44:33:22:11:00'),
    ];
  }

  /// Connect to a Bluetooth device
  static Future<bool> connectToDevice(BluetoothDevice device) async {
    if (kIsWeb) return false;

    try {
      // Disconnect if already connected
      await disconnect();

      debugPrint('Mock: Connecting to ${device.name} (${device.address})');
      
      // Mock connection - simulate successful connection
      await Future.delayed(const Duration(seconds: 1)); // Simulate connection delay
      _connectedDevice = device;
      
      _connectionStateController.add(true);
      debugPrint('Mock: Connected to ${device.name}');
      return true;
      
    } catch (e) {
      debugPrint('Mock: Error connecting to device: $e');
      // _connection = null; // Not used in mock
      _connectedDevice = null;
      _connectionStateController.add(false);
      return false;
    }
  }

  /// Disconnect from the current device
  static Future<void> disconnect() async {
    if (_connectedDevice != null) {
      debugPrint('Mock: Disconnected from ${_connectedDevice?.name}');
      
      // _connection = null; // Not used in mock
      _connectedDevice = null;
      _connectionStateController.add(false);
    }
  }

  /// Send raw data to the connected printer
  static Future<bool> sendData(List<int> data) async {
    if (!isConnected) {
      debugPrint('Mock: No device connected');
      return false;
    }

    try {
      debugPrint('Mock: Data sent successfully (${data.length} bytes)');
      return true;
    } catch (e) {
      debugPrint('Mock: Error sending data: $e');
      return false;
    }
  }

  /// Get bonded (paired) devices
  static Future<List<BluetoothDevice>> getBondedDevices() async {
    if (kIsWeb) return [];
    
    // Mock implementation - return sample paired devices
    debugPrint('Mock: getBondedDevices returning sample paired devices');
    return [
      const BluetoothDevice(name: 'Paired Thermal Printer', address: 'AA:BB:CC:DD:EE:FF'),
    ];
  }

  /// Dispose resources
  static void dispose() {
    disconnect();
    _connectionStateController.close();
  }
}