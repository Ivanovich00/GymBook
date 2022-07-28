import 'dart:io';

import 'package:GymBook/api/firebase_api.dart';
import 'package:GymBook/helpers/showLoading.dart';
import 'package:GymBook/screens/administrador_screens/export_screens.dart';
import 'package:GymBook/screens/entrenador_screens/ejercicios_screen.dart';
import 'package:GymBook/screens/screens.dart';
import 'package:GymBook/services/services.dart';
import 'package:GymBook/ui/input_decorations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

String? userdoc;
String? dirty_info_user;

bool _isConnectedBool = true;
bool _isPressed = false;

bool _isDescending = false;

String? _nombre;
String? _descripcion;
String? uid_final;
String? _imagen;

bool _isOscuro = false;

File? _filePic;
XFile? _filePicked;
var _namePic;
String? _uid;

final db = FirebaseFirestore.instance;

final TextEditingController _controllerNombre = new TextEditingController();
final TextEditingController _controllerDescripcion =
    new TextEditingController();

final TextEditingController _controllerSearch = new TextEditingController();

String dropdownvalue = 'Ordenar de A a Z';
var items = [
  'Ordenar de A a Z',
  'Ordenar de Z a A',
  'Ordenar de antiguo a reciente',
  'Ordenar de reciente a antiguo'
];

class PantallaHombro extends StatefulWidget {
  const PantallaHombro({Key? key}) : super(key: key);
  @override
  State<PantallaHombro> createState() => _PantallaHombroState();
}

class _PantallaHombroState extends State<PantallaHombro> {
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

    dirty_info_user = await authService.readUserInfo();

