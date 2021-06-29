part of app_logger;

class BlocRecord {
  final int number;
  final String name;
  var state;
  final DeviceInfo? deviceInfo;
  final String? project;
  final int sessionId;

  BlocRecord({
    required this.number,
    required this.name,
    required this.state,
    required this.deviceInfo,
    required this.project,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() {
    try {
      return {
        "number": number,
        "name": name,
        "state": state,
        "deviceInfo": deviceInfo,
        "project": project,
        "sessionId": sessionId,
      };
    } catch(err) {
      return {
        "number": number,
        "name": name,
        "deviceInfo": deviceInfo,
        "project": project,
        "sessionId": sessionId,
        "state": {},
      };
    }
  }

  String toString() =>
      "BlocRecord[number=$number,name=$name,state=$state, deviceInfo: $deviceInfo, project: $project, sessionId: $sessionId]";
}
