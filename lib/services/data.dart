import 'package:simple_wake_on_lan/services/utilities.dart';

abstract class Device implements Comparable<NetworkDevice> {
  final String hostName;
  final String ipAddress;
  final String macAddress;
  final int? wolPort;
  final String? deviceType;

  Device(
      {required this.hostName,
      required this.ipAddress,
      required this.macAddress,
      this.wolPort,
      this.deviceType});

  Device copyWith({
    String? id,
    String? hostName,
    String? ipAddress,
    String? macAddress,
    int? wolPort,
    DateTime? modified,
    String? deviceType,
  });

  Map<String, dynamic> toJson();
}

class StorageDevice extends Device {
  final String id;
  final DateTime modified;
  bool? isOnline;

  StorageDevice(
      {required this.id,
      required hostName,
      required ipAddress,
      required macAddress,
      wolPort,
      this.isOnline,
      required this.modified,
      deviceType})
      : super(
            hostName: hostName,
            ipAddress: ipAddress,
            macAddress: macAddress,
            wolPort: wolPort,
            deviceType: deviceType);

  @override
  int compareTo(NetworkDevice other) {
    return ipToNumeric(ipAddress).compareTo(ipToNumeric(other.ipAddress));
  }

  @override
  StorageDevice copyWith({
    String? id,
    String? hostName,
    String? ipAddress,
    String? macAddress,
    int? wolPort,
    DateTime? modified,
    String? deviceType,
    bool? isOnline,
  }) {
    return StorageDevice(
      id: id ?? this.id,
      hostName: hostName ?? this.hostName,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      wolPort: wolPort ?? this.wolPort,
      modified: modified ?? this.modified,
      deviceType: deviceType ?? this.deviceType,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      "hostName": hostName,
      "ipAddress": ipAddress,
      "macAddress": macAddress,
      "wolPort": wolPort,
      "deviceType": deviceType,
      "modified": modified.toIso8601String(),
    };
  }

  factory StorageDevice.fromJson(Map<String, dynamic> json) {
    return StorageDevice(
      id: json['id'],
      hostName: json['hostName'],
      ipAddress: json['ipAddress'],
      macAddress: json['macAddress'],
      wolPort: json['wolPort'],
      modified: DateTime.parse(json['modified']),
      deviceType: json['deviceType'],
    );
  }

  NetworkDevice toNetworkDevice() {
    return NetworkDevice(
      hostName: hostName,
      ipAddress: ipAddress,
      macAddress: macAddress,
      wolPort: wolPort,
      deviceType: deviceType,
    );
  }
}

class NetworkDevice extends Device {
  NetworkDevice(
      {hostName = '', ipAddress = '', macAddress = '', wolPort, deviceType})
      : super(
            hostName: hostName,
            ipAddress: ipAddress,
            macAddress: macAddress,
            wolPort: wolPort,
            deviceType: deviceType);

  @override
  int compareTo(NetworkDevice other) {
    return ipToNumeric(ipAddress).compareTo(ipToNumeric(other.ipAddress));
  }

  // TODO: not all parameters are necessary
  @override
  Device copyWith({
    String? id,
    String? hostName,
    String? ipAddress,
    String? macAddress,
    int? wolPort,
    DateTime? modified,
    String? deviceType,
  }) {
    return NetworkDevice(
      hostName: hostName ?? this.hostName,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      wolPort: wolPort ?? this.wolPort,
      deviceType: deviceType ?? this.deviceType,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'ipAddress': ipAddress,
      'macAddress': macAddress,
      'hostName': hostName,
      "wolPort": wolPort,
      "deviceType": deviceType,
    };
  }

  static NetworkDevice fromJson(Map<String, dynamic> json) {
    return NetworkDevice(
      ipAddress: json['hostName'],
      macAddress: json['macAddress'],
      hostName: json['name'],
      wolPort: json['wolPort'],
      deviceType: json['deviceType'],
    );
  }

  StorageDevice toStorageDevice({
    required String id,
    String? name,
    String? ipAddress,
    String? macAddress,
    int? wolPort,
    required DateTime modified,
    String? deviceType,
  }) {
    return StorageDevice(
      id: id,
      hostName: name ?? hostName,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      wolPort: wolPort ?? this.wolPort,
      modified: modified,
      deviceType: deviceType ?? this.deviceType,
    );
  }
}

enum MsgType { error, check, ping, online, other }

class Message {
  String text;
  MsgType type;

  Message({required this.text, this.type = MsgType.other});
}
