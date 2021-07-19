import 'package:app_logger/app_logger.dart';

class RequestPayload {
  final number;
  final url;
  final code;
  final method;
  final status;
  final statusCode;
  final headers;
  final headersResponse;
  final params;
  final payload;
  final action;
  final createdAt;
  final responseAt;
  final curl;
  final size;
  final String? baseUrl;
  final String install;

  RequestPayload({
    required this.number,
    required this.url,
    required this.code,
    required this.method,
    required this.status,
    required this.statusCode,
    required this.headers,
    required this.headersResponse,
    required this.params,
    required this.payload,
    required this.action,
    required this.createdAt,
    required this.responseAt,
    required this.curl,
    required this.size,
    required this.baseUrl,
    required this.install,
  });

  toJson() => {
        'device_identifier': AppLogger().deviceInfo?.identifier,
        'session_id': AppLogger().sessionId,
        'project': AppLogger().project,
        'number': number,
        'url': url,
        'code': code,
        'method': method,
        "status": status,
        "status_code": statusCode,
        'headers': headers,
        'headers_response': headersResponse,
        'params': params,
        'payload': payload,
        'action': action,
        'created_at': createdAt,
        'response_at': responseAt,
        'curl': curl,
        'size': size,
        'baseUrl': baseUrl,
        'install': install,
      };
}
