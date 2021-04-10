part of app_logger;

class DeviceRequestActionBlocOnChange {
  final String action;
  final BlocStateDiff payload;
  final DeviceInfo deviceInfo;
  final String project;
  final int sessionId;

  DeviceRequestActionBlocOnChange({
    this.action = 'onChange',
    @required this.payload,
    @required this.deviceInfo,
    @required this.project,
    @required this.sessionId,
  });

  Map<String, dynamic> toJson() => {
    "action": action,
    "payload": payload,
    "deviceInfo": deviceInfo,
    "project": project,
    "sessionId": sessionId,
  };
}
