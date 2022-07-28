import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:GymBook/screens/cliente_screens/export_screens.dart';
import 'package:GymBook/screens/cliente_screens/help.dart';
import 'package:GymBook/screens/cliente_screens/widget_cliente/tarjetas_paginas.dart';
import 'package:GymBook/services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:GymBook/screens/screens.dart';

String? userdoc_cliente;

bool _isNewNotification = false;
bool _isNotificationScreen = false;

bool _isOscuro = false;
bool _isConnectedBool = true;
bool _isIntro = false;
bool _isDialog = false;

String? nombreControl_cliente, apellidoControl_cliente, emailControl_cliente;

final DateFormat formatter = DateFormat('dd-MM-yyyy');

class ClienteScreen extends StatefulWidget {
  @override
  State<ClienteScreen> createState() => _ClienteScreenState();
}

class _ClienteScreenState extends State<ClienteScreen> {
  @override
  void initState() {
    super.initState();
    _initGetDetails();
  }

  Future<void> _initGetDetails() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    User? user = _firebaseAuth.currentUser;

    userdoc_cliente = user!.uid;

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
            .doc(userdoc_cliente)
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
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final authService = Provider.of<AuthService>(context, listen: false);

    final db = FirebaseFirestore.instance;

    return SafeArea(
      child: Material(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              child: (!_isNotificationScreen)
                    ? Scaffold(
                        appBar: AppBar(
                          leading: Center(
                            child: Image.asset(
                              'assets/app_icon_transparent.png',
                              fit: BoxFit.fill,
                              width: 40,
                              height: 40,
                            ),
                          ),
                          centerTitle: true,
                          backgroundColor: Color.fromRGBO(72, 83, 98, 1),
                          actions: <Widget>[
                            Tooltip(
                              message: 'Notificaciones',
                              child: IconButton(
                                icon: Stack(
                                  children: [
                                    Icon(
                                      Icons.notifications,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    if (_isNewNotification)
                                      Positioned(
                                          top: 5,
                                          right: 5,
                                          child: Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          )),
                                  ],
                                ),
                                onPressed: () async {
                                  _isNotificationScreen = true;
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
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
                            //Background(),
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
                                          Icon(Icons.help,
                                              size: 25, color: Colors.white),
                                        ]),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Scaffold(
                        appBar: AppBar(
                          leading: IconButton(
                              splashRadius: 25,
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _isNotificationScreen = false;
                                _initGetDetails();
                                setState(() {});
                              }),
                          centerTitle: false,
                          backgroundColor: Color.fromRGBO(72, 83, 98, 1),
                          title: Text("Notificaciones",
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontStyle: FontStyle.normal,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white))),
                          actions: [
                            Tooltip(
                              message: "Eliminar todo",
                              child: IconButton(
                                  splashRadius: 25,
                                  icon: Icon(
                                    Icons.delete_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('notificaciones')
                                        .doc(userdoc_cliente)
                                        .collection('nuevas')
                                        .get()
                                        .then((snapshot) {
                                      for (DocumentSnapshot ds in snapshot.docs) {
                                        ds.reference.delete();
                                      }
                                      ;
                                    }).then((value) {
                                      FirebaseFirestore.instance
                                          .collection('notificaciones')
                                          .doc(userdoc_cliente)
                                          .delete();
      
                                      setState(() {});
                                    });
      
                                    setState(() {});
                                  }),
                            ),
                          ],
                        ),
                        body: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Container(
                              width: width,
                              height: height,
                              color: (_isOscuro)
                                  ? Color.fromRGBO(31, 31, 31, 1)
                                  : Colors.white,
                            ),
                            Container(
                              width: 250,
                              height: 250,
                              child: ClipOval(
                                child: Image.asset('assets/splash_icon.png'),
                              ),
                            ),
                            StreamBuilder<QuerySnapshot>(
                                stream: db
                                    .collection('notificaciones')
                                    .doc(userdoc_cliente)
                                    .collection('nuevas')
                                    .orderBy('timestamp', descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (_isConnectedBool == true) {
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else {
                                      if (!snapshot.data!.docs.isEmpty) {
                                        return Column(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                color: Colors.transparent,
                                                child: Scrollbar(
                                                  thickness: 10,
                                                  radius: Radius.circular(10),
                                                  child: ListView(
                                                    shrinkWrap: true,
                                                    scrollDirection: Axis.vertical,
                                                    children:
                                                        snapshot.data!.docs.map((doc) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          setState(() {});
                                                        },
                                                        child: Column(
                                                          children: [
                                                            Stack(
                                                              children: [
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .fromLTRB(15, 15,
                                                                          15, 0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: (_isOscuro)
                                                                        ? Colors.white
                                                                        : Color
                                                                            .fromRGBO(
                                                                                31,
                                                                                31,
                                                                                31,
                                                                                1),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(15),
                                                                      topRight: Radius
                                                                          .circular(15),
                                                                      bottomLeft: Radius
                                                                          .circular(15),
                                                                      bottomRight:
                                                                          Radius
                                                                              .circular(
                                                                                  0),
                                                                    ),
                                                                  ),
                                                                  child: Container(
                                                                    padding: EdgeInsets
                                                                        .symmetric(
                                                                            horizontal:
                                                                                15,
                                                                            vertical:
                                                                                10),
                                                                    width: width,
                                                                    height: 85,
                                                                    color: Colors
                                                                        .transparent,
                                                                    child: Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Text(
                                                                                doc[
                                                                                    'titulo'],
                                                                                style: GoogleFonts.poppins(
                                                                                    fontSize:
                                                                                        18,
                                                                                    color: (_isOscuro)
                                                                                        ? Color.fromRGBO(49, 49, 49, 1)
                                                                                        : Colors.white,
                                                                                    fontWeight: FontWeight.w500)),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Text(
                                                                                doc[
                                                                                    'cuerpo'],
                                                                                style: GoogleFonts.poppins(
                                                                                    fontSize:
                                                                                        15,
                                                                                    color: (_isOscuro)
                                                                                        ? Color.fromRGBO(49, 49, 49, 1)
                                                                                        : Colors.white,
                                                                                    fontWeight: FontWeight.w300)),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  top: 25,
                                                                  right: 25,
                                                                  child: Tooltip(
                                                                      message:
                                                                          'Eliminar notificacion',
                                                                      child: SizedBox
                                                                          .fromSize(
                                                                        size: Size(
                                                                            25, 25),
                                                                        child: ClipOval(
                                                                          child:
                                                                              Material(
                                                                            color: Colors
                                                                                    .red[
                                                                                700], // button color
                                                                            child:
                                                                                InkWell(
                                                                              splashColor:
                                                                                  Colors
                                                                                      .white, // splash color
                                                                              onTap:
                                                                                  () async {
                                                                                FirebaseFirestore
                                                                                    .instance
                                                                                    .collection('notificaciones')
                                                                                    .doc(userdoc_cliente)
                                                                                    .collection('nuevas')
                                                                                    .doc(doc.id)
                                                                                    .delete();
      
                                                                                setState(
                                                                                    () {});
                                                                              }, // button pressed
                                                                              child:
                                                                                  Align(
                                                                                alignment:
                                                                                    Alignment.center,
                                                                                child: Icon(
                                                                                    Icons
                                                                                        .close_rounded,
                                                                                    color:
                                                                                        Colors.white,
                                                                                    size: 18.5),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )),
                                                                ),
                                                              ],
                                                            ),
                                                            Container(
                                                              margin:
                                                                  EdgeInsets.fromLTRB(
                                                                      15, 0, 15, 0),
                                                              width: width,
                                                              height: 30,
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Container(),
                                                                  ),
                                                                  Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: (_isOscuro)
                                                                          ? Colors.white
                                                                          : Color
                                                                              .fromRGBO(
                                                                                  49,
                                                                                  49,
                                                                                  49,
                                                                                  1),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                        topLeft: Radius
                                                                            .circular(
                                                                                0),
                                                                        topRight: Radius
                                                                            .circular(
                                                                                0),
                                                                        bottomLeft: Radius
                                                                            .circular(
                                                                                10),
                                                                        bottomRight:
                                                                            Radius
                                                                                .circular(
                                                                                    10),
                                                                      ),
                                                                    ),
                                                                    width: 200,
                                                                    height: 50,
                                                                    child: Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                            formatter.format(doc['timestamp']
                                                                                    .toDate()) +
                                                                                ' - ' +
                                                                                DateFormat.jm().format(doc['timestamp']
                                                                                    .toDate()),
                                                                            textAlign:
                                                                                TextAlign
                                                                                    .center,
                                                                            style: GoogleFonts.poppins(
                                                                                fontSize:
                                                                                    14,
                                                                                color: (_isOscuro)
                                                                                    ? Color.fromRGBO(
                                                                                        49,
                                                                                        49,
                                                                                        49,
                                                                                        1)
                                                                                    : Colors
                                                                                        .white,
                                                                                fontWeight:
                                                                                    FontWeight.w400)),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return Container(
                                          color: (_isOscuro)
                                              ? Color.fromRGBO(49, 49, 49, 1)
                                              : Colors.white,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(Icons.notifications_off_rounded,
                                                    color: Colors.orange[700],
                                                    size: 120),
                                                SizedBox(height: 15),
                                                Text('No tienes nuevas',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 20,
                                                        color: (_isOscuro)
                                                            ? Colors.white
                                                            : Color.fromRGBO(
                                                                49, 49, 49, 1),
                                                        fontWeight: FontWeight.normal)),
                                                SizedBox(height: 5),
                                                Text('notificaciones',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 20,
                                                        color: (_isOscuro)
                                                            ? Colors.white
                                                            : Color.fromRGBO(
                                                                49, 49, 49, 1),
                                                        fontWeight: FontWeight.normal)),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    return Container(
                                      color: (_isOscuro)
                                          ? Color.fromRGBO(49, 49, 49, 1)
                                          : Colors.white,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.warning_rounded,
                                                color: Colors.red[900], size: 120),
                                            SizedBox(height: 15),
                                            Text('No se ha podido establecer',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 20,
                                                    color: (_isOscuro)
                                                        ? Colors.white
                                                        : Color.fromRGBO(49, 49, 49, 1),
                                                    fontWeight: FontWeight.normal)),
                                            SizedBox(height: 5),
                                            Text('conexión con el servidor',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 20,
                                                    color: (_isOscuro)
                                                        ? Colors.white
                                                        : Color.fromRGBO(49, 49, 49, 1),
                                                    fontWeight: FontWeight.normal)),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                }),
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
                                .collection("clientes")
                                .doc(userdoc_cliente)
                                .snapshots()
                                .listen((event) {
                              nombreControl_cliente = event.get('nombre').toString();
                              apellidoControl_cliente =
                                  event.get('apellido').toString();
                              emailControl_cliente = event.get('email').toString();
      
                              setState(() {});
      
                              Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.fade,
                                      child: PantallaHelpCliente(
                                          nombreControl_cliente:
                                              nombreControl_cliente,
                                          apellidoControl_cliente:
                                              apellidoControl_cliente,
                                          emailControl_cliente: emailControl_cliente),
                                      duration: Duration(milliseconds: 250)));
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
        children: [
          TarjetasOpciones(),
        ],
      ),
    );
  }
}
