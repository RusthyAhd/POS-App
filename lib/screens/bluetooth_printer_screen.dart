import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../services/bluetooth_service.dart';
import '../services/thermal_printer_service.dart';

class BluetoothPrinterScreen extends StatefulWidget {
  const BluetoothPrinterScreen({super.key});

  @override
  State<BluetoothPrinterScreen> createState() => _BluetoothPrinterScreenState();
}

class _BluetoothPrinterScreenState extends State<BluetoothPrinterScreen> {
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  bool _isConnected = false;
  BluetoothDevice? _connectedDevice;
  Timer? _connectionCheckTimer;

  @override
  void initState() {
    super.initState();
    _connectedDevice = BluetoothService.connectedDevice;
    _isConnected = BluetoothService.isConnected;
    _loadBondedDevices();
    _startConnectionStatusCheck();
    
    // Listen for connection changes
    BluetoothService.connectionStateStream.listen((connected) {
      if (mounted) {
        setState(() {
          _isConnected = connected;
          _connectedDevice = BluetoothService.connectedDevice;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectionCheckTimer?.cancel();
    super.dispose();
  }

  void _startConnectionStatusCheck() {
    _connectionCheckTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkConnectionStatus(),
    );
  }

  void _checkConnectionStatus() async {
    if (!mounted) return;
    
    final isConnected = BluetoothService.isConnected;
    if (isConnected != _isConnected) {
      setState(() {
        _isConnected = isConnected;
        if (!isConnected) {
          _connectedDevice = null;
        }
      });
    }
  }

  Future<void> _loadBondedDevices() async {
    try {
      final devices = await BluetoothService.getBondedDevices();
      setState(() {
        _devices = devices;
      });
    } catch (e) {
      _showErrorSnackBar('Error loading devices: $e');
    }
  }

  Future<void> _scanForDevices() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // Check and request permissions first
      bool hasPermissions = await BluetoothService.checkPermissions();
      if (!hasPermissions) {
        throw Exception('Bluetooth permissions required');
      }

      // Check if Bluetooth is enabled
      bool isEnabled = await BluetoothService.isBluetoothEnabled();
      if (!isEnabled) {
        throw Exception('Bluetooth is not enabled');
      }

      // Load bonded devices first
      await _loadBondedDevices();
      
      // Then discover new devices
      final devices = await BluetoothService.discoverDevices();
      setState(() {
        _devices = devices;
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      _showErrorSnackBar('Error scanning: $e');
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Connecting...'),
          ],
        ),
      ),
    );

    try {
      bool success = false;
      
      // Try connecting up to 3 times
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          success = await BluetoothService.connectToDevice(device);
          if (success) break;
          
          if (attempt < 3) {
            // Wait before retry
            await Future.delayed(const Duration(seconds: 2));
          }
        } catch (e) {
          debugPrint('Connection attempt $attempt failed: $e');
          if (attempt == 3) rethrow;
        }
      }
      
      if (mounted) {
        Navigator.pop(context);
        
        if (success) {
          setState(() {
            _isConnected = true;
            _connectedDevice = device;
          });
          _showSuccessSnackBar('Connected to ${device.name}');
        } else {
          _showErrorSnackBar('Failed to connect to ${device.name} after 3 attempts');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorSnackBar('Connection error: $e');
      }
    }
  }

  Future<void> _disconnect() async {
    await BluetoothService.disconnect();
    setState(() {
      _isConnected = false;
      _connectedDevice = null;
    });
    _showSuccessSnackBar('Disconnected from printer');
  }

  Future<void> _printTestPage() async {
    if (!_isConnected) {
      _showErrorSnackBar('No printer connected');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Printing test page...'),
          ],
        ),
      ),
    );

    try {
      final success = await ThermalPrinterService.printTestPage();
      
      if (mounted) {
        Navigator.pop(context);
        
        if (success) {
          _showSuccessSnackBar('Test page printed successfully');
        } else {
          _showErrorSnackBar('Failed to print test page');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorSnackBar('Print error: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Printer'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _scanForDevices,
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection Status Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isConnected ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isConnected ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isConnected ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                if (_connectedDevice != null) ...[
                  const SizedBox(height: 8),
                  Text('Device: ${_connectedDevice!.name}'),
                  Text('Address: ${_connectedDevice!.address}'),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (_isConnected) ...[
                      ElevatedButton.icon(
                        onPressed: _disconnect,
                        icon: const Icon(Icons.bluetooth_disabled),
                        label: const Text('Disconnect'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _printTestPage,
                        icon: const Icon(Icons.print),
                        label: const Text('Test Print'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Scan Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _scanForDevices,
                icon: _isScanning 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: Text(_isScanning ? 'Scanning...' : 'Scan for Printers'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Devices List
          Expanded(
            child: _devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bluetooth_searching,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No printers found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap "Scan for Printers" to discover devices',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      final isCurrentDevice = _connectedDevice?.address == device.address;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            isCurrentDevice
                                ? Icons.bluetooth_connected
                                : Icons.bluetooth,
                            color: isCurrentDevice ? Colors.green : Colors.blue,
                          ),
                          title: Text(
                            device.name ?? 'Unknown Device',
                            style: TextStyle(
                              fontWeight: isCurrentDevice ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(device.address),
                          trailing: isCurrentDevice
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : ElevatedButton(
                                  onPressed: () => _connectToDevice(device),
                                  child: const Text('Connect'),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}