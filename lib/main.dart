import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber/dataproviders/appdata.dart';
import 'package:uber/screens/loginpage.dart';
import 'package:uber/screens/mainpage.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:uber/screens/registrationpage.dart';
import 'firebase_options.dart';
import 'package:geolocator/geolocator.dart';

Future<LocationPermission> permission = Geolocator.requestPermission();

const USE_DATABASE_EMULATOR = false;
const emulatorPort = 9000;
final emulatorHost =
    (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
        ? '10.0.2.2'
        : 'localhost';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (USE_DATABASE_EMULATOR) {
    FirebaseDatabase.instance.useDatabaseEmulator(emulatorHost, emulatorPort);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
          title: '',
          theme: ThemeData(
            fontFamily: 'Brand-Regular',
            primarySwatch: Colors.blue,
          ),
          // ignore: prefer_const_constructors
          initialRoute: RegistrationPage.id,
          debugShowCheckedModeBanner: false,
          routes: {
            // ignore: prefer_const_constructors
            MainPage.id: (context) => MainPage(),
            RegistrationPage.id: (context) => RegistrationPage(),
            LoginPage.id: (context) => LoginPage(),
          }),
    );
  }
}
