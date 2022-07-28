import 'dart:async';

import 'package:GymBook/screens/administrador_screens/crear_rutinas_screen.dart';
import 'package:GymBook/screens/screens.dart';
import 'package:GymBook/services/push_notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:GymBook/screens/screens.dart';
import 'package:GymBook/services/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await PushNotificationService.initializeApp();

  runApp(AppState());
}

class AppState extends StatefulWidget {
  @override
  State<AppState> createState() => _AppStateState();
}

class _AppStateState extends State<AppState> {
  @override
  void initState() {
    super.initState();
    
    BackButtonInterceptor.add(myInterceptor);

    PushNotificationService.messagesStream.listen((message) {
      Get.snackbar(
        message, // title
        "Tienes una nueva rutina asignada",
        icon: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Icon(Icons.fitness_center_rounded, color: Colors.black87),
        ),
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.TOP,
        shouldIconPulse: true,
        barBlur: 0,
        isDismissible: true,
        duration: Duration(seconds: 5),
        colorText: Colors.black87,
        backgroundColor: Colors.white,
      );
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Get.snackbar(
      "Funcion no permitida", // title
      "Presiona el boton de la barra superior para regresar",
      icon: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Icon(Icons.error, color: Colors.black87),
      ),
      borderColor: Colors.black,
      borderRadius: 10,
      borderWidth: 1,
      margin: EdgeInsets.symmetric(vertical: 10),
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.BOTTOM,
      shouldIconPulse: true,
      barBlur: 0,
      isDismissible: true,
      duration: Duration(seconds: 3),
      colorText: Colors.black87,
      backgroundColor: Colors.white,
      maxWidth: 350,
      padding: EdgeInsets.symmetric(
      horizontal: 8, vertical: 8),
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Carga de imagenes en la cache (Imagenes que se necesitan mostrar al inicio de la APP)
    precacheImage(AssetImage("assets/splash_icon.png"), context);
    precacheImage(AssetImage("assets/app_icon_transparent.png"), context);
    precacheImage(AssetImage("assets/images/introduction/vector-lupa.png"), context);

    return Provider(
      create: (BuildContext context) {  },
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GymBook',
        initialRoute: 'CHECKING',
        routes: {
          'CHECKING': (_) => CheckAuthScreen(),
    
          'LOGIN': (_) => LoginScreen(),
          'REGISTER': (_) => RegisterScreen(),
    
          'CLIENTES': ( _ ) => ClienteScreen(),
          'ENTRENADOR': (_) => EntrenadorScreen(),
          'ADMINISTRADOR': (_) => AdministradorScreen(),

        },
        scaffoldMessengerKey: NotificationsService.messengerKey,
      ),
    );
  }
}
