import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:provider/provider.dart';
import 'package:uberapp_clone/Data/appData.dart';
import 'package:uberapp_clone/Models/direction_details.dart';
import 'package:uberapp_clone/helper/helper_methods.dart';
import 'package:uberapp_clone/helper/requestHelper.dart';
import 'package:uberapp_clone/main.dart';
import 'package:uberapp_clone/screens/drawer_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uberapp_clone/screens/search_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = 'home-screen';

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController> _mapController = Completer();

  late GoogleMapController _newGoogleMapController;

  late Animation<Offset> sidebarAnimation;
  late Animation<double> fadeAnimation;
  late AnimationController sidebarAnimationController;
  var sidebarHidden = true;
  late CameraPosition cameraPosition;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polyLineSet = {};
  Set<Marker> markers = {};
  Set<Circle> circle = {};

  DirectionDetails? tripDirectionDetails = null;

  double location_panel = 300;
  double riderDetail_panel = 0;
  double requestRide_panel = 0;

  @override
  void initState() {
    super.initState();
    sidebarAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    sidebarAnimation = Tween<Offset>(
      begin: Offset(-1, 0),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: sidebarAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: sidebarAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    sidebarAnimationController.dispose();
    _newGoogleMapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<AppData>(context).pickupLocation;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: 250),
              myLocationButtonEnabled: true,
              initialCameraPosition: HomeScreen._kGooglePlex,
              mapType: MapType.normal,
              myLocationEnabled: true,
              polylines: polyLineSet,
              markers: markers,
              circles: circle,
              onMapCreated: (cont) async {
                _mapController.complete(cont);
                _newGoogleMapController = cont;

                await locatePosition();
              },
            ),
            Positioned(
              child: AnimatedSize(
                vsync: this,
                duration: Duration(milliseconds: 350),
                curve: Curves.easeIn,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(13),
                      topRight: Radius.circular(13),
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 16,
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(0.7, 0.7),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          "Hi There",
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          "Where To?",
                          style: TextStyle(fontSize: 30, fontFamily: "Bolt"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () async {
                            var res = await Navigator.of(context)
                                .pushNamed(SearchScreen.routeName);

                            if (res == "ObtainDirections") {
                              displayRideDetailContainer();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 6,
                                  color: Colors.black.withOpacity(0.3),
                                  offset: Offset(0.7, 0.7),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.search),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("Search"),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.home,
                              size: 20,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Consumer<AppData>(
                              builder: (context, prevData, child) => Expanded(
                                child: Text(
                                  data == null
                                      ? "Add Home"
                                      : "${data.placeFormatAddress}",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 20,
                          color: Colors.amber,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.work,
                              size: 20,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Office",
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              left: 0,
              right: 0,
              bottom: 0,
            ),
            Positioned(
              left: 35,
              top: 25,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    sidebarHidden = false;
                  });
                  sidebarAnimationController.forward();
                },
                child: Container(
                  child: Icon(
                    Icons.menu,
                    size: 35,
                  ),
                  height: 40,
                  width: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 15,
                        color: Colors.black54,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              child: AnimatedSize(
                vsync: this,
                duration: Duration(milliseconds: 350),
                curve: Curves.easeIn,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16,
                        offset: Offset(0.7, 0.7),
                      ),
                    ],
                  ),
                  height: riderDetail_panel,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.tealAccent,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/taxi.png',
                                  height: 70,
                                  width: 70,
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Car",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Text(
                                      tripDirectionDetails == null
                                          ? ''
                                          : tripDirectionDetails!.distanceText,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                                Expanded(child: Container()),
                                Text(
                                  tripDirectionDetails == null
                                      ? ''
                                      : 'Rs.${HelperMethods.calculateFair(tripDirectionDetails!).truncate()}',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.moneyCheckAlt,
                                size: 18,
                                color: Colors.black54,
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Text('Cash'),
                              SizedBox(
                                width: 16,
                              ),
                              Icon(Icons.keyboard_arrow_down,
                                  size: 16, color: Colors.black54),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.amber,
                            ),
                            onPressed: () {
                              displayRequestRideContainer();
                              getUserinFirebase();
                            },
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Request",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    FontAwesomeIcons.taxi,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              bottom: 0,
              left: 0,
              right: 0,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 16,
                      color: Colors.black,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                height: requestRide_panel,
                child: Column(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    lottie.Lottie.network(
                      "https://assets5.lottiefiles.com/datafiles/HN7OcWNnoqje6iXIiZdWzKxvLIbfeCGTmvXmEm1h/data.json",
                      fit: BoxFit.cover,
                      height: 150,
                      width: 150,
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await cancelRide();
                        setState(() {
                          requestRide_panel = 0;
                        });
                      },
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(width: 2, color: Colors.black54),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 26,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        "Cancel Ride",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IgnorePointer(
              ignoring: sidebarHidden,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: GestureDetector(
                  child: Container(
                    color: Color.fromRGBO(36, 38, 41, 0.4),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
                  onTap: () {
                    setState(() {
                      sidebarHidden = !sidebarHidden;
                    });
                    sidebarAnimationController.reverse();
                  },
                ),
              ),
            ),
            SlideTransition(
              position: sidebarAnimation,
              child: SafeArea(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width * 0.8,
                  color: Colors.amber,
                  child: DrawerScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng ltlnPosition = LatLng(position.latitude, position.longitude);
    cameraPosition = CameraPosition(target: ltlnPosition, zoom: 15);
    _newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await HelperMethods.searchCoordinatesAddress(position, context);
  }

  void displayRideDetailContainer() async {
    await getPlaceDirection();

    setState(() {
      riderDetail_panel = 300;
      location_panel = 0;
    });
  }

  void displayRequestRideContainer() {
    setState(() {
      requestRide_panel = 300;
      riderDetail_panel = 0;
    });
  }

  getUserinFirebase() async {
    String userUid = auth.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> user =
        await FirebaseFirestore.instance.collection('rider').doc(userUid).get();

    var pickup = Provider.of<AppData>(context, listen: false).pickupLocation;
    var dropoff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUpMap = {
      'latitude': pickup!.latitude,
      'longitude': pickup.longitude,
    };

    Map dropOffMap = {
      'latitude': dropoff!.latitude,
      'longitude': dropoff.longitude,
    };

    var riderInfoMap = {
      'created_at': DateTime.now().toString(),
      'driver_id': 'waiting',
      'payment_method': 'cash',
      'pickUp': pickUpMap,
      'dropOff': dropOffMap,
      'riderName': user.data()!['name'],
      'rider_phone': user.data()!['phone'],
      'pickUp_address': pickup.placeFormatAddress,
      'dropOff_address': dropoff.placeFormatAddress,
    };

    print(riderInfoMap);
    FirebaseFirestore.instance
        .collection('riderRequest')
        .doc(userUid)
        .set(riderInfoMap);
  }

  cancelRide() async {
    String userUid = auth.currentUser!.uid;
    setState(() {
      circle.clear();
      markers.clear();
      polyLineSet.clear();
      pLineCoordinates.clear();
    });
    await FirebaseFirestore.instance
        .collection('riderRequest')
        .doc(userUid)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
  }

  Future<void> getPlaceDirection() async {
    var initialPosition =
        Provider.of<AppData>(context, listen: false).pickupLocation;
    var dropoffPosition =
        Provider.of<AppData>(context, listen: false).dropOffLocation;

    var picupkLatLng =
        LatLng(initialPosition!.latitude, initialPosition.longitude);

    var dropOffLatLng =
        LatLng(dropoffPosition!.latitude, dropoffPosition.longitude);

    DirectionDetails details = await HelperMethods.obtainPlaceDirectionDetails(
        picupkLatLng, dropOffLatLng);

    setState(() {
      tripDirectionDetails = details;
    });

    print(details.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();

    if (decodePolyLinePointsResult.isNotEmpty) {
      decodePolyLinePointsResult.forEach((element) {
        pLineCoordinates.add(LatLng(element.latitude, element.longitude));
      });
    }

    polyLineSet.clear();
    Polyline polyline = Polyline(
      polylineId: PolylineId('PolyLineId'),
      color: Colors.amber,
      jointType: JointType.round,
      points: pLineCoordinates,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
    );

    setState(() {
      polyLineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (picupkLatLng.latitude > dropOffLatLng.latitude &&
        picupkLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: picupkLatLng);
    } else if (picupkLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(picupkLatLng.latitude, dropOffLatLng.longitude),
        northeast: LatLng(dropOffLatLng.latitude, picupkLatLng.longitude),
      );
    } else if (picupkLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(dropOffLatLng.latitude, picupkLatLng.longitude),
        northeast: LatLng(picupkLatLng.latitude, dropOffLatLng.longitude),
      );
    } else {
      latLngBounds =
          LatLngBounds(southwest: picupkLatLng, northeast: dropOffLatLng);
    }

    _newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpMarker = Marker(
        markerId: MarkerId("PickUpId"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: initialPosition.placeFormatAddress,
          snippet: "My Location",
        ),
        position: picupkLatLng);

    Marker dropOffMarker = Marker(
        markerId: MarkerId("dropOffMarker"),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: dropoffPosition.placeFormatAddress,
          snippet: "Drop Off Location",
        ),
        position: dropOffLatLng);

    setState(() {
      markers.add(dropOffMarker);
      markers.add(pickUpMarker);
    });

    Circle pickUpCircle = Circle(
      fillColor: Colors.amber,
      radius: 12,
      circleId: CircleId("PickupCircle"),
      center: picupkLatLng,
      strokeWidth: 4,
      strokeColor: Colors.amber,
    );

    Circle dropOffCircle = Circle(
      fillColor: Colors.pink.shade300,
      radius: 12,
      circleId: CircleId("dropOffCircle"),
      center: dropOffLatLng,
      strokeWidth: 4,
      strokeColor: Colors.pink.shade300,
    );

    setState(() {
      circle.add(pickUpCircle);
      circle.add(dropOffCircle);
    });
  }
}
