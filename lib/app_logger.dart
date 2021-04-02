library app_logger;
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as Http;

part 'app_logger_bloc_observer.dart';
part 'device_info.dart';
part 'logger_interceptor.dart';
part 'logger_http.dart';
part 'curl.dart';

class AppLogger {
  static final AppLogger _singleton = AppLogger._internal();
  String path;

  factory AppLogger() {
    return _singleton;
  }

  AppLogger._internal();

  DeviceInfo deviceInfo;
  int sessionId = 0;
  IOWebSocketChannel channel;
  String loggerUrl = '';
  String project;

  List messages = [];

  init(String loggerUrl, String project, {bool hasConnect = true}) async {
    this.loggerUrl = loggerUrl;
    this.project = project;
    deviceInfo = await getDeviceDetails();

    if (sessionId == 0) {
      var prefs = await SharedPreferences.getInstance();
      sessionId = prefs.getInt('sessionId') ?? sessionId;
      sessionId++;
      prefs.setInt('sessionId', sessionId);
    }

    if (hasConnect) {
      print('[Logger] init');
      channel = IOWebSocketChannel.connect(loggerUrl);

      channel.sink.add(jsonEncode({
        'action': 'device_connect',
        'payload': deviceInfo,
      }));

      if (messages.isNotEmpty) {
        messages.forEach((element) {
          channel.sink.add(element);
        });
      }

      channel.stream.listen((message) {
        // print(message);
        // channel.sink.close(status.goingAway);
      });
    } else {
      print('[Logger] init, no connect remote');
    }
  }

  List<BlocRecord> blocs = [];

  log(String message) {
    final payload = jsonEncode({
      'action': 'device_log',
      'payload': {
        'identifier': deviceInfo.identifier,
        'project': project,
        'sessionId': sessionId,
        'log': message,
      },
    });

    if (project == null) {
      messages.add(payload);
    } else {
      this.channel.sink.add(payload);
    }
  }

  addBloc(String name, state) {
    final bloc = BlocRecord(
      number: blocs.length,
      name: name,
      state: state,
      deviceInfo: deviceInfo,
      project: project,
      sessionId: sessionId,
    );
    this.blocs.add(bloc);

    final payload = jsonEncode(DeviceRequestActionBlocOnCreated(
      payload: blocs,
      deviceInfo: deviceInfo,
      project: project,
      sessionId: sessionId,
    ).toMap());

    if (project == null) {
      messages.add(payload);
    } else {
      this.channel.sink.add(payload);
    }
  }

  removeBloc(String name) {
    if (project == null) return;
    final index = this.blocs.indexWhere((element) => element.name == name);
    this.blocs.removeAt(index);

    final payload = jsonEncode(DeviceRequestActionBlocOnClose(payload: blocs).toMap());

    if (project == null) {
      messages.add(payload);
    } else {
      this.channel.sink.add(payload);
    }
  }

  onChangeBloc(String name, state1, state2) {
    if (project == null) return;
    try {
      final change = DeviceRequestActionBlocOnChange(
        payload: BlocStateDiff(
          bloc: name,
          currentState: state1,
          nextState: state2,
          eventName: null,
          isBloc: false,
        ),
        deviceInfo: deviceInfo,
        project: project,
        sessionId: sessionId,
      );

      final payload = jsonEncode(jsonEncode(change));

      if (project == null) {
        messages.add(payload);
      } else {
        this.channel.sink.add(payload);
      }

    } catch (e) {
      print(e);
    }
  }

  onTransitionBloc(String name, state1, state2, String eventName) {
    if (project == null) return;
    try {
      final change = DeviceRequestActionBlocOnTransition(
        payload: BlocStateDiff(
          bloc: name,
          currentState: state1,
          nextState: state2,
          eventName: eventName,
          isBloc: true,
        ),
        deviceInfo: deviceInfo,
        project: project,
        sessionId: sessionId,
      );

      final payload = jsonEncode(jsonEncode(change));

      if (project == null) {
        messages.add(payload);
      } else {
        this.channel.sink.add(payload);
      }
    } catch (e) {
      print(e);
    }
  }
}