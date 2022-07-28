import 'package:flutter/material.dart';

class NotificationsService{

  static GlobalKey<ScaffoldMessengerState> messengerKey = new GlobalKey<ScaffoldMessengerState>();

  //SNACKBAR PARA MOSTRAR ERRORES
  static showSnackbar(String message){
      final snackBar = new SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blueGrey[800],
        //duration: ,
      );

      messengerKey.currentState!.showSnackBar(snackBar);

  }


}