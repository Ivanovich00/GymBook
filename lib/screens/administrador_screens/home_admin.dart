import 'dart:io';

import 'package:GymBook/screens/administrador_screens/export_screens.dart';
import 'package:GymBook/screens/administrador_screens/help.dart';
import 'package:GymBook/screens/administrador_screens/usuarios_screen.dart';
import 'package:GymBook/screens/administrador_screens/widget_admin/tarjetas_paginas.dart';
import 'package:GymBook/services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:GymBook/screens/screens.dart';
import 'package:page_transition/page_transition.dart';

class AdministradorScreen extends StatefulWidget{
  @override
  State<AdministradorScreen> createState() => _AdministradorScreenState();
}

String? userdoc;
String? nombreControl, apellidoControl, emailControl;

bool _isNewNotification = false;
bool _isNotificationScreen = false;

bool _isOscuro = false;
bool _isConnectedBool = true;
bool _isIntro = false;
bool _isDialog = false;

class _AdministradorScreenState extends State<AdministradorScreen> {
  @override
  void initState() {
    super.initState();
    _initGetDetails();
  }

  Future<void> _initGetDetails() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    User? user = _firebaseAuth.currentUser;

    userdoc = user!.uid;

    final authService = Provider.of<AuthService>(context, listen: false);
    final valor_isOscuro = await authService.readTheme();

    if (valor_isOscuro == 'OSCURO') {
      _isOscuro = true;
    } else {
      _isOscuro = false;
    }

    final valor_isIntro = await authService.readIntro();

    if (valor_isIntro == 'TRUE') {
      _isIntro = true;
    } else {
      _isIntro = false;
    }

    try {
      final result = await InternetAddress.lookup('example.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _isConnectedBool = true;
      }
    } catch (_) {
      _isConnectedBool = false;
    }

    try {
      final result = await InternetAddress.lookup('example.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('notificaciones')
            .doc(userdoc)
            .collection('nuevas')
            .get()
            .then((value) {
          if (value.docs.length != 0) {
            _isNewNotification = true;
          } else {
            _isNewNotification = false;
          }

          setState(() {});
        });
      }
    } catch (_) {
      Get.snackbar(
        "Error", // title
        "No hay conexión a Internet", // message
        icon: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Icon(Icons.wifi_off_rounded, color: Colors.white),
        ),
        margin: EdgeInsets.symmetric(vertical: 10),
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.BOTTOM,
        shouldIconPulse: true,
        barBlur: 0,
        isDismissible: true,
        duration: Duration(seconds: 3),
        colorText: Colors.white,
        backgroundColor: Colors.red[800],
        maxWidth: 350,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      );
    }
  }

  @override
  Widget build (BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Material(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              child: Scaffold(
                appBar: AppBar(
                  leading: Center(
                    child: Image.asset(
                      'assets/app_icon_transparent.png',
                      fit: BoxFit.fill,
                      width: 40,
                      height: 40,
                    ),
                  ),
                  automaticallyImplyLeading: true,
                  centerTitle: true,
                  backgroundColor: Color.fromRGBO(71, 83, 97, 1),
                  title: Text("Las Barras GYM",
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.white))),
                ),
                body: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Background(),
                    _HomeBody(),
                    Positioned(
                      right: 5,
                      bottom: 5,
                      child: Tooltip(
                        message: "Ayuda",
                        child: Material(
                          color: Colors.transparent,
                          child: new InkWell(
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            splashColor: Colors.white38,
                            onTap: () {
                              _isDialog = true;
                              setState(() {});
                            },
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromRGBO(48, 48, 48, 0.75),
                                  ),
                                ),
                                Icon(Icons.help, size: 25, color: Colors.white),
                              ]
                            ),
                          ),
                        ),
                      ),
                    ),
                    ],
                ),
              ),
            ),
            Visibility(
              visible: (_isDialog),
              maintainState: false,
              maintainAnimation: false,
              maintainSize: false,
              maintainSemantics: false,
              maintainInteractivity: false,
              child: GestureDetector(
                onTap: (){
                  _isDialog = false;
                  setState(() {});
                },
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  width: width,
                  height: height,
                ),
              ),
            ),
            Visibility(
              visible: (_isDialog),
              maintainState: false,
              maintainAnimation: false,
              maintainSize: false,
              maintainSemantics: false,
              maintainInteractivity: false,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                width: 250,
                height: 190,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "¿Necesitas ayuda?",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 18, color: Color.fromARGB(255, 49, 49, 49), fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 15),
                    Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color.fromRGBO(107, 195, 130, 1))),
                child: Material(
                  color: Colors.transparent,
                  child: new InkWell(
                    customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    splashColor: Colors.white38,
                    onTap: () async {

                      _isDialog = false;

                      try {
                        final result = await InternetAddress.lookup('example.com');
      
                        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                            FirebaseFirestore.instance
                                .collection("administradores")
                                .doc(userdoc)
                                .snapshots()
                                .listen((event) {
                              nombreControl = event.get('nombre').toString();
                              apellidoControl = event.get('apellido').toString();
                              emailControl = event.get('email').toString();
      
                              Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.fade,
                                      child: PantallaHelpAdministrador(nombreControl: nombreControl, apellidoControl: apellidoControl, emailControl: emailControl),                                      duration: Duration(milliseconds: 250)));
                            });
                          }
                        }
                      } catch (e) {
                        Get.snackbar(
                          "Error", // title
                          "No hay conexión a Internet", // message
                          icon: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Icon(Icons.wifi_off_rounded, color: Colors.white),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 10),
                          snackStyle: SnackStyle.FLOATING,
                          snackPosition: SnackPosition.BOTTOM,
                          shouldIconPulse: true,
                          barBlur: 0,
                          isDismissible: true,
                          duration: Duration(seconds: 3),
                          colorText: Colors.white,
                          backgroundColor: Colors.red[800],
                          maxWidth: 350,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        );
                      }
                      
                      setState(() {});
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          width: 225,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.transparent,
                                    child: Container(
                                      child: Icon(Icons.headset_mic_outlined,
                                          size: 27,
                                          color:
                                              Color.fromRGBO(107, 195, 130, 1)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5),
                              Text('Contactanos', style: TextStyle(fontFamily: 'Poppins', fontStyle: FontStyle.normal, fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      "Introducción",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontFamily: 'Poppins', fontStyle: FontStyle.normal, fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black54),
                    ),
                  SizedBox(width: 10),
                  CupertinoSwitch(
                    trackColor: Colors.black26,
                    value: _isIntro,
                    onChanged: (bool value) async {
                      _isIntro = !_isIntro;
                      if(value == true){
                        await storage.write(key: 'INTRO', value: 'TRUE');
                      } else {
                        await storage.write(key: 'INTRO', value: 'FALSE');
                      }
                      setState(() {});
                    },
                  ),
                ],
              ),
            ],
          ),
      
                  ],
                ),
              ),
            )
          
          ],
        ),
      ),
    );
  }

}

class _HomeBody extends StatefulWidget {
  const _HomeBody({
    Key? key,
  }) : super(key: key);

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children:[
          TarjetasOpciones(),
        ],
      ),
    );
  }
}

