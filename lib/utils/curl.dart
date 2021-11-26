part of app_logger;

String cURLRepresentationDio(RequestOptions options) {
  try {
    List<String> components = ["curl -i"];
    if (options.method.toUpperCase() == "GET") {
      components.add("-X ${options.method}");
    }

    options.headers.forEach((k, v) {
      if (k != "Cookie") {
        components.add("-H \"$k: $v\"");
      }
    });

    var data = json.encode(options.data);
    if (data != "null") {
      components.add("-d $data");
    }

    if (options.method == "POST")
      components.add("\"${options.path}\"");
    else
      components.add("\"${options.uri.toString()}\"");

    return components.join('\\\n\t');
  } catch (err) {
    debugPrint(err.toString());
    return "error export";
  }
}

String cURLRepresentationHttp(Http.Request options) {
  try {
    List<String> components = ["curl -i"];
    if (options.method.toUpperCase() == "GET") {
      components.add("-X ${options.method}");
    }

    options.headers.forEach((k, v) {
      if (k != "Cookie") {
        components.add("-H \"$k: $v\"");
      }
    });

    var data = json.encode(options.body);
    if (data != "null") {
      components.add("-d $data");
    }

    components.add("\"${options.url.toString()}\"");

    return components.join('\\\n\t');
  } catch (err) {
    debugPrint(err.toString());
    return "error export";
  }
}
