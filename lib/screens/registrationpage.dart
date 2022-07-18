import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uber/screens/loginpage.dart';
import 'package:uber/screens/mainpage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../brand_colors.dart';
import '../widgets/ProgressDialog.dart';
import '../widgets/TaxiButton.dart';

class RegistrationPage extends StatefulWidget {
  static const String id = 'register';

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
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

  // Inscription
  var fullNameController = TextEditingController();

  var phoneController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void RegisterUser() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(status: '  Inscription en cours'));

    try {
      final UserCredential user = (await _auth.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text));

      Navigator.pop(context);
      if (user != null) {
        DatabaseReference newUserRef =
            FirebaseDatabase.instance.ref().child('users/${user.user?.uid}');

        Map userMap = {
          'fullname': fullNameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
        };

        newUserRef.set(userMap);
        Navigator.pushNamedAndRemoveUntil(
            context, MainPage.id, (route) => false);
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
                  // ignore: prefer_const_constructors
                  SizedBox(
                    height: 70,
                  ),
                  Image(
                      alignment: Alignment.center,
                      height: 100.0,
                      width: 100.0,
                      image: AssetImage('images/logo.png')),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Inscription',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      // ignore: prefer_const_literals_to_create_immutables
                      children: <Widget>[
                        TextField(
                          controller: fullNameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              labelText: 'Nom Complet',
                              labelStyle: TextStyle(fontSize: 14.0),
                              hintStyle: TextStyle(
                                  color: Colors.grey, fontSize: 10.0)),
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(
                          height: 10,
                        ),
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
                          height: 10,
                        ),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              labelText: 'Téléphone',
                              labelStyle: TextStyle(fontSize: 14.0),
                              hintStyle: TextStyle(
                                  color: Colors.grey, fontSize: 10.0)),
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(
                          height: 10,
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
                          title: 'INSCRIPTION',
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
                            if (fullNameController.text.length < 3) {
                              showSnack('Veuillez entrer un Nom valide SVP !');
                              return;
                            }

                            if (!emailController.text.contains('@')) {
                              showSnack(
                                  'Veuillez entrer une adresse valide SVP !');
                              return;
                            }

                            if (phoneController.text.length < 10) {
                              showSnack(
                                  'Veuillez entrer un numéro valide SVP !');
                              return;
                            }

                            if (passwordController.text.length < 6) {
                              showSnack(
                                  'Le mot de passe doit contenir au moins 6 charactères !');
                              return;
                            }
                            RegisterUser();
                          },
                        ),
                      ],
                    ),
                  ),

                  InkWell(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, LoginPage.id, (route) => false);
                      },
                      child: Text('Déja inscris, connection ici '))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
