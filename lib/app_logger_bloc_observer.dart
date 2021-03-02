part of app_logger;

class AppLoggerBlocObserver extends BlocObserver {
  @override
  void onCreate(Cubit cubit) {
    super.onCreate(cubit);
    // print('onCreate -- cubit: ${cubit.runtimeType}');
    AppLogger().addBloc(cubit.runtimeType.toString(), cubit.state);
  }

  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    // print('onEvent -- bloc: ${bloc.runtimeType}, event: $event');
  }

  @override
  void onChange(Cubit cubit, Change change) {
    super.onChange(cubit, change);
    // print('onChange -- cubit: ${cubit.runtimeType}, change: $change');
    if (cubit.runtimeType.toString().contains('Cubit')) {
      AppLogger().onChangeBloc(cubit.runtimeType.toString(), change.currentState, change.nextState);
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    // print('onTransition -- bloc: ${bloc.runtimeType}, transition: $transition');
    AppLogger().onTransitionBloc(
      bloc.runtimeType.toString(),
      transition.currentState,
      transition.nextState,
      transition.event.runtimeType.toString(),
    );
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    print('onError -- cubit: ${cubit.runtimeType}, error: $error');
    // AppLogger().onChangeBloc(cubit.runtimeType.toString(), change.currentState, change.nextState);
    // AppLogger().onTransitionBloc(
    //   bloc.runtimeType.toString(),
    //   transition.currentState,
    //   transition.nextState,
    //   transition.event.runtimeType.toString(),
    // );
    super.onError(cubit, error, stackTrace);
  }

  @override
  void onClose(Cubit cubit) {
    super.onClose(cubit);
    print('onClose -- cubit: ${cubit.runtimeType}');
    AppLogger().removeBloc(cubit.runtimeType.toString());
  }
}

class BlocRecord {
  final int number;
  final String name;
  var state;

  BlocRecord({
    @required this.number,
    @required this.name,
    @required this.state,
  });

  Map<String, dynamic> toJson() => {"number": number, "name": name, "state": state};

  String toString() => "BlocRecord[number=$number,name=$name,state=$state]";
}

class DeviceRequestActionBlocOnCreated {
  final String action;
  final List<BlocRecord> payload;

  DeviceRequestActionBlocOnCreated({
    this.action = 'onCreate',
    @required this.payload,
  });

  Map<String, dynamic> toMap() => {"action": action, "payload": payload};
}

class DeviceRequestActionBlocOnClose {
  final String action;
  final List<BlocRecord> payload;

  DeviceRequestActionBlocOnClose({
    this.action = 'onClose',
    @required this.payload,
  });

  Map<String, dynamic> toMap() => {"action": action, "payload": payload};
}

class BlocStateDiff {
  var currentState;
  var nextState;
  final String bloc;
  final String eventName;
  final bool isBloc;
  final DeviceInfo deviceInfo;
  final String project;
  final int sessionId;

  BlocStateDiff({
    @required this.currentState,
    @required this.nextState,
    @required this.bloc,
    @required this.eventName,
    @required this.isBloc,
    @required this.deviceInfo,
    @required this.project,
    @required this.sessionId,
  });

  Map<String, dynamic> toJson() =>
      {"currentState": currentState, "nextState": nextState, "bloc": bloc, "eventName": eventName, "isBloc": isBloc};
}

class DeviceRequestActionBlocOnChange {
  final String action;
  final BlocStateDiff payload;

  DeviceRequestActionBlocOnChange({
    this.action = 'onChange',
    @required this.payload,
  });

  Map<String, dynamic> toJson() => {"action": action, "payload": payload};
}

class DeviceRequestActionBlocOnTransition {
  final String action;
  final BlocStateDiff payload;

  DeviceRequestActionBlocOnTransition({
    this.action = 'onTransition',
    @required this.payload,
  });

  Map<String, dynamic> toJson() => {"action": action, "payload": payload};
}