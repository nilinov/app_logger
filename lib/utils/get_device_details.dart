part of app_logger;

Future<DeviceInfo> getDeviceDetails({
  @required String project,
  @required int session,
}) async {
  final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
  var res;

  try {
    if (Platform.isAndroid) {
      var build = await deviceInfoPlugin.androidInfo;
      res = DeviceInfo(
        build.androidId,
        build.model,
        build.version.toString(),
        build.androidId, //UUID for Androi,
        build.product,
        project,
        session,
      );
    } else if (Platform.isIOS) {
      var data = await deviceInfoPlugin.iosInfo;
      res = DeviceInfo(
        data.identifierForVendor,
        data.name,
        data.systemVersion,
        data.identifierForVendor, //UUID for iOS,
        data.systemName,
        project,
        session,
      );
    }
  } on PlatformException {
    print('Failed to get platform version');
  }

  return res;
}

