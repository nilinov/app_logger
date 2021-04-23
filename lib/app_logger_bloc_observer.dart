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
