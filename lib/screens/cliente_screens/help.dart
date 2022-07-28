import 'dart:async';
import 'dart:io';
import 'package:GymBook/screens/screens.dart';
import 'package:GymBook/services/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

DateFormat dateFormat = DateFormat("dd-MM-yyyy HH:mm");

class PantallaHelpCliente extends StatefulWidget {
  final String? nombreControl_cliente, apellidoControl_cliente, emailControl_cliente;
  PantallaHelpCliente({Key? key, required this.nombreControl_cliente, required this.apellidoControl_cliente, required this.emailControl_cliente}) : super(key: key);
  @override
  State<PantallaHelpCliente> createState() => _PantallaHelpClienteState();
}

final db = FirebaseFirestore.instance;

String? userdoc;

bool _isSelected = false;
bool _isConnectedBool = true;

final TextEditingController _nombreController = TextEditingController();
final TextEditingController _apellidoController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _imagenController = TextEditingController();
final TextEditingController _sujetoController = TextEditingController();
final TextEditingController _mensajeController = TextEditingController();

class _PantallaHelpClienteState extends State<PantallaHelpCliente> {
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

    _nombreController.text = nombreControl_cliente![0].toString().toUpperCase() + nombreControl_cliente.toString().substring(1).toLowerCase();
    _apellidoController.text = apellidoControl_cliente![0].toString().toUpperCase() + apellidoControl_cliente.toString().substring(1).toLowerCase();
    _emailController.text = emailControl_cliente.toString().toLowerCase();

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
                  backgroundColor: (_isOscuro) ? Color.fromRGBO(31, 31, 31, 1) : Color.fromRGBO(255, 255, 255, 1),
                  resizeToAvoidBottomInset: true,
                  appBar: AppBar(
                    leading: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _sujetoController.text = "";
                          _mensajeController.text = "";

                          Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRight, child: ClienteScreen(), duration: Duration(milliseconds: 250)));
              
                          setState(() {});
              
                        }),
                    backgroundColor: Color.fromRGBO(71, 83, 97, 1),
                    elevation: 0,
                    title: Text(
                      'CONTACTO',
                      style: TextStyle(
                        color: Colors.white,
                      )
                    ),
                  ),
                  body: SingleChildScrollView(
                    child: Container(
                      width: width,
                      color: (_isOscuro) ? Color.fromRGBO(31, 31, 31, 1) : Color.fromRGBO(255, 255, 255, 1),
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 30),
                              Text(
                                "SUGERENCIAS Y COMENTARIOS",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: (_isOscuro) ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: width * 0.04,
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                width: width * 0.8,
                                height: height * 0.06,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  border: Border.all(color: Color.fromRGBO(44, 181, 110, 1), width: 2),
                                ),
                                child: TextFormField(
                                  initialValue: _nombreController.text + ' ' + _apellidoController.text,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w300,
                                    fontSize: width * 0.04,
                                    color: Colors.black87
                                  ),
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 5.0),
                                      child: Container(
                                        height: height,
                                        margin: EdgeInsets.only(right: width * 0.01),
                                        width: width * 0.115,
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(44, 181, 110, 1),
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    hintText: 'Nombre',
                                    hintStyle: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w300,
                                      fontSize: width * 0.04,
                                      color: (_isOscuro) ? Colors.black87 : Colors.white
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(width: 1, color:Colors.transparent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(width: 1, color:Colors.transparent),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(width: 1, color:Colors.transparent),
                                    ),
                                  ),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z\u00f1\u00d1]*"))
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                              Container(
                                width: width * 0.8,
                                height: height * 0.06,
                                decoration: BoxDecoration(
                                color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  border: Border.all(color: Color.fromRGBO(44, 181, 110, 1), width: 2),
                                ),
                                child: TextFormField(
                                  initialValue: _emailController.text.toString().toLowerCase(),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w300,
                                    fontSize: width * 0.04,
                                    color: Colors.black87
                                  ),
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 5.0),
                                      child: Container(
                                        height: height,
                                        margin: EdgeInsets.only(right: width * 0.01),
                                        width: width * 0.115,
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(44, 181, 110, 1),
                                        ),
                                        child: const Icon(
                                          Icons.email,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    hintText: 'Correo Electronico',
                                    hintStyle: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w300,
                                      fontSize: width * 0.04,
                                      color: (_isOscuro) ? Colors.black87 : Colors.white
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(width: 1, color:Colors.transparent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(width: 1, color:Colors.transparent),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(width: 1, color:Colors.transparent),
                                    ),
                                  ),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z\u00f1\u00d1]*"))
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                              Container(
                                width: width * 0.8,
                                height: height * 0.06,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  border: Border.all(color: Color.fromRGBO(44, 181, 110, 1), width: 2),
                                ),
                                child: TextFormField(
                                  controller: _sujetoController,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w300,
                                    fontSize: width * 0.04,
                                    color: Colors.black87
                                  ),
                                  readOnly: false,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 5.0),
                                      child: Container(
                                        height: height,
                                        margin: EdgeInsets.only(right: width * 0.01),
                                        width: width * 0.115,
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(44, 181, 110, 1),
                                        ),
                                        child: const Icon(
                                          Icons.subject_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    hintText: 'Sujeto',
                                    hintStyle: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w300,
                                      fontSize: width * 0.04,
                                      color: Colors.black54
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(width: 1, color:Colors.transparent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(width: 1, color:Colors.transparent),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(width: 1, color:Colors.transparent),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              Container(
                                width: width * 0.8,
                                height: height * 0.15,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  border: Border.all(color: Color.fromRGBO(44, 181, 110, 1), width: 2),
                                ),
                                child: TextFormField(
                                  controller: _mensajeController,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w300,
                                    fontSize: width * 0.04,
                                    color: Colors.black87
                                  ),
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 5.0),
                                      child: Container(
                                        height: height,
                                        margin: EdgeInsets.only(right: width * 0.01),
                                        width: width * 0.115,
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(44, 181, 110, 1),
                                        ),
                                        child: const Icon(
                                          Icons.chat,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    hintText: 'Mensaje',
                                    hintStyle: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w300,
                                      fontSize: width * 0.04,
                                      color: Colors.black54
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(width: 1, color:Colors.transparent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(width: 1, color:Colors.transparent),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(width: 1, color:Colors.transparent),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 40),
                              MaterialButton(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                disabledColor: Colors.grey,
                                elevation: 0,
                                minWidth: 150,
                                height: 45,
                                color: Color.fromRGBO(44, 181, 110, 1),
                                child: Container(
                                  child: Text(
                                    'Enviar',
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontStyle: FontStyle.normal,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white
                                      )
                                    ),
                                  )
                                ),
                                onPressed: (){
                                  if(_nombreController.text != '' && _emailController.text != '' && _sujetoController.text != '' && _mensajeController.text != ''){
                                    enviar();
                                  } else {
                                    Get.snackbar(
                                      "Error", // title
                                      "Complete correctamente los campos anteriores", // message
                                      icon: Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Icon(Icons.info, color: Colors.white),
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
                                }
                              ),
                            ],
                          ),
                      ),
                    ),
                  )
                ),
              );
          } else {
            return Container(color: (_isOscuro) ? Color.fromRGBO(31, 31, 31, 1) : Colors.white, child: Center(child: Container(width: 100, height: 100, child: CircularProgressIndicator(color: (_isOscuro) ? Colors.white : Color.fromRGBO(1, 29, 69, 1)))));
          }
        }
    );
  }

  void enviar(){
    Get.defaultDialog(
      title: "CONTACTO",
      barrierDismissible: false,
      titlePadding: EdgeInsets.all(15),
      titleStyle: TextStyle(
        fontStyle: FontStyle.normal,
        fontSize: 19.0,
        fontWeight: FontWeight.bold,
        color: Colors.black),
      radius: 15.0,
      content: Text("¿Estas seguro de enviar este mensaje?"),
      confirm: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(1, 29, 69, 1)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0),
                side: BorderSide(color: Color.fromRGBO(1, 29, 69, 1))))),
          child: Text("SI"),
          onPressed: () async {
            Navigator.of(context).pop();

            db.collection("sugerencias").add({
              "nombre" : _nombreController.text + ' ' + _apellidoController.text,
              "email" : _emailController.text,
              "sujeto" : _sujetoController.text,
              "mensaje" : _mensajeController.text,
              "registro" : DateFormat('dd/MM/yyyy h:mm a').format(DateTime.now())
            }).whenComplete((){
              _sujetoController.text = "";
              _mensajeController.text = "";

              Get.snackbar(
                "Aviso", // title
                "Mensaje enviado correctamente, muchas gracias!", // message
                icon: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(Icons.check_circle, color: Colors.white),
                ),
                margin: EdgeInsets.symmetric(vertical: 10),
                snackStyle: SnackStyle.FLOATING,
                snackPosition: SnackPosition.BOTTOM,
                shouldIconPulse: true,
                barBlur: 0,
                isDismissible: true,
                duration: Duration(seconds: 3),
                colorText: Colors.white,
                backgroundColor: Color.fromARGB(255, 60, 124, 64),
                maxWidth: 350,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              );
            });

            setState(() {});
          },
        ),
      ),
      cancel: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0),
              side: BorderSide(color: Colors.black)))),
          child: Text("NO"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );

  }

}
