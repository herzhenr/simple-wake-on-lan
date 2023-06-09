// import 'package:test/test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
// import 'dart:convert';
// import 'package:uuid/uuid.dart';
// import 'package:simple_wake_on_lan/services/data.dart';
// import 'package:simple_wake_on_lan/services/database.dart';
//
// class MockFile extends Mock implements File {}
//
// class MockDirectory extends Mock implements Directory {}
//
// class MockDeviceStorage extends Mock implements DeviceStorage {}
//
// void main() {
//   group('DeviceStorage', () {
//     final mockFile = MockFile();
//     final mockDirectory = MockDirectory();
//     final mockDeviceStorage = MockDeviceStorage();
//
//     setUp(() {
//       when(mockDirectory.path).thenReturn('/path/to/documents');
//       when(mockFile.path).thenReturn('/path/to/documents/devices.json');
//       when(getApplicationDocumentsDirectory())
//           .thenAnswer((_) => Future.value(mockDirectory));
//     });
//
//     test('getFilePath returns the correct file path', () async {
//       final deviceStorage = DeviceStorage();
//       final filePath = await deviceStorage.getFilePath();
//       expect(filePath, '/path/to/documents/devices.json');
//     });
//
//     test('loadDevices returns an empty list when the file does not exist',
//         () async {
//       when(mockFile.readAsString()).thenThrow(FileSystemException());
//       final deviceStorage = DeviceStorage();
//       final devices = await deviceStorage.loadDevices();
//       expect(devices, isEmpty);
//     });
//
//     test('loadDevices returns an empty list when the file is empty', () async {
//       when(mockFile.readAsString()).thenAnswer((_) => Future.value(''));
//       final deviceStorage = DeviceStorage();
//       final devices = await deviceStorage.loadDevices();
//       expect(devices, isEmpty);
//     });
//
//     test('loadDevices returns a list of devices when the file is valid',
//         () async {
//       final jsonData = [
//         {'id': '1', 'name': 'Device 1', 'modified': '2022-01-01T00:00:00.000Z', 'type': 'network'}
//       ];
//       final jsonString = json.encode(jsonData);
//       when(mockFile.readAsString()).thenAnswer((_) => Future.value(jsonString));
//       final deviceStorage = DeviceStorage();
//       final devices = await deviceStorage.loadDevices();
//       expect(devices, hasLength(1));
//       expect(devices.first.id, '1');
//       expect(devices.first.hostName, 'Device 1');
//       expect(devices.first.modified, DateTime.utc(2022, 1, 1));
//       expect(devices.first.deviceType, 'network');
//     });
//
//     test('saveDevices writes the correct data to the file', () async {
//       final device = NetworkDevice(hostName: 'Device 1', ipAddress: '192.168.1.1', macAddress: '00:11:22:33:44:55');
//       final storageDevice = StorageDevice(
//           id: '1', hostName: 'Device 1', modified: DateTime.now(), deviceType: 'network', ipAddress: '192.168.1.1', macAddress: '00:11:22:33:44:55');
//       final devices = [storageDevice];
//       final jsonData = [
//         {'id': '1', 'name': 'Device 1', 'modified': storageDevice.modified.toIso8601String(), 'type': 'network', 'ipAddress': '192.168.1.1', 'macAddress': '00:11:22:33:44:55'}
//       ];
//       final jsonString = json.encode(jsonData);
//       when(mockFile.writeAsString(any)).thenAnswer((_) => Future.value());
//       final deviceStorage = DeviceStorage();
//       await deviceStorage.saveDevices(devices);
//       verify(mockFile.writeAsString(jsonString)).called(1);
//     });
//
//     test('addDevice adds a device to the list of devices', () async {
//       final device = NetworkDevice(id: '1', name: 'Device 1', ipAddress: '192.168.1.1', macAddress: '00:11:22:33:44:55');
//       final storageDevice = StorageDevice(
//           id: '1', name: 'Device 1', modified: DateTime.now(), type: 'network', ipAddress: '192.168.1.1', macAddress: '00:11:22:33:44:55');
//       final devices = [storageDevice];
//       when(mockDeviceStorage.loadDevices()).thenAnswer((_) => Future.value(devices));
//       when(mockDeviceStorage.saveDevices(any)).thenAnswer((_) => Future.value());
//       when(Uuid().v1()).thenReturn('2');
//       final updatedDevices = await mockDeviceStorage.addDevice(device);
//       expect(updatedDevices, hasLength(2));
//       expect(updatedDevices.last.id, '2');
//       expect(updatedDevices.last.name, 'Device 1');
//       expect(updatedDevices.last.type, 'network');
//       expect(updatedDevices.last.ipAddress, '192.168.1.1');
//       expect(updatedDevices.last.macAddress, '00:11:22:33:44:55');
//     });
//
//     test('updateDevice updates a device in the list of devices', () async {
//       final device = StorageDevice(
//           id: '1', name: 'Device 1', modified: DateTime.now(), type: 'network', ipAddress: '192.168.1.1', macAddress: '00:11:22:33:44:55');
//       final devices = [device];
//       final updatedDevice = device.copyWith(name: 'Updated Device');
//       when(mockDeviceStorage.loadDevices()).thenAnswer((_) => Future.value(devices));
//       when(mockDeviceStorage.saveDevices(any)).thenAnswer((_) => Future.value());
//       final updatedDevices = await mockDeviceStorage.updateDevice(updatedDevice);
//       expect(updatedDevices, hasLength(1));
//       expect(updatedDevices.first.id, '1');
//       expect(updatedDevices.first.name, 'Updated Device');
//       expect(updatedDevices.first.type, 'network');
//       expect(updatedDevices.first.ipAddress, '192.168.1.1');
//       expect(updatedDevices.first.macAddress, '00:11:22:33:44:55');
//     });
//
//     test('deleteDevice deletes a device from the list of devices', () async {
//       final device = StorageDevice(
//           id: '1', name: 'Device 1', modified: DateTime.now(), type: 'network', ipAddress: '192.168.1.1', macAddress: '00:11:22:33:44:55');
//       final devices = [device];
//       when(mockDeviceStorage.loadDevices()).thenAnswer((_) => Future.value(devices));
//       when(mockDeviceStorage.saveDevices(any)).thenAnswer((_) => Future.value());
//       final updatedDevices = await mockDeviceStorage.deleteDevice('1');
//       expect(updatedDevices, isEmpty);
//     });
//
//     test('deleteAllDevices deletes the devices file', () async {
//       when(mockFile.delete()).thenAnswer((_) => Future.value());
//       final deviceStorage = DeviceStorage();
//       await deviceStorage.deleteAllDevices();
//       verify(mockFile.delete()).called(1);
//     });
//   });
// }
