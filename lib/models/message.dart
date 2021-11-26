part of app_logger;

class Message<Payload> {
  final String action;
  final Payload payload;

  Message(
    this.action,
    this.payload,
  );

  Map<String, dynamic> toJson() {
    var payloadJson;

    try {
      payloadJson = (payload as dynamic).toJson();
    } catch (err) {
      try {
        payloadJson = (payload as dynamic).toMap();
      } catch (err) {
        debugPrint(err.toString());
        payloadJson = payload.toString();
      }
    }

    return {
      "action": action,
      "payload": payloadJson,
      "deviceInfo": AppLogger().deviceInfo,
      "project": AppLogger().project,
      "sessionId": AppLogger().sessionId,
      "install": AppLogger().install,
    };
  }
}
