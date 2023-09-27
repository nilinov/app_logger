library app_logger;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_logger/models/request_payload.dart';
import 'package:app_logger/utils/generate_random_string.dart';
import 'package:bloc/bloc.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as Http;
import 'package:shared_preferences/shared_preferences.dart';

part 'app_bloc.dart';

part 'app_logger_bloc_observer.dart';

part 'logger_http.dart';

part 'logger_interceptor.dart';

part 'models/bloc/bloc_record.dart';

part 'models/bloc/bloc_state_diff.dart';

part 'models/device_info.dart';

part 'models/message.dart';

part 'utils/curl.dart';

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
  String loggerUrl = '';
  String? baseUrl = '';
  String install = '';
  String? project;
  StreamController<Message> messagesStream = new StreamController();
  bool hideErrorBlocSerialize = true;
  bool hasConnect = false;
  late SharedPreferences prefs;
  late Options httpOptions;
  DateTime lastSend = DateTime.now();
  int durationSend = 1;

  List<Message> messages = <Message>[];

  create() {
    if (messagesStream.isClosed) {
      messagesStream = new StreamController();
    }
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

        messages.add(event);
      });
      isCreated = true;
    }

    Timer.periodic(Duration(seconds: durationSend), (timer) {
      if (hasConnect) {
        if (messages.isNotEmpty) {
          sendMessage([...messages]);
          messages.clear();
        }
      }
    });
  }

  init(String loggerUrl, String project, {bool? hasConnect, String? baseUrl, bool? hideErrorBlocSerialize, int? durationSend})
  async {
    this.loggerUrl = loggerUrl;
    this.project = project;
    this.baseUrl = baseUrl;
    this.hideErrorBlocSerialize = hideErrorBlocSerialize ?? this.hideErrorBlocSerialize;
    this.durationSend = durationSend ?? this.durationSend;

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
      deviceInfo = deviceInfo!.copyWith(
        project: project,
        session: sessionId,
        baseUrl: baseUrl,
        install: install,
      );
    }

    final isEmulator = Platform.isAndroid
        ? (await DeviceInfoPlugin().androidInfo).isPhysicalDevice == false
        : (await DeviceInfoPlugin().iosInfo).isPhysicalDevice == false;

    final bool canConnect = hasConnect == true || isEmulator;

    if (canConnect) {
      print('[Logger] init, session $sessionId');

      this.hasConnect = true;

      httpOptions = Options(headers: {'install': install, 'project': project, 'sessionId': sessionId});

      messages.add(Message('device_connect', deviceInfo));

      if (messages.isNotEmpty) {
        sendMessage([...messages]);
        messages.clear();
      }
    } else {
      print('[Logger] init, no connect remote, session $sessionId');
    }
  }

  sendMessage(List<Message> messages) async {
    try {
      var payload = [];

      messages.forEach((element) {
        try {
          jsonEncode(element.payload);
          payload.add(element);
        } catch(e) {
          print('Не могу отправить в логгер сообщение');
          print(e);
        }
      });

      await Dio().post(loggerUrl + '/request', data: jsonEncode(payload), options: httpOptions);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<BlocRecord> blocs = [];

  log(String message) {
    try {
      create();
      this.messagesStream.sink.add(Message('device_log', message));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  refreshCache(Map<String, dynamic> cache) {
    try {
      create();
      this.messagesStream.sink.add(Message('cache', cache));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  dispose() {
    messagesStream.close();
  }
}
