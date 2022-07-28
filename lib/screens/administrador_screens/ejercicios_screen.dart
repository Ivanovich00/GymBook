import 'dart:io';

import 'package:GymBook/screens/administrador_screens/export_screens.dart';
import 'package:GymBook/screens/ejercicios/abdomen/abdomen.dart';
import 'package:GymBook/screens/ejercicios/brazo/brazo.dart';
import 'package:GymBook/screens/ejercicios/espalda/espalda.dart';
import 'package:GymBook/screens/ejercicios/hombro/hombro.dart';
import 'package:GymBook/screens/ejercicios/pecho/pecho.dart';
import 'package:GymBook/screens/ejercicios/pierna/pierna.dart';
import 'package:GymBook/screens/screens.dart';
import 'package:GymBook/services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PantallaEjercicios extends StatefulWidget {
  const PantallaEjercicios({Key? key}) : super(key: key);
  @override
  State<PantallaEjercicios> createState() => _PantallaEjerciciosState();
}

class _PantallaEjerciciosState extends State<PantallaEjercicios> {
  bool _isOscuro = false;

  Future<void> _initGetDetails() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    User? user = _firebaseAuth.currentUser;

    String userdoc = user!.uid;

    final authService = Provider.of<AuthService>(context, listen: false);
    final valor_isOscuro = await authService.readTheme();

    if (valor_isOscuro == 'OSCURO') {
      _isOscuro = true;
    } else {
      _isOscuro = false;
    }

