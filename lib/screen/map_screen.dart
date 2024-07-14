import 'dart:async';

import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:real_time_car_tracking/common/globs.dart';
import 'package:real_time_car_tracking/common/location_manager.dart';
import 'package:real_time_car_tracking/common/service_call.dart';
import 'package:real_time_car_tracking/common/socket_manager.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  late LatLng currentPosition;
  // Set<Marker> markers = Set();

  Map<String, Marker> usersCarArr = {};

  BitmapDescriptor? icon;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getIcon();
    currentPosition = LatLng(LocationManager.shared.currentPos?.latitude ?? 0.0,
        LocationManager.shared.currentPos?.longitude ?? 0.0);

    SocketManager.shared.socket?.on(SVKey.nvCarJoin, (data) {
      if (data[KKey.status] == "1") {
        updateOtherCarLocation(data[KKey.payload] as Map? ?? {});
      } else {}
    });

    SocketManager.shared.socket?.on(SVKey.nvCarUpdateLocation, (data) {
      if (data[KKey.status] == "1") {
        updateOtherCarLocation(data[KKey.payload] as Map? ?? {});
      } else {}
    });

    apiCarJoin();
    // addMarker();
    // FBroadcast.instance().register("update_location", (newLocation, callback) {
    //   if (newLocation is Position) {
    //     var mid = MarkerId(ServiceCall.userUUID);
    //     var newPosition = LatLng(newLocation.latitude, newLocation.longitude);
    //     markers = {
    //       Marker(
    //           markerId: mid,
    //           position: newPosition,
    //           icon: icon ?? BitmapDescriptor.defaultMarker,

    //           rotation: LocationManager.calculateDegrees(currentPosition, newPosition) ,
    //           anchor: const Offset(0.5, 0.5)
    //           )
    //     };
    //     currentPosition = newPosition;
    //     setState(() {});
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: usersCarArr.values.toSet(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: currentPosition)));
  }

  // void addMarker() {
  //   var mid = MarkerId(ServiceCall.userUUID);
  //   markers.add(Marker(
  //       markerId: mid,
  //       position: currentPosition,
  //       icon: icon ?? BitmapDescriptor.defaultMarker));
  //   setState(() {});
  // }

  getIcon() async {
    var icon = await BitmapDescriptor.asset(
        const ImageConfiguration(devicePixelRatio: 3.2), "assets/car.png",
        width: 40, height: 40);

    setState(() {
      this.icon = icon;
    });
  }

  void updateOtherCarLocation(Map obj) {
    usersCarArr[obj["uuid"].toString()] = Marker(
        markerId: MarkerId(obj["uuid"].toString()),
        position: LatLng(double.tryParse(obj["lat"].toString()) ?? 0.0,
            double.tryParse(obj["long"].toString()) ?? 0.0),
        icon: icon ?? BitmapDescriptor.defaultMarker,
        rotation: double.tryParse(obj["degree"].toString()) ?? 0.0,
        anchor: const Offset(0.5, 0.5));

    if (mounted) {
      setState(() {});
    }
  }

  //TODO: ApiCalling

  void apiCarJoin() {
    ServiceCall.post({
      "uuid": ServiceCall.userUUID,
      "lat": currentPosition.latitude.toString(),
      "long": currentPosition.longitude.toString(),
      "degree": LocationManager.shared.carDegree.toString(),
      "socket_id": SocketManager.shared.socket?.id ?? "",
    }, SVKey.svCarJoin, (responseObj) async {
      if (responseObj[KKey.status] == "1") {
        (responseObj[KKey.payload] as Map? ?? {}).forEach((key, value) {
          usersCarArr[key.toString()] = Marker(
              markerId: MarkerId(key.toString()),
              position: LatLng(double.tryParse(value["lat"].toString()) ?? 0.0,
                  double.tryParse(value["long"].toString()) ?? 0.0),
              icon: icon ?? BitmapDescriptor.defaultMarker,
              rotation: double.tryParse(value["degree"].toString()) ?? 0.0,
              anchor: const Offset(0.5, 0.5));
        });

        if (mounted) {
          setState(() {});
        }
      } else {
        debugPrint(responseObj[KKey.message] as String? ?? MSG.fail);
      }
    }, (error) async {
      debugPrint(error.toString());
    });
  }
}
