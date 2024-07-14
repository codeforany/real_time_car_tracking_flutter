import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:real_time_car_tracking/common/globs.dart';
import 'package:real_time_car_tracking/common/service_call.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketManager {
  static final SocketManager sigleton = SocketManager._internal();
  SocketManager._internal();
  IO.Socket? socket;
  static SocketManager get shared => sigleton;

  void initSocket() {
    socket = IO.io(SVKey.nodeUrl, {
      "transports": ['websocket'],
      "autoConnect": true
    });

    socket?.on("connect", (data) {
      if (kDebugMode) {
        print("Socket Connect Done");
      }
      updateSocketIdApi();
    });

    socket?.on("connect_error", (data) {
      if (kDebugMode) {
        print("Socket Connect Error");
        print(data);
      }
    });

    socket?.on("error", (data) {
      if (kDebugMode) {
        print("Socket Error");
        print(data);
      }
    });

    socket?.on("disconnect", (data) {
      if (kDebugMode) {
        print("Socket Disconnect");
        print(data);
      }
    });

    socket?.on("UpdateSocket", (data) {
      print("UpdateSocket : -------------");
      print(data);
    });
  }

  Future updateSocketIdApi() async {
    if (ServiceCall.userUUID == "") {
      return;
    }

    try {
      socket?.emit("UpdateSocket", jsonEncode({'uuid': ServiceCall.userUUID}));
    } catch (e) {
      if (kDebugMode) {
        print("Socket Disconnect");
        print(e.toString());
      }
    }
  }
}