    try {
      final result = await InternetAddress.lookup('example.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FirebaseFirestore.instance
            .collection("administradores")
            .doc(userdoc)
            .snapshots()
            .listen((event) {
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
  void initState() {
    super.initState();
    _initGetDetails();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final authService = Provider.of<AuthService>(context, listen: false);

    return FutureBuilder(
        future: authService.readTheme(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('');
          }

          if (snapshot.data != '') {
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                          splashRadius: 25,
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            PageTransition(
                                type: PageTransitionType.leftToRight,
                                child: AdministradorScreen(),
                                duration: Duration(milliseconds: 250)));
                      }),
                  backgroundColor: Color.fromRGBO(72, 83, 98, 1),
                  elevation: 0,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text('CATEGORIAS DE EJERCICIOS',
                            style: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                    ],
                  ),
                ),
                body: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Background(),
                    SingleChildScrollView(
                      child: Container(
                        child: Column(
                          children: [
                            Table(children: [
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: (_isOscuro)
                                              ? Color.fromRGBO(255, 255, 255, 0.5)
                                              : Color.fromRGBO(48, 48, 48, 0.75),
                                          borderRadius: BorderRadius.circular(20)),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: new InkWell(
                                          customBorder: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          splashColor: Colors.white38,
                                          onTap: () {
                                            Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRight, child: PantallaBrazo(), duration: Duration(milliseconds: 250)));
                                          },
                                          child: Container(
                                            height: 160,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: LinearGradient(
                                                          colors: [
                                                            Color.fromRGBO(
                                                                82, 154, 186, 1),
                                                            Color.fromRGBO(
                                                                70, 145, 172, 1),
                                                            Color.fromRGBO(
                                                                69, 139, 171, 1),
                                                            Color.fromRGBO(
                                                                62, 129, 152, 1),
                                                            Color.fromRGBO(
                                                                60, 119, 144, 1),
                                                            Color.fromRGBO(
                                                                51, 107, 127, 1),
                                                          ],
                                                          begin: Alignment.topLeft, 
                                                          end: Alignment.bottomRight
                                                      )
                                                  ),
                                                  child: CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor: Colors.transparent,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(15.0),
                                                      child: Container(
                                                        child: Image.asset('assets/icons_ejercicios/brazo.png'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text('Brazo',
                                                    style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                            fontStyle:
                                                                FontStyle.normal,
                                                            fontSize: 17.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Colors.white)))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: (_isOscuro)
                                              ? Color.fromRGBO(255, 255, 255, 0.5)
                                              : Color.fromRGBO(48, 48, 48, 0.75),
                                          borderRadius: BorderRadius.circular(20)),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: new InkWell(
                                          customBorder: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          splashColor: Colors.white38,
                                          onTap: () {
                                            Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: PantallaAbdomen(), duration: Duration(milliseconds: 500)));
                                          },
                                          child: Container(
                                            height: 160,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: LinearGradient(
                                                          colors: [
                                                            Color.fromRGBO(
                                                                82, 154, 186, 1),
                                                            Color.fromRGBO(
                                                                70, 145, 172, 1),
                                                            Color.fromRGBO(
                                                                69, 139, 171, 1),
                                                            Color.fromRGBO(
                                                                62, 129, 152, 1),
                                                            Color.fromRGBO(
                                                                60, 119, 144, 1),
                                                            Color.fromRGBO(
                                                                51, 107, 127, 1),
                                                          ],
                                                          begin: Alignment.topLeft,
                                                          end:
                                                              Alignment.bottomRight)),
                                                  child: CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(15.0),
                                                      child: Container(
                                                        child: Image.asset(
                                                            'assets/icons_ejercicios/abdomen.png'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text('Abdomen',
                                                    style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                            fontStyle:
                                                                FontStyle.normal,
                                                            fontSize: 17.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Colors.white)))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: (_isOscuro)
                                              ? Color.fromRGBO(255, 255, 255, 0.5)
                                              : Color.fromRGBO(48, 48, 48, 0.75),
                                          borderRadius: BorderRadius.circular(20)),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: new InkWell(
                                          customBorder: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          splashColor: Colors.white38,
                                          onTap: () {
                                            Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: PantallaEspalda(), duration: Duration(milliseconds: 500)));
                                          },
                                          child: Container(
                                            height: 160,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: LinearGradient(
                                                          colors: [
                                                            Color.fromRGBO(
                                                                82, 154, 186, 1),
                                                            Color.fromRGBO(
                                                                70, 145, 172, 1),
                                                            Color.fromRGBO(
                                                                69, 139, 171, 1),
                                                            Color.fromRGBO(
                                                                62, 129, 152, 1),
                                                            Color.fromRGBO(
                                                                60, 119, 144, 1),
                                                            Color.fromRGBO(
                                                                51, 107, 127, 1),
                                                          ],
                                                          begin: Alignment.topLeft, 
                                                          end: Alignment.bottomRight
                                                      )
                                                  ),
                                                  child: CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor: Colors.transparent,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(15.0),
                                                      child: Container(
                                                        child: Image.asset('assets/icons_ejercicios/espalda.png'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text('Espalda',
                                                    style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                            fontStyle:
                                                                FontStyle.normal,
                                                            fontSize: 17.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Colors.white)))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                    
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: (_isOscuro)
                                              ? Color.fromRGBO(255, 255, 255, 0.5)
                                              : Color.fromRGBO(48, 48, 48, 0.75),
                                          borderRadius: BorderRadius.circular(20)),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: new InkWell(
                                          customBorder: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          splashColor: Colors.white38,
                                          onTap: () {
                                            Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: PantallaPierna(), duration: Duration(milliseconds: 500)));
                                          },
                                          child: Container(
                                            height: 160,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: LinearGradient(
                                                          colors: [
                                                            Color.fromRGBO(
                                                                82, 154, 186, 1),
                                                            Color.fromRGBO(
                                                                70, 145, 172, 1),
                                                            Color.fromRGBO(
                                                                69, 139, 171, 1),
                                                            Color.fromRGBO(
                                                                62, 129, 152, 1),
                                                            Color.fromRGBO(
                                                                60, 119, 144, 1),
                                                            Color.fromRGBO(
                                                                51, 107, 127, 1),
                                                          ],
                                                          begin: Alignment.topLeft, 
                                                          end: Alignment.bottomRight
                                                      )
                                                  ),
                                                  child: CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor: Colors.transparent,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(15.0),
                                                      child: Container(
                                                        child: Image.asset('assets/icons_ejercicios/pierna.png'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text('Pierna',
                                                    style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                            fontStyle:
                                                                FontStyle.normal,
                                                            fontSize: 17.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Colors.white)))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                                    
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: (_isOscuro)
                                              ? Color.fromRGBO(255, 255, 255, 0.5)
                                              : Color.fromRGBO(48, 48, 48, 0.75),
                                          borderRadius: BorderRadius.circular(20)),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: new InkWell(
                                          customBorder: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          splashColor: Colors.white38,
                                          onTap: () {
                                            Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: PantallaPecho(), duration: Duration(milliseconds: 500)));
                                          },
                                          child: Container(
                                            height: 160,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: LinearGradient(
                                                          colors: [
                                                            Color.fromRGBO(
                                                                82, 154, 186, 1),
                                                            Color.fromRGBO(
                                                                70, 145, 172, 1),
                                                            Color.fromRGBO(
                                                                69, 139, 171, 1),
                                                            Color.fromRGBO(
                                                                62, 129, 152, 1),
                                                            Color.fromRGBO(
                                                                60, 119, 144, 1),
                                                            Color.fromRGBO(
                                                                51, 107, 127, 1),
                                                          ],
                                                          begin: Alignment.topLeft, 
                                                          end: Alignment.bottomRight
                                                      )
                                                  ),
                                                  child: CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor: Colors.transparent,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(15.0),
                                                      child: Container(
                                                        child: Image.asset('assets/icons_ejercicios/pecho.png'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text('Pecho',
                                                    style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                            fontStyle:
                                                                FontStyle.normal,
                                                            fontSize: 17.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Colors.white)))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                    
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: (_isOscuro)
                                              ? Color.fromRGBO(255, 255, 255, 0.5)
                                              : Color.fromRGBO(48, 48, 48, 0.75),
                                          borderRadius: BorderRadius.circular(20)),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: new InkWell(
                                          customBorder: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          splashColor: Colors.white38,
                                          onTap: () {
                                            Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: PantallaHombro(), duration: Duration(milliseconds: 500)));
                                          },
                                          child: Container(
                                            height: 160,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: LinearGradient(
                                                          colors: [
                                                            Color.fromRGBO(
                                                                82, 154, 186, 1),
                                                            Color.fromRGBO(
                                                                70, 145, 172, 1),
                                                            Color.fromRGBO(
                                                                69, 139, 171, 1),
                                                            Color.fromRGBO(
                                                                62, 129, 152, 1),
                                                            Color.fromRGBO(
                                                                60, 119, 144, 1),
                                                            Color.fromRGBO(
                                                                51, 107, 127, 1),
                                                          ],
                                                          begin: Alignment.topLeft, 
                                                          end: Alignment.bottomRight
                                                      )
                                                  ),
                                                  child: CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor: Colors.transparent,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(15.0),
                                                      child: Container(
                                                        child: Image.asset('assets/icons_ejercicios/hombros.png'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text('Hombro',
                                                    style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                            fontStyle:
                                                                FontStyle.normal,
                                                            fontSize: 17.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Colors.white)))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              
                            ]),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          } else {
            return Container(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
