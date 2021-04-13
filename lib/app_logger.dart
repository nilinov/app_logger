library app_logger;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_logger/models/request_payload.dart';
import 'package:bloc/bloc.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as Http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

part 'app_logger_bloc_observer.dart';

part 'utils/curl.dart';

part 'logger_http.dart';

part 'logger_interceptor.dart';

part 'models/device_info.dart';

part 'models/bloc/bloc_record.dart';

part 'models/bloc/device_request_action_bloc_on_created.dart';

part 'models/bloc/device_request_action_bloc_on_close.dart';

part 'models/bloc/bloc_state_diff.dart';

part 'models/bloc/device_request_action_bloc_on_change.dart';

part 'models/bloc/device_request_action_bloc_on_transition.dart';

part 'utils/get_device_details.dart';

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
  String baseUrl = '';
  String project;
  StreamController messagesStream;
  bool hideErrorBlocSerialize = true;

  List messages = [];

  init(String loggerUrl, String project, {bool hasConnect = true, String baseUrl, bool hideErrorBlocSerialize}) async {
    messagesStream = new StreamController();
    this.loggerUrl = loggerUrl;
    this.project = project;
    this.baseUrl = baseUrl;
    this.hideErrorBlocSerialize = hideErrorBlocSerialize ?? this.hideErrorBlocSerialize;

    if (sessionId == 0) {
      var prefs = await SharedPreferences.getInstance();
      sessionId = prefs.getInt('sessionId') ?? sessionId;
      sessionId++;
      prefs.setInt('sessionId', sessionId);
    }

    deviceInfo = await getDeviceDetails(
      project: project,
      session: sessionId,
      baseUrl: baseUrl,
    );

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

    messagesStream.stream.listen((event) {
      if (hasConnect) {
        channel.sink.add(event);
      } else {
        messages.add(event);
      }
    });
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

    this.messagesStream.sink.add(payload);
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

    this.messagesStream.sink.add(payload);
  }

  removeBloc(String name) {
    if (project == null) return;
    final index = this.blocs.indexWhere((element) => element.name == name);
    this.blocs.removeAt(index);

    final payload = jsonEncode(DeviceRequestActionBlocOnClose(payload: blocs).toMap());
    this.messagesStream.sink.add(payload);
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
      this.messagesStream.sink.add(payload);
    } catch (e) {
      if (!AppLogger().hideErrorBlocSerialize) {
        print(e);
      }
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
      this.messagesStream.sink.add(payload);
    } catch (e) {
      if (!AppLogger().hideErrorBlocSerialize) {
        print(e);
      }
    }
  }

  dispose() {
    messagesStream?.close();
  }
}
