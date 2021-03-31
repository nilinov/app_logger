part of app_logger;

class LoggerInterceptor extends Interceptor {
  var countRequest = 0;

  @override
  Future onRequest(RequestOptions options) async {
    final createdAt = DateTime.now().toIso8601String();

    final curl = cURLRepresentation(options);

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
      if (AppLogger().project == null) {
        AppLogger().messages.add(payload);
      } else {
        AppLogger().channel.sink.add(payload);
      }

    } catch (e) {
      print(e);
    }

    this.countRequest++;
    return super.onRequest(options);
  }

  @override
  Future onResponse(Response response) {
    try {
      final responseAt = DateTime.now().toIso8601String();

      var number = int.parse(response.request?.extra['number'] ?? '0');
      var createdAt = response.request?.extra['createdAt'] ?? '';
      var curl = response.request?.extra['curl'] ?? '';

      Map jsonData = {
        'action': 'device_request',
        'payload': {
          'device_identifier': AppLogger().deviceInfo.identifier,
          'session_id': AppLogger().sessionId,
          'project': AppLogger().project,
          'number': number,
          'url': response.request.uri.toString(),
          'code': response.statusCode,
          'method': response.request.method,
          "status": 'done',
          "status_code": response.statusCode,
          'headers': response.request.headers,
          'headers_response': response.headers.map,
          'params': response.request.data,
          'payload': response.data,
          'action': 'getElementById',
          'created_at': createdAt,
          'response_at': responseAt,
          'curl': curl,
          'size': response.data
              .toString()
              .length,
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

    return super.onResponse(response);
  }

  @override
  Future onError(DioError err) {
    var response = err.response;
    try {
      final responseAt = DateTime.now().toIso8601String();

      var number = int.parse(response.request?.extra['number'] ?? '0');
      var createdAt = response.request?.extra['createdAt'] ?? '';
      var curl = response.request?.extra['curl'] ?? '';

      Map jsonData = {
        'action': 'device_request',
        'payload': {
          'device_identifier': AppLogger().deviceInfo.identifier,
          'session_id': AppLogger().sessionId,
          'project': AppLogger().project,
          'number': number,
          'url': response.request.uri.toString(),
          'code': response.statusCode,
          'method': response.request.method,
          "status": 'error',
          "status_code": response.statusCode,
          'headers': response.request.headers,
          'headers response': response.headers.map,
          'params': response.request.data,
          'payload': response.data,
          'action': 'getElementById',
          'created_at': createdAt,
          'response_at': responseAt,
          'curl': curl,
          'size': response.data
              .toString()
              .length,
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

    return super.onError(err);
  }

  String cURLRepresentation(RequestOptions options) {
    List<String> components = ["curl -i"];
    if (options.method != null && options.method.toUpperCase() == "GET") {
      components.add("-X ${options.method}");
    }

    if (options.headers != null) {
      options.headers.forEach((k, v) {
        if (k != "Cookie") {
          components.add("-H \"$k: $v\"");
        }
      });
    }

    var data = json.encode(options.data);
    if (data != null && data != "null") {
      components.add("-d $data");
    }

    components.add("\"${options.uri.toString()}\"");

    return components.join('\\\n\t');
  }


}