    try {
      final result = await InternetAddress.lookup('example.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _isConnectedBool = true;
      }
    } catch (_) {
      _isConnectedBool = false;
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

  Future<void> _isConnected() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final valor_isOscuro = await authService.readTheme();

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    User? user = _firebaseAuth.currentUser;

    userdoc = user!.uid;

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

  @override
  void initState() {
    super.initState();
    _initGetDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final authService = Provider.of<AuthService>(context, listen: false);

    return new FutureBuilder(
        future: authService.readTheme(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('');
          }

          if (snapshot.data != '') {
            return new SafeArea(
              child: Scaffold(
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.endFloat,
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {},
                    child: SpeedDial(
                      elevation: 8.0,
                      overlayColor: Colors.black,
                      overlayOpacity: 0.3,
                      tooltip: 'Opciones',
                      animatedIcon: AnimatedIcons.menu_close,
                      animatedIconTheme: IconThemeData(
                        size: 22.0,
                        color: (_isOscuro)
                            ? Color.fromRGBO(49, 49, 49, 1)
                            : Colors.white,
                      ),
                      backgroundColor: (_isOscuro)
                          ? Colors.white
                          : Color.fromRGBO(49, 49, 49, 1),
                      foregroundColor: Colors.black,
                      visible: true,
                      curve: Curves.bounceIn,
                      spacing: 12.5,
                      children: [
                        SpeedDialChild(
                          child: Icon(
                            Icons.add_circle_rounded,
                            color: (_isOscuro)
                                ? Color.fromRGBO(49, 49, 49, 1)
                                : Colors.white,
                          ),
                          backgroundColor: (_isOscuro)
                              ? Colors.white
                              : Color.fromRGBO(49, 49, 49, 1),
                          onTap: () async {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child: CrearEjercicio(),
                                    duration: Duration(milliseconds: 250)));

                            uid_final = '';
                            _nombre = '';
                            _namePic = '';
                            _filePic = null;
                            _filePicked = null;
                            _isPressed = false;
                            _controllerDescripcion.clear();
                            _controllerNombre.clear();
                            _controllerSearch.clear();
                            setState(() {});
                          },
                          label: 'Crear nuevo ejercicio',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: (_isOscuro)
                                  ? Color.fromRGBO(49, 49, 49, 1)
                                  : Colors.white,
                              fontSize: 16.0),
                          labelBackgroundColor: (_isOscuro)
                              ? Colors.white
                              : Color.fromRGBO(49, 49, 49, 1),
                        ),
                        (_isPressed)
                            ? SpeedDialChild(
                                child: Icon(
                                  Icons.edit,
                                  color: (_isOscuro)
                                      ? Color.fromRGBO(49, 49, 49, 1)
                                      : Colors.white,
                                ),
                                backgroundColor: (_isOscuro)
                                    ? Colors.white
                                    : Color.fromRGBO(49, 49, 49, 1),
                                onTap: () {
                                  _namePic = '';
                                  _filePic = null;
                                  _filePicked = null;
                                  _isPressed = false;
                                  _controllerSearch.clear();
                                  setState(() {});

                                  Navigator.pushReplacement(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.fade,
                                          child: EditarEjercicio(),
                                          duration:
                                              Duration(milliseconds: 250)));
                                },
                                label: 'Editar ejercicio',
                                labelStyle: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: (_isOscuro)
                                        ? Color.fromRGBO(49, 49, 49, 1)
                                        : Colors.white,
                                    fontSize: 16.0),
                                labelBackgroundColor: (_isOscuro)
                                    ? Colors.white
                                    : Color.fromRGBO(49, 49, 49, 1),
                              )
                            : SpeedDialChild(
                                child: null,
                              ),
                        (_isPressed)
                            ? SpeedDialChild(
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                                backgroundColor: Colors.red[900],
                                onTap: () {
                                  Get.defaultDialog(
                                    title: 'Eliminar Ejercicio',
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
                                              '¿Estas seguro de eliminar el siguiente ejercicio?',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                  textStyle: TextStyle(
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      fontSize: 17.0,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors.black))),
                                          SizedBox(height: 20),
                                          Text(_nombre!,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                  textStyle: TextStyle(
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                          try {
                                            final result =
                                                await InternetAddress.lookup(
                                                    'example.com');

                                            if (result.isNotEmpty &&
                                                result[0]
                                                    .rawAddress
                                                    .isNotEmpty) {
                                              Get.back();

                                              FirebaseFirestore.instance
                                                  .collection("ejercicios")
                                                  .doc('categorias')
                                                  .collection('hombro')
                                                  .doc(uid_final)
                                                  .delete()
                                                  .then((value) => {
                                                        Get.snackbar(
                                                          "Ejercicio eliminado", // title
                                                          "Se elimino correctamente el ejercicio deseado",
                                                          icon: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10),
                                                            child: Icon(
                                                                Icons.delete,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 10),
                                                          snackStyle: SnackStyle
                                                              .FLOATING,
                                                          snackPosition:
                                                              SnackPosition
                                                                  .BOTTOM,
                                                          shouldIconPulse: true,
                                                          barBlur: 0,
                                                          isDismissible: true,
                                                          duration: Duration(
                                                              seconds: 3),
                                                          colorText:
                                                              Colors.white,
                                                          backgroundColor:
                                                              Colors.red[800],
                                                          maxWidth: 350,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 8),
                                                        )
                                                      });

                                              _isPressed = false;
                                              setState(() {});
                                            }
                                          } catch (_) {
                                            Get.back();
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
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              shouldIconPulse: true,
                                              barBlur: 0,
                                              isDismissible: true,
                                              duration: Duration(seconds: 3),
                                              colorText: Colors.white,
                                              backgroundColor: Colors.red[800],
                                              maxWidth: 350,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 8),
                                            );
                                          }
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

                                  setState(() {});
                                },
                                label: 'Eliminar ejercicio',
                                labelStyle: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 16.0),
                                labelBackgroundColor: Colors.red[900],
                              )
                            : SpeedDialChild(
                                child: null,
                              )
                      ],
                    ),
                  ),
                  appBar: AppBar(
                    leading: IconButton(
              splashRadius: 25,
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {});

                          _nombre = '';
                          _isPressed = false;

                          _controllerSearch.clear();

                          if (dirty_info_user
                              .toString()
                              .contains('administrador')) {
                            Navigator.pushReplacement(
                                context,
                                PageTransition(
                                    type: PageTransitionType.leftToRight,
                                    child: PantallaEjercicios(),
                                    duration: Duration(milliseconds: 250)));
                          } else if (dirty_info_user
                              .toString()
                              .contains('entrenador')) {
                            Navigator.pushReplacement(
                                context,
                                PageTransition(
                                    type: PageTransitionType.leftToRight,
                                    child: PantallaEjercicios2(),
                                    duration: Duration(milliseconds: 250)));
                          } else {
                            final authService = Provider.of<AuthService>(
                                context,
                                listen: false);
                            authService.logout();
                            Navigator.pushReplacement(
                                context,
                                PageTransition(
                                    type: PageTransitionType.fade,
                                    child: LoginScreen(),
                                    duration: Duration(milliseconds: 500)));
                            Get.snackbar(
                              "Sesion Cerrada", // title
                              "Por favor, vuelve a iniciar sesion", // message
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                            );
                          }
                        }),
                    actions: [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 15, 5),
                          child: DropdownButton(
                            dropdownColor: Color.fromRGBO(31, 31, 31, 1),
                            iconEnabledColor: Colors.white,
                            value: dropdownvalue,
                            icon: Icon(Icons.keyboard_arrow_down),
                            items: items.map((String items) {
                              return DropdownMenuItem(
                                  value: items,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Text(items,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontStyle: FontStyle.normal,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w200,
                                                color: Colors.white))),
                                  ));
                            }).toList(),
                            onChanged: (newValue) {
                              dropdownvalue = newValue.toString();
                              if (newValue.toString() == 'Ordenar de A a Z') {
                                _isDescending = false;
                              } else if (newValue.toString() ==
                                  'Ordenar de Z a A') {
                                _isDescending = true;
                              } else if (newValue.toString() ==
                                  'Ordenar de antiguo a reciente') {
                                _isDescending = false;
                              } else {
                                _isDescending = true;
                              }
                              setState(() {});
                            },
                          ))
                    ],
                    backgroundColor: Color.fromRGBO(72, 83, 98, 1),
                    elevation: 0,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text('HOMBRO',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                        ),
                      ],
                    ),
                  ),
                  body: Stack(
                    children: [
                      Container(
                        width: width,
                        height: height,
                        color: (_isOscuro)
                            ? Color.fromRGBO(31, 31, 31, 1)
                            : Colors.white,
                      ),
                      StreamBuilder<QuerySnapshot>(
                          stream: (dropdownvalue.toString() ==
                                      'Ordenar de A a Z' ||
                                  dropdownvalue.toString() ==
                                      'Ordenar de Z a A')
                              ? db
                                  .collection('ejercicios')
                                  .doc('categorias')
                                  .collection('hombro')
                                  .orderBy('nombre', descending: _isDescending)
                                  .snapshots()
                              : db
                                  .collection('ejercicios')
                                  .doc('categorias')
                                  .collection('hombro')
                                  .orderBy('timestamp',
                                      descending: _isDescending)
                                  .snapshots(),
                          builder: (context, snapshot) {
                            _isConnected();

                            if (_isConnectedBool == true) {
                              if (!snapshot.hasData) {
                                return new Container(
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
                                                    : Color.fromRGBO(
                                                        1, 29, 69, 1)))));
                              } else {
                                if (!snapshot.data!.docs.isEmpty) {
                                  return new Column(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(30, 10, 30, 10),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                          ),
                                          child: TextField(
                                            autocorrect: false,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            controller: _controllerSearch,
                                            onChanged: (value) {
                                              uid_final = '';
                                              _nombre = '';
                                              _descripcion = '';
                                              _imagen = '';
                                              _isPressed = false;
                                              setState(() {});
                                            },
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.all(10.0),
                                              labelText: "Buscar ejercicio",
                                              hintText: "Busca un ejercicio...",
                                              prefixIcon: Icon(
                                                Icons.search,
                                                color: Color.fromRGBO(
                                                    1, 29, 69, 1),
                                              ),
                                              suffixIcon: (_controllerSearch
                                                          .text ==
                                                      '')
                                                  ? null
                                                  : IconButton(
                                                      splashColor:
                                                          Colors.black45,
                                                      splashRadius: 25,
                                                      icon: Icon(Icons.close,
                                                          color: Color.fromRGBO(
                                                              1, 29, 69, 1),
                                                          size: 22.5),
                                                      onPressed: () {
                                                        _controllerSearch
                                                            .clear();
                                                        setState(() {});
                                                      },
                                                    ),
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.never,
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(15))),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Color.fromRGBO(
                                                        45, 44, 45, 1),
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          color: (_isOscuro)
                                              ? Color.fromRGBO(31, 31, 31, 1)
                                              : Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2.5, vertical: 2.5),
                                            child: Scrollbar(
                                              thickness: 10,
                                              radius: Radius.circular(10),
                                              child: ListView(
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                children: snapshot.data!.docs
                                                    .map((doc) {
                                                  return (doc['nombre']
                                                              .toString()
                                                              .toLowerCase()
                                                              .contains(
                                                                  _controllerSearch
                                                                      .text
                                                                      .toLowerCase()) ||
                                                          doc['descripcion']
                                                              .toString()
                                                              .toLowerCase()
                                                              .contains(
                                                                  _controllerSearch
                                                                      .text
                                                                      .toLowerCase()))
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  20, 0, 20, 0),
                                                          child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          bottom:
                                                                              10.0),
                                                                  width: double
                                                                      .infinity,
                                                                  height: 350,
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      if (_nombre ==
                                                                          doc['nombre']) {
                                                                        if (_isPressed) {
                                                                          _nombre =
                                                                              '';
                                                                          _isPressed =
                                                                              false;
                                                                        } else {
                                                                          _isPressed =
                                                                              !_isPressed;
                                                                          _descripcion =
                                                                              doc['descripcion'];
                                                                          _controllerNombre.text =
                                                                              _nombre!;
                                                                          _controllerDescripcion.text =
                                                                              _descripcion!;
                                                                          _imagen =
                                                                              doc['imagenURL'];
                                                                          uid_final =
                                                                              doc.id;
                                                                          _uid =
                                                                              doc.id;
                                                                        }
                                                                      } else {
                                                                        if (!_isPressed) {
                                                                          _isPressed =
                                                                              true;
                                                                        }
                                                                        _nombre =
                                                                            doc['nombre'];
                                                                        _descripcion =
                                                                            doc['descripcion'];
                                                                        _controllerNombre.text =
                                                                            _nombre!;
                                                                        _controllerDescripcion.text =
                                                                            _descripcion!;
                                                                        _imagen =
                                                                            doc['imagenURL'];
                                                                        uid_final =
                                                                            doc.id;
                                                                        _uid = doc
                                                                            .id;
                                                                      }

                                                                      setState(
                                                                          () {});
                                                                    },
                                                                    child:
                                                                        Stack(
                                                                      alignment:
                                                                          Alignment
                                                                              .bottomCenter,
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              350,
                                                                          height:
                                                                              350,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(15)),
                                                                            image:
                                                                                DecorationImage(
                                                                              image: AssetImage('assets/images/picture_default.png'),
                                                                              fit: BoxFit.fill,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              CachedNetworkImage(
                                                                            imageUrl:
                                                                                doc['imagenURL'],
                                                                            imageBuilder: (context, imageProvider) =>
                                                                                Container(
                                                                              width: 350,
                                                                              height: 350,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                              ),
                                                                            ),
                                                                            placeholder: (context, url) =>
                                                                                Center(child: Container(width: 100, height: 100, child: CircularProgressIndicator(color: Colors.white))),
                                                                            errorWidget: (context, url, error) =>
                                                                                Icon(Icons.error),
                                                                          ),
                                                                        ),
                                                                        AnimatedContainer(
                                                                            padding:
                                                                                EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                                                            width: double.infinity,
                                                                            height: (doc['nombre'] == _nombre && _isPressed) ? 250 : 125,
                                                                            decoration: BoxDecoration(
                                                                              color: (doc['nombre'] == _nombre && _isPressed) ? Color.fromRGBO(3, 26, 59, 0.95) : Color.fromRGBO(44, 181, 110, 1),
                                                                              borderRadius: BorderRadius.all(Radius.circular(15)),
                                                                            ),
                                                                            duration: const Duration(seconds: 1),
                                                                            curve: Curves.fastOutSlowIn,
                                                                            margin: EdgeInsets.all(10),
                                                                            child: SingleChildScrollView(
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  Container(
                                                                                    alignment: AlignmentDirectional.center,
                                                                                    height: 100,
                                                                                    child: Text(
                                                                                      doc['nombre'],
                                                                                      textAlign: TextAlign.center,
                                                                                      style: GoogleFonts.poppins(textStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 23, fontWeight: FontWeight.w200, color: Colors.white)),
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      maxLines: 3,
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(height: 10),
                                                                                  Text(
                                                                                    doc['descripcion'],
                                                                                    textAlign: TextAlign.justify,
                                                                                    style: GoogleFonts.poppins(textStyle: TextStyle(fontStyle: FontStyle.normal, fontSize: 18, fontWeight: FontWeight.w400, color: Colors.white)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            )),
                                                                      ],
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
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return new Container(
                                    color: (_isOscuro)
                                        ? Color.fromRGBO(31, 31, 31, 1)
                                        : Colors.white,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.query_stats_rounded,
                                              color: Color.fromRGBO(
                                                  95, 189, 132, 1),
                                              size: 110),
                                          SizedBox(height: 15),
                                          Text('No existen ejercicios',
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 20,
                                                  color: (_isOscuro)
                                                      ? Colors.white
                                                      : Color.fromRGBO(
                                                          31, 31, 31, 1),
                                                  fontWeight:
                                                      FontWeight.normal)),
                                          SizedBox(height: 5),
                                          Text('para esta categoría...',
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 20,
                                                  color: (_isOscuro)
                                                      ? Colors.white
                                                      : Color.fromRGBO(
                                                          31, 31, 31, 1),
                                                  fontWeight:
                                                      FontWeight.normal)),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              }
                            } else {
                              return new Container(
                                color: (_isOscuro)
                                    ? Color.fromRGBO(31, 31, 31, 1)
                                    : Colors.white,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.warning_rounded,
                                          color: Colors.red[900], size: 110),
                                      SizedBox(height: 15),
                                      Text('No se ha podido establecer',
                                          style: GoogleFonts.montserrat(
                                              fontSize: 20,
                                              color: (_isOscuro)
                                                  ? Colors.white
                                                  : Color.fromRGBO(
                                                      31, 31, 31, 1),
                                              fontWeight: FontWeight.normal)),
                                      SizedBox(height: 5),
                                      Text('conexión con el servidor',
                                          style: GoogleFonts.montserrat(
                                              fontSize: 20,
                                              color: (_isOscuro)
                                                  ? Colors.white
                                                  : Color.fromRGBO(
                                                      31, 31, 31, 1),
                                              fontWeight: FontWeight.normal)),
                                    ],
                                  ),
                                ),
                              );
                            }
                          }),
                    ],
                  )),
            );
          } else {
            return new Container(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class CrearEjercicio extends StatefulWidget {
  const CrearEjercicio({Key? key}) : super(key: key);

  @override
  State<CrearEjercicio> createState() => _CrearEjercicioState();
}

class _CrearEjercicioState extends State<CrearEjercicio> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return new SafeArea(
      child: Scaffold(
        backgroundColor:
            (_isOscuro) ? Color.fromRGBO(31, 31, 31, 1) : Colors.white,
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(72, 83, 98, 1),
          leading: IconButton(
              splashRadius: 25,
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                _nombre = '';
                _namePic = '';
                _filePicked = null;
                _filePic = null;
                _isPressed = false;
                _controllerNombre.clear();
                _controllerDescripcion.clear();

                setState(() {});

                Navigator.pushReplacement(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade,
                        child: PantallaHombro(),
                        duration: Duration(milliseconds: 250)));
              }),
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text('CREAR EJERCICIO',
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15)),
                          boxShadow: [
                            BoxShadow(color: Colors.black, blurRadius: 5)
                          ]),
                      width: double.infinity,
                      height: 350,
                      child: Container(
                        child: Container(
                          width: 600,
                          height: 600,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15)),
                            boxShadow: [
                              BoxShadow(color: Colors.black, blurRadius: 5)
                            ],
                            image: DecorationImage(
                                image: (_filePicked == null ||
                                        _filePic == null ||
                                        _namePic == '')
                                    ? AssetImage(
                                        'assets/images/picture_default.png')
                                    : (_filePic.toString().contains('File')
                                        ? FileImage(_filePic!) as ImageProvider
                                        : AssetImage(
                                            'assets/images/picture_default.png')),
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30,
                    right: 30,
                    child: IgnorePointer(
                      ignoring: (_namePic != '') ? false : true,
                      child: AnimatedOpacity(
                        opacity: (_namePic != '') ? 1 : 0,
                        duration: Duration(milliseconds: 500),
                        child: Container(
                          width: 40,
                          height: 40,
                          child: new FloatingActionButton(
                            heroTag: null,
                            onPressed: () async {
                              _filePic = null;
                              _filePicked = null;
                              _namePic = '';
                              setState(() {});
                            },
                            child: Icon(Icons.close_rounded,
                                size: 20, color: Colors.white),
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      top: 290,
                      left: 30,
                      child: new FloatingActionButton(
                        heroTag: null,
                        onPressed: () async {
                          _filePicked = await ImagePicker().pickImage(
                            source: ImageSource.camera,
                          );

                          if (_filePicked == null) {
                            _namePic = '';
                            _filePicked == null;
                            _filePic == null;
                          } else {
                            int bytes = await _filePicked!.length();
                            final kb = bytes / 1024;
                            final mb = kb / 1024;

                            if (mb > 3) {
                              _namePic = '';
                              _filePicked == null;
                              _filePic == null;

                              Get.snackbar(
                                "Se excedió el tamaño máximo", // title
                                "Intente seleccionar una imagen no mayor a 3MB", // message
                                icon: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Icon(Icons.error_outline_rounded,
                                      color: Colors.white),
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                              );
                            } else {
                              _namePic = File(_filePicked!.name);
                              _filePic = File(_filePicked!.path);
                            }
                          }
                          setState(() {});
                        },
                        child: Icon(Icons.camera_alt_outlined,
                            size: 40, color: Colors.white),
                        backgroundColor: Color.fromRGBO(72, 83, 98, 1),
                      )),
                  Positioned(
                      top: 290,
                      right: 30,
                      child: new FloatingActionButton(
                        heroTag: null,
                        onPressed: () async {
                          _filePicked = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                          );

                          if (_filePicked == null) {
                            _namePic = '';
                            _filePicked == null;
                            _filePic == null;
                          } else {
                            int bytes = await _filePicked!.length();
                            final kb = bytes / 1024;
                            final mb = kb / 1024;

                            if (mb > 3) {
                              _namePic = '';
                              _filePicked == null;
                              _filePic == null;

                              Get.snackbar(
                                "Se excedió el tamaño máximo", // title
                                "Intente seleccionar una imagen no mayor a 3MB", // message
                                icon: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Icon(Icons.error_outline_rounded,
                                      color: Colors.white),
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                              );
                            } else {
                              _namePic = File(_filePicked!.name);
                              _filePic = File(_filePicked!.path);
                            }
                          }
                          setState(() {});
                        },
                        child: Icon(Icons.photo_library_sharp,
                            size: 40, color: Colors.white),
                        backgroundColor: Color.fromRGBO(72, 83, 98, 1),
                      ))
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15)),
                    ),
                    child: Form(
                        child: Column(children: [
                      SizedBox(height: 10),
                      TextFormField(
                        maxLength: 65,
                        controller: _controllerNombre,
                        decoration: InputDecoration(
                          hintText: 'Ejercicio',
                          labelText: 'Nombre del Ejercicio',
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        textAlign: TextAlign.justify,
                        maxLines: 3,
                        controller: _controllerDescripcion,
                        decoration: InputDecoration(
                          hintText: 'Escriba algo...',
                          labelText: 'Descripción:',
                        ),
                      ),
                      SizedBox(height: 20),
                    ]))),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                    color: Color.fromRGBO(72, 83, 98, 1),
                    borderRadius: BorderRadius.circular(20)),
                child: Material(
                  color: Colors.transparent,
                  child: new InkWell(
                    customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    splashColor: Colors.white38,
                    onTap: () async {
                      try {
                        final result =
                            await InternetAddress.lookup('example.com');

                        if (result.isNotEmpty &&
                            result[0].rawAddress.isNotEmpty) {
                          if (_controllerNombre.text == '' ||
                              _controllerDescripcion.text == '') {
                            Get.snackbar(
                              "Error en la creación", // title
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                            );
                          } else {
                            showLoading();

                            final uid_final = await FirebaseFirestore.instance
                                .collection('ejercicios')
                                .doc('categorias')
                                .collection('hombro')
                                .add({
                              "nombre": toBeginningOfSentenceCase(
                                  _controllerNombre.text.trim()),
                              "descripcion": toBeginningOfSentenceCase(
                                  _controllerDescripcion.text.trim()),
                              "imagenURL":
                                  "https://firebasestorage.googleapis.com/v0/b/gymbook-services.appspot.com/o/picture_default.png?alt=media&token=f6b01dbf-2845-4dc1-9843-9303ca5c7fbc",
                              'timestamp': Timestamp.now()
                            });

                            if (_namePic.toString().contains('File')) {
                              final destination =
                                  'ejercicios/hombro/${uid_final.id}/foto_${uid_final.id}';

                              setState(() {});
                              task = FirebaseApi.uploadFile(
                                  destination, _filePic!);

                              if (task == null) return;

                              try {
                                final snapshot = await task!.whenComplete(() {
                                  task = null;
                                });
                                final urlDownload =
                                    await snapshot.ref.getDownloadURL();

                                _imagen = urlDownload;

                                FirebaseFirestore.instance
                                    .collection("ejercicios")
                                    .doc('categorias')
                                    .collection('hombro')
                                    .doc(uid_final.id)
                                    .update({'imagenURL': _imagen}).catchError(
                                        (error) {
                                  Get.snackbar(
                                      "Error", // title
                                      "No hay conexión a Internet", // message
                                      icon: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Icon(Icons.wifi_off_rounded,
                                            color: Colors.white),
                                      ),
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10),
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
                                });
                              } catch (e) {
                                Get.snackbar(
                                    "Error", // title
                                    "No hay conexión a Internet", // message
                                    icon: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Icon(Icons.wifi_off_rounded,
                                          color: Colors.white),
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
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8));
                                ;
                              }
                            }

                            dismissLoadingWidget();

                            _namePic = '';
                            _filePic = null;
                            _filePicked = null;

                            Navigator.pop(context);
                          }
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8));
                      }

                      setState(() {});

                      if (task == null) {
                        setState(() {});
                      }
                    },
                    child: Container(
                      height: 55,
                      width: 140,
                      child: Center(
                        child: task != null
                            ? buildUploadStatus(task!)
                            : Text(
                                'CREAR',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(1);

            return new Center(
              child: Text(
                (snap != null) ? '$percentage %' : 'LISTO',
                style: TextStyle(fontSize: 17, color: Colors.white),
              ),
            );
          } else {
            return new Center();
          }
        },
      );
}

