part of app_logger;

class DeviceInfo {
  final String uuid;
  final String deviceName;
  final String deviceVersion;
  final String identifier;
  final String product;
  final String project;
  final int session;
  final String baseUrl;

  DeviceInfo(
    this.uuid,
    this.deviceName,
    this.deviceVersion,
    this.identifier,
    this.product,
    this.project,
    this.session,
    this.baseUrl,
  );

  @override
  String toString() {
    return json.encode(toJson());
  }

  toJson() {
    return {
      'uuid': uuid,
      'device_name': deviceName,
      'device_version': deviceVersion,
      'identifier': identifier,
      'product': product,
      'project': project,
      'session': session,
      'baseUrl': baseUrl,
    };
  }
}
