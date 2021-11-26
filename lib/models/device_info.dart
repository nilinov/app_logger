part of app_logger;

class DeviceInfo {
  String? uuid;
  String? deviceName;
  String? deviceVersion;
  String? identifier;
  String? product;
  String? project;
  int? session;
  String? baseUrl;
  String install;

  DeviceInfo(
    this.uuid,
    this.deviceName,
    this.deviceVersion,
    this.identifier,
    this.product,
    this.project,
    this.session,
    this.baseUrl,
    this.install,
  );

  @override
  String toString() {
    return json.encode(toJson());
  }

  copyWith({
    String? uuid,
    String? deviceName,
    String? deviceVersion,
    String? identifier,
    String? product,
    String? project,
    int? session,
    String? baseUrl,
    String? install,
  }) {
    return DeviceInfo(
      uuid ?? this.uuid,
      deviceName ?? this.deviceName,
      deviceVersion ?? this.deviceVersion,
      identifier ?? this.identifier,
      product ?? this.product,
      project ?? this.project,
      session ?? this.session,
      baseUrl ?? this.baseUrl,
      install ?? this.install,
    );
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
      'install': install,
    };
  }
}
