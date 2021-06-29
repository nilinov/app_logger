part of app_logger;

class AppLoggerBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    // print('onCreate -- cubit: ${cubit.runtimeType}');
    AppLogger().addBloc(bloc.runtimeType.toString(), bloc.state);
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    // print('onEvent -- bloc: ${bloc.runtimeType}, event: $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // print('onChange -- cubit: ${cubit.runtimeType}, change: $change');
    if (bloc.runtimeType.toString().contains('Cubit')) {
      AppLogger().onChangeBloc(bloc.runtimeType.toString(), change.currentState, change.nextState);
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
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('onError -- cubit: ${bloc.runtimeType}, error: $error');
    // AppLogger().onChangeBloc(cubit.runtimeType.toString(), change.currentState, change.nextState);
    // AppLogger().onTransitionBloc(
    //   bloc.runtimeType.toString(),
    //   transition.currentState,
    //   transition.nextState,
    //   transition.event.runtimeType.toString(),
    // );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('onClose -- cubit: ${bloc.runtimeType}');
    AppLogger().removeBloc(bloc.runtimeType.toString());
  }
}
