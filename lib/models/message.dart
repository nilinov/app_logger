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

    if (payload is List || payload is int || payload is String || payload is double || payload is bool) {
      payloadJson = payload;
    } else {
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
