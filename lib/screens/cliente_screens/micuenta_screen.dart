import 'dart:io';
import 'dart:ui';

import 'package:GymBook/api/firebase_api.dart';
import 'package:GymBook/helpers/showLoading.dart';
import 'package:GymBook/screens/cliente_screens/export_screens.dart';
import 'package:GymBook/screens/screens.dart';
import 'package:GymBook/services/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

class PantallaCuenta extends StatefulWidget {
  const PantallaCuenta({Key? key}) : super(key: key);

  @override
  State<PantallaCuenta> createState() => _PantallaCuentaState();
}

final userReference = FirebaseFirestore.instance.collection('clientes');

class _PantallaCuentaState extends State<PantallaCuenta> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();

  String profileUrl = '';
  String email = '';

  bool _isEdit = false;
  bool _isConnected = false;

  File? _filePic;
  XFile? _filePicked;
  var _namePic;

  String? _isFotoURL;

  bool _isOscuro = false;

  Future<void> _initGetDetails() async {
    _isEdit = false;
    task = null;
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
            .collection("clientes")
            .doc(userdoc)
            .snapshots()
            .listen((event) {
          setState(() {
            _nombreController.text = event.get('nombre').toString();
            _apellidoController.text = event.get('apellido').toString();
            _edadController.text = event.get('edad').toString();

            profileUrl = event.get('imagenURL').toString();
            email = event.get('email').toString();
            _namePic = 'user';
            _isConnected = true;
          });
        });
      }
    } catch (e) {
      _isConnected = false;
      _nombreController.clear();
      _apellidoController.clear();
      _edadController.clear();

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

  Future<void> _editDetails() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    User? user = _firebaseAuth.currentUser;

    String userdoc = user!.uid;

    try {
      final result = await InternetAddress.lookup('example.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FirebaseFirestore.instance
            .collection("clientes")
            .doc(userdoc)
            .snapshots()
            .listen((event) {
          setState(() {
            _nombreController.text = event.get('nombre').toString();
            _apellidoController.text = event.get('apellido').toString();
            _edadController.text = event.get('edad').toString();

            profileUrl = event.get('imagenURL').toString();
            email = event.get('email').toString();
            _namePic = 'user';
            _isConnected = true;
            _isEdit = true;
          });
        });
      }
    } catch (e) {
      _isConnected = false;
      _isEdit = false;

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
                        if (task == null) {
                          Navigator.pushReplacement(
                              context,
                              PageTransition(
                                  type: PageTransitionType.leftToRight,
                                  child: ClienteScreen(),
                                  duration: Duration(milliseconds: 250)));
                          _nombreController.clear();
                          _apellidoController.clear();
                          _edadController.clear();
                          profileUrl = '';
                          email = '';
                        }
                      }),
                  backgroundColor: Color.fromRGBO(71, 83, 97, 1),
                  elevation: 0,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text('MI PERFIL',
                            style: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    InkWell(
                      radius: 0,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        setState(() {});
                      },
                      child:
                          // ignore: deprecated_member_use
                          Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: (_isOscuro)
                                ? Colors.white
                                : Color.fromRGBO(31, 31, 31, 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    'Modo\nOscuro',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: width * 0.03,
                                      color: (_isOscuro)
                                          ? Color.fromRGBO(31, 31, 31, 1)
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                                CupertinoSwitch(
                                  trackColor: Colors.white24,
                                  value: _isOscuro,
                                  onChanged: (value) async {
                                    _isOscuro = value;

                                    if (value) {
                                      await storage.write(
                                          key: 'TEMA', value: 'OSCURO');
                                    } else {
                                      await storage.write(
                                          key: 'TEMA', value: 'BRILLO');
                                    }

                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: RefreshIndicator(
                        onRefresh: () => _initGetDetails(),
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              SizedBox(height: 55),
                              Container(
                                constraints: BoxConstraints(
                                    maxHeight: width * 0.5,
                                    maxWidth: width * 0.5),
                                child: Stack(children: [
                                  Container(
                                      height: width * 0.5,
                                      width: width * 0.5,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: Container(
                                          height: width * 0.5,
                                          width: width * 0.5,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: _isOscuro
                                                      ? Colors.white
                                                      : Color.fromRGBO(
                                                          31, 31, 31, 1),
                                                  spreadRadius: 3)
                                            ],
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    'assets/images/loading2.gif'),
                                                fit: BoxFit.cover),
                                          ),
                                          child: CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            backgroundImage: (!_isConnected)
                                                ? AssetImage(
                                                    'assets/images/account_default.png')
                                                : (_namePic == 'user')
                                                    ? NetworkImage(profileUrl)
                                                    : (_namePic
                                                            .toString()
                                                            .contains('File'))
                                                        ? FileImage(_filePic!)
                                                            as ImageProvider
                                                        : (_namePic == 'asset')
                                                            ? AssetImage(
                                                                'assets/images/account_default.png')
                                                            : null,
                                          ))),
                                  new Positioned(
                                    left: 5,
                                    top: 5,
                                    child: AnimatedOpacity(
                                      opacity: (!_isEdit) ? 0 : 1,
                                      duration: Duration(milliseconds: 300),
                                      child: Container(
                                        constraints: new BoxConstraints(
                                            maxHeight: 50, maxWidth: 50),
                                        decoration: new BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Color.fromRGBO(
                                                    31, 31, 31, 1),
                                                spreadRadius: 3),
                                          ],
                                          border: Border.all(
                                            color: Colors.black26,
                                            width: 0.5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color:
                                              Color.fromRGBO(253, 253, 253, 1),
                                          shape: BoxShape.rectangle,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (task == null) {
                                              FocusScope.of(context).unfocus();
                                              _getFromGallery();
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Icon(
                                              Icons.photo,
                                              size: 32.5,
                                              color:
                                                  Color.fromRGBO(31, 31, 31, 1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  new Positioned(
                                    right: 5,
                                    top: 5,
                                    child: AnimatedOpacity(
                                      opacity: (!_isEdit) ? 0 : 1,
                                      duration: Duration(milliseconds: 300),
                                      child: Container(
                                        constraints: new BoxConstraints(
                                            maxHeight: 50, maxWidth: 50),
                                        decoration: new BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Color.fromRGBO(31, 31, 31, 1),
                                                spreadRadius: 3),
                                          ],
                                          border: Border.all(
                                            color: Colors.black26,
                                            width: 0.5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color:
                                              Color.fromRGBO(253, 253, 253, 1),
                                          shape: BoxShape.rectangle,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (task == null) {
                                              FocusScope.of(context).unfocus();
                                              _getFromCamera();
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Icon(
                                              Icons.camera_rounded,
                                              size: 32.5,
                                              color:
                                                  Color.fromRGBO(31, 31, 31, 1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  new Positioned(
                                    right: 5,
                                    bottom: 5,
                                    child: AnimatedOpacity(
                                      opacity: (!_isEdit)
                                          ? 0
                                          : (_namePic
                                                  .toString()
                                                  .contains('File'))
                                              ? 1
                                              : (_namePic == 'user' &&
                                                      !profileUrl.contains(
                                                          'account_default'))
                                                  ? 1
                                                  : 0,
                                      duration: Duration(milliseconds: 300),
                                      child: Container(
                                        constraints: new BoxConstraints(
                                            maxHeight: 50, maxWidth: 50),
                                        decoration: new BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Color.fromRGBO(
                                                    31, 31, 31, 1),
                                                spreadRadius: 3),
                                          ],
                                          border: Border.all(
                                            color: Colors.black26,
                                            width: 0.5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          color:
                                              Color.fromRGBO(253, 253, 253, 1),
                                          shape: BoxShape.rectangle,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (task == null) {
                                              FocusScope.of(context).unfocus();
                                              setState(() {
                                                _namePic = 'asset';
                                                _filePicked == null;
                                                _filePic == null;
                                              });
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Icon(
                                              Icons.clear_rounded,
                                              size: 32.5,
                                              color: Colors.red[800],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                              SizedBox(height: 25),
                              Text(
                                email,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300,
                                  fontSize: width * 0.05,
                                  color: (_isOscuro)
                                      ? Colors.white
                                      : Colors.black45,
                                ),
                              ),
                              SizedBox(height: 20),
                              AbsorbPointer(
                                absorbing: !_isEdit,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Center(
                                    child: Column(children: [
                                      Container(
                                        height: width * 0.15,
                                        decoration: const BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              spreadRadius: 0.01,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.15),
                                              blurRadius: 12.0,
                                            ),
                                          ],
                                        ),
                                        child: Card(
                                          elevation: 0,
                                          shadowColor: Colors.black38,
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: TextFormField(
                                              controller: _nombreController,
                                              style: GoogleFonts.poppins(
                                                  fontSize: width * 0.05,
                                                  color: Colors.black),
                                              decoration: InputDecoration(
                                                fillColor: Colors.white,
                                                contentPadding: EdgeInsets.zero,
                                                prefixIcon: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 5.0),
                                                  child: Container(
                                                    height: height,
                                                    margin: EdgeInsets.only(
                                                        right: width * 0.01),
                                                    width: width * 0.115,
                                                    decoration: const BoxDecoration(
                                                        color: Color.fromRGBO(
                                                            44, 181, 110, 1),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        5),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        5))),
                                                    child: const Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                hintText: '  Nombre',
                                                hintStyle: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: width * 0.05,
                                                  color: Colors.black45,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      width: 1,
                                                      color:
                                                          Colors.transparent),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                // focusColor: purple,
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.transparent,
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.white),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(RegExp("[a-zA-Z\u00f1\u00d1]*"))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                        height: width * 0.15,
                                        decoration: const BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              spreadRadius: 0.01,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.15),
                                              blurRadius: 12.0,
                                            ),
                                          ],
                                        ),
                                        child: Card(
                                          elevation: 0,
                                          shadowColor: Colors.black38,
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: TextFormField(
                                              controller: _apellidoController,
                                              style: GoogleFonts.poppins(
                                                  fontSize: width * 0.05,
                                                  color: Colors.black),
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.zero,
                                                prefixIcon: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 5.0),
                                                  child: Container(
                                                    height: height,
                                                    margin: EdgeInsets.only(
                                                        right: width * 0.01),
                                                    width: width * 0.115,
                                                    decoration: const BoxDecoration(
                                                        color: Color.fromRGBO(
                                                            44, 181, 110, 1),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        5),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        5))),
                                                    child: const Icon(
                                                      Icons.person_outline,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                hintText: '  Apellido',
                                                hintStyle: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: width * 0.05,
                                                  color: Colors.black45,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      width: 1,
                                                      color:
                                                          Colors.transparent),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                // focusColor: purple,
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.transparent,
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.white),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(RegExp("[a-zA-Z\u00f1\u00d1]*"))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                        height: width * 0.15,
                                        decoration: const BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              spreadRadius: 0.01,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.15),
                                              blurRadius: 12.0,
                                            ),
                                          ],
                                        ),
                                        child: Card(
                                          elevation: 0,
                                          shadowColor: Colors.black38,
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: TextFormField(
                                              controller: _edadController,
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      decimal: false,
                                                      signed: false),
                                              style: GoogleFonts.poppins(
                                                  fontSize: width * 0.05,
                                                  color: Colors.black),
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.zero,
                                                prefixIcon: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 5.0),
                                                  child: Container(
                                                    height: height,
                                                    margin: EdgeInsets.only(
                                                        right: width * 0.01),
                                                    width: width * 0.115,
                                                    decoration: const BoxDecoration(
                                                        color: Color.fromRGBO(
                                                            44, 181, 110, 1),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        5),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        5))),
                                                    child: const Icon(
                                                      Icons
                                                          .app_registration_rounded,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                hintText: '  Edad',
                                                hintStyle: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: width * 0.05,
                                                  color: Colors.black45,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      width: 1,
                                                      color:
                                                          Colors.transparent),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                // focusColor: purple,
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.transparent,
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.white),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(RegExp("[0-9]"))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                    ]),
                                  ),
                                ),
                              ),
                              Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  AnimatedOpacity(
                                    opacity: (_isEdit) ? 1 : 0,
                                    duration: Duration(milliseconds: 350),
                                    child: Visibility(
                                      visible: _isEdit,
                                      maintainState: false,
                                      maintainAnimation: false,
                                      maintainSize: false,
                                      maintainSemantics: false,
                                      maintainInteractivity: false,
                                      child: AbsorbPointer(
                                        absorbing: !_isEdit,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: width * 0.12,
                                              width: width * 0.4,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.red,
                                                  onPrimary: Colors.red,
                                                  // foreground
                                                ),
                                                onPressed: () async {
                                                  if (task == null) {
                                                    showCancelarDialog(context);
                                                  }
                                                },
                                                child: Text(
                                                  'CANCELAR',
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 15),
                                            SizedBox(
                                              height: width * 0.12,
                                              width: width * 0.4,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: !_isOscuro
                                                      ? Color.fromRGBO(
                                                          31, 31, 31, 1)
                                                      : Colors.white,
                                                  onPrimary: _isOscuro
                                                      ? Color.fromRGBO(
                                                          31, 31, 31, 1)
                                                      : Colors.white,
                                                  // foreground
                                                ),
                                                onPressed: () async {
                                                  if (task == null) {
                                                    showActualizarDialog(
                                                        context);
                                                  }
                                                },
                                                child: task != null
                                                    ? buildUploadStatus(task!)
                                                    : Text(
                                                        'ACTUALIZAR',
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          color: _isOscuro
                                                              ? Color.fromRGBO(
                                                                  31, 31, 31, 1)
                                                              : Colors.white,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  AnimatedOpacity(
                                    opacity: (!_isEdit) ? 1 : 0,
                                    duration: Duration(milliseconds: 350),
                                    child: Visibility(
                                      visible: !_isEdit,
                                      maintainState: false,
                                      maintainAnimation: false,
                                      maintainSize: false,
                                      maintainSemantics: false,
                                      maintainInteractivity: false,
                                      child: SizedBox(
                                        height: width * 0.12,
                                        width: width * 0.4,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            primary: !_isOscuro
                                                ? Color.fromRGBO(31, 31, 31, 1)
                                                : Colors.white,
                                            onPrimary: _isOscuro
                                                ? Color.fromRGBO(31, 31, 31, 1)
                                                : Colors.white,
                                            // foreground
                                          ),
                                          onPressed: () async {
                                            if (task == null) {
                                              _isEdit = true;
                                              _editDetails();
                                              setState(() {});
                                            }
                                          },
                                          child: Text(
                                            'EDITAR',
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: _isOscuro
                                                  ? Color.fromRGBO(0, 0, 0, 1)
                                                  : Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                //bottomNavigationBar: BarraNavegacionDos(),
              ),
            );
          } else {
            return Center(
              child: Container(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(color: Colors.red),
              ),
            );
          }
        });
  }

  void _getFromGallery() async {
    _filePicked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (_filePicked == null) {
      return;
    } else {
      int bytes = await _filePicked!.length();
      final kb = bytes / 1024;
      final mb = kb / 1024;

      if (mb > 5) {
        _namePic = 'asset';
        _filePicked == null;
        _filePic == null;

        Get.snackbar(
          "Se excedió el tamaño máximo", // title
          "Intente seleccionar una imagen no mayor a 3MB", // message
          icon: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Icon(Icons.error_outline_rounded, color: Colors.white),
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
        _namePic = File(_filePicked!.name);
        _filePic = File(_filePicked!.path);
      }
    }
    setState(() {});
  }

  void _getFromCamera() async {
    _filePicked = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (_filePicked == null) {
      return;
    } else {
      int bytes = await _filePicked!.length();
      final kb = bytes / 1024;
      final mb = kb / 1024;

      if (mb > 5) {
        _namePic = 'asset';
        _filePicked == null;
        _filePic == null;

        Get.snackbar(
          "Se excedió el tamaño máximo", // title
          "Intente seleccionar una imagen no mayor a 3MB", // message
          icon: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Icon(Icons.error_outline_rounded, color: Colors.white),
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
        _namePic = File(_filePicked!.name);
        _filePic = File(_filePicked!.path);
      }
    }
    setState(() {});
  }

  showCancelarDialog(BuildContext context) {
    FocusScope.of(context).unfocus();
    Widget cancelButton = TextButton(
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: BorderSide(color: Colors.black)))),
      child: Text("NO"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: BorderSide(color: Colors.red)))),
      child: Text("SI"),
      onPressed: () {
        setState(() {
          _initGetDetails();
          Navigator.of(context).pop();
        });
      },
    );

    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      title: Text("Cancelar actualización",
          style: TextStyle(
              fontStyle: FontStyle.normal,
              fontSize: 19.0,
              fontWeight: FontWeight.bold,
              color: Colors.black)),
      content: Text("¿Estas seguro de no actualizar tu perfil?",
          style: GoogleFonts.poppins(
              textStyle: TextStyle(
                  fontStyle: FontStyle.normal,
                  fontSize: 17.0,
                  fontWeight: FontWeight.w300,
                  color: Colors.black))),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), child: alert);
      },
    );
  }

  showActualizarDialog(BuildContext context) {
    FocusScope.of(context).unfocus();
    Widget cancelButton = TextButton(
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: BorderSide(color: Colors.red)))),
      child: Text("Cancelar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: BorderSide(color: Colors.black)))),
      child: Text("Guardar"),
      onPressed: () async {
        Navigator.of(context).pop();
        FocusScope.of(context).unfocus();

        final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
        User? user = _firebaseAuth.currentUser;
        String userdoc = user!.uid;

        try {
          final result = await InternetAddress.lookup('example.com');

          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            int edad_final = int.parse(_edadController.text);

            if (_nombreController.text == '' ||
                _apellidoController.text == '' ||
                _edadController.text == '' ||
                edad_final <= 1 ||
                edad_final >= 99) {
              Get.snackbar(
                "Error en la actualizacion", // title
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

              if (_namePic.toString().contains('File')) {
                FirebaseFirestore.instance
                    .collection('clientes')
                    .doc(userdoc)
                    .update({
                  "nombre": _nombreController.text.trim(),
                  "apellido": _apellidoController.text.trim(),
                  "edad": _edadController.text.trim(),
                });

                final destination = 'users/$userdoc/foto_$userdoc';

                setState(() {});
                task = FirebaseApi.uploadFile(destination, _filePic!);

                if (task == null) return;

                try {
                  final snapshot = await task!.whenComplete(() {
                    task = null;
                    _initGetDetails();
                  });
                  final urlDownload = await snapshot.ref.getDownloadURL();

                  _isFotoURL = urlDownload;

                  FirebaseFirestore.instance
                      .collection("clientes")
                      .doc(userdoc)
                      .update({'imagenURL': _isFotoURL}).catchError(
                          (error) => _getInternetFailed());
                } catch (e) {
                  _getInternetFailed();
                }
              } else if (_namePic == 'asset') {
                FirebaseFirestore.instance
                    .collection('clientes')
                    .doc(userdoc)
                    .update({
                  "nombre": _nombreController.text.trim(),
                  "apellido": _apellidoController.text.trim(),
                  "edad": _edadController.text.trim(),
                });

                if (!profileUrl.contains('account_default')) {
                  FirebaseFirestore.instance
                      .collection("clientes")
                      .doc(userdoc)
                      .update({
                    'imagenURL':
                        'https://firebasestorage.googleapis.com/v0/b/gymbook-services.appspot.com/o/account_default.png?alt=media&token=374b407e-68e7-45d1-ab0e-ec8bd8ae881b'
                  }).catchError((error) => _getInternetFailed());
                }
              } else {
                FirebaseFirestore.instance
                    .collection('clientes')
                    .doc(userdoc)
                    .update({
                  "nombre": _nombreController.text.trim(),
                  "apellido": _apellidoController.text.trim(),
                  "edad": _edadController.text.trim(),
                });
              }

              dismissLoadingWidget();
              _updated();

              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => this.widget));
            }
          }
        } catch (e) {
          if(e.toString().contains("number")){
            Get.snackbar(
              "Error", // title
              "Ingresa una edad correcta...", // message
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
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8));
          } else {
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
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8));
          }
        }

        setState(() {});
      },
    );

    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      title: Text("Actualizar informacion",
          style: TextStyle(
              fontStyle: FontStyle.normal,
              fontSize: 19.0,
              fontWeight: FontWeight.bold,
              color: Colors.black)),
      content: Text("¿Estas seguro de actualizar tu perfil?",
          style: GoogleFonts.poppins(
              textStyle: TextStyle(
                  fontStyle: FontStyle.normal,
                  fontSize: 17.0,
                  fontWeight: FontWeight.w300,
                  color: Colors.black))),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6), child: alert);
      },
    );
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return Center(
              child: Text(
                (snap != null) ? '$percentage %' : 'ACTUALIZAR',
                style: TextStyle(fontSize: 17, color: Colors.white),
              ),
            );
          } else {
            return Center();
          }
        },
      );

  void _getInternetFailed() {
    dismissLoadingWidget();

    Get.snackbar(
      "Error al subir la imagen", // title
      "Se perdió la conexión con el servidor", // message
      icon: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Icon(Icons.signal_wifi_connected_no_internet_4,
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }

  void _updated() {
    Get.snackbar(
      "Perfil actualizado",
      "Los cambios se realizaron correctamente",
      icon: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Icon(Icons.check_circle_outline, color: Colors.white),
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.BOTTOM,
      shouldIconPulse: true,
      barBlur: 0,
      isDismissible: true,
      duration: Duration(seconds: 3),
      colorText: Colors.white,
      backgroundColor: Color.fromRGBO(85, 139, 47, 1),
      maxWidth: 350,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }
}
