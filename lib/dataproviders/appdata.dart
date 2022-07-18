import 'package:flutter/cupertino.dart';
import 'package:uber/datamodels/address.dart';

class AppData extends ChangeNotifier {
  Address pickupAdress = Address(
      placeId: "",
      latitude: 0,
      longitude: 0,
      placeName: "",
      placeFormattedAddress: "");

  Address destinationAddress = Address(
      placeId: "",
      latitude: 0,
      longitude: 0,
      placeName: "",
      placeFormattedAddress: "");

  void updatePickupAddress(Address pickup) {
    pickupAdress = pickup;
    notifyListeners();
  }

  void updatedestinationAddress(Address destination) {
    destinationAddress = destination;
    notifyListeners();
  }
}
