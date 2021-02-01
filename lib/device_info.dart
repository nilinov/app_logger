part of app_logger;

Future<DeviceInfo> getDeviceDetails() async {
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
      );
    } else if (Platform.isIOS) {
      var data = await deviceInfoPlugin.iosInfo;
      res = DeviceInfo(
        data.identifierForVendor,
        data.name,
        data.systemVersion,
        data.identifierForVendor, //UUID for iOS,
        data.systemName,
      );
    }
  } on PlatformException {
    print('Failed to get platform version');
  }

  return res;
}

class DeviceInfo {
  final String uuid;
  final String deviceName;
  final String deviceVersion;
  final String identifier;
  final String product;

  DeviceInfo(this.uuid, this.deviceName, this.deviceVersion, this.identifier, this.product);

  @override
  String toString() {
    return json.encode(toJson());
  }

  toJson() {
    return {
      'uuid': uuid,
      'device_name': deviceName,
      'device_version': deviceVersion,
      'identifier': identifier,
      'product': product,
    };
  }
}