import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_it/components/checkPrices.dart';
import 'package:ride_it/components/locationInputs.dart';
import 'package:ride_it/components/maps.dart';
import 'package:ride_it/conts.dart';
import 'package:google_maps_webservice/places.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Ride IT',
        home: HomePage(),
        theme: ThemeData(primaryColor: Colors.red));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: PLACEAPIKEY);
  PolylinePoints polylinePoints = PolylinePoints();

  Completer<GoogleMapController> mapController = Completer();
  CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(37.43296265331129, -122.08832357078792),
    zoom: 14.4746,
  );

  TextEditingController pickUpController = TextEditingController();
  TextEditingController dropOffController = TextEditingController();

  LatLng? pickUpLocation;
  LatLng? dropOffLocation;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  DateTime time = DateTime.now();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      getCurrentLocation();
      print('initState');
    });
  }

  void getCurrentLocation() async {
    await Geolocator.requestPermission();

    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    GoogleMapController controller = await mapController.future;
    LatLng latLng = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 14);
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    Marker pickUpMarker = Marker(
        markerId: MarkerId('pickUp'),
        position: latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
    pickUpLocation = latLng;
    setState(() {
      initialCameraPosition = cameraPosition;
      pickUpController.text = 'Your Current Location';
      markers.add(pickUpMarker);
    });
  }

  void changeLocation(String placeId, bool isPickUp) async {
    GoogleMapController controller = await mapController.future;
    PlacesDetailsResponse? place = await _places.getDetailsByPlaceId(placeId);

    double lat = place.result.geometry!.location.lat;
    double lng = place.result.geometry!.location.lng;
    LatLng latLng = LatLng(lat, lng);
    if (isPickUp) {
      CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 14);
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      Marker pickUpMarker = Marker(
          markerId: MarkerId('pickUp'),
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
      pickUpLocation = latLng;
      setState(() {
        initialCameraPosition = cameraPosition;
        pickUpController.text = place.result.name;
        markers.clear();
        polylines.clear();
        markers.add(pickUpMarker);
        dropOffController.clear();
        dropOffLocation = null;
      });
    } else {
      dropOffLocation = latLng;
      Marker dropOffMarker = Marker(
          markerId: MarkerId('dropOff'),
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));

      PolylineResult pointsresult =
          await polylinePoints.getRouteBetweenCoordinates(
              PLACEAPIKEY,
              PointLatLng(pickUpLocation!.latitude, pickUpLocation!.longitude),
              PointLatLng(
                  dropOffLocation!.latitude, dropOffLocation!.longitude));

      print(pointsresult.errorMessage);

      Polyline polyline = Polyline(
          polylineId: PolylineId('polyline'),
          color: Colors.red,
          width: 5,
          points: pointsresult.points
              .map((e) => LatLng(e.latitude, e.longitude))
              .toList());

      LatLngBounds bounds;
      if (initialCameraPosition.target.latitude > latLng.latitude &&
          initialCameraPosition.target.longitude > latLng.longitude) {
        bounds = LatLngBounds(
            southwest: latLng, northeast: initialCameraPosition.target);
      } else if (initialCameraPosition.target.longitude > latLng.longitude) {
        bounds = LatLngBounds(
            southwest:
                LatLng(initialCameraPosition.target.latitude, latLng.longitude),
            northeast: LatLng(
                latLng.latitude, initialCameraPosition.target.longitude));
      } else if (initialCameraPosition.target.latitude > latLng.latitude) {
        bounds = LatLngBounds(
            southwest:
                LatLng(latLng.latitude, initialCameraPosition.target.longitude),
            northeast: LatLng(
                initialCameraPosition.target.latitude, latLng.longitude));
      } else {
        bounds = LatLngBounds(
            southwest: initialCameraPosition.target, northeast: latLng);
      }

      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

      setState(() {
        dropOffController.text = place.result.name;
        markers.add(dropOffMarker);
        polylines.add(polyline);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: dropOffLocation != null
          ? Container(
              height: 60,
              width: double.infinity,
              color: Colors.black,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showCheckPricesBottomSheet(
                            context, pickUpLocation!, dropOffLocation!, time);
                      },
                      child: Text(
                        'Check Prices',
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                    ),
                    // pick time icon button
                    IconButton(
                      onPressed: () {
                        showTimePicker(
                                context: context, initialTime: TimeOfDay.now())
                            .then((value) {
                          setState(() {
                            time = DateTime(time.year, time.month, time.day,
                                value!.hour, value.minute);
                          });
                        });
                      },
                      icon: Icon(Icons.timer),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            )
          : Container(
              height: 0,
              width: 0,
            ),
      body: Stack(
        children: [
          MapsWidget(
              mapController: mapController,
              initialCameraPosition: initialCameraPosition,
              markers: markers,
              polylines: polylines),
          SelectLocationInputWidget(
              pickUpController: pickUpController,
              dropOffController: dropOffController,
              changeLocation: changeLocation),
        ],
      ),
    );
  }
}
