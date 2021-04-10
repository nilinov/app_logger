part of app_logger;

class DeviceRequestActionBlocOnClose {
  final String action;
  final List<BlocRecord> payload;

  DeviceRequestActionBlocOnClose({
    this.action = 'onClose',
    @required this.payload,
  });

  Map<String, dynamic> toMap() => {"action": action, "payload": payload};
}
