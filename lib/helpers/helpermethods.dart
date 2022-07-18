import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber/datamodels/address.dart';
import 'package:uber/datamodels/directiondetails.dart';
import 'package:uber/datamodels/user.dart';
import 'package:uber/dataproviders/appdata.dart';
import 'package:uber/globalvariable.dart';
import 'package:uber/helpers/requesthelper.dart';

class HelperMethods {
  static Future<String> findCordinateAddress(Position position, context) async {
    String placeAddress = "";
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return placeAddress;
    }

    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var response = await RequestHelper.getRequest(url);

    if (response != 'failed') {
      placeAddress = response['results'][0]['formatted_address'];
      Address pickupAddress = new Address(
          placeId: "",
          latitude: position.latitude,
          longitude: position.longitude,
          placeName: placeAddress,
          placeFormattedAddress: "");

      Provider.of<AppData>(context, listen: false)
          .updatePickupAddress(pickupAddress);
    }

    return placeAddress;
  }

  static Future<DirectionDetails?> getDirectionDetails(
      LatLng startPosition, LatLng EndPosition) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${EndPosition.latitude},${EndPosition.longitude}&mode=driving&key=$mapKey";

    var response = await RequestHelper.getRequest(url);
    if (response == "failed") {
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails(
        distanceText: '',
        distanceValue: 0,
        durationText: '',
        durationValue: 0,
        encodePonits: '');

    directionDetails.durationText =
        response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue =
        response['routes'][0]['legs'][0]['duration']['value'];
    directionDetails.distanceText =
        response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue =
        response['routes'][0]['legs'][0]['distance']['value'];
    directionDetails.encodePonits =
        response['routes'][0]['overview_polyline']['points'];

    return directionDetails;
  }

  static int estimateFares(DirectionDetails details) {
    //prix par mk = 0.76 francs cfa
    //prix par minute = 0.56 francs cfa
    // base de conduite = 1500 francs
    double baseFaire = 250;
    double distanceFaire = (details.distanceValue / 1000) * 100;
    double timeFare = (details.durationValue / 60) * 100;

    double totalFare = baseFaire + distanceFaire + timeFare;

    return totalFare.truncate();
  }

  static Future<void> getCurrentUserInfo() async {
    user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;
    DatabaseReference reference =
        FirebaseDatabase.instance.ref().child('users/$userId');

    final snapshot =
        await reference.get(); // you should use await on async methods
    if (snapshot.value != null) {
      currentUserInfo = Users.fromSnapshot(snapshot);
    }
  }
}
