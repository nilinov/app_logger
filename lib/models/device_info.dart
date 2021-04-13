part of app_logger;

class DeviceInfo {
  String uuid;
  String deviceName;
  String deviceVersion;
  String identifier;
  String product;
  String project;
  int session;
  String baseUrl;

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

  update({
    String uuid,
    String deviceName,
    String deviceVersion,
    String identifier,
    String product,
    String project,
    int session,
    String baseUrl,
  }) {
    this.baseUrl = uuid ?? this.baseUrl;
    this.baseUrl = deviceName ?? this.baseUrl;
    this.baseUrl = deviceVersion ?? this.baseUrl;
    this.baseUrl = identifier ?? this.baseUrl;
    this.baseUrl = product ?? this.baseUrl;
    this.baseUrl = project ?? this.baseUrl;
    this.baseUrl = session ?? this.baseUrl;
    this.baseUrl = baseUrl ?? this.baseUrl;
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
