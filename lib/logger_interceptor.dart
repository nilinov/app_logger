part of app_logger;

class LoggerInterceptor extends Interceptor {
  var countRequest = 0;

  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final createdAt = DateTime.now().toIso8601String();

    final curl = cURLRepresentationDio(options);

    options.extra.addAll({
      'number': countRequest.toString(),
      'createdAt': createdAt,
      'curl': curl,
    });

    try {
      Map jsonData = {
        'action': 'device_request',
        'payload': {
          'device_identifier': AppLogger().deviceInfo.identifier,
          'session_id': AppLogger().sessionId,
          'project': AppLogger().project,
          'number': countRequest,
          'url': options.uri.toString(),
          'code': null,
          "status": "pending",
          "method": options.method,
          'headers': options.headers,
          'headers_response': {},
          'params': options.data,
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
      AppLogger().messagesStream.sink.add(payload);
    } catch (e) {
      print(e);
    }

    this.countRequest++;
    return super.onRequest(options, handler);
  }

  @override
  onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      final responseAt = DateTime.now().toIso8601String();

      final options = response.requestOptions;

      var number = int.parse(options?.extra['number'] ?? '0');
      var createdAt = options?.extra['createdAt'] ?? '';
      var curl = options?.extra['curl'] ?? '';

      Map jsonData = {
        'action': 'device_request',
        'payload': RequestPayload(
          number: number,
          url: options.uri.toString(),
          code: response.statusCode,
          method: options.method,
          status: 'done',
          statusCode: response.statusCode,
          headers: options.headers,
          headersResponse: response.headers.map,
          params: options.data,
          payload: response.data,
          action: 'getElementById',
          createdAt: createdAt,
          responseAt: responseAt,
          curl: curl,
          size: response.data.toString().length,
          baseUrl: AppLogger().baseUrl,
        ),
      };

      final payload = jsonEncode(jsonData);
      AppLogger().messagesStream.sink.add(payload);
    } catch (e) {
      print(e);
    }

    return super.onResponse(response, handler);
  }

  @override
  onError(DioError err, ErrorInterceptorHandler handler) {
    var response = err.response;
    try {
      final responseAt = DateTime.now().toIso8601String();
      final options = response.requestOptions;

      var number = int.parse(options?.extra['number'] ?? '0');
      var createdAt = options?.extra['createdAt'] ?? '';
      var curl = options?.extra['curl'] ?? '';

      Map jsonData = {
        'action': 'device_request',
        'payload': RequestPayload(
          number: number,
          url: options.uri.toString(),
          code: response.statusCode,
          method: options.method,
          status: 'error',
          statusCode: response.statusCode,
          headers: options.headers,
          headersResponse: response.headers.map,
          params: options.data,
          payload: response.data,
          action: 'getElementById',
          createdAt: createdAt,
          responseAt: responseAt,
          curl: curl,
          size: response.data.toString().length,
          baseUrl: AppLogger().baseUrl,
        )
      };
      final payload = jsonEncode(jsonData);
      AppLogger().messagesStream.sink.add(payload);
    } catch (e) {
      print(e);
    }

    return super.onError(err, handler);
  }
}
