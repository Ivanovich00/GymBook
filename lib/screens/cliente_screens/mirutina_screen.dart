import 'dart:io';

import 'package:GymBook/screens/screens.dart';
import 'package:GymBook/services/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';


String? userdoc;
bool _isConnectedBool = true;

bool _isView = false;
bool _isView2 = false;
String? e_uid;
String? e_uid2;
String pantalla = 'usuarios';

bool _tiene = false;

bool _isPreview = false;

class PantallaRutina extends StatefulWidget {
  const PantallaRutina({Key? key}) : super(key: key);
  @override
  State<PantallaRutina> createState() => _PantallaRutinaState();
}

class _PantallaRutinaState extends State<PantallaRutina> {
  final db = FirebaseFirestore.instance;

  bool _isOscuro = false;

  @override
  void initState() {
    super.initState();
    _initGetDetails();
  }

  Future<void> _isConnected() async {
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

    try {
      final result = await InternetAddress.lookup('example.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _isConnectedBool = true;
      }
    } catch (_) {
      _isConnectedBool = false;
    }
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

    try {
      final result = await InternetAddress.lookup('example.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FirebaseFirestore.instance
            .collection("clientes")
            .doc(userdoc)
            .snapshots()
            .listen((event) {
          setState(() {});
        });
      }

      await FirebaseFirestore.instance.collection('rutinas').doc(userdoc).collection('ejercicios').get().then((value) {
        if(value.docs.length == 0){
          _tiene = false;
        } else {
          _tiene = true;
        }
      }).then((value){
        setState(() {});
      });

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

    return FutureBuilder(
        future: authService.readTheme(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('');
          }

          if (snapshot.data != '') {
            return SafeArea(
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Scaffold(
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
                                    child: ClienteScreen(),
                                    duration: Duration(milliseconds: 250)));
                          }),
                      backgroundColor: Color.fromRGBO(72, 83, 98, 1),
                      elevation: 0,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Text('RUTINA',
                                style: TextStyle(
                                  color: Colors.white,
                                )),
                          ),
                        ],
                      ),
                      actions: [
                        if (_tiene) Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 20, 5),
                          child: Tooltip(
                              message: 'Terminar rutina',
                              child: SizedBox(
                                width: 125,
                                height: 35,
                                child: TextButton(
                                  child: Text('FINALIZAR RUTINA', textAlign: TextAlign.center,),
                                  style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.red[700],
                                    onSurface: Colors.grey,
                                  ),
                                  onPressed: () {
                                    Get.defaultDialog(
                                          title: 'TERMINAR RUTINA',
                                          titlePadding: EdgeInsets.all(15),
                                          titleStyle: TextStyle(
                                              fontStyle: FontStyle.normal,
                                              fontSize: 19.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                          content: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 25.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                    '¿Estas seguro de terminar tu rutina?',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                            fontStyle:
                                                                FontStyle.normal,
                                                            fontSize: 17.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Colors.black)))
                                              ],
                                            ),
                                          ),
                                          barrierDismissible: false,
                                          radius: 15.0,
                                          confirm: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextButton(
                                              style: ButtonStyle(
                                                  foregroundColor:
                                                      MaterialStateProperty.all<Color>(
                                                          Colors.white),
                                                  backgroundColor:
                                                      MaterialStateProperty.all<Color>(
                                                          Colors.red),
                                                  shape: MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(
                                                              15.0),
                                                          side: BorderSide(
                                                              color: Colors.red)))),
                                              child: Text("SI"),
                                              onPressed: () async {
                                                pantalla = 'eliminar';

                                                Navigator.of(context).pop();

                                                FirebaseFirestore.instance
                                                    .collection('clientes')
                                                    .doc(userdoc)
                                                    .update({
                                                  "rutina": false,
                                                });

                                                FirebaseFirestore.instance
                                                    .collection('rutinas')
                                                    .doc(userdoc)
                                                    .collection('ejercicios')
                                                    .get()
                                                    .then((snapshot) {
                                                  for (DocumentSnapshot ds
                                                      in snapshot.docs) {
                                                    ds.reference.delete();
                                                  }
                                                  ;
                                                }).then((value) {
                                                  FirebaseFirestore.instance
                                                      .collection('rutinas')
                                                      .doc(userdoc)
                                                      .delete();
                                                });

                                                _tiene = false;

                                                setState(() {});
                                              },
                                            ),
                                          ),
                                          cancel: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextButton(
                                            style: ButtonStyle(
                                                foregroundColor:
                                                    MaterialStateProperty.all<Color>(
                                                        Colors.black),
                                                backgroundColor:
                                                    MaterialStateProperty.all<Color>(
                                                        Colors.white),
                                                shape: MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(
                                                            15.0),
                                                        side: BorderSide(
                                                            color: Colors.black)))),
                                            child: Text("NO"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ),
                                    );
                                  }
                                ),
                              )
                          ),
                        ),
                      ],
                    ),
                    body: Container(
                      color: (_isOscuro)
                          ? Color.fromRGBO(49, 49, 49, 1)
                          : Colors.white,
                      child: Center(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: db
                                .collection('rutinas')
                                .doc(userdoc)
                                .collection('ejercicios')
                                .orderBy('timestamp', descending: false)
                                .snapshots(),
                            builder: (context, snapshot) {
                              _isConnected();

                              if (_isConnectedBool == true) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else {
                                  if (!snapshot.data!.docs.isEmpty) {
                                    return new Column(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            color: (_isOscuro)
                                                ? Color.fromRGBO(31, 31, 31, 1)
                                                : Colors.white,
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
                                                      if (e_uid == '') {
                                                        e_uid = doc.id;
                                                        _isView = true;
                                                      } else if (e_uid == doc.id &&
                                                          _isView != false) {
                                                        e_uid = doc.id;
                                                        _isView = false;
                                                      } else {
                                                        e_uid = doc.id;
                                                        _isView = true;
                                                      }

                                                      setState(() {});
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.fromLTRB(
                                                          15, 5, 15, 5),
                                                      decoration: BoxDecoration(
                                                        color: (_isOscuro)
                                                            ? Colors.white
                                                            : Color.fromARGB(255, 212, 212, 212),
                                                        borderRadius:
                                                            BorderRadius.all(Radius.circular(15)),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Column(
                                                            children: [
                                                              AnimatedContainer(
                                                                curve: Curves.fastLinearToSlowEaseIn,
                                                                width:
                                                                    double.infinity,
                                                                height: (_isView && e_uid == doc.id)
                                                                    ? 200
                                                                    : 125,
                                                                duration: Duration(milliseconds:500),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors.transparent,
                                                                  borderRadius:
                                                                      BorderRadius.only(
                                                                    topLeft: Radius.circular(15),
                                                                    topRight: Radius.circular(15),
                                                                  ),
                                                                ),
                                                                child: Padding(
                                                                  padding: (_isView && e_uid == doc.id)
                                                                      ? EdgeInsets.all(8.0)
                                                                      : EdgeInsetsDirectional.fromSTEB(8, 8, 8, 0),
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    physics: (_isView && e_uid == doc.id)
                                                                        ? BouncingScrollPhysics()
                                                                        : NeverScrollableScrollPhysics(),
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Card(
                                                                              shape:
                                                                                  RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                    BorderRadius.circular(15.0),
                                                                              ),
                                                                              elevation: 2.5,
                                                                              child:
                                                                                  GestureDetector(
                                                                                    onLongPress: () {
                                                                                      setState(() {
                                                                                        _isPreview = true;
                                                                                        imagenURL = doc['imagenURL'];
                                                                                      });
                                                                                    },
                                                                                    onLongPressEnd: (details) {
                                                                                      setState(() {
                                                                                        _isPreview = false;
                                                                                      });
                                                                                    },
                                                                                    child: Container(
                                                                                                                                                                  width: 100,
                                                                                                                                                                  height: 100,
                                                                                                                                                                  decoration:
                                                                                      BoxDecoration(
                                                                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                                    image: DecorationImage(
                                                                                      image: AssetImage('assets/images/picture_default.png'),
                                                                                      fit: BoxFit.fill,
                                                                                    ),
                                                                                                                                                                  ),
                                                                                                                                                                  child:
                                                                                      CachedNetworkImage(
                                                                                    imageUrl: doc['imagenURL'],
                                                                                    imageBuilder: (context, imageProvider) => Container(
                                                                                      width: 100,
                                                                                      height: 100,
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                                        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                                      ),
                                                                                    ),
                                                                                    placeholder: (context, url) => Center(child: Container(width: 100, height: 100, child: CircularProgressIndicator(color: Colors.white))),
                                                                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                                                                                                                                                  ),
                                                                                                                                                                ),
                                                                                  ),
                                                                            ),
                                                                            SizedBox(
                                                                                width:
                                                                                    10),
                                                                            Container(
                                                                              width:
                                                                                  width - 175,
                                                                              child: Text(
                                                                                  doc['nombre'].toString().toUpperCase(),
                                                                                  textAlign: TextAlign.center,
                                                                                  maxLines: 3,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: GoogleFonts.poppins(fontSize: 20, color: Color.fromRGBO(49, 49, 49, 1), fontWeight: FontWeight.normal)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                10),
                                                                        Container(
                                                                          alignment:
                                                                              Alignment
                                                                                  .center,
                                                                          width:
                                                                              width,
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child: Text(
                                                                                doc[
                                                                                    'descripcion'],
                                                                                textAlign: TextAlign
                                                                                    .justify,
                                                                                style: GoogleFonts.poppins(
                                                                                    fontSize: 16,
                                                                                    color: Color.fromRGBO(49, 49, 49, 1),
                                                                                    fontWeight: FontWeight.normal)),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .transparent,
                                                                  ),
                                                                  width: double
                                                                      .infinity,
                                                                  height: 120,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Table(
                                                                        children: [
                                                                          TableRow(
                                                                              children: [
                                                                                Text('No. de\nSeries',
                                                                                    textAlign: TextAlign.center,
                                                                                    style: GoogleFonts.poppins(fontSize: 16, color: Color.fromRGBO(49, 49, 49, 1), fontWeight: FontWeight.normal)),
                                                                                Text('No. de\nReps',
                                                                                    textAlign: TextAlign.center,
                                                                                    style: GoogleFonts.poppins(fontSize: 16, color: Color.fromRGBO(49, 49, 49, 1), fontWeight: FontWeight.normal)),
                                                                                if (doc['tiempo'] !=
                                                                                    '')
                                                                                  if (doc['tiempo'] != '0')
                                                                                    Text('Tiempo en\nsegs', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, color: Color.fromRGBO(49, 49, 49, 1), fontWeight: FontWeight.normal)),
                                                                                if (doc['peso'] !=
                                                                                    '')
                                                                                  if (doc['peso'] != '0')
                                                                                    Text('Peso en\nlbs', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, color: Color.fromRGBO(49, 49, 49, 1), fontWeight: FontWeight.normal)),
                                                                              ]),
                                                                          TableRow(
                                                                              children: [
                                                                                SizedBox(height: 5),
                                                                                SizedBox(height: 5),
                                                                                if (doc['tiempo'] !=
                                                                                    '')
                                                                                  if (doc['tiempo'] != '0')
                                                                                    SizedBox(height: 5),
                                                                                if (doc['peso'] !=
                                                                                    '')
                                                                                  if (doc['peso'] != '0')
                                                                                    SizedBox(height: 5),
                                                                              ]),
                                                                          TableRow(
                                                                              children: [
                                                                                Center(
                                                                                  child: Container(
                                                                                    width: 50,
                                                                                    height: 50,
                                                                                    decoration: BoxDecoration(
                                                                                      color: Color.fromRGBO(1, 29, 69, 1),
                                                                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                                    ),
                                                                                    child: Align(
                                                                                      alignment: Alignment.center,
                                                                                      child: Text(doc['series'], textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Center(
                                                                                  child: Container(
                                                                                    width: 50,
                                                                                    height: 50,
                                                                                    decoration: BoxDecoration(
                                                                                      color: Color.fromRGBO(1, 29, 69, 1),
                                                                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                                    ),
                                                                                    child: Align(
                                                                                      alignment: Alignment.center,
                                                                                      child: Text(doc['repeticiones'], textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                if (doc['tiempo'] !=
                                                                                    '')
                                                                                  if (doc['tiempo'] != '0')
                                                                                    Center(
                                                                                      child: Container(
                                                                                        width: 50,
                                                                                        height: 50,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Color.fromRGBO(1, 29, 69, 1),
                                                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                                        ),
                                                                                        child: Align(
                                                                                          alignment: Alignment.center,
                                                                                          child: Text(doc['tiempo'], textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                if (doc['peso'] !=
                                                                                    '')
                                                                                  if (doc['peso'] != '0')
                                                                                    Center(
                                                                                      child: Container(
                                                                                        width: 50,
                                                                                        height: 50,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Color.fromRGBO(1, 29, 69, 1),
                                                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                                        ),
                                                                                        child: Align(
                                                                                          alignment: Alignment.center,
                                                                                          child: Text(doc['peso'], textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                              ]),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  )),
                                                              (doc['observaciones'] !=
                                                                      '')
                                                                  ? SingleChildScrollView(
                                                                      physics:
                                                                          NeverScrollableScrollPhysics(),
                                                                      child: Stack(
                                                                        alignment:
                                                                            AlignmentDirectional
                                                                                .topCenter,
                                                                        children: [
                                                                          Column(
                                                                            children: [
                                                                              SizedBox(height: 5),
                                                                              Text(
                                                                                  'Observaciones:',
                                                                                  textAlign: TextAlign.center,
                                                                                  style: GoogleFonts.poppins(fontSize: 18, color: Color.fromRGBO(41, 41, 41, 1), fontWeight: FontWeight.w600)),
                                                                              Container(
                                                                                  decoration: BoxDecoration(
                                                                                color: Color.fromRGBO(44, 181, 110, 1),
                                                                                borderRadius: new BorderRadius.only(
                                                                                  bottomLeft: const Radius.circular(15.0),
                                                                                  bottomRight: const Radius.circular(15.0),
                                                                                )),
                                                                                  width: width + 35,
                                                                                  height: 30,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 7.5),
                                                                                    child: Marquee(
                                                                              text: doc['observaciones'],
                                                                              style: TextStyle(color: Color.fromRGBO(41, 41, 41, 1), fontWeight: FontWeight.w300, fontSize: 16),
                                                                              scrollAxis: Axis.horizontal,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              blankSpace: 40.0,
                                                                              velocity: 50.0,
                                                                              pauseAfterRound: Duration(seconds: 0),
                                                                              startPadding: 50.0,
                                                                              accelerationDuration: Duration(seconds: 0),
                                                                              accelerationCurve: Curves.linear,
                                                                              decelerationDuration: Duration(milliseconds: 0),
                                                                              decelerationCurve: Curves.linear,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : Container(),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
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
                                            Icon(Icons.fitness_center_outlined,
                                                color: Colors.orange[700],
                                                size: 120),
                                            SizedBox(height: 15),
                                            Text('No existen ejercicios',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 20,
                                                    color: (_isOscuro)
                                                        ? Colors.white
                                                        : Color.fromRGBO(
                                                            49, 49, 49, 1),
                                                    fontWeight: FontWeight.normal)),
                                            SizedBox(height: 5),
                                            Text('registrados en tu rutina',
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
                      ),
                    ),
                  ),
                  if (_isPreview) Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 300,
                          maxWidth: 300,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: imagenURL,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                          placeholder: (context, url) => Center(child: Container(width: 100, height: 100, child: CircularProgressIndicator(color: Colors.white))),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return SafeArea(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            );
          }
        });
  }
}
