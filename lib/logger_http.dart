part of app_logger;

class LoggerHttp {
  static final LoggerHttp _singleton = LoggerHttp._internal();

  factory LoggerHttp() => _singleton;

  LoggerHttp._internal();

  var countRequest = 0;
  List requests = [];

  onRequest(url, String method,
      {Map<String, String>? headers, Map<String, dynamic>? params, Future<Http.Response>? request}) async {
    final createdAt = DateTime.now().toIso8601String();

    requests.add({
      'request': request,
      'number': this.countRequest,
      'createdAt': createdAt,
      'params': params,
      'method': null,
      'headers': headers,
      'data': params,
      'curl': null,
    });

    try {
      final payload = {
        'device_identifier': AppLogger().deviceInfo?.identifier,
        'session_id': AppLogger().sessionId,
        'project': AppLogger().project,
        'number': countRequest,
        'url': url,
        'code': null,
        "status": "pending",
        "method": method,
        'headers': headers,
        'headers_response': {},
        'params': null,
        'response': null,
        'action': 'getElementById',
        'created_at': createdAt,
        'response_at': null,
        'size': null,
        'payload': null,
        'curl': null,
      };
      AppLogger().messages.add(Message('device_request', payload));
    } catch (e) {
      print(e);
    }

    this.countRequest++;

    return this.countRequest;
  }

  onResponse(Http.Response response, int number) {
    // if (response.body
    //     .toString()
    //     .length > 10000) {
    //   print('Слишком большой запрос. Данные не будут показаны в логгере');
    //   return;
    // }

    try {
      final responseAt = DateTime.now().toIso8601String();

      final _extra = requests[number - 1];

      final payload = {
        'device_identifier': AppLogger().deviceInfo?.identifier,
        'session_id': AppLogger().sessionId,
        'project': AppLogger().project,
        'number': _extra['number'],
        'url': response.request!.url.toString(),
        'code': response.statusCode,
        'method': response.request!.method,
        "status": 'done',
        "status_code": response.statusCode,
        'headers': response.request!.headers,
        'headers_response': response.headers,
        'params': _extra['params'],
        'payload': response.body,
        'action': 'getElementById',
        'created_at': _extra['createdAt'],
        'response_at': responseAt,
        'curl': _extra['curl'],
        'size': response.body.toString().length,
      };
      AppLogger().messages.add(Message('device_request', payload));
    } catch (e) {
      print(e);
    }
  }

  onError(Http.Response response, int number) {
    try {
      final responseAt = DateTime.now().toIso8601String();
      final _extra = requests[number - 1];

      final payload = {
        'device_identifier': AppLogger().deviceInfo?.identifier,
        'session_id': AppLogger().sessionId,
        'project': AppLogger().project,
        'number': number,
        'url': _extra.uri.toString(),
        'code': response.statusCode,
        'method': _extra['method'],
        "status": 'error',
        "status_code": response.statusCode,
        'headers': _extra['headers'],
        'headers response': response.headers.map,
        'params': _extra['data'],
        'payload': response.body,
        'action': 'getElementById',
        'created_at': _extra['createdAt'],
        'response_at': responseAt,
        'curl': _extra['curl'],
        'size': response.body.toString().length,
      };
      AppLogger().messagesStream.sink.add(Message('device_request', payload));
    } catch (e) {
      print(e);
    }
  }
}
