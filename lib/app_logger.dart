library app_logger;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_logger/models/request_payload.dart';
import 'package:app_logger/utils/generate_random_string.dart';
import 'package:bloc/bloc.dart';
import 'package:check_key_app/check_key_app.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as Http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

part 'app_logger_bloc_observer.dart';
part 'logger_http.dart';
part 'logger_interceptor.dart';
part 'models/bloc/bloc_record.dart';
part 'models/bloc/bloc_state_diff.dart';
part 'models/device_info.dart';
part 'models/message.dart';
part 'utils/curl.dart';
part 'app_bloc.dart';
part 'utils/get_device_details.dart';

class AppLogger {
  static final AppLogger _singleton = AppLogger._internal();
  String? path;

  bool isCreated = false;

  factory AppLogger() {
    return _singleton;
  }

  AppLogger._internal();

  DeviceInfo? deviceInfo;
  int sessionId = 0;
  IOWebSocketChannel? channel;
  WebSocketChannelState _state = WebSocketChannelState.connecting;
  String loggerUrl = '';
  String? baseUrl = '';
  String install = '';
  String? project;
  StreamController<Message> messagesStream = new StreamController();
  bool hideErrorBlocSerialize = true;
  bool hasConnect = false;
  late SharedPreferences prefs;

  List<Message> messages = <Message>[];

  create() {
    if (!isCreated) {
      messagesStream.stream.listen((event) async {
        if (deviceInfo == null) {
          deviceInfo = await getDeviceDetails(
            project: project,
            session: sessionId,
            baseUrl: baseUrl,
            install: install,
          );
        }

        if (hasConnect) {
          sendMessage(event);
        } else {
          messages.add(event);
        }
      });
      isCreated = true;
    }
  }

  init(String loggerUrl, String project, {bool? hasConnect, String? baseUrl, bool? hideErrorBlocSerialize}) async {
    this.loggerUrl = loggerUrl;
    this.project = project;
    this.baseUrl = baseUrl;
    this.hideErrorBlocSerialize = hideErrorBlocSerialize ?? this.hideErrorBlocSerialize;

    prefs = await SharedPreferences.getInstance();
    this.install = prefs.getString('install') ?? generateRandomString(20);
    prefs.setString('install', this.install);

    if (sessionId == 0) {
      sessionId = prefs.getInt('sessionId') ?? sessionId;
      sessionId++;
      prefs.setInt('sessionId', sessionId);
    }

    create();

    if (deviceInfo == null) {
      deviceInfo = await getDeviceDetails(
        project: project,
        session: sessionId,
        baseUrl: baseUrl,
        install: install,
      );
    } else {
      deviceInfo = deviceInfo!.update(
        project: project,
        session: sessionId,
        baseUrl: baseUrl,
      );
    }

    final isEmulator = Platform.isAndroid
        ? (await DeviceInfoPlugin().androidInfo).isPhysicalDevice == false
        : (await DeviceInfoPlugin().iosInfo).isPhysicalDevice == false;

    final bool canConnect =
        hasConnect == true || (hasConnect == null && (await CheckKeyApp.isAppInstalled == true)) || isEmulator;

    if (canConnect) {
      print('[Logger] init, session $sessionId');

      if (this.channel != null && this._state != WebSocketChannelState.closed) {
        dispose();
      }

      _doConnect();
      this.hasConnect = true;

      messages.add(Message('device_connect', deviceInfo));

      if (messages.isNotEmpty) {
        messages.forEach((element) {
          sendMessage(element);
        });
      }
    } else {
      print('[Logger] init, no connect remote, session $sessionId');
    }
  }

  void _doConnect() {
    if (this.channel != null && this._state != WebSocketChannelState.closed) {
      dispose();
    }

    this.channel = IOWebSocketChannel.connect(loggerUrl, pingInterval: Duration(seconds: 1));

    _state = WebSocketChannelState.connecting;

    this.channel!.stream.listen(onReceiveData, onDone: onClosed, onError: onError, cancelOnError: false);
  }

  void onReceiveData(data) {
    print("ReceiveData: $data");
  }

  void onClosed() {
    print("websocket close");
    new Future.delayed(Duration(seconds: 1), () {
      print("websocket restore connect");
      _doConnect();
    });
  }

  void onError(err, StackTrace stackTrace) {
    print("websocket 出错:" + err.toString());
    if (stackTrace != null) {
      print(stackTrace);
    }
  }

  sendMessage(Message message) {
    channel!.sink.add(jsonEncode(message.toJson()));
  }

  List<BlocRecord> blocs = [];

  log(String message) {
    create();
    this.messagesStream.sink.add(Message('device_log', message));
  }

  dispose() {
    create();

    this.channel!.sink.close();
    this._state = WebSocketChannelState.closed;

    messagesStream?.close();
  }
}

enum WebSocketChannelState {
  connecting,
  closed,
}
