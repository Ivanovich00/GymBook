import 'dart:io';
import 'dart:ui';

import 'package:GymBook/helpers/showLoading.dart';
import 'package:GymBook/screens/entrenador_screens/usuarios_screen.dart';
import 'package:GymBook/services/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:page_transition/page_transition.dart';

class PantallaVerRutinas extends StatefulWidget {
  final String? uid, nombre, imagenURL;
  const PantallaVerRutinas({Key? key, required this.uid, this.nombre, this.imagenURL}) : super(key: key);
  @override
  State<PantallaVerRutinas> createState() => _PantallaVerRutinasState();
}

final db = FirebaseFirestore.instance;

bool _isOscuro = false;
bool _isConnectedBool = false;

String ua_micuenta = "";

String? userdoc, tipo, e_uid, e_uid2;
String? nombre_e, descripcion_e, imagenURL_e, uid_e;

bool _isPreview = false;

bool _isSelected = false;

class _PantallaVerRutinasState extends State<PantallaVerRutinas>{
  @override
  void initState() {
    super.initState();
    _initGetDetails();
    _isConnected();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initGetDetails() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    User? user = _firebaseAuth.currentUser;

    userdoc = user!.uid;

    final authService = Provider.of<AuthService>(context, listen: false);
    tipo = await authService.readUserInfo();
    final valor_isOscuro = await authService.readTheme();

    if (valor_isOscuro == 'OSCURO') {
      _isOscuro = true;
    } else {
      _isOscuro = false;
    }

    setState(() {});
  }

  Future<void> _isConnected() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    User? user = _firebaseAuth.currentUser;

    userdoc = user!.uid;

    await FirebaseFirestore.instance
        .collection('entrenadores')
        .doc(userdoc)
        .get()
        .then((value) {
      ua_micuenta = value['nombre'];
    });

