import 'dart:io';

import 'package:GymBook/screens/administrador_screens/introduccion_screen.dart';
import 'package:GymBook/screens/cliente_screens/introduccion_screen.dart';
import 'package:GymBook/screens/entrenador_screens/introduccion_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:GymBook/screens/screens.dart';
import 'package:GymBook/services/services.dart';
import 'package:get/get.dart';

import 'package:provider/provider.dart';

class CheckAuthScreen extends StatefulWidget {
  @override
  State<CheckAuthScreen> createState() => _CheckAuthScreenState();
}

String _isIntro = 'TRUE';

class _CheckAuthScreenState extends State<CheckAuthScreen> {  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: FutureBuilder(
            future: authService.readUserInfo(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return SafeArea(
                  child: Container(
                    color: Color.fromARGB(255, 255, 255, 255),
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(color: Color.fromRGBO(1, 29, 69, 1)),
                      ),
                    ),
                  ),
                );
              } else {
                if (snapshot.data == '' || snapshot.data == null) {
                  Future.microtask(() {
                    storage.write(key: 'TEMA', value: 'BRILLO');
                    storage.write(key: 'INTRO', value: 'TRUE');
                    Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: LoginScreen(), duration: Duration(milliseconds: 1500)));
                  });

                  return SafeArea(
                    child: Container(
                      color: Color.fromARGB(255, 255, 255, 255),
                      child: Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(color: Color.fromRGBO(1, 29, 69, 1)),
                        ),
                      ),
                    ),
                  );
                } else {
                  List<String> user_array = snapshot.data.toString().split(',');
                  String tipo = user_array[1];

                  Future.microtask(() async {
                    await authService.readIntro().then((value){
                      if(value == 'TRUE'){
                        if (tipo == 'cliente') {
                          Get.offAll(() => IntroduccionCliente());
                        } else if (tipo == 'entrenador'){
                          Get.offAll(() => IntroduccionEntrenador());
                        } else if (tipo == 'administrador') {
                          Get.offAll(() => IntroduccionAdministrador());
                        } else if (tipo == 'eliminado') {
                          Get.snackbar(
                            "Error al iniciar sesión", // title
                            "Su cuenta ha sido suspendida, contacte con un administrador", // message
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
                            duration: Duration(seconds: 8),
                            colorText: Colors.white,
                            backgroundColor: Colors.red[800],
                            maxWidth: 350,
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          );
                        } else {
                          Get.offAll(() => LoginScreen());
                        }
                      } else {
                        if (tipo == 'cliente') {
                          Get.offAll(() => ClienteScreen());
                        } else if (tipo == 'entrenador'){
                          Get.offAll(() => EntrenadorScreen());
                        } else if (tipo == 'administrador') {
                          Get.offAll(() => AdministradorScreen());
                        } else if (tipo == 'eliminado') {
                          Get.snackbar(
                            "Error al iniciar sesión", // title
                            "Su cuenta ha sido suspendida, contacte con un administrador", // message
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
                            duration: Duration(seconds: 8),
                            colorText: Colors.white,
                            backgroundColor: Colors.red[800],
                            maxWidth: 350,
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          );
                        } else {
                          Get.offAll(() => LoginScreen());
                        }
                      }
                    });
                  });
                  
                  return SafeArea(
                    child: Container(
                      color: Color.fromARGB(255, 255, 255, 255),
                      child: Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(color: Color.fromRGBO(1, 29, 69, 1)),
                        ),
                      ),
                    ),
                  );
                }
              }

            },
          ),
        ),
      ),
    );
  }
}
