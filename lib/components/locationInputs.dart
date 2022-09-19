import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:ride_it/conts.dart';
import 'package:google_maps_webservice/places.dart';

class SelectLocationInputWidget extends StatefulWidget {
  TextEditingController pickUpController;
  TextEditingController dropOffController;
  Function changeLocation;

  SelectLocationInputWidget(
      {super.key,
      required this.pickUpController,
      required this.dropOffController,
      required this.changeLocation});

  @override
  State<SelectLocationInputWidget> createState() =>
      _SelectLocationInputWidgetState();
}

class _SelectLocationInputWidgetState extends State<SelectLocationInputWidget> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        top: size.height * 0.08,
        left: size.width * 0.06,
        right: size.width * 0.06,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Card(
          elevation: 20,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text(
                  //   'Select Pick and Drop Locations',
                  //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  // ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            Prediction? p = await PlacesAutocomplete.show(
                                context: context,
                                apiKey: PLACEAPIKEY,
                                radius: 10000000,
                                types: [],
                                strictbounds: false,
                                mode: Mode.overlay,
                                language: "en",
                                components: [],
                                logo: Container(
                                  height: 0,
                                  width: 0,
                                ));
                            if (p != null) {
                              widget.changeLocation(p.placeId, true);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: TextField(
                              controller: widget.pickUpController,
                              enabled: false,
                              decoration: InputDecoration(
                                hintText: 'Pickup Location',
                                fillColor: Colors.grey[200],
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    left: 11.0, top: 8.0, bottom: 8.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.redAccent),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            Prediction? p = await PlacesAutocomplete.show(
                                context: context,
                                apiKey: PLACEAPIKEY,
                                radius: 10000000,
                                types: [],
                                strictbounds: false,
                                mode: Mode.overlay,
                                language: "en",
                                components: [],
                                logo: Container(
                                  height: 0,
                                  width: 0,
                                ));
                            if (p != null) {
                              widget.changeLocation(p.placeId, false);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: TextField(
                              controller: widget.dropOffController,
                              enabled: false,
                              decoration: InputDecoration(
                                hintText: 'Destination Location',
                                fillColor: Colors.grey[200],
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    left: 11.0, top: 8.0, bottom: 8.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
