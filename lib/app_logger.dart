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

part 'app_logger_bloc_observer.dart';
part 'device_info.dart';
part 'logger_interceptor.dart';

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

  init(String loggerUrl, String project) async {
    this.loggerUrl = loggerUrl;
    this.project = project;
    deviceInfo = await getDeviceDetails();

    if (sessionId == 0) {
      var prefs = await SharedPreferences.getInstance();
      sessionId = prefs.getInt('sessionId') ?? sessionId;
      sessionId++;
      prefs.setInt('sessionId', sessionId);
    }

    print('[Logger] init');
    channel = IOWebSocketChannel.connect(loggerUrl);

    channel.sink.add(jsonEncode({
      'action': 'device_connect',
      'payload': deviceInfo,
    }));

    channel.stream.listen((message) {
      // print(message);
      // channel.sink.close(status.goingAway);
    });
  }

  List<BlocRecord> blocs = [];

  log(String payload) {
    this.channel.sink.add(jsonEncode({
      'action': 'device_log',
      'payload': {
        'identifier': deviceInfo.identifier,
        'project': project,
        'sessionId': sessionId,
        'log': payload,
      },
    }));
  }

  addBloc(String name, state) {
    final bloc = BlocRecord(number: blocs.length, name: name, state: state);
    this.blocs.add(bloc);
    this.channel.sink.add(jsonEncode(DeviceRequestActionBlocOnCreated(payload: blocs).toMap()));
  }

  removeBloc(String name) {
    final index = this.blocs.indexWhere((element) => element.name == name);
    this.blocs.removeAt(index);
    this.channel.sink.add(jsonEncode(DeviceRequestActionBlocOnClose(payload: blocs).toMap()));
  }

  onChangeBloc(String name, state1, state2) {
    try {
      final change = DeviceRequestActionBlocOnChange(
          payload: BlocStateDiff(
            bloc: name,
            currentState: state1,
            nextState: state2,
            eventName: null,
            isBloc: false,
            project: project,
            sessionId: sessionId,
            deviceInfo: deviceInfo,
          ));
      this.channel.sink.add(jsonEncode(change));
    } catch (e) {
      print(e);
    }
  }

  onTransitionBloc(String name, state1, state2, String eventName) {
    try {
      final change = DeviceRequestActionBlocOnTransition(
          payload: BlocStateDiff(
            bloc: name,
            currentState: state1,
            nextState: state2,
            eventName: eventName,
            isBloc: true,
            project: project,
            sessionId: sessionId,
            deviceInfo: deviceInfo,
          ));
      this.channel.sink.add(jsonEncode(change));
    } catch (e) {
      print(e);
    }
  }
}