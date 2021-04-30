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

part 'utils/get_device_details.dart';

class AppLogger {
  static final AppLogger _singleton = AppLogger._internal();
  String path;

  bool isCreated = false;

  factory AppLogger() {
    return _singleton;
  }

  AppLogger._internal();

  DeviceInfo deviceInfo;
  int sessionId = 0;
  IOWebSocketChannel channel;
  String loggerUrl = '';
  String baseUrl = '';
  String install = '';
  String project;
  StreamController<Message> messagesStream = new StreamController();
  bool hideErrorBlocSerialize = true;
  bool hasConnect = false;
  SharedPreferences prefs;

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

  init(String loggerUrl, String project, {bool hasConnect, String baseUrl, bool hideErrorBlocSerialize}) async {
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
      deviceInfo = deviceInfo.update(
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
      channel = IOWebSocketChannel.connect(loggerUrl);
      this.hasConnect = true;

      messages.add(Message('device_connect', deviceInfo));

      if (messages.isNotEmpty) {
        messages.forEach((element) {
          sendMessage(element);
        });
      }

      channel.stream.listen((message) {
        // print(message);
        // channel.sink.close(status.goingAway);
      });
    } else {
      print('[Logger] init, no connect remote, session $sessionId');
    }
  }

  sendMessage(Message message) {
    channel.sink.add(jsonEncode(message.toJson()));
  }

  List<BlocRecord> blocs = [];

  log(String message) {
    create();
    this.messagesStream.sink.add(Message('device_log', message));
  }

  addBloc(String name, state) {
    create();

    final bloc = BlocRecord(
      number: blocs.length,
      name: name,
      state: state,
      deviceInfo: deviceInfo,
      project: project,
      sessionId: sessionId,
    );
    this.blocs.add(bloc);

    try {
      this.messagesStream.sink.add(Message('onCreate', blocs));
    } catch (err) {
      if (!AppLogger().hideErrorBlocSerialize) {
        debugPrint(err);
      }
    }
  }

  removeBloc(String name) {
    create();

    if (project == null) return;
    final index = this.blocs.indexWhere((element) => element.name == name);
    this.blocs.removeAt(index);

    this.messagesStream.sink.add(Message('onClose', blocs));
  }

  onChangeBloc(String name, state1, state2) {
    create();

    if (project == null) return;
    try {
      this.messagesStream.sink.add(Message(
          'onChange',
          BlocStateDiff(
            bloc: name,
            currentState: state1,
            nextState: state2,
            eventName: null,
            isBloc: false,
          )));
    } catch (e) {
      if (!AppLogger().hideErrorBlocSerialize) {
        print(e);
      }
    }
  }

  onTransitionBloc(String name, state1, state2, String eventName) {
    create();

    if (project == null) return;
    try {
      this.messagesStream.sink.add(Message(
          'onTransition',
          BlocStateDiff(
            bloc: name,
            currentState: state1,
            nextState: state2,
            eventName: eventName,
            isBloc: true,
          )));
    } catch (e) {
      if (!AppLogger().hideErrorBlocSerialize) {
        print(e);
      }
    }
  }

  dispose() {
    create();

    messagesStream?.close();
  }
}
