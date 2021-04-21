part of app_logger;

class DeviceRequestActionBlocOnCreated {
  final String action;
  final List<BlocRecord> payload;
  final DeviceInfo deviceInfo;
  final String project;
  final String install;
  final int sessionId;

  DeviceRequestActionBlocOnCreated({
    this.action = 'onCreate',
    @required this.payload,
    @required this.deviceInfo,
    @required this.project,
    @required this.sessionId,
    @required this.install,
  });

  Map<String, dynamic> toMap() {
    try {
      return {
        "action": action,
        "payload": payload,
        "deviceInfo": deviceInfo,
        "project": project,
        "sessionId": sessionId,
        "install": install,
      };
    } catch (err) {
      return {
        "action": null,
        "payload": null,
        "deviceInfo": deviceInfo,
        "project": project,
        "sessionId": sessionId,
        "install": install,
      };
    }
  }
}
