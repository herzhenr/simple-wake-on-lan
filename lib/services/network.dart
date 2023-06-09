import 'dart:async';

import 'package:dart_ping/dart_ping.dart';
import 'dart:io';
import 'package:wake_on_lan/wake_on_lan.dart';
import 'data.dart';

Stream<NetworkDevice> findDevicesInNetwork(
  String networkPrefix,
  void Function(double) progressCallback,
) {
  final controller = StreamController<NetworkDevice>();
  var progress = 0;
  const step = 25;

  /* Recursive function which pings a single device and schedules the next ping
    step ips away from the current as long as this ip is still within the subnet */
  void pingDevice(int index) async {
    final address = '$networkPrefix.$index';
    final ping = Ping(address, count: 1, timeout: 1);

    // Wait for the current ping to complete
    await for (final response in ping.stream) {
      if (response.response != null && response.error == null) {
        // try to get the hostname of the device
        String host = "";
        try {
          await InternetAddress(address)
              .reverse()
              .then((value) => host = value.host);
        } on SocketException {
          host = "";
        }
        controller.add(NetworkDevice(ipAddress: address, hostName: host));
        break;
      }
    }

    // If the end of the subnet is reached, close the stream
    if (index == 254) {
      controller.close();
    }

    // Increase the progress variable and report the result to the UI
    final progressPercent = ++progress / 255;
    progressCallback(progressPercent);

    // Schedule the next ping
    if (index + step < 255) {
      pingDevice(index + step);
    }
  }

  // Start the initial pings.
  for (int i = 1; i <= step; i++) {
    pingDevice(i);
  }

  return controller.stream;
}

/// sends the magic packet to the [device] that should receive a magic wol package in order to get woken up
Stream<Message> sendWolPackage({required NetworkDevice device}) async* {
  // Validate correct formatting of ip and mac addresses
  final ip = device.ipAddress;
  final mac = device.macAddress;
  final int? port = device.wolPort;
  bool invalid = false;

  if (!IPv4Address.validate(ip)) {
    yield Message(text: "'$ip' is a invalid IPv4 address", type: MsgType.error);
    invalid = true;
  }

  if (!MACAddress.validate(mac)) {
    yield Message(text: "'$mac' is a invalid MAC address", type: MsgType.error);
    invalid = true;
  }

  //validate port
  if (port == null || port < 0 || port > 65535) {
    yield Message(text: "'$port' is an invalid port", type: MsgType.error);
    invalid = true;
  }

  if (invalid) {
    // yield Message(text: "There was a error when trying to send a WOL Package to this host", type: MsgType.error);
    return;
  }

  // if no error occurred: try to send wol package
  yield Message(text: "Provided ip and mac address are both valid");
  yield Message(text: "Trying to send a WOL Package");
  IPv4Address ipv4Address = IPv4Address(ip);
  MACAddress macAddress = MACAddress(mac);
  try {
    WakeOnLAN wol = WakeOnLAN(ipv4Address, macAddress, port: port!);
    await wol.wake();
    yield Message(
        text: "Successfully send WOL package to $ip", type: MsgType.check);
  } catch (e) {
    yield Message(
        text:
            "There was a error when trying to send a WOL Package to this host",
        type: MsgType.error);
  }

  // ping device until it is online
  yield Message(text: "Trying to ping device until it is online...");
  bool online = false;
  int tries = 0;
  while (!online && tries < 10) {
    tries++;
    yield Message(text: "Sending ping $tries/10", type: MsgType.ping);

    final ping = Ping(ip, count: 1, timeout: 5);

    // Wait for the current ping to complete
    await for (final response in ping.stream) {
      if (response.response != null && response.error == null) {
        online = true;
      }
    }
  }
  if (online) {
    yield Message(text: "Device is online", type: MsgType.online);
  } else {
    yield Message(text: "Device is not online", type: MsgType.error);
  }
}

/// returns a list of Messages by using the sendWolPackage function
/// accumulates the messages in a list and yields the list after each message
Stream<List<Message>> sendWolAndGetMessages(
    {required NetworkDevice device}) async* {
  List<Message> messages = [];
  await for (Message message in sendWolPackage(device: device)) {
    // if last message is ping, replace it with the new one
    if (messages.isNotEmpty &&
        messages.last.type == MsgType.ping &&
        message.type == MsgType.ping) {
      messages.removeLast();
    }
    messages.add(message);
    yield messages;
  }
}

/// Playground: Test different Discover methods

// void findDevicesMDNS() async {
//   const String name = '_dartobservatory._tcp.local';
//   final MDnsClient client = MDnsClient();
//   // Start the client with default options.
//   await client.start();
//
//   // Get the PTR record for the service.
//   await for (final PtrResourceRecord ptr in client
//       .lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name))) {
//     // Use the domainName from the PTR record to get the SRV record,
//     // which will have the port and local hostname.
//     // Note that duplicate messages may come through, especially if any
//     // other mDNS queries are running elsewhere on the machine.
//     await for (final SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
//         ResourceRecordQuery.service(ptr.domainName))) {
//       // Domain name will be something like "io.flutter.example@some-iphone.local._dartobservatory._tcp.local"
//       final String bundleId =
//           ptr.domainName; //.substring(0, ptr.domainName.indexOf('@'));
//       // print('Dart observatory instance found at '
//       //     '${srv.target}:${srv.port} for "$bundleId".');
//     }
//   }
//   client.stop();
//
//   // print('Done.');
// }
