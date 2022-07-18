// ignore_for_file: prefer_const_constructors
// ignore: prefer_const_literals_to_create_immutables
// ignore: prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber/brand_colors.dart';
import 'package:uber/datamodels/directiondetails.dart';
import 'package:uber/dataproviders/appdata.dart';
import 'package:uber/globalvariable.dart';
import 'package:uber/helpers/helpermethods.dart';
import 'package:uber/screens/searchpage.dart';
import 'package:uber/styles/styles.dart';
import 'package:uber/widgets/BrandDivider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:uber/widgets/ProgressDialog.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uber/widgets/TaxiButton.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  static const String id = 'mainpage';

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scafoldKey = new GlobalKey<ScaffoldState>();
  double mapBottomPadding = 0;

  Completer<GoogleMapController> _controller = Completer();

  late GoogleMapController mapController;

  DirectionDetails tripDirectionDetails = DirectionDetails(
      distanceText: "",
      distanceValue: 0,
      durationText: "",
      durationValue: 0,
      encodePonits: "");

  double rideDetailSheetHeight = 0;

  double requestingSheetHeight = 0;

  double searchSheetHeight = (Platform.isIOS) ? 300 : 275;

  bool drawerCanOpen = true;

  late DatabaseReference rideRef;

  void showDetailSheet() async {
    await getDirection();

    setState(() {
      searchSheetHeight = 0;
      rideDetailSheetHeight = (Platform.isAndroid) ? 235 : 260;
      mapBottomPadding = (Platform.isAndroid) ? 240 : 230;
      drawerCanOpen = false;
    });
  }

  void showRequestingSheet() async {
    setState(() {
      rideDetailSheetHeight = 0;
      requestingSheetHeight = (Platform.isAndroid) ? 195 : 220;
      mapBottomPadding = (Platform.isAndroid) ? 200 : 190;

      drawerCanOpen = false;
    });

    createRideRequest();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('nameIs');
    HelperMethods.getCurrentUserInfo();
  }

  var geoLocator = Geolocator();
  late Position currentPosition;

  List<LatLng> polylineCoordinates = [];

  Set<Polyline> _polylines = {};

  Set<Marker> _Markers = {};

  Set<Circle> _Circles = {};

  void setupPositionLocator() async {
    LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    // Recuperation de la latitude et de la longitude de l'utilisateur
    LatLng pos = LatLng(position.latitude, position.longitude);
    // Modification de la position de la camera
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    // Mise a jour de la posotion de la camera avec zoom in de 14
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));

    String address =
        await HelperMethods.findCordinateAddress(position, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scafoldKey,
        drawer: Container(
            width: 250,
            color: Colors.white,
            child: Drawer(
              child: ListView(
                padding: EdgeInsets.all(0),
                children: <Widget>[
                  Container(
                      color: Colors.white,
                      height: 160,
                      child: DrawerHeader(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Row(children: <Widget>[
                          Image.asset(
                            "images/user_icon.png",
                            height: 60,
                            width: 60,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Daniel',
                                style: TextStyle(
                                    fontSize: 20, fontFamily: 'Brand-Bold'),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text("Voir le profile")
                            ],
                          )
                        ]),
                      )),
                  BrandDivider(),
                  SizedBox(height: 10),
                  ListTile(
                      leading: Icon(Icons.card_giftcard_outlined),
                      title: Text(
                        "Course Gratuite",
                        style: kDrawerItemStyle,
                      )),
                  ListTile(
                      leading: Icon(Icons.credit_card),
                      title: Text(
                        "Paiements",
                        style: kDrawerItemStyle,
                      )),
                  ListTile(
                      leading: Icon(Icons.history),
                      title: Text(
                        "Historique",
                        style: kDrawerItemStyle,
                      )),
                  ListTile(
                      leading: Icon(Icons.contact_support_outlined),
                      title: Text(
                        "Support",
                        style: kDrawerItemStyle,
                      )),
                  ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text(
                        "A proopos",
                        style: kDrawerItemStyle,
                      )),
                ],
              ),
            )),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              padding: EdgeInsets.only(bottom: mapBottomPadding),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              initialCameraPosition: googlePlex,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              polylines: _polylines,
              markers: _Markers,
              circles: _Circles,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                mapController = controller;

                setState(() {
                  mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
                });

                setupPositionLocator();
              },
            ),

            /// Boutton Menu
            Positioned(
              top: 44,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  if (drawerCanOpen) {
                    scafoldKey.currentState?.openDrawer();
                  } else {
                    resetApp();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      // ignore: prefer_const_literals_to_create_immutables
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7),
                        )
                      ]),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: Icon(
                      (drawerCanOpen) ? Icons.menu : Icons.arrow_back,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),

            ///Page de Recherche

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                duration: new Duration(milliseconds: 150),
                curve: Curves.easeIn,
                child: Container(
                  height: searchSheetHeight,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      // ignore: prefer_const_literals_to_create_immutables
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15.0,
                            spreadRadius: 0.5,
                            offset: Offset(
                              0.7,
                              0.7,
                            ))
                      ]),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Ravi de vous revoir !',
                          style: TextStyle(fontSize: 10),
                        ),
                        Text(
                          'Ou allez vous ?',
                          style:
                              TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () async {
                            var response = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchPage()));

                            if (response == 'getDirection') {
                              showDetailSheet();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                // ignore: prefer_const_literals_to_create_immutables
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5.0,
                                      spreadRadius: 0.5,
                                      offset: Offset(0.7, 0.7))
                                ]),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Row(
                                  // ignore: prefer_const_literals_to_create_immutables
                                  children: <Widget>[
                                    Icon(
                                      Icons.search,
                                      color: Colors.blueAccent,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text("Chercher une destination")
                                  ]),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        Row(
                          children: <Widget>[
                            Icon(Icons.home_outlined,
                                color: BrandColors.colorDimText),
                            SizedBox(
                              width: 12,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // ignore: prefer_const_literals_to_create_immutables
                              children: <Widget>[
                                // ignore: unnecessary_null_comparison
                                Text((Provider.of<AppData>(context)
                                            .pickupAdress
                                            .placeName !=
                                        null)
                                    ? Provider.of<AppData>(context)
                                        .pickupAdress
                                        .placeName
                                    : 'Ajouter Domicile'),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  'Votre domicile actuel',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: BrandColors.colorDimText),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        BrandDivider(),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: <Widget>[
                            Icon(Icons.work_outline,
                                color: BrandColors.colorDimText),
                            SizedBox(
                              width: 12,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // ignore: prefer_const_literals_to_create_immutables
                              children: <Widget>[
                                Text("Ajouter Bureau"),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  'Votre Bureau actuel',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: BrandColors.colorDimText),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // pos
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                duration: new Duration(milliseconds: 150),
                curve: Curves.easeIn,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7))
                    ],
                  ),
                  height: rideDetailSheetHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          color: BrandColors.colorAccent1,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: <Widget>[
                                Image.asset(
                                  'images/taxi.png',
                                  height: 70,
                                  width: 70,
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  // ignore: prefer_const_literals_to_create_immutables
                                  children: <Widget>[
                                    Text(
                                      "Taxi Koffi",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Brand-Bold'),
                                    ),
                                    Text(
                                      (tripDirectionDetails != null)
                                          ? tripDirectionDetails.distanceText
                                          : "",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Brand-Bold'),
                                    )
                                  ],
                                ),
                                Expanded(child: Container()),
                                Text(
                                  // ignore: unnecessary_null_comparison
                                  (tripDirectionDetails != null)
                                      ? '${HelperMethods.estimateFares(tripDirectionDetails).toString()} Francs'
                                      : '',
                                  style: TextStyle(
                                      fontSize: 18, fontFamily: 'Brand-Bold'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            // ignore: prefer_const_literals_to_create_immutables
                            children: <Widget>[
                              Icon(FontAwesomeIcons.moneyBillAlt,
                                  size: 18, color: BrandColors.colorTextLight),
                              SizedBox(
                                width: 16,
                              ),
                              Text("Cash"),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(Icons.keyboard_arrow_down_outlined,
                                  size: 16, color: BrandColors.colorTextLight),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 22,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TaxiButton(
                              title: 'Commander',
                              onPressed: () {
                                showRequestingSheet();
                              },
                              color: BrandColors.colorGreen),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                duration: new Duration(milliseconds: 150),
                curve: Curves.easeInSine,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15.0,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7))
                      ]),
                  height: requestingSheetHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: TextLiquidFill(
                            text: "Recherche d'un véhicule",
                            waveColor: BrandColors.colorTextSemiLight,
                            boxBackgroundColor: Colors.white,
                            textStyle: TextStyle(
                              fontSize: 22.0,
                              fontFamily: 'Brand-Bold',
                            ),
                            boxHeight: 40.0,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            cancelRequest();
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadiusDirectional.circular(25),
                              border: Border.all(
                                  width: 1.0,
                                  color: BrandColors.colorLightGrayFair),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 25,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: double.infinity,
                          child: Text(
                            'Annuler la course',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }

  Future<void> getDirection() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAdress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    var pickupLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destinationLatLng = LatLng(destination.latitude, destination.longitude);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            ProgressDialog(status: "   Récuperation des données"));

    var thisDetails = await HelperMethods.getDirectionDetails(
        pickupLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetails = thisDetails!;
    });

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails!.encodePonits);
    polylineCoordinates.clear();
    if (results.isNotEmpty) {
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    _polylines.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Color.fromARGB(255, 95, 109, 237),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polylines.add(polyline);
    });

    LatLngBounds bounds;

    if (pickupLatLng.latitude > destinationLatLng.latitude &&
        pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, pickupLatLng.longitude));
    } else if (pickupLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
          northeast:
              LatLng(pickupLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);
    }
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
        markerId: MarkerId('pickup'),
        position: pickupLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow:
            InfoWindow(title: pickup.placeName, snippet: 'Ma Position'));

    Marker destinationMarker = Marker(
        markerId: MarkerId('destination'),
        position: destinationLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow:
            InfoWindow(title: destination.placeName, snippet: 'Destination'));

    setState(() {
      _Markers.add(pickupMarker);
      _Markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
        circleId: CircleId('pickup'),
        strokeColor: Colors.green,
        strokeWidth: 3,
        radius: 12,
        center: pickupLatLng,
        fillColor: BrandColors.colorGreen);

    Circle destinationCircle = Circle(
        circleId: CircleId('destination'),
        strokeColor: BrandColors.colorAccentPurple,
        strokeWidth: 3,
        radius: 12,
        center: destinationLatLng,
        fillColor: BrandColors.colorAccentPurple);

    setState(() {
      _Circles.add(pickupCircle);
      _Circles.add(destinationCircle);
    });
  }

  void createRideRequest() {
    rideRef = FirebaseDatabase.instance.ref().child('rideRequest').push();
    var pickup = Provider.of<AppData>(context, listen: false).pickupAdress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    Map pickuMap = {
      'latitude': pickup.latitude.toString(),
      'longitude': pickup.longitude.toString()
    };
    Map destinationMap = {
      'latitude': destination.latitude.toString(),
      'longitude': destination.longitude.toString()
    };

    Map rideMap = {
      'created_at': DateTime.now().toString(),
      'rider_name': currentUserInfo.fullName,
      'rider_phone': currentUserInfo.phone,
      'pickup_address': pickup.placeName,
      'destination_address': destination.placeName,
      'location': pickuMap,
      'destination': destinationMap,
      'payment_method': 'carte',
      'driver_id': 'waiting',
    };

    rideRef.set(rideMap);
  }

  void cancelRequest() {
    rideRef.remove();
    resetApp();
  }

  void resetApp() {
    setState(() {
      polylineCoordinates.clear();
      _polylines.clear();
      _Markers.clear();
      _Circles.clear();
      rideDetailSheetHeight = 0;
      requestingSheetHeight = 0;
      searchSheetHeight = (Platform.isAndroid) ? 275 : 300;
      mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
      drawerCanOpen = true;
      requestingSheetHeight = 0;
    });
  }
}
