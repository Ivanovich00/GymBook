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

class PantallaCrearRutinas extends StatefulWidget {
  final String? uid, nombre, imagenURL;
  const PantallaCrearRutinas({Key? key, required this.uid, this.nombre, this.imagenURL}) : super(key: key);
  @override
  State<PantallaCrearRutinas> createState() => _PantallaCrearRutinasState();
}

final db = FirebaseFirestore.instance;

bool _isOscuro = false;
bool _isConnectedBool = false;

String ua_micuenta = "";

String? userdoc, tipo, e_uid, e_uid2;
String? nombre_e, descripcion_e, imagenURL_e, uid_e;

String _isPantalla = "Ejercicio";
bool _isPreview = false;

bool _isSelected = false;

final TextEditingController _searchAbdomen = new TextEditingController();
final TextEditingController _searchBrazo = new TextEditingController();
final TextEditingController _searchEspalda = new TextEditingController();
final TextEditingController _searchHombro = new TextEditingController();
final TextEditingController _searchPecho = new TextEditingController();
final TextEditingController _searchPierna = new TextEditingController();

final TextEditingController _series = new TextEditingController();
final TextEditingController _repeticiones = new TextEditingController();
final TextEditingController _tiempo = new TextEditingController();
final TextEditingController _peso = new TextEditingController();
final TextEditingController _obs = new TextEditingController();