class EditarEjercicio extends StatefulWidget {
  const EditarEjercicio({Key? key}) : super(key: key);

  @override
  State<EditarEjercicio> createState() => _EditarEjercicioState();
}

class _EditarEjercicioState extends State<EditarEjercicio> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return new SafeArea(
      child: Scaffold(
        backgroundColor:
            (_isOscuro) ? Color.fromRGBO(31, 31, 31, 1) : Colors.white,
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(72, 83, 98, 1),
          leading: IconButton(
              splashRadius: 25,
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                _nombre = '';
                _namePic = '';
                _filePicked = null;
                _filePic = null;
                _isPressed = false;
                _controllerNombre.clear();
                _controllerDescripcion.clear();

                setState(() {});

                Navigator.pushReplacement(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade,
                        child: PantallaHombro(),
                        duration: Duration(milliseconds: 250)));
              }),
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text('EDITAR EJERCICIO',
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white60,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15)),
                          boxShadow: [
                            BoxShadow(color: Colors.black, blurRadius: 5)
                          ]),
                      width: double.infinity,
                      height: 350,
                      child: Container(
                        width: 600,
                        height: 600,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(72, 83, 98, 1),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15)),
                          boxShadow: [
                            BoxShadow(color: Colors.black, blurRadius: 5)
                          ],
                          image: DecorationImage(
                              image: (_filePicked == null ||
                                      _filePic == null ||
                                      _namePic == '')
                                  ? CachedNetworkImageProvider(_imagen!,
                                      maxHeight: 350, maxWidth: 350)
                                  : (_filePic.toString().contains('File')
                                      ? FileImage(_filePic!) as ImageProvider
                                      : AssetImage(
                                          'assets/images/picture_default.png')),
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30,
                    right: 30,
                    child: IgnorePointer(
                      ignoring: (_namePic != '') ? false : true,
                      child: AnimatedOpacity(
                        opacity: (_namePic != '') ? 1 : 0,
                        duration: Duration(milliseconds: 500),
                        child: Container(
                          width: 40,
                          height: 40,
                          child: new FloatingActionButton(
                            heroTag: null,
                            onPressed: () async {
                              _filePic = null;
                              _filePicked = null;
                              _namePic = '';
                              setState(() {});
                            },
                            child: Icon(Icons.close_rounded,
                                size: 20, color: Colors.white),
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      top: 290,
                      left: 30,
                      child: new FloatingActionButton(
                        heroTag: null,
                        onPressed: () async {
                          _filePicked = await ImagePicker().pickImage(
                            source: ImageSource.camera,
                          );

                          if (_filePicked == null) {
                            _namePic = '';
                            _filePicked == null;
                            _filePic == null;
                          } else {
                            int bytes = await _filePicked!.length();
                            final kb = bytes / 1024;
                            final mb = kb / 1024;

                            if (mb > 3) {
                              _namePic = '';
                              _filePicked == null;
                              _filePic == null;

                              Get.snackbar(
                                "Se excedió el tamaño máximo", // title
                                "Intente seleccionar una imagen no mayor a 3MB", // message
                                icon: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Icon(Icons.error_outline_rounded,
                                      color: Colors.white),
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                              );
                            } else {
                              _namePic = File(_filePicked!.name);
                              _filePic = File(_filePicked!.path);
                            }
                          }
                          setState(() {});
                        },
                        child: Icon(Icons.camera_alt_outlined,
                            size: 40, color: Colors.white),
                        backgroundColor: Color.fromRGBO(72, 83, 98, 1),
                      )),
                  Positioned(
                      top: 290,
                      right: 30,
                      child: new FloatingActionButton(
                        heroTag: null,
                        onPressed: () async {
                          _filePicked = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                          );

                          if (_filePicked == null) {
                            _namePic = '';
                            _filePicked == null;
                            _filePic == null;
                          } else {
                            int bytes = await _filePicked!.length();
                            final kb = bytes / 1024;
                            final mb = kb / 1024;

                            if (mb > 3) {
                              _namePic = '';
                              _filePicked == null;
                              _filePic == null;

                              Get.snackbar(
                                "Se excedió el tamaño máximo", // title
                                "Intente seleccionar una imagen no mayor a 3MB", // message
                                icon: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Icon(Icons.error_outline_rounded,
                                      color: Colors.white),
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                              );
                            } else {
                              _namePic = File(_filePicked!.name);
                              _filePic = File(_filePicked!.path);
                            }
                          }
                          setState(() {});
                        },
                        child: Icon(Icons.photo_library_sharp,
                            size: 40, color: Colors.white),
                        backgroundColor: Color.fromRGBO(72, 83, 98, 1),
                      ))
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15)),
                    ),
                    child: Form(
                        child: Column(children: [
                      SizedBox(height: 10),
                      TextFormField(
                        maxLength: 65,
                        controller: _controllerNombre,
                        decoration: InputDecoration(
                          hintText: 'Ejercicio',
                          labelText: 'Nombre del Ejercicio',
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        textAlign: TextAlign.justify,
                        maxLines: 3,
                        controller: _controllerDescripcion,
                        decoration: InputDecoration(
                          hintText: 'Escriba algo...',
                          labelText: 'Descripción:',
                        ),
                      ),
                      SizedBox(height: 20),
                    ]))),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                    color: Color.fromRGBO(72, 83, 98, 1),
                    borderRadius: BorderRadius.circular(20)),
                child: Material(
                  color: Colors.transparent,
                  child: new InkWell(
                    customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    splashColor: Colors.white38,
                    onTap: () async {
                      try {
                        final result =
                            await InternetAddress.lookup('example.com');

                        if (result.isNotEmpty &&
                            result[0].rawAddress.isNotEmpty) {
                          if (_controllerNombre.text == '' ||
                              _controllerDescripcion.text == '') {
                            Get.snackbar(
                              "Error en la actualización", // title
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                            );
                          } else {
                            showLoading();

                            await FirebaseFirestore.instance
                                .collection('ejercicios')
                                .doc('categorias')
                                .collection('hombro')
                                .doc(_uid)
                                .update({
                              "nombre": toBeginningOfSentenceCase(
                                  _controllerNombre.text.trim()),
                              "descripcion": toBeginningOfSentenceCase(
                                  _controllerDescripcion.text.trim()),
                              'timestamp': Timestamp.now()
                            });

                            if (_namePic.toString().contains('File')) {
                              final destination =
                                  'ejercicios/hombro/${_uid}/foto_${_uid}';

                              setState(() {});
                              task = FirebaseApi.uploadFile(
                                  destination, _filePic!);

                              if (task == null) return;

                              try {
                                final snapshot = await task!.whenComplete(() {
                                  task = null;
                                });
                                final urlDownload =
                                    await snapshot.ref.getDownloadURL();

                                _imagen = urlDownload;

                                FirebaseFirestore.instance
                                    .collection("ejercicios")
                                    .doc('categorias')
                                    .collection('hombro')
                                    .doc(_uid)
                                    .update({'imagenURL': _imagen}).catchError(
                                        (error) {
                                  Get.snackbar(
                                      "Error", // title
                                      "No hay conexión a Internet", // message
                                      icon: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Icon(Icons.wifi_off_rounded,
                                            color: Colors.white),
                                      ),
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10),
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
                                });
                              } catch (e) {
                                Get.snackbar(
                                    "Error", // title
                                    "No hay conexión a Internet", // message
                                    icon: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Icon(Icons.wifi_off_rounded,
                                          color: Colors.white),
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
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8));
                                ;
                              }
                            }

                            dismissLoadingWidget();

                            _namePic = '';
                            _filePic = null;
                            _filePicked = null;

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PantallaHombro()));
                          }
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8));
                      }

                      setState(() {});

                      if (task == null) {
                        setState(() {});
                      }
                    },
                    child: Container(
                      height: 55,
                      width: 140,
                      child: Center(
                        child: task != null
                            ? buildUploadStatus(task!)
                            : Text(
                                'ACEPTAR',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(1);

            return new Center(
              child: Text(
                (snap != null) ? '$percentage %' : 'LISTO',
                style: TextStyle(fontSize: 17, color: Colors.white),
              ),
            );
          } else {
            return new Center();
          }
        },
      );
}