    try {
      final result = await InternetAddress.lookup('example.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _isConnectedBool = true;
      }
    } catch (_) {
      _isConnectedBool = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return FutureBuilder(
      future: authService.readTheme(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SafeArea(
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Scaffold(
                      appBar: AppBar(
                        centerTitle: true,
                        leading: Tooltip(
                          message: "Regresar al listado de usuarios",
                          child: IconButton(
                              splashRadius: 25,
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRight, child: PantallaUsuarios(), duration: Duration(milliseconds: 250)));

                                setState(() {});
                              }),
                        ),
                        backgroundColor: Color.fromRGBO(72, 83, 98, 1),
                        elevation: 0,
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Text('RUTINA DE ' + nombre!.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16
                                  )),
                            ),
                          ],
                        ),
                      ),
                      body: Container(
                        color: (_isOscuro)
                          ? Color.fromRGBO(49, 49, 49, 1)
                          : Colors.white,
                        child: Center(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: db.collection('rutinas').doc(uid!).collection('ejercicios').orderBy('timestamp', descending: false).snapshots(),
                            builder: (context, snapshot) {
                              _isConnected();

                                if (!snapshot.hasData) {
                                  return Container(
                                    color: (_isOscuro)
                                      ? Color.fromRGBO(31, 31, 31, 1)
                                      : Colors.white,
                                    child: Center(
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        child: CircularProgressIndicator(
                                          color: (_isOscuro)
                                            ? Colors.white
                                            : Color.fromRGBO(1, 29, 69, 1)
                                        )
                                      )
                                    )
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
                                            child: ListView(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              children: snapshot.data!.docs.map((doc) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    if(e_uid == ''){
                                                      e_uid = doc.id;
                                                      _isSelected = true;
                                                    } else if(e_uid == doc.id && _isSelected != false){
                                                      e_uid = doc.id;
                                                      _isSelected = false;
                                                    } else {
                                                      e_uid = doc.id;
                                                      _isSelected = true;
                                                    }

                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                  margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
                                                  decoration: BoxDecoration(
                                                    color: (_isOscuro) ? Colors.white : Color.fromARGB(255, 207, 207, 207),
                                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Column(
                                                        children: [
                                                          AnimatedContainer(
                                                            curve: Curves.fastLinearToSlowEaseIn,
                                                            width: double.infinity,
                                                            height: (_isSelected && e_uid == doc.id) ? 200 : 125,
                                                            duration: Duration(milliseconds: 500),
                                                            decoration: BoxDecoration(
                                                              color: Colors.transparent,
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(15),
                                                                topRight: Radius.circular(15),
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding: (_isSelected && e_uid == doc.id) ? EdgeInsets.all(8.0) : EdgeInsetsDirectional.fromSTEB(8, 8, 8, 0),
                                                              child: SingleChildScrollView(
                                                                physics: (_isSelected && e_uid == doc.id) ? BouncingScrollPhysics() : NeverScrollableScrollPhysics(),
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Card(
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(15.0),
                                                                          ),
                                                                          elevation: 2.5,
                                                                          child: GestureDetector(
                                                                            onLongPress: () {
                                                                              setState(() {
                                                                                _isPreview = true;
                                                                                imagenURL_e = doc['imagenURL'];
                                                                              });
                                                                            },
                                                                            onLongPressEnd: (details) {
                                                                              setState(() {
                                                                                _isPreview = false;
                                                                                imagenURL_e = "";
                                                                              });
                                                                            },
                                                                            child: Container(
                                                                              width: 100,
                                                                              height: 100,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                                image: DecorationImage(
                                                                                  image: AssetImage('assets/images/picture_default.png'),
                                                                                  fit: BoxFit.fill,
                                                                                ),
                                                                              ),
                                                                            child: CachedNetworkImage(
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
                                                                      SizedBox(width: 10),
                                                                      Container(
                                                                        width: width - 175,
                                                                        child: Text(
                                                                          doc['nombre'].toString().toUpperCase(),
                                                                          textAlign: TextAlign.center,
                                                                          maxLines: 3,
                                                                          overflow: TextOverflow.ellipsis,
                                                                          style: GoogleFonts.poppins(
                                                                            fontSize: 20,
                                                                            color: Color.fromRGBO(49, 49, 49, 1),
                                                                            fontWeight: FontWeight.normal
                                                                          )
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: 10),
                                                                  Container(
                                                                    alignment: Alignment.center,
                                                                    width: width,
                                                                    child: Align(
                                                                      alignment: Alignment.center,
                                                                      child: Text(
                                                                        doc['descripcion'],
                                                                        textAlign: TextAlign.justify,
                                                                        style: GoogleFonts.poppins(
                                                                          fontSize: 16,
                                                                          color: Color.fromRGBO(49, 49, 49, 1),
                                                                          fontWeight: FontWeight.normal
                                                                        )
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color: Colors.transparent,
                                                          ),
                                                          width: double.infinity,
                                                          height: 120,
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              
                                                              Table(
                                                                children: [
                                                                  TableRow(
                                                                    children: [
                                                                      Text(
                                                                        'No.\n de Series',
                                                                        textAlign: TextAlign.center,
                                                                        style: GoogleFonts.poppins(
                                                                          fontSize: 16,
                                                                          color: Color.fromRGBO(49, 49, 49, 1),
                                                                          fontWeight: FontWeight.normal
                                                                        )
                                                                      ),
                                                                      Text(
                                                                        'No. de\nReps',
                                                                        textAlign: TextAlign.center,
                                                                        style: GoogleFonts.poppins(
                                                                          fontSize: 16,
                                                                          color: Color.fromRGBO(49, 49, 49, 1),
                                                                          fontWeight: FontWeight.normal
                                                                        )
                                                                      ),
                                                                      if (doc['tiempo'] != '')
                                                                      if (doc['tiempo'] != '0') Text(
                                                                        'Tiempo en\nsegs',
                                                                        textAlign: TextAlign.center,
                                                                        style: GoogleFonts.poppins(
                                                                          fontSize: 16,
                                                                          color: Color.fromRGBO(49, 49, 49, 1),
                                                                          fontWeight: FontWeight.normal
                                                                        )
                                                                      ),
                                                                      if (doc['peso'] != '') if (doc['peso'] != '0') Text(
                                                                        'Peso en\nlbs',
                                                                        textAlign: TextAlign.center,
                                                                        style: GoogleFonts.poppins(
                                                                          fontSize: 16,
                                                                          color: Color.fromRGBO(49, 49, 49, 1),
                                                                          fontWeight: FontWeight.normal
                                                                        )
                                                                      ),
                                                                    ]),
                                                                  TableRow(
                                                                    children: [
                                                                      SizedBox(height: 5),
                                                                      SizedBox(height: 5),
                                                                      if (doc['tiempo'] != '') if (doc['tiempo'] != '0') SizedBox(height: 5),
                                                                      if (doc['peso'] != '') if (doc['peso'] != '0') SizedBox(height: 5),
                                                                    ]
                                                                  ),
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
                                                                            child: Text(
                                                                              doc['series'],
                                                                              textAlign: TextAlign.center,
                                                                              style: GoogleFonts.poppins(
                                                                                fontSize: 20,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold
                                                                              )
                                                                            ),
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
                                                                              child: Text(
                                                                                doc['repeticiones'],
                                                                                textAlign: TextAlign.center,
                                                                                style: GoogleFonts.poppins(
                                                                                  fontSize: 20,
                                                                                  color: Colors.white,
                                                                                  fontWeight: FontWeight.bold
                                                                                )
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        if (doc['tiempo'] != '') if (doc['tiempo'] != '0') Center(
                                                                          child: Container(
                                                                            width: 50,
                                                                            height: 50,
                                                                            decoration: BoxDecoration(
                                                                              color: Color.fromRGBO(1, 29, 69, 1),
                                                                              borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                            ),
                                                                            child: Align(
                                                                            alignment: Alignment.center,
                                                                            child: Text(
                                                                              doc['tiempo'],
                                                                              textAlign: TextAlign.center,
                                                                              style: GoogleFonts.poppins(
                                                                                fontSize: 20,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold
                                                                              )
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      if (doc['peso'] != '') if (doc['peso'] != '0') Center(
                                                                        child: Container(
                                                                          width: 50,
                                                                          height: 50,
                                                                          decoration: BoxDecoration(
                                                                            color: Color.fromRGBO(1, 29, 69, 1),
                                                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                          ),
                                                                          child: Align(
                                                                            alignment: Alignment.center,
                                                                            child: Text(
                                                                              doc['peso'],
                                                                              textAlign: TextAlign.center,
                                                                              style: GoogleFonts.poppins(
                                                                                fontSize: 20,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold
                                                                              )
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ]),
                                                                  ],
                                                                ),
                                                              ],
                                                            )
                                                          ),
                                                        
                                                        (doc['observaciones'] != '') ? SingleChildScrollView(
                                                          physics: NeverScrollableScrollPhysics(),
                                                          child: Stack(
                                                            alignment: AlignmentDirectional.topCenter,
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  SizedBox(height: 5),
                                                                  Text('Observaciones:', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 18, color: Color.fromRGBO(41, 41, 41, 1), fontWeight: FontWeight.w600)),
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
                                                    Positioned(
                                                      top: 8,
                                                      right: 8,
                                                      child: Tooltip(
                                                        message: 'Eliminar ejercicio',
                                                        child: SizedBox.fromSize(
                                                          size: Size(25, 25),
                                                          child: ClipOval(
                                                            child: Material(
                                                              color: Colors.red, // button color
                                                              child: InkWell(
                                                                splashColor: Colors.white, // splash color
                                                                onTap: ()  async {
                                                                  FirebaseFirestore.instance.collection('rutinas').doc(uid!).collection('ejercicios').doc(doc.id).delete();
                                                                  e_uid = '';

                                                                  await FirebaseFirestore.instance.collection('rutinas').doc(uid!).collection('ejercicios').get().then((value) {
                                                                    if(value.docs.length == 0){FirebaseFirestore.instance.collection('clientes').doc(uid).update({"rutina": false,});}
                                                                  });
                                                                  setState(() {});

                                                                }, // button pressed
                                                                child: Align(
                                                                  alignment: Alignment.center,
                                                                  child: Icon(Icons.close_rounded, color: Colors.white, size: 18.5),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                            }).toList(),
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
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.fitness_center_outlined,
                                            color: Colors.orange[700],
                                            size: 120),
                                            SizedBox(height: 15),
                                            Text('No existen ejercicios',
                                            style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              color: (_isOscuro) ? Colors.white : Color.fromRGBO(49, 49, 49, 1),
                                              fontWeight: FontWeight.normal)),
                                              SizedBox(height: 5),
                                                Text('registrados en tu rutina',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 20,
                                                    color: (_isOscuro) ? Colors.white : Color.fromRGBO(49, 49, 49, 1),
                                                    fontWeight:FontWeight.normal)),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                }
                                }),
                              ),
                          )
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
                          imageUrl: imagenURL_e!,
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
            )
          );
        } else {
          return Container(
            color: (_isOscuro)
              ? Color.fromRGBO(31, 31, 31, 1)
              : Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.warning_rounded,
                    color: Colors.red[900],
                    size: 120),
                  SizedBox(height: 15),
                  Text(
                    'No se ha podido establecer',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: (_isOscuro)
                          ? Colors.white
                          : Color.fromRGBO(31, 31, 31, 1),
                        fontWeight: FontWeight.normal)),
                  SizedBox(height: 5),
                  Text(
                    'conexión con el servidor',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: (_isOscuro)
                          ? Colors.white
                          : Color.fromRGBO(31, 31, 31, 1),
                        fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          );
        }
      }
    );
  }

  _noInternet() {
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
