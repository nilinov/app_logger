# app_logger

Пакет предназначен для логирования http запросов через Interceptor пакета dio.
Так же возможно отслеживать состояние приложения (bloc, cubit).

Example:

*http logger*

```dart
    await AppLogger().init(EnvVariament.logger_url, 'json_placeholder');
    Dio _dio = Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'));
    _dio.interceptors.add(LoggerInterceptor());
```

*bloc logger*

```dart
void main() async {
  Bloc.observer = AppLoggerBlocObserver();
  runApp(MyApp());
}
```