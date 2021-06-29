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

  update({
    String? uuid,
    String? deviceName,
    String? deviceVersion,
    String? identifier,
    String? product,
    String? project,
    int? session,
    String? baseUrl,
  }) {
    this.uuid = uuid ?? this.baseUrl;
    this.deviceName = deviceName ?? this.baseUrl;
    this.deviceVersion = deviceVersion ?? this.baseUrl;
    this.identifier = identifier ?? this.baseUrl;
    this.product = product ?? this.baseUrl;
    this.project = project ?? this.baseUrl;
    this.session = session ?? this.baseUrl as int?;
    this.baseUrl = baseUrl ?? this.baseUrl;
    this.install = install ?? this.install;
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
