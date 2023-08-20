import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'data.dart';

class DeviceStorage {
  static const _fileName = 'devices.json';

  Future<String> getFilePath() async {
    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    return '${appDocumentsDirectory.path}/$_fileName';
  }

  Future<List<StorageDevice>> loadDevices() async {
    try {
      final filePath = await getFilePath();
      final file = File(filePath);
      final fileContents = await file.readAsString();
      final jsonData = json.decode(fileContents) as List<dynamic>;
      return jsonData.map((item) => StorageDevice.fromJson(item)).toList();
    } on FileSystemException {
      return [];
    } on FormatException {
      // TODO: show error in ui
      return [];
    }
  }

  /// Saves a list of devices to the file [_fileName] in the app documents directory
  /// [devices] the list of devices to save
  Future<void> saveDevices(List<StorageDevice> devices) async {
    final filePath = await getFilePath();
    final jsonData = devices.map((item) => item.toJson()).toList();
    final jsonString = json.encode(jsonData);
    final file = File(filePath);
    await file.writeAsString(jsonString);
  }

  /// Adds a new device to the list of devices
  /// [device] the device to add
  Future<(List<StorageDevice>, StorageDevice)> addDevice(
      NetworkDevice device, List<StorageDevice> devices) async {
    final storageDevice =
        device.toStorageDevice(id: const Uuid().v1(), modified: DateTime.now());
    final updatedDevices = [...devices, storageDevice];
    await saveDevices(updatedDevices);
    return (updatedDevices, storageDevice);
  }

  /// Updates a device in the list of devices
  /// [updatedDevice] the device to update
  /// [devices] the list of all devices
  Future<(List<StorageDevice>, StorageDevice)> updateDevice(
      StorageDevice updatedDevice, List<StorageDevice> devices) async {
    final updatedDevices = devices.map((device) {
      if (device.id == updatedDevice.id) {
        return updatedDevice.copyWith(modified: DateTime.now());
      }
      return device;
    }).toList();
    await saveDevices(updatedDevices);
    return (updatedDevices, updatedDevice);
  }

  /// Deletes a device from the list of devices
  /// [deviceId] the id of the device to delete
  Future<List<StorageDevice>> deleteDevice(
      String deviceId, List<StorageDevice> devices) async {
    final updatedDevices =
        devices.where((device) => device.id != deviceId).toList();
    await saveDevices(updatedDevices);
    return updatedDevices;
  }

  /// Deletes the devices file
  Future<void> deleteAllDevices() async {
    try {
      final filePath = await getFilePath();
      final file = File(filePath);
      await file.delete();
    } on FileSystemException {
      // ignore
    }
  }
}
