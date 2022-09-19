import 'dart:async';

import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsWidget extends StatefulWidget {
  Completer<GoogleMapController> mapController;
  CameraPosition initialCameraPosition;
  Set<Marker> markers;
  Set<Polyline> polylines;

  MapsWidget(
      {super.key,
      required this.mapController,
      required this.initialCameraPosition,
      required this.markers,
      required this.polylines});

  @override
  State<MapsWidget> createState() => _MapsWidgetState();
}

class _MapsWidgetState extends State<MapsWidget> {
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: widget.initialCameraPosition,
      markers: widget.markers,
      polylines: widget.polylines,
      onMapCreated: (GoogleMapController controller) {
        widget.mapController.complete(controller);
      },
    );
  }
}
