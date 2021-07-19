part of app_logger;

extension AppBloc on AppLogger {
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
        debugPrint(err.toString());
      }
    }
  }

  removeBloc(String name) {
    create();

    if (project == null) return;
    final index = this.blocs.indexWhere((element) => element.name == name);
    this.blocs.removeAt(index);

    try {
      this.messagesStream.sink.add(Message('onClose', blocs));
    } catch (e) {
      debugPrint(e.toString());
    }
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
        debugPrint(e.toString());
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
        debugPrint(e.toString());
      }
    }
  }
}
