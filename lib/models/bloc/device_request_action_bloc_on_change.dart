part of app_logger;

class DeviceRequestActionBlocOnChange {
  final String action;
  final BlocStateDiff payload;
  final DeviceInfo deviceInfo;
  final String project;
  final String install;
  final int sessionId;

  DeviceRequestActionBlocOnChange({
    this.action = 'onChange',
    @required this.payload,
    @required this.deviceInfo,
    @required this.project,
    @required this.sessionId,
    @required this.install,
  });

  Map<String, dynamic> toJson() => {
    "action": action,
    "payload": payload,
    "deviceInfo": deviceInfo,
    "project": project,
    "sessionId": sessionId,
    "install": install,
  };
}
