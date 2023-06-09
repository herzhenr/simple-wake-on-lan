int ipToNumeric(String ipAddress) {
  final parts = ipAddress.split('.');
  final octets = parts.map(int.parse).toList();
  final numeric =
      (octets[0] << 24) + (octets[1] << 16) + (octets[2] << 8) + octets[3];
  return numeric;
}
