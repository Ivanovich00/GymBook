import 'dart:convert';
import 'dart:io';
import 'package:GymBook/screens/login_screen.dart';
import 'package:GymBook/screens/screens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//IMPORTANTE: Ver documentacion API REST en: https://firebase.google.com/docs/reference/rest/database

class AuthService extends ChangeNotifier {
  final String _baseUrl = 'identitytoolkit.googleapis.com';
  final String _firebaseToken = 'AIzaSyDTXINnhocoF-SrTDHuj8mPRvJCVeOVusY';

  final storage = new FlutterSecureStorage();

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<String> createUser(String email, String password, String nombre, String apellido, String edad, String genero, String imagenURL, String tipo) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user;

      String userdoc = user!.uid;

      List<String> registro_total = user.metadata.creationTime.toString().split(' ');
      String registro = registro_total[0];

      await FirebaseFirestore.instance.collection("users").doc(userdoc).set({
        "tipo": tipo,
        "uid": userdoc,
        "token_message": 'null',
        "provider": "correo",
      });

      await FirebaseFirestore.instance.collection("providers").doc("correo").collection(email).doc(userdoc).set({
        "uid": userdoc,
      });

      await FirebaseFirestore.instance.collection("clientes").doc(userdoc).set({
        "email": email,
        "nombre": nombre,
        "apellido": apellido,
        "edad": edad,
        "genero": genero,
        "imagenURL": imagenURL,
        "registro": registro,
        "uid" : userdoc,
        "rutina": false,
      });

      tipo = 'cliente';

      storage.write(key: 'INFO', value: userdoc + ',' + tipo);
      storage.write(key: 'INTRO', value: 'FALSE');
      await readTheme().then((value) {
        if (value == '') {
          storage.write(key: 'TEMA', value: 'BRILLO');
        }
      });

      return "Created with UID: $userdoc";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email';
      }
    } catch (e) {
      return "Error occurred";
    }
    return 'Information Required';
  }

  Future<String?> login(String email, String password) async {
     try {
      final credential = await auth.signInWithEmailAndPassword(email: email, password: password);
      final user = credential.user;

      String userdoc = user!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userdoc)
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        String user_data = documentSnapshot.data().toString();

        List<String> user_data_array = user_data.split(',');
        String tipo = user_data_array[1].toString().replaceAll(' tipo: ', '');

        storage.write(key: 'INFO', value: userdoc + ',' + tipo);
        storage.write(key: 'INTRO', value: 'TRUE');
        await readTheme().then((value) {
          if (value == '') {
            storage.write(key: 'TEMA', value: 'BRILLO');
          }
        });

        Future.microtask(() async {
          await FirebaseMessaging.instance.getToken().then((value) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(user_data_array[0].toString().replaceAll('{uid: ', ''))
                .update({"token_message": value});
          });
        });
      });

      return "Logged with UID: $userdoc";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user';
      } else if(e.code == 'user-disabled') {
        return 'User disabled by admin';
      } else {
        return 'Error';
      }
    }
  }

  Future<String?> forgotPass(String requestType, String email) async {
    try{
      await auth.sendPasswordResetEmail(email: email);

      return 'Email sent';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        return 'Too many requests';
      } else if (e.code == 'user-not-found') {
        return 'No user found for that email';
      } else {
        return 'Error';
      }
    }
  }

  Future<bool?> checkInternet(bool isConnected) async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future logout() async {
    await storage.deleteAll();

    FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({"token_message": 'null'});

    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      final _providerData = _auth.currentUser!.providerData;
      if (_providerData.isNotEmpty) {
        if (_providerData[0].providerId.toLowerCase().contains('google')) {
          await GoogleSignIn().signOut(); // google signOut
        } else if (_providerData[0]
            .providerId
            .toLowerCase()
            .contains('facebook')) {
          await FacebookAuth.instance.login(); // facebook signOut
        }
      }
      await _auth.signOut(); // firebase email signOut
    } catch (e) {
      print(e);
    }

    return;
  }

  Future<String> readUserInfo() async {
    return await storage.read(key: 'INFO') ?? '';
  }

  Future<String> readTheme() async {
    return await storage.read(key: 'TEMA') ?? 'BRILLO';
  }

  Future<String> readIntro() async {
    return await storage.read(key: 'INTRO') ?? 'TRUE';
  }

}
