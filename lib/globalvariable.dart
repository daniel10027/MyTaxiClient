import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber/datamodels/user.dart';

String mapKey = "AIzaSyBDH3KjqIWdultRw2oTtM8t1jHoRvcJCMA";

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);

User? user;
Users currentUserInfo = Users(fullName: "", email: "", phone: "", id: "");
