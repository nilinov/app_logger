part of app_logger;

class BlocStateDiff {
  var currentState;
  var nextState;
  final String bloc;
  final String? eventName;
  final bool isBloc;

  BlocStateDiff({
    required this.currentState,
    required this.nextState,
    required this.bloc,
    required this.eventName,
    required this.isBloc,
  });

  Map<String, dynamic> toJson() => {
    "currentState": currentState,
    "nextState": nextState,
    "bloc": bloc,
    "eventName": eventName,
    "isBloc": isBloc,
  };
}
