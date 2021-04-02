part of app_logger;

class LoggerHttp {
  static final LoggerHttp _singleton = LoggerHttp._internal();

  factory LoggerHttp() => _singleton;

  LoggerHttp._internal();

  var countRequest = 0;
  List extra = [];

  onRequest(Http.Request options) async {
    final createdAt = DateTime.now().toIso8601String();

    final curl = cURLRepresentationHttp(options);

    extra.add({
      'hash': options.hashCode,
      'number': countRequest.toString(),
      'createdAt': createdAt,
      'curl': curl,
      'params': options.body,
    });

    try {
      Map jsonData = {
        'action': 'device_request',
        'payload': {
          'device_identifier': AppLogger().deviceInfo.identifier,
          'session_id': AppLogger().sessionId,
          'project': AppLogger().project,
          'number': countRequest,
          'url': options.url.toString(),
          'code': null,
          "status": "pending",
          "method": options.method,
          'headers': options.headers,
          'headers_response': {},
          'params': options.body,
          'response': null,
          'action': 'getElementById',
          'created_at': createdAt,
          'response_at': null,
          'size': null,
          'payload': null,
          'curl': curl,
        }
      };

      final payload = jsonEncode(jsonData);
      if (AppLogger().project == null) {
        AppLogger().messages.add(payload);
      } else {
        AppLogger().channel.sink.add(payload);
      }
    } catch (e) {
      print(e);
    }

    this.countRequest++;
  }

  onResponse(Http.Response response) {
    try {
      final responseAt = DateTime.now().toIso8601String();

      final _extra = extra.firstWhere(
          (element) => element['hash'] == response.request.hashCode,
          orElse: () => null);

      Map jsonData = {
        'action': 'device_request',
        'payload': {
          'device_identifier': AppLogger().deviceInfo.identifier,
          'session_id': AppLogger().sessionId,
          'project': AppLogger().project,
          'number': _extra['number'],
          'url': response.request.url.toString(),
          'code': response.statusCode,
          'method': response.request.method,
          "status": 'done',
          "status_code": response.statusCode,
          'headers': response.request.headers,
          'headers_response': response.headers.map,
          'params': _extra['params'],
          'payload': response.body,
          'action': 'getElementById',
          'created_at': _extra['createdAt'],
          'response_at': responseAt,
          'curl': _extra['curl'],
          'size': response.body.toString().length,
        }
      };

      final payload = jsonEncode(jsonData);
      if (AppLogger().project == null) {
        AppLogger().messages.add(payload);
      } else {
        AppLogger().channel.sink.add(payload);
      }
    } catch (e) {
      print(e);
    }
  }
}
