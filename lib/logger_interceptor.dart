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
      final payload = RequestPayload(
        number: countRequest,
        url: options.uri.toString(),
        code: null,
        method: options.method,
        status: 'pending',
        statusCode: null,
        headers: options.headers,
        headersResponse: {},
        params: options.data,
        payload: null,
        action: 'getElementById',
        createdAt: createdAt,
        responseAt: null,
        curl: curl,
        size: null,
        baseUrl: AppLogger().baseUrl,
        install: AppLogger().install,
      );
      AppLogger().messagesStream.sink.add(Message('device_request', payload));
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

      final payload = RequestPayload(
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
        install: AppLogger().install,
      );
      AppLogger().messagesStream.sink.add(Message('device_request', payload));
    } catch (e) {
      print(e);
    }

    return super.onResponse(response, handler);
  }

  @override
  onError(DioError err, ErrorInterceptorHandler handler) {
    var response = err.response!;
    try {
      final responseAt = DateTime.now().toIso8601String();
      final options = response.requestOptions;

      var number = int.parse(options?.extra['number'] ?? '0');
      var createdAt = options?.extra['createdAt'] ?? '';
      var curl = options?.extra['curl'] ?? '';

      final payload = RequestPayload(
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
        install: AppLogger().install,
      );
      AppLogger().messagesStream.sink.add(Message('device_request', payload));
    } catch (e) {
      print(e);
    }

    return super.onError(err, handler);
  }
}
