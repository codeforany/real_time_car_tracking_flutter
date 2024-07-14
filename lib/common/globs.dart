import 'package:real_time_car_tracking/main.dart';

class Globs {
  static const appName = "Car Tracking";

  static void udStringSet(String data, String key) {
    prefs?.setString( key, data );
  }

  static String udValueString(String key) {
    return prefs?.getString(key ) ?? "";
  }
}

class SVKey {
    static const mainUrl = "http://localhost:3001";
    static const baseUrl = "$mainUrl/api/";
    static const nodeUrl = mainUrl;

    static const nvCarJoin = "car_join";
    static const nvCarUpdateLocation = "car_update_location";

    static const svCarJoin = "$baseUrl$nvCarJoin";
    static const svCarUpdateLocation = "$baseUrl$nvCarUpdateLocation";
}

class KKey {
    static const payload = "payload";
    static const status = "status";
    static const message = "message";
}

class MSG {
  static const success = "success";
  static const fail = "fail";
}