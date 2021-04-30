part of app_logger;

class Message<Payload> {
  final String action;
  final Payload payload;

  Message(
    this.action,
    this.payload,
  );

  Map<String, dynamic> toJson() => {
    "action": action,
    "payload": payload,
    "deviceInfo": AppLogger().deviceInfo,
    "project": AppLogger().project,
    "sessionId": AppLogger().sessionId,
    "install": AppLogger().install,
  };
}