import 'dart:async';
import 'dart:math' as Math;

import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:real_time_car_tracking/common/globs.dart';
import 'package:real_time_car_tracking/common/service_call.dart';
import 'package:real_time_car_tracking/common/socket_manager.dart';

class LocationManager {
  static final LocationManager sigleton = LocationManager._internal();
  LocationManager._internal();
  static LocationManager get shared => sigleton;

  Position? currentPos;
  double carDegree = 0.0;

  void initLocation() {
    getLocaitonUpdates();
  }

  getLocaitonUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint(" Location service are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint(" Location service are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint(
          " Location permission are permanently denied, we cannot request permission");
      return;
    }

    const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 15);

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      carDegree = calculateDegrees(
          LatLng(currentPos?.latitude ?? 0.0, currentPos?.longitude ?? 0.0),
          LatLng(position.latitude, position.longitude));
      currentPos = position;
      apiCarUpdateLocation();
      FBroadcast.instance().broadcast("update_location", value: position);
      debugPrint(position.toString());
    });
  }

  static double calculateDegrees(LatLng startPoint, LatLng endPoint) {
    final double startLat = toRadians(startPoint.latitude);
    final double startLng = toRadians(startPoint.longitude);
    final double endLat = toRadians(endPoint.latitude);
    final double endLng = toRadians(endPoint.longitude);

    final double deltaLng = endLng - startLng;

    final double y = Math.sin(deltaLng) * Math.cos(endLat);
    final double x = Math.cos(startLat) * Math.sin(endLat) -
        Math.sin(startLat) * Math.cos(endLat) * Math.cos(deltaLng);

    final double bearing = Math.atan2(y, x);
    return (toDegrees(bearing) + 360) % 360;
  }

  static double toRadians(double degrees) {
    return degrees * (Math.pi / 180.0);
  }

  static double toDegrees(double radians) {
    return radians * (180.0 / Math.pi);
  }

  //TODO: ApiCalling

  void apiCarUpdateLocation() {
    ServiceCall.post({
      "uuid": ServiceCall.userUUID,
      "lat": (currentPos?.latitude ?? 0.0).toString(),
      "long": (currentPos?.longitude ?? 0.0).toString(),
      "degree": carDegree.toString(),
      "socket_id": SocketManager.shared.socket?.id ?? "",
    }, SVKey.svCarUpdateLocation, (responseObj) async {
      if (responseObj[KKey.status] == "1") {
        debugPrint(responseObj[KKey.message] as String? ?? MSG.success);
      } else {
        debugPrint(responseObj[KKey.message] as String? ?? MSG.fail);
      }
    }, (error) async {
      debugPrint(error.toString());
    });
  }
}