class _PantallaCrearRutinasState extends State<PantallaCrearRutinas>{
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
            child: (_isPantalla == "Ver")
            ? Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Scaffold(
                      appBar: AppBar(
                        centerTitle: true,
                        leading: Tooltip(
                          message: 'Asignar ejercicios',
                          child: IconButton(
                              splashRadius: 25,
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                e_uid = '';
                                _isPantalla = "Ejercicio";

                                _isSelected = false;

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
            : (_isPantalla == "Ejercicio")
            ? DefaultTabController(
              length: 6,
              child: Scaffold(
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                appBar: AppBar(
                  leading: Tooltip(
                    message: "Regresar al listado de usuarios",
                    child: IconButton(
                      splashRadius: 25,
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _isPantalla = "Ejercicio";
                        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRight, child: PantallaUsuarios(), duration: Duration(milliseconds: 250)));
                        
                        _searchAbdomen.clear();
                        _searchBrazo.clear();
                        _searchEspalda.clear();
                        _searchHombro.clear();
                        _searchPecho.clear();
                        _searchPierna.clear();
                      }),
                  ),
                    actions: [
                      Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Tooltip(
                          message: 'Inspeccionar rutina',
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                splashRadius: 25,
                                  icon: Icon(
                                    Icons.remove_red_eye_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    _isPantalla = "Ver";

                                    _searchAbdomen.clear();
                                    _searchBrazo.clear();
                                    _searchEspalda.clear();
                                    _searchHombro.clear();
                                    _searchPecho.clear();
                                    _searchPierna.clear();

                                    setState(() {});
                                  }),
                            ],
                          ),
                        ),
                      ),
                    ],
                    backgroundColor: Color.fromRGBO(72, 83, 98, 1),
                    elevation: 0,
                    title: Text('AGREGAR EJERCICIOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14
                    )),
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(80.0),
                      child: TabBar(
                        isScrollable: true,
                        onTap: (index) {
                          _isConnected();

                          FocusScope.of(context).unfocus();
                          _searchAbdomen.clear();
                          _searchBrazo.clear();
                          _searchEspalda.clear();
                          _searchHombro.clear();
                          _searchPecho.clear();
                          _searchPierna.clear();

                          setState(() {});
                        },
                        tabs: [
                          Tab(
                            child: Text('Abdomen',
                            style: TextStyle(color: Colors.white, fontSize: 13)),
                            icon: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  child: Image.asset('assets/icons_ejercicios/abdomen.png'),
                                ),
                              ),
                            ),
                          ),
                          Tab(
                            child: Text('Brazo',
                            style: TextStyle(color: Colors.white, fontSize: 13)),
                            icon: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  child: Image.asset('assets/icons_ejercicios/brazo.png'),
                                ),
                              ),
                            ),
                          ), 
                          Tab(
                            child: Text('Espalda',
                            style: TextStyle(color: Colors.white, fontSize: 13)),
                            icon: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  child: Image.asset('assets/icons_ejercicios/espalda.png'),
                                ),
                              ),
                            ),
                          ), 
                          Tab(
                            child: Text('Hombro',
                            style: TextStyle(color: Colors.white, fontSize: 13)),
                            icon: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  child: Image.asset('assets/icons_ejercicios/hombros.png'),
                                ),
                              ),
                            ),
                          ),
                          Tab(
                            child: Text('Pecho',
                            style: TextStyle(color: Colors.white, fontSize: 13)),
                            icon: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  child: Image.asset('assets/icons_ejercicios/pecho.png'),
                                ),
                              ),
                            ),
                          ),
                          Tab(
                            child: Text('Pierna',
                            style: TextStyle(color: Colors.white, fontSize: 13)),
                            icon: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  child: Image.asset('assets/icons_ejercicios/pierna.png'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                    body: TabBarView(
                    children: [
                      Stack( //ABDOMEN
                        children: [
                          Container(
                            width: width,
                            height: height,
                            color: (_isOscuro)
                              ? Color.fromRGBO(31, 31, 31, 1)
                              : Colors.white,
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: db.collection('ejercicios').doc('categorias').collection('abdomen').snapshots(),
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
                                            : Color.fromRGBO(1, 29, 69,1)))));
                                } else {
                                  if (!snapshot.data!.docs.isEmpty) {
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                                          child: TextFormField(
                                            controller: _searchAbdomen,
                                            autocorrect: false,
                                            textAlignVertical: TextAlignVertical.center,
                                            style: TextStyle(color: (!_isOscuro) ? Colors.grey[800] : Colors.white),
                                            onTap: () {
                                              FocusScope.of(context).unfocus();
                                            },
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(10.0),
                                              labelText: "Busca un ejercicio...",
                                              hintText: "Busca un ejercicio...",
                                              labelStyle: TextStyle(color: (!_isOscuro) ? Colors.black : Colors.white),
                                              hintStyle: TextStyle(color: (!_isOscuro) ? Colors.black : Colors.white),
                                              prefixIcon: Icon(Icons.search, color: (!_isOscuro) ? Colors.grey[800] : Colors.white),
                                              suffixIcon: InkWell(
                                                onTap: (){
                                                  _searchAbdomen.text = "";
                                                  FocusScope.of(context).unfocus();
                                                  setState(() {});
                                                },
                                                child: Icon((_searchAbdomen.text != "") ? Icons.close : null, color: (!_isOscuro) ? Colors.grey[800] : Colors.white)
                                              ),
                                              floatingLabelBehavior: FloatingLabelBehavior.never,
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                borderSide: BorderSide(
                                                  style: BorderStyle.solid,
                                                  color: Colors.grey.shade800, width: 0.5
                                                )
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                borderSide: BorderSide(
                                                  style: BorderStyle.solid,
                                                  color: Colors.grey.shade800, width: 0.5
                                                )
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15))),
                                            ),
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(RegExp("[a-zA-Z\u00f1\u00d1]*"))
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            color: (_isOscuro)
                                              ? Color.fromRGBO(31, 31, 31, 1)
                                              : Colors.white,
                                              child: ListView(
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                children: snapshot.data!.docs.map((doc) {
                                                  
                                                  return (doc['nombre'].toString().toLowerCase().contains(_searchAbdomen.text.toLowerCase()) || doc['descripcion'].toString().toLowerCase().contains(_searchAbdomen.text.toLowerCase()))
                                                    ? Padding(
                                                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                            child: Container(
                                                              margin: EdgeInsets.only(bottom: 10.0),
                                                              width: double.infinity,
                                                              height: 350,
                                                              decoration: BoxDecoration(
                                                                color: (doc['nombre'] == nombre) ? Color.fromRGBO(3, 26, 59, 1) : Colors.grey, //Color(0xFF424242),
                                                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: (doc['nombre'] == nombre) ? Color.fromRGBO(44, 181, 110, 1) : Colors.transparent,
                                                                    blurRadius: 1,
                                                                  )
                                                                ]
                                                              ),
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  nombre_e = doc['nombre'];
                                                                  descripcion_e = doc['descripcion'];
                                                                  imagenURL_e = doc['imagenURL'];
                                                                  uid_e = doc.id;

                                                                  _isPantalla = "Crear";
                                                                  
                                                                  setState(() {});
                                                                },
                                                                child: Stack(
                                                                  children: [
                                                                    CachedNetworkImage(
                                                                      imageUrl: doc['imagenURL'],
                                                                      imageBuilder: (context, imageProvider) => Container(
                                                                        width: 600,
                                                                        height: 600,
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                        ),
                                                                      ),
                                                                      placeholder: (context, url) => Center(child: Container(width: 100, height: 100, child: CircularProgressIndicator(color: Colors.white))),
                                                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                                                    ),
                                                                    Column(
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                          width: double.infinity,
                                                                          decoration: BoxDecoration(
                                                                            color: Color.fromRGBO(3, 26, 59, 1),
                                                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                          ),
                                                                          margin: EdgeInsets.all(10),
                                                                          child: SingleChildScrollView(
                                                                            child: Text(
                                                                              doc['nombre'],
                                                                              textAlign: TextAlign.center,
                                                                              style: GoogleFonts.poppins(textStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 23, fontWeight: FontWeight.w600, color: Colors.white)),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          )
                                                                        ),

                                                                        Expanded(child: Container()),

                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                          width: double.infinity,
                                                                          decoration: BoxDecoration(
                                                                            color: Color.fromRGBO(3, 26, 59, 1),
                                                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                          ),
                                                                          margin: EdgeInsets.all(10),
                                                                          child: SingleChildScrollView(
                                                                            child: Text(
                                                                              doc['descripcion'],
                                                                              textAlign: TextAlign.center,
                                                                              style: GoogleFonts.poppins(textStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 19, fontWeight: FontWeight.w200, color: Colors.white)),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          )
                                                                        )

                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ]),
                                                    )
                                                    
                                                  : Container();
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ],
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
                                              Icon(
                                                Icons.query_stats_rounded,
                                                color: Color.fromRGBO(95, 189, 132, 1),
                                                size: 110),
                                              SizedBox(height: 15),
                                              Text('No existen ejercicios',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 20,
                                                  color: (_isOscuro)
                                                    ? Colors.white
                                                    : Color.fromRGBO(31, 31, 31, 1),
                                                    fontWeight: FontWeight.normal)),
                                              SizedBox(height: 5),
                                              Text('para esta categoría...',
                                                style: GoogleFonts.montserrat(
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
                                }),
                              ],
                            ),

                      Stack( //BRAZO
                        children: [
                          Container(
                            width: width,
                            height: height,
                            color: (_isOscuro)
                              ? Color.fromRGBO(31, 31, 31, 1)
                              : Colors.white,
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: db.collection('ejercicios').doc('categorias').collection('brazo').snapshots(),
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
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                                          child: TextFormField(
                                            controller: _searchBrazo,
                                            autocorrect: false,
                                            textAlignVertical: TextAlignVertical.center,
                                            style: TextStyle(color: (!_isOscuro) ? Colors.grey[800] : Colors.white),
                                            onTap: () {
                                              FocusScope.of(context).unfocus();
                                            },
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(10.0),
                                              labelText: "Busca un ejercicio...",
                                              hintText: "Busca un ejercicio...",
                                              labelStyle: TextStyle(color: (!_isOscuro) ? Colors.black : Colors.white),
                                              hintStyle: TextStyle(color: (!_isOscuro) ? Colors.black : Colors.white),
                                              prefixIcon: Icon(Icons.search, color: (!_isOscuro) ? Colors.grey[800] : Colors.white),
                                              suffixIcon: InkWell(
                                                onTap: (){
                                                  _searchAbdomen.text = "";
                                                  FocusScope.of(context).unfocus();
                                                  setState(() {});
                                                },
                                                child: Icon((_searchBrazo.text != "") ? Icons.close : null, color: (!_isOscuro) ? Colors.grey[800] : Colors.white)
                                              ),
                                              floatingLabelBehavior: FloatingLabelBehavior.never,
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                borderSide: BorderSide(
                                                  style: BorderStyle.solid,
                                                  color: Colors.grey.shade800, width: 0.5
                                                )
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                borderSide: BorderSide(
                                                  style: BorderStyle.solid,
                                                  color: Colors.grey.shade800, width: 0.5
                                                )
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15))),
                                            ),
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(RegExp("[a-zA-Z\u00f1\u00d1]*"))
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            color: (_isOscuro)
                                              ? Color.fromRGBO(31, 31, 31, 1)
                                              : Colors.white,
                                              child: ListView(
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                children: snapshot.data!.docs.map((doc) {
                                                  
                                                  return (doc['nombre'].toString().toLowerCase().contains(_searchBrazo.text.toLowerCase()) || doc['descripcion'].toString().toLowerCase().contains(_searchBrazo.text.toLowerCase()))
                                                    ? Padding(
                                                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                            child: Container(
                                                              margin: EdgeInsets.only(bottom: 10.0),
                                                              width: double.infinity,
                                                              height: 350,
                                                              decoration: BoxDecoration(
                                                                color: (doc['nombre'] == nombre) ? Color.fromRGBO(3, 26, 59, 1) : Colors.grey, //Color(0xFF424242),
                                                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: (doc['nombre'] == nombre) ? Color.fromRGBO(44, 181, 110, 1) : Colors.transparent,
                                                                    blurRadius: 5,
                                                                  )
                                                                ]
                                                              ),
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  nombre_e = doc['nombre'];
                                                                  descripcion_e = doc['descripcion'];
                                                                  imagenURL_e = doc['imagenURL'];
                                                                  uid_e = doc.id;

                                                                  _isPantalla = "Crear";
                                                                  
                                                                  setState(() {});
                                                                },
                                                                child: Stack(
                                                                  children: [
                                                                    CachedNetworkImage(
                                                                      imageUrl: doc['imagenURL'],
                                                                      imageBuilder: (context, imageProvider) => Container(
                                                                        width: 600,
                                                                        height: 600,
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                        ),
                                                                      ),
                                                                      placeholder: (context, url) => Center(child: Container(width: 100, height: 100, child: CircularProgressIndicator(color: Colors.white))),
                                                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                                                    ),
                                                                    Column(
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                          width: double.infinity,
                                                                          decoration: BoxDecoration(
                                                                            color: Color.fromRGBO(3, 26, 59, 1),
                                                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                          ),
                                                                          margin: EdgeInsets.all(10),
                                                                          child: SingleChildScrollView(
                                                                            child: Text(
                                                                              doc['nombre'],
                                                                              textAlign: TextAlign.center,
                                                                              style: GoogleFonts.poppins(textStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 23, fontWeight: FontWeight.w600, color: Colors.white)),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          )
                                                                        ),

                                                                        Expanded(child: Container()),

                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                          width: double.infinity,
                                                                          decoration: BoxDecoration(
                                                                            color: Color.fromRGBO(3, 26, 59, 1),
                                                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                          ),
                                                                          margin: EdgeInsets.all(10),
                                                                          child: SingleChildScrollView(
                                                                            child: Text(
                                                                              doc['descripcion'],
                                                                              textAlign: TextAlign.center,
                                                                              style: GoogleFonts.poppins(textStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 19, fontWeight: FontWeight.w200, color: Colors.white)),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          )
                                                                        )

                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ]),
                                                    )
                                                    
                                                  : Container();
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ],
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
                                              Icon(
                                                Icons.query_stats_rounded,
                                                color: Color.fromRGBO(95, 189, 132, 1),
                                                size: 110),
                                              SizedBox(height: 15),
                                              Text('No existen ejercicios',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 20,
                                                  color: (_isOscuro)
                                                    ? Colors.white
                                                    : Color.fromRGBO(31, 31, 31, 1),
                                                    fontWeight: FontWeight.normal)),
                                              SizedBox(height: 5),
                                              Text('para esta categoría...',
                                                style: GoogleFonts.montserrat(
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
                                  }),
                              ],
                            ),

                      Stack( //ESPALDA
                        children: [
                          Container(
                            width: width,
                            height: height,
                            color: (_isOscuro)
                              ? Color.fromRGBO(31, 31, 31, 1)
                              : Colors.white,
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: db.collection('ejercicios').doc('categorias').collection('espalda').snapshots(),
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
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                                          child: TextFormField(
                                            controller: _searchEspalda,
                                            autocorrect: false,
                                            textAlignVertical: TextAlignVertical.center,
                                            style: TextStyle(color: (!_isOscuro) ? Colors.grey[800] : Colors.white),
                                            onTap: () {
                                              FocusScope.of(context).unfocus();
                                            },
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(10.0),
                                              labelText: "Busca un ejercicio...",
                                              hintText: "Busca un ejercicio...",
                                              labelStyle: TextStyle(color: (!_isOscuro) ? Colors.black : Colors.white),
                                              hintStyle: TextStyle(color: (!_isOscuro) ? Colors.black : Colors.white),
                                              prefixIcon: Icon(Icons.search, color: (!_isOscuro) ? Colors.grey[800] : Colors.white),
                                              suffixIcon: InkWell(
                                                onTap: (){
                                                  _searchEspalda.text = "";
                                                  FocusScope.of(context).unfocus();
                                                  setState(() {});
                                                },
                                                child: Icon((_searchEspalda.text != "") ? Icons.close : null, color: (!_isOscuro) ? Colors.grey[800] : Colors.white)
                                              ),
                                              floatingLabelBehavior: FloatingLabelBehavior.never,
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                borderSide: BorderSide(
                                                  style: BorderStyle.solid,
                                                  color: Colors.grey.shade800, width: 0.5
                                                )
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                borderSide: BorderSide(
                                                  style: BorderStyle.solid,
                                                  color: Colors.grey.shade800, width: 0.5
                                                )
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15))),
                                            ),
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(RegExp("[a-zA-Z\u00f1\u00d1]*"))
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            color: (_isOscuro)
                                              ? Color.fromRGBO(31, 31, 31, 1)
                                              : Colors.white,
                                              child: ListView(
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                children: snapshot.data!.docs.map((doc) {
                                                  
                                                  return (doc['nombre'].toString().toLowerCase().contains(_searchEspalda.text.toLowerCase()) || doc['descripcion'].toString().toLowerCase().contains(_searchEspalda.text.toLowerCase()))
                                                    ? Padding(
                                                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                            child: Container(
                                                              margin: EdgeInsets.only(bottom: 10.0),
                                                              width: double.infinity,
                                                              height: 350,
                                                              decoration: BoxDecoration(
                                                                color: (doc['nombre'] == nombre) ? Color.fromRGBO(3, 26, 59, 1) : Colors.grey, //Color(0xFF424242),
                                                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: (doc['nombre'] == nombre) ? Color.fromRGBO(44, 181, 110, 1) : Colors.transparent,
                                                                    blurRadius: 5,
                                                                  )
                                                                ]
                                                              ),
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  nombre_e = doc['nombre'];
                                                                  descripcion_e = doc['descripcion'];
                                                                  imagenURL_e = doc['imagenURL'];
                                                                  uid_e = doc.id;

                                                                  _isPantalla = "Crear";
                                                                  
                                                                  setState(() {});
                                                                },
                                                                child: Stack(
                                                                  children: [
                                                                    CachedNetworkImage(
                                                                      imageUrl: doc['imagenURL'],
                                                                      imageBuilder: (context, imageProvider) => Container(
                                                                        width: 600,
                                                                        height: 600,
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                        ),
                                                                      ),
                                                                      placeholder: (context, url) => Center(child: Container(width: 100, height: 100, child: CircularProgressIndicator(color: Colors.white))),
                                                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                                                    ),
                                                                    Column(
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                          width: double.infinity,
                                                                          decoration: BoxDecoration(
                                                                            color: Color.fromRGBO(3, 26, 59, 1),
                                                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                          ),
                                                                          margin: EdgeInsets.all(10),
                                                                          child: SingleChildScrollView(
                                                                            child: Text(
                                                                              doc['nombre'],
                                                                              textAlign: TextAlign.center,
                                                                              style: GoogleFonts.poppins(textStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 23, fontWeight: FontWeight.w600, color: Colors.white)),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          )
                                                                        ),

                                                                        Expanded(child: Container()),

                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                          width: double.infinity,
                                                                          decoration: BoxDecoration(
                                                                            color: Color.fromRGBO(3, 26, 59, 1),
                                                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                          ),
                                                                          margin: EdgeInsets.all(10),
                                                                          child: SingleChildScrollView(
                                                                            child: Text(
                                                                              doc['descripcion'],
                                                                              textAlign: TextAlign.center,
                                                                              style: GoogleFonts.poppins(textStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 19, fontWeight: FontWeight.w200, color: Colors.white)),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          )
                                                                        )

                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ]),
                                                    )
                                                    
                                                  : Container();
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ],
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
                                              Icon(
                                                Icons.query_stats_rounded,
                                                color: Color.fromRGBO(95, 189, 132, 1),
                                                size: 110),
                                              SizedBox(height: 15),
                                              Text('No existen ejercicios',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 20,
                                                  color: (_isOscuro)
                                                    ? Colors.white
                                                    : Color.fromRGBO(31, 31, 31, 1),
                                                    fontWeight: FontWeight.normal)),
                                              SizedBox(height: 5),
                                              Text('para esta categoría...',
                                                style: GoogleFonts.montserrat(
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
                                
                                  }),
                              ],
                            ),

                      Stack( //HOMBRO
                        children: [
                          Container(
                            width: width,
                            height: height,
                            color: (_isOscuro)
                              ? Color.fromRGBO(31, 31, 31, 1)
                              : Colors.white,
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: db.collection('ejercicios').doc('categorias').collection('hombro').snapshots(),
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
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                                          child: TextFormField(
                                            controller: _searchHombro,
                                            autocorrect: false,
                                            textAlignVertical: TextAlignVertical.center,
                                            style: TextStyle(color: (!_isOscuro) ? Colors.grey[800] : Colors.white),
                                            onTap: () {
                                              FocusScope.of(context).unfocus();
                                            },
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(10.0),
                                              labelText: "Busca un ejercicio...",
                                              hintText: "Busca un ejercicio...",
                                              labelStyle: TextStyle(color: (!_isOscuro) ? Colors.black : Colors.white),
                                              hintStyle: TextStyle(color: (!_isOscuro) ? Colors.black : Colors.white),
                                              prefixIcon: Icon(Icons.search, color: (!_isOscuro) ? Colors.grey[800] : Colors.white),
                                              suffixIcon: InkWell(
                                                onTap: (){
                                                  _searchHombro.text = "";
                                                  FocusScope.of(context).unfocus();
                                                  setState(() {});
                                                },
                                                child: Icon((_searchHombro.text != "") ? Icons.close : null, color: (!_isOscuro) ? Colors.grey[800] : Colors.white)
                                              ),
                                              floatingLabelBehavior: FloatingLabelBehavior.never,
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                borderSide: BorderSide(
                                                  style: BorderStyle.solid,
                                                  color: Colors.grey.shade800, width: 0.5
                                                )
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                borderSide: BorderSide(
                                                  style: BorderStyle.solid,
                                                  color: Colors.grey.shade800, width: 0.5
                                                )
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15))),
                                            ),
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(RegExp("[a-zA-Z\u00f1\u00d1]*"))
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            color: (_isOscuro)
                                              ? Color.fromRGBO(31, 31, 31, 1)
                                              : Colors.white,
                                              child: ListView(
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                children: snapshot.data!.docs.map((doc) {
                                                  
                                                  return (doc['nombre'].toString().toLowerCase().contains(_searchHombro.text.toLowerCase()) || doc['descripcion'].toString().toLowerCase().contains(_searchHombro.text.toLowerCase()))
                                                    ? Padding(
                                                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                            child: Container(
                                                              margin: EdgeInsets.only(bottom: 10.0),
                                                              width: double.infinity,
                                                              height: 350,
                                                              decoration: BoxDecoration(
                                                                color: (doc['nombre'] == nombre) ? Color.fromRGBO(3, 26, 59, 1) : Colors.grey, //Color(0xFF424242),
                                                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: (doc['nombre'] == nombre) ? Color.fromRGBO(44, 181, 110, 1) : Colors.transparent,
                                                                    blurRadius: 5,
                                                                  )
                                                                ]
                                                              ),
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  nombre_e = doc['nombre'];
                                                                  descripcion_e = doc['descripcion'];
                                                                  imagenURL_e = doc['imagenURL'];
                                                                  uid_e = doc.id;

                                                                  _isPantalla = "Crear";
                                                                  
                                                                  setState(() {});
                                                                },
                                                                child: Stack(
                                                                  children: [
                                                                    CachedNetworkImage(
                                                                      imageUrl: doc['imagenURL'],
                                                                      imageBuilder: (context, imageProvider) => Container(
                                                                        width: 600,
                                                                        height: 600,
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                        ),
                                                                      ),
                                                                      placeholder: (context, url) => Center(child: Container(width: 100, height: 100, child: CircularProgressIndicator(color: Colors.white))),
                                                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                                                    ),
                                                                    Column(
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                          width: double.infinity,
                                                                          decoration: BoxDecoration(
                                                                            color: Color.fromRGBO(3, 26, 59, 1),
                                                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                          ),
                                                                          margin: EdgeInsets.all(10),
                                                                          child: SingleChildScrollView(
                                                                            child: Text(
                                                                              doc['nombre'],
                                                                              textAlign: TextAlign.center,
                                                                              style: GoogleFonts.poppins(textStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 23, fontWeight: FontWeight.w600, color: Colors.white)),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          )
                                                                        ),

                                                                        Expanded(child: Container()),

                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                          width: double.infinity,
                                                                          decoration: BoxDecoration(
                                                                            color: Color.fromRGBO(3, 26, 59, 1),
                                                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                          ),
                                                                          margin: EdgeInsets.all(10),
                                                                          child: SingleChildScrollView(
                                                                            child: Text(
                                                                              doc['descripcion'],
                                                                              textAlign: TextAlign.center,
                                                                              style: GoogleFonts.poppins(textStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 19, fontWeight: FontWeight.w200, color: Colors.white)),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          )
                                                                        )

                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ]),
                                                    )
                                                    
                                                  : Container();
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ],
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
                                              Icon(
                                                Icons.query_stats_rounded,
                                                color: Color.fromRGBO(95, 189, 132, 1),
                                                size: 110),
                                              SizedBox(height: 15),
                                              Text('No existen ejercicios',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 20,
                                                  color: (_isOscuro)
                                                    ? Colors.white
                                                    : Color.fromRGBO(31, 31, 31, 1),
                                                    fontWeight: FontWeight.normal)),
                                              SizedBox(height: 5),
                                              Text('para esta categoría...',
                                                style: GoogleFonts.montserrat(
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
                                  }),
                              ],
                            ),

                      Stack( //PECHO
                        children: [
                          Container(
                            width: width,
                            height: height,
                            color: (_isOscuro)
                              ? Color.fromRGBO(31, 31, 31, 1)
                              : Colors.white,
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: db.collection('ejercicios').doc('categorias').collection('pecho').snapshots(),
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
                                            : Color.fromRGBO(1, 29, 69,1)))));
                                } else {
                                  if (!snapshot.data!.docs.isEmpty) {
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                                          child: TextFormField(
                                            controller: _searchPecho,
                                            autocorrect: false,
                                            textAlignVertical: TextAlignVertical.center,
                                            style: TextStyle(color: (!_isOscuro) ? Colors.grey[800] : Colors.white),
                                            onTap: () {
                                              FocusScope.of(context).unfocus();
                                            },
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(10.0),
                                              labelText: "Busca un ejercicio...",
                                              hintText: "Busca un ejercicio...",
                                              labelStyle: TextStyle(color: (!_isOscuro) ? Colors.black : Colors.white),
                                              hintStyle: TextStyle(color: (!_isOscuro) ? Colors.black : Colors.white),
                                              prefixIcon: Icon(Icons.search, color: (!_isOscuro) ? Colors.grey[800] : Colors.white),
                                              suffixIcon: InkWell(
                                                onTap: (){
                                                  _searchPecho.text = "";
                                                  FocusScope.of(context).unfocus();
                                                  setState(() {});
                                                },
                                                child: Icon((_searchPecho.text != "") ? Icons.close : null, color: (!_isOscuro) ? Colors.grey[800] : Colors.white)
                                              ),
                                              floatingLabelBehavior: FloatingLabelBehavior.never,
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                borderSide: BorderSide(
                                                  style: BorderStyle.solid,
                                                  color: Colors.grey.shade800, width: 0.5
                                                )
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                borderSide: BorderSide(
                                                  style: BorderStyle.solid,
                                                  color: Colors.grey.shade800, width: 0.5
                                                )
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15))),
                                            ),
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(RegExp("[a-zA-Z\u00f1\u00d1]*"))
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            color: (_isOscuro)
                                              ? Color.fromRGBO(31, 31, 31, 1)
                                              : Colors.white,
                                              child: ListView(
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                children: snapshot.data!.docs.map((doc) {
                                                  
                                                  return (doc['nombre'].toString().toLowerCase().contains(_searchPecho.text.toLowerCase()) || doc['descripcion'].toString().toLowerCase().contains(_searchPecho.text.toLowerCase()))
                                                    ? Padding(
                                                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                            child: Container(
                                                              margin: EdgeInsets.only(bottom: 10.0),
                                                              width: double.infinity,
                                                              height: 350,
                                                              decoration: BoxDecoration(
                                                                color: (doc['nombre'] == nombre) ? Color.fromRGBO(3, 26, 59, 1) : Colors.grey, //Color(0xFF424242),
                                                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: (doc['nombre'] == nombre) ? Color.fromRGBO(44, 181, 110, 1) : Colors.transparent,
                                                                    blurRadius: 5,
                                                                  )
                                                                ]
                                                              ),
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  nombre_e = doc['nombre'];
                                                                  descripcion_e = doc['descripcion'];
                                                                  imagenURL_e = doc['imagenURL'];
                                                                  uid_e = doc.id;

                                                                  _isPantalla = "Crear";
                                                                  
                                                                  setState(() {});
                                                                },
                                                                child: Stack(
                                                                  children: [
                                                                    CachedNetworkImage(
                                                                      imageUrl: doc['imagenURL'],
                                                                      imageBuilder: (context, imageProvider) => Container(
                                                                        width: 600,
                                                                        height: 600,
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                        ),
                                                                      ),
                                                                      placeholder: (context, url) => Center(child: Container(width: 100, height: 100, child: CircularProgressIndicator(color: Colors.white))),
                                                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                                                    ),
                                                                    Column(
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                          width: double.infinity,
                                                                          decoration: BoxDecoration(
                                                                            color: Color.fromRGBO(3, 26, 59, 1),
                                                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                          ),
                                                                          margin: EdgeInsets.all(10),
                                                                          child: SingleChildScrollView(
                                                                            child: Text(
                                                                              doc['nombre'],
                                                                              textAlign: TextAlign.center,
                                                                              style: GoogleFonts.poppins(textStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 23, fontWeight: FontWeight.w600, color: Colors.white)),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          )
                                                                        ),

                                                                        Expanded(child: Container()),

                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                          width: double.infinity,
                                                                          decoration: BoxDecoration(
                                                                            color: Color.fromRGBO(3, 26, 59, 1),
                                                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                          ),
                                                                          margin: EdgeInsets.all(10),
                                                                          child: SingleChildScrollView(
                                                                            child: Text(
                                                                              doc['descripcion'],
                                                                              textAlign: TextAlign.center,
                                                                              style: GoogleFonts.poppins(textStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 19, fontWeight: FontWeight.w200, color: Colors.white)),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          )
                                                                        )

                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ]),
                                                    )
                                                    
                                                  : Container();
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ],
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
                                              Icon(
                                                Icons.query_stats_rounded,
                                                color: Color.fromRGBO(95, 189, 132, 1),
                                                size: 110),
                                              SizedBox(height: 15),
                                              Text('No existen ejercicios',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 20,
                                                  color: (_isOscuro)
                                                    ? Colors.white
                                                    : Color.fromRGBO(31, 31, 31, 1),
                                                    fontWeight: FontWeight.normal)),
                                              SizedBox(height: 5),
                                              Text('para esta categoría...',
                                                style: GoogleFonts.montserrat(
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
                                
                                  }),
                              ],
                            ),

                      Stack( //PIERNA
                        children: [
                          Container(
                            width: width,
                            height: height,
                            color: (_isOscuro)
                              ? Color.fromRGBO(31, 31, 31, 1)
                              : Colors.white,
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: db.collection('ejercicios').doc('categorias').collection('pierna').snapshots(),
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
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                                          child: TextFormField(
                                            controller: _searchPierna,
                                            autocorrect: false,
                                            textAlignVertical: TextAlignVertical.center,
                                            style: TextStyle(color: (!_isOscuro) ? Colors.grey[800] : Colors.white),
                                            onTap: () {
                                              FocusScope.of(context).unfocus();
                                            },
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(10.0),
                                              labelText: "Busca un ejercicio...",
                                              hintText: "Busca un ejercicio...",
                                              labelStyle: TextStyle(color: (!_isOscuro) ? Colors.black : Colors.white),
                                              hintStyle: TextStyle(color: (!_isOscuro) ? Colors.black : Colors.white),
                                              prefixIcon: Icon(Icons.search, color: (!_isOscuro) ? Colors.grey[800] : Colors.white),
                                              suffixIcon: InkWell(
                                                onTap: (){
                                                  _searchPierna.text = "";
                                                  FocusScope.of(context).unfocus();
                                                  setState(() {});
                                                },
                                                child: Icon((_searchPierna.text != "") ? Icons.close : null, color: (!_isOscuro) ? Colors.grey[800] : Colors.white)
                                              ),
                                              floatingLabelBehavior: FloatingLabelBehavior.never,
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                borderSide: BorderSide(
                                                  style: BorderStyle.solid,
                                                  color: Colors.grey.shade800, width: 0.5
                                                )
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                borderSide: BorderSide(
                                                  style: BorderStyle.solid,
                                                  color: Colors.grey.shade800, width: 0.5
                                                )
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15))),
                                            ),
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(RegExp("[a-zA-Z\u00f1\u00d1]*"))
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            color: (_isOscuro)
                                              ? Color.fromRGBO(31, 31, 31, 1)
                                              : Colors.white,
                                              child: ListView(
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                children: snapshot.data!.docs.map((doc) {
                                                  
                                                  return (doc['nombre'].toString().toLowerCase().contains(_searchPierna.text.toLowerCase()) || doc['descripcion'].toString().toLowerCase().contains(_searchPierna.text.toLowerCase()))
                                                    ? Padding(
                                                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                            child: Container(
                                                              margin: EdgeInsets.only(bottom: 10.0),
                                                              width: double.infinity,
                                                              height: 350,
                                                              decoration: BoxDecoration(
                                                                color: (doc['nombre'] == nombre) ? Color.fromRGBO(3, 26, 59, 1) : Colors.grey, //Color(0xFF424242),
                                                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: (doc['nombre'] == nombre) ? Color.fromRGBO(44, 181, 110, 1) : Colors.transparent,
                                                                    blurRadius: 5,
                                                                  )
                                                                ]
                                                              ),
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  nombre_e = doc['nombre'];
                                                                  descripcion_e = doc['descripcion'];
                                                                  imagenURL_e = doc['imagenURL'];
                                                                  uid_e = doc.id;

                                                                  _isPantalla = "Crear";
                                                                  
                                                                  setState(() {});
                                                                },
                                                                child: Stack(
                                                                  children: [
                                                                    CachedNetworkImage(
                                                                      imageUrl: doc['imagenURL'],
                                                                      imageBuilder: (context, imageProvider) => Container(
                                                                        width: 600,
                                                                        height: 600,
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                                                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                        ),
                                                                      ),
                                                                      placeholder: (context, url) => Center(child: Container(width: 100, height: 100, child: CircularProgressIndicator(color: Colors.white))),
                                                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                                                    ),
                                                                    Column(
                                                                      children: [
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                          width: double.infinity,
                                                                          decoration: BoxDecoration(
                                                                            color: Color.fromRGBO(3, 26, 59, 1),
                                                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                          ),
                                                                          margin: EdgeInsets.all(10),
                                                                          child: SingleChildScrollView(
                                                                            child: Text(
                                                                              doc['nombre'],
                                                                              textAlign: TextAlign.center,
                                                                              style: GoogleFonts.poppins(textStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 23, fontWeight: FontWeight.w600, color: Colors.white)),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          )
                                                                        ),

                                                                        Expanded(child: Container()),

                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                          width: double.infinity,
                                                                          decoration: BoxDecoration(
                                                                            color: Color.fromRGBO(3, 26, 59, 1),
                                                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                          ),
                                                                          margin: EdgeInsets.all(10),
                                                                          child: SingleChildScrollView(
                                                                            child: Text(
                                                                              doc['descripcion'],
                                                                              textAlign: TextAlign.center,
                                                                              style: GoogleFonts.poppins(textStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 19, fontWeight: FontWeight.w200, color: Colors.white)),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          )
                                                                        )

                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ]),
                                                    )
                                                    
                                                  : Container();
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ],
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
                                              Icon(
                                                Icons.query_stats_rounded,
                                                color: Color.fromRGBO(95, 189, 132, 1),
                                                size: 110),
                                              SizedBox(height: 15),
                                              Text('No existen ejercicios',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 20,
                                                  color: (_isOscuro)
                                                    ? Colors.white
                                                    : Color.fromRGBO(31, 31, 31, 1),
                                                    fontWeight: FontWeight.normal)),
                                              SizedBox(height: 5),
                                              Text('para esta categoría...',
                                                style: GoogleFonts.montserrat(
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
                                  }),
                              ],
                            ),
                    
                    ],
                  )
              ),
            )
            : (_isPantalla == "Crear")
            ? Scaffold(
              appBar: AppBar(
                centerTitle: true,
                leading: Tooltip(
                  message: 'Asignar ejercicios',
                  child: IconButton(
                    splashRadius: 25,
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _isPantalla = "Ejercicio";
                      nombre_e = '';
                      descripcion_e = '';
                      imagenURL_e = '';
                      _series.clear();
                      _repeticiones.clear();
                      _tiempo.clear();
                      _peso.clear();
                      _obs.clear();

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
                    child: Text('Agregar ejercicio',
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
                ? Color.fromRGBO(31, 31, 31, 1)
                : Colors.white,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 5)
                              ]),
                            width: double.infinity,
                            height: 350,
                            child: Container(
                              child: Container(
                                width: 600,
                                height: 600,
                                child: CachedNetworkImage(
                                  imageUrl: imagenURL_e!,
                                  imageBuilder: (context, imageProvider) => Container(
                                    width: 600,
                                    height: 600,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(0)),
                                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                    ),
                                  ),
                                  placeholder: (context, url) => Center(child: Container(width: 100, height: 100, child: CircularProgressIndicator(color: Colors.white))),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 1)
                                ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 5)
                            ]),
                          child: Form(
                          child: Column(children: [
                                SizedBox(height: 10),
                                TextFormField(
                                  enabled: false,
                                  initialValue: nombre_e,
                                  decoration: InputDecoration(
                                    labelText: 'Ejercicio:',
                                  ),
                                ),
                                SizedBox(height: 5),
                                TextFormField(
                                  maxLines: null,
                                  enabled: false,
                                  initialValue: descripcion_e,
                                  decoration: InputDecoration(
                                    labelText: 'Descripcion:',
                                  ),
                                ),
                                SizedBox(height: 5),
                                TextFormField(
                                  maxLength: 3,
                                  keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
                                  controller: _series,
                                  decoration: InputDecoration(
                                    labelText: 'Numero de Series:',
                                  ),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(RegExp(
                                      "[0-9.]*"))
                                    ],
                                ),
                                SizedBox(height: 5),
                                TextFormField(
                                  maxLength: 3,
                                  keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
                                  controller: _repeticiones,
                                  decoration: InputDecoration(
                                    labelText: 'Numero de Repeticiones:',
                                  ),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(RegExp(
                                      "[0-9.]*"))
                                  ],
                                ),
                                SizedBox(height: 5),
                                TextFormField(
                                  maxLength: 3,
                                  keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
                                  controller: _tiempo,
                                  decoration: InputDecoration(
                                    labelText: 'Tiempo (Segundos):',
                                  ),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(RegExp(
                                      "[0-9.]*"))
                                  ],
                                ),
                                SizedBox(height: 5),
                                TextFormField(
                                  maxLength: 3,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                                  controller: _peso,
                                  decoration: InputDecoration(
                                    labelText: 'Peso (Lbs):',
                                  ),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(RegExp(
                                      "[0-9.]*"))
                                  ],
                                ),
                                SizedBox(height: 5),
                                TextFormField(
                                  maxLines: null,
                                  maxLength: 100,
                                  keyboardType: TextInputType.text,
                                  controller: _obs,
                                  decoration: InputDecoration(
                                    labelText: 'Observaciones:',
                                  ),
                                ),
                                SizedBox(height: 20),
                              ]))),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          height: width * 0.12,
                          width: width * 0.4,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              onPrimary: Colors.green,
                              // foreground
                            ),
                            onPressed: () async {
                              try {
                                final result = await InternetAddress.lookup('example.com');

                                if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                                  if (_series.text == '' || _repeticiones.text == '' || _tiempo.text == '' || _peso.text == '') {
                                    Get.snackbar(
                                      "Error en la asignacion del ejercicio", // title
                                      "Compruebe todos los campos", // message
                                      icon: Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Icon(Icons.error, color: Colors.white),
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
                                  } else {
                                    showLoading();

                                    FirebaseFirestore.instance
                                        .collection('rutinas')
                                        .doc(uid)
                                        .collection('ejercicios')
                                        .doc(uid_e)
                                        .set({
                                      "nombre": nombre_e,
                                      "descripcion": descripcion_e,
                                      "imagenURL": imagenURL_e,
                                      "series": _series.text.trim(),
                                      "repeticiones": _repeticiones.text.trim(),
                                      "tiempo": _tiempo.text.trim(),
                                      "peso": _peso.text.trim(),
                                      "observaciones": _obs.text.trim(),
                                      'timestamp': Timestamp.now()
                                    });

                                    FirebaseFirestore.instance
                                      .collection('clientes')
                                      .doc(uid)
                                      .update({
                                        "rutina": true,
                                      });

                                    dismissLoadingWidget();

                                    _isPantalla = "Ejercicio";

                                    nombre_e = '';
                                    descripcion_e = '';
                                    imagenURL_e = '';
                                    _series.clear();
                                    _repeticiones.clear();
                                    _tiempo.clear();
                                    _peso.clear();
                                    _obs.clear();

                                  }
                                }
                              } catch (e) {
                                print(e.toString());
                                Get.snackbar(
                                    "Error", // title
                                    "No hay conexión a Internet", // message
                                    icon: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10),
                                      child: Icon(Icons.wifi_off_rounded,
                                          color: Colors.white),
                                    ),
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10),
                                    snackStyle: SnackStyle.FLOATING,
                                    snackPosition: SnackPosition.BOTTOM,
                                    shouldIconPulse: true,
                                    barBlur: 0,
                                    isDismissible: true,
                                    duration: Duration(seconds: 3),
                                    colorText: Colors.white,
                                    backgroundColor: Colors.red[800],
                                    maxWidth: 350,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8));
                              }

                              setState(() {});
                            },
                            child: Text(
                              'ASIGNAR EJERCICIO',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  ),
                )
            : Container(
              width: width,
              height: height,
              color: (_isOscuro) ? Colors.white : Color.fromRGBO(31, 31, 31, 1),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          );
        } return Container(
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
                Text('conexión con el servidor',
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
      },

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
