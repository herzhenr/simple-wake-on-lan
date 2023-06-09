import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../services/database.dart';

Future<void> shareJsonFile() async {
  final deviceStorage = DeviceStorage();
  final filePath = await deviceStorage.getFilePath();

  final file = File(filePath);
  if (!await file.exists()) {
    await file.create();
  }

  // Share the file using the Share plugin
  await Share.shareXFiles([XFile(filePath)], subject: 'devices.json');
}

Future<File?> getJsonFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result == null || result.files.single.path == null) return null;

  File file = File(result.files.single.path!);

  //if (file.path.split('.').last != 'json') return null;

  return file;
}
