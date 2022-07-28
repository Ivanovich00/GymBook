import 'package:flutter/material.dart';
import 'package:get/get.dart';

showLoading(){
  Get.defaultDialog(
    title: "Cargando...",
    content: CircularProgressIndicator(
        color: Colors.blueGrey[200],
        backgroundColor: Colors.black54,
      ),
    barrierDismissible: true
  );
}

dismissLoadingWidget(){
  Get.back();
}