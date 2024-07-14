import 'dart:io';

import 'package:flutter/material.dart';
import 'package:real_time_car_tracking/common/globs.dart';
import 'package:real_time_car_tracking/common/location_manager.dart';
import 'package:real_time_car_tracking/common/my_http_overrides.dart';
import 'package:real_time_car_tracking/common/service_call.dart';
import 'package:real_time_car_tracking/common/socket_manager.dart';
import 'package:real_time_car_tracking/screen/map_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

SharedPreferences? prefs;

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();

  ServiceCall.userUUID = Globs.udValueString("uuid");

  if (ServiceCall.userUUID == "") {
    ServiceCall.userUUID = const Uuid().v6();
    Globs.udStringSet(ServiceCall.userUUID, "uuid");
  }

  SocketManager.shared.initSocket();
  LocationManager.shared.initLocation();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}
