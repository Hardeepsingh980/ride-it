import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

const APIKEY = 'AIzaSyA8xYAKtqohyLZyh_JsLhobfGFraOZodac';
const PLACEAPIKEY = 'AIzaSyCe2Ue4NPPRQBgUssSXw1fv23YOOyd2QDU';

// Micro:- 12, Night:- 16
// Mini:- 15, Night:- 20
// Auto:- 10, Night:- 13
// Bike:- 9, Night: 12
// Prime Executive:- 20, Night:- 25
// Prime SUV:- 25, Night:- 29
// Luxury:- 32, Night:- 38

const List<Map<String, dynamic>> CAB_TYPES = [
  {
    'name': 'Bike',
    'image': 'assets/types/bike.png',
    'price': 9,
    'nightPrice': 12,
    'subtitle': '1 Passenger',
  },
  {
    'name': 'Auto',
    'image': 'assets/types/auto.png',
    'price': 10,
    'nightPrice': 13,
    'subtitle': '2 Passenger',
  },
  {
    'name': 'Micro',
    'image': 'assets/types/micro.png',
    'price': 12,
    'nightPrice': 16,
    'subtitle': '4 Passenger',
  },
  {
    'name': 'Mini',
    'image': 'assets/types/mini.png',
    'price': 15,
    'nightPrice': 20,
    'subtitle': '4 Passenger',
  },
  {
    'name': 'Prime Executive',
    'image': 'assets/types/prime_sedan.png',
    'price': 20,
    'nightPrice': 25,
    'subtitle': '4 Passenger',
  },
  {
    'name': 'Prime SUV',
    'image': 'assets/types/suv.png',
    'price': 25,
    'nightPrice': 29,
    'subtitle': '6 Passenger',
  },
  {
    'name': 'Luxury',
    'image': 'assets/types/luxury.png',
    'price': 32,
    'nightPrice': 38,
    'subtitle': '6 Passenger',
  }
];

bool isDayTime(DateTime time) => time.hour >= 6 && time.hour <= 18;

void navigateTo(LatLng origin, LatLng destination) async {
  var uri = Uri.parse("https://www.google.com/maps/dir/?api=1&origin=" +
      origin.latitude.toString() +
      "," +
      origin.longitude.toString() +
      "&destination=" +
      destination.latitude.toString() +
      "," +
      destination.longitude.toString() +
      "&travelmode=driving&dir_action=navigate");
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch ${uri.toString()}';
  }
}

String distanceMatrixApiUrl(LatLng destination, LatLng origin) =>
    'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${origin.latitude},${origin.longitude}&destinations=${destination.latitude},${destination.longitude}&key=$PLACEAPIKEY';
