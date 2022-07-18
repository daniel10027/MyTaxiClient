// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uber/brand_colors.dart';
import 'package:uber/screens/mainpage.dart';
import 'package:uber/screens/registrationpage.dart';
import 'package:uber/widgets/ProgressDialog.dart';
import '../widgets/TaxiButton.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  void showSnack(String title) {
    final snackbar = SnackBar(
        content: Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 15,
      ),
    ));
    scaffoldMessengerKey.currentState?.showSnackBar(snackbar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void login() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(status: '  Connexion en cours'));

    try {
      final UserCredential user = (await _auth.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text));
      // ignore: unnecessary_null_comparison
      Navigator.pop(context);
      if (user != null) {
        // ignore: unused_local_variable

        DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child('users/${user.user?.uid}');

        userRef.once().then((DatabaseEvent snapshot) {
          if (snapshot.snapshot.value != null) {
            Navigator.pushNamedAndRemoveUntil(
                context, MainPage.id, (route) => false);
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showSnack(e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                // ignore: prefer_const_literals_to_create_immutables
                children: <Widget>[
                  SizedBox(
                    height: 70,
                  ),
                  Image(
                      alignment: Alignment.center,
                      height: 100.0,
                      width: 100.0,
                      image: AssetImage('images/logo.png')),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    'Connexion Chauffeur',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      // ignore: prefer_const_literals_to_create_immutables
                      children: <Widget>[
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              labelText: 'Adresse E-mail',
                              labelStyle: TextStyle(fontSize: 14.0),
                              hintStyle: TextStyle(
                                  color: Colors.grey, fontSize: 10.0)),
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextField(
                          obscureText: true,
                          controller: passwordController,
                          decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              labelStyle: TextStyle(fontSize: 14.0),
                              hintStyle: TextStyle(
                                  color: Colors.grey, fontSize: 10.0)),
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        TaxiButton(
                          title: 'CONNEXION',
                          color: BrandColors.colorGreen,
                          onPressed: () async {
                            var connectivityResult =
                                await (Connectivity().checkConnectivity());

                            if (connectivityResult !=
                                    ConnectivityResult.mobile &&
                                connectivityResult != ConnectivityResult.wifi) {
                              showSnack('Aucune connexion Internet ');
                              return;
                            }

                            if (!emailController.text.contains('@')) {
                              showSnack(
                                  'Veuillez entrer une adresse valide SVP !');
                              return;
                            }

                            if (passwordController.text.length < 6) {
                              showSnack(
                                  'Le mot de passe doit contenir au moins 6 charactères !');
                              return;
                            }

                            login();
                          },
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    child: Text('Pas de compte ? , Inscrivez vous  ici '),
                     onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, RegistrationPage.id, (route) => false);
                      },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
