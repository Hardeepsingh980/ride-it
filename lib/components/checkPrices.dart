import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:ride_it/conts.dart';

void showCheckPricesBottomSheet(
    BuildContext context, LatLng origin, LatLng destination, DateTime time) {
  showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        Size size = MediaQuery.of(context).size;
        return CheckPriceWidget(
            size: size, origin: origin, destination: destination, time: time);
      });
}

class CheckPriceWidget extends StatefulWidget {
  final LatLng origin;
  final LatLng destination;
  final DateTime time;

  const CheckPriceWidget({
    Key? key,
    required this.size,
    required this.origin,
    required this.destination,
    required this.time,
  }) : super(key: key);

  final Size size;

  @override
  State<CheckPriceWidget> createState() => _CheckPriceWidgetState();
}

class _CheckPriceWidgetState extends State<CheckPriceWidget> {
  bool isLoading = true;
  bool isError = false;

  Map<String, dynamic> data = {};

  @override
  void initState() {
    super.initState();
    getDataFromDistanceMatrix();
  }

  void getDataFromDistanceMatrix() async {
    String url = distanceMatrixApiUrl(widget.destination, widget.origin);
    var response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);

      // check lenth of elements
      if (data['rows'][0]['elements'][0]['status'] == 'OK') {
        setState(() {
          data = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 150),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        child: Scaffold(
          appBar: AppBar(
            leading: Container(),
            centerTitle: true,
            backgroundColor: Colors.black,
            title: Text('Check Prices'),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close))
            ],
          ),
          bottomNavigationBar: InkWell(
            onTap: () {
              navigateTo(widget.origin, widget.destination);
            },
            child: Container(
              height: 50,
              width: double.infinity,
              color: Colors.black,
              child: Center(
                child: Text(
                  'Start Ride',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          body: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : isError
                  ? Center(
                      child: Text('No Route Found'),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Icon(
                                    Icons.directions_car,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    data['rows'][0]['elements'][0]['distance']
                                        ['text'],
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    data['rows'][0]['elements'][0]['duration']
                                        ['text'],
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ...List.generate(CAB_TYPES.length, (index) {
                            double kmInDouble = double.parse(data['rows'][0]
                                    ['elements'][0]['distance']['text']
                                .split(' ')[0]);

                            bool day = isDayTime(widget.time);
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      CAB_TYPES[index]['name'],
                                    ),
                                    leading: Image.asset(
                                      CAB_TYPES[index]['image'],
                                      height: 60,
                                      width: 60,
                                    ),
                                    subtitle:
                                        Text(CAB_TYPES[index]['subtitle']),
                                    trailing: Text(
                                      "₹" +
                                          ((day
                                                      ? CAB_TYPES[index]
                                                          ['price']
                                                      : CAB_TYPES[index]
                                                          ['nightPrice']) *
                                                  kmInDouble)
                                              .toString(),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Divider(
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
