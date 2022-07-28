import 'dart:convert';
import 'dart:io';

import 'package:GymBook/screens/administrador_screens/introduccion_screen.dart';
import 'package:GymBook/screens/cliente_screens/introduccion_screen.dart';
import 'package:GymBook/screens/entrenador_screens/introduccion_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'package:GymBook/helpers/showLoading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:GymBook/providers/login_form_provider.dart';
import 'package:GymBook/screens/screens.dart';
import 'package:GymBook/services/services.dart';
import 'package:GymBook/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

final TextEditingController _controllerEmail = new TextEditingController();

Map<String, dynamic>? _userData;
AccessToken? _accessToken;
bool isConnexion = false;

String email = '', password = '', nombre = '', apellido = '', edad = '', genero = '', imagenURL = '', tipo = '', registro = '';

bool isConnected = false;

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  Future<void> _initGetDetails() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      isConnected = true;
    } catch (e) {
      isConnected = false;
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
    _initGetDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: AuthBackground(
            child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.21),
              CardContainer(
                  child: Column(
                children: [
                  Text(
                    'Ingresar',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w300,
                      fontSize: 40,
                      color: Color.fromRGBO(1, 29, 69, 1),
                    ),
                  ),
                  SizedBox(height: 20),
                  ChangeNotifierProvider(
                    create: (_) => LoginFormProvider(),
                    child: _LoginForm(),
                  )
                ],
              )),
              SizedBox(height: 20),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeftWithFade,
                            child: RegisterScreen(),
                            duration: Duration(milliseconds: 250)));

                    Future.delayed(const Duration(milliseconds: 750), () {
                      _controllerEmail.clear();
                      email = '';
                    });
                  },
                  style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(
                          Colors.blueGrey.withOpacity(0.2)),
                      shape: MaterialStateProperty.all(StadiumBorder())),
                  child: Text('Crea una cuenta nueva',
                      style: TextStyle(
                          fontSize: 16, color: Color.fromRGBO(1, 29, 69, 1))))
            ],
          ),
        )),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  bool _isObscure = true;
  final firestoreInstance = FirebaseFirestore.instance;

  Future loginWithFacebook() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final LoginResult loginResult = await FacebookAuth.instance.login();

    if(loginResult.status == LoginStatus.success){
      final OAuthCredential facebookAuthCredential = await FacebookAuthProvider.credential(loginResult.accessToken!.token);
      try {
        await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

        await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value_user) async {
          await authService.readIntro().then((value){
            if(value == 'TRUE'){
              storage.write(key: 'INFO', value: FirebaseAuth.instance.currentUser!.uid + ',' + value_user['tipo']);
              storage.write(key: 'TEMA', value: 'BRILLO');
              storage.write(key: 'INTRO', value: 'TRUE');
              if (value_user['tipo'] == 'cliente') {
                Get.offAll(() => IntroduccionCliente());
              } else if (value_user['tipo'] == 'entrenador'){
                Get.offAll(() => IntroduccionEntrenador());
              } else if (value_user['tipo'] == 'administrador') {
                Get.offAll(() => IntroduccionAdministrador());
              } else if (value_user['tipo'] == 'eliminado') {
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
              storage.write(key: 'INFO', value: FirebaseAuth.instance.currentUser!.uid + ',' + value_user['tipo']);
              storage.write(key: 'TEMA', value: 'BRILLO');
              storage.write(key: 'INTRO', value: 'FALSE');
              if (value_user['tipo'] == 'cliente') {
                Get.offAll(() => ClienteScreen());
              } else if (value_user['tipo'] == 'entrenador'){
                Get.offAll(() => EntrenadorScreen());
              } else if (value_user['tipo'] == 'administrador') {
                Get.offAll(() => AdministradorScreen());
              } else if (value_user['tipo'] == 'eliminado') {
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
        }).onError((error, stackTrace) async {
          await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).set({
            "tipo": "cliente",
            "uid": FirebaseAuth.instance.currentUser!.uid,
            "token_message": "null",
            "provider": "facebook",
          });

          var jsonFacebook = await http.get(Uri.parse('https://graph.facebook.com/v2.12/me?fields=first_name,last_name,email,gender&access_token=${loginResult.accessToken!.token}'));
          var profileFacebook = json.decode(jsonFacebook.body);

          final profileData = await FacebookAuth.instance.getUserData();

          await FirebaseFirestore.instance.collection("providers").doc("facebook").collection(profileFacebook!['email']).doc(FirebaseAuth.instance.currentUser!.uid).set({
            "uid": FirebaseAuth.instance.currentUser!.uid,
          });

          List<String> registro_total = FirebaseAuth.instance.currentUser!.metadata.creationTime.toString().split(' ');
          String registro = registro_total[0];

          await FirebaseFirestore.instance.collection("clientes").doc(FirebaseAuth.instance.currentUser!.uid).set({ 
            "email": profileFacebook!['email'],
            "nombre": profileFacebook!['first_name'],
            "apellido": profileFacebook!['last_name'],
            "edad": '??',
            "genero": 'Hombre',
            "imagenURL": profileData['picture']['data']['url'],
            "registro": registro,
            "uid": FirebaseAuth.instance.currentUser!.uid,
            "rutina": false,
          });

          await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((DocumentSnapshot documentSnapshot) async { 
            String user_data = documentSnapshot.data().toString();
            List<String> user_data_array = user_data.split(',');
            Future.microtask(() async {
              await FirebaseMessaging.instance.getToken().then((value) {
                FirebaseFirestore.instance.collection('users').doc(user_data_array[0].toString().replaceAll('{uid: ', '')).update({"token_message": value});
              });
            });
          });
          
          storage.write(key: 'INFO', value: FirebaseAuth.instance.currentUser!.uid + ',cliente');
          storage.write(key: 'TEMA', value: 'BRILLO');
          storage.write(key: 'INTRO', value: 'TRUE');

          Get.offAll(() => IntroduccionCliente());
        });
      } catch (e) {
        Get.snackbar(
          "Error al iniciar sesión", // title
          "Intente entrar mediante su correo y contraseña...", // message
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
      }
      
    } else {
      print('Usuario cancelo inisio de sesion mediante Facebook');
    }

  }

  Future loginWithGoogle() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();   
    try {
      final GoogleSignInAuthentication? googleAuth = await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      try {
        UserCredential result = await FirebaseAuth.instance.signInWithCredential(credential);

        await FirebaseFirestore.instance.collection('users').doc(result.user!.uid).get().then((value_user) async {
          await authService.readIntro().then((value){
              if(value == 'TRUE'){
                if (value_user['tipo'] == 'cliente') {
                  Get.offAll(() => IntroduccionCliente());
                } else if (value_user['tipo'] == 'entrenador'){
                  Get.offAll(() => IntroduccionEntrenador());
                } else if (value_user['tipo'] == 'administrador') {
                  Get.offAll(() => IntroduccionAdministrador());
                } else if (value_user['tipo'] == 'eliminado') {
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
                if (value_user['tipo'] == 'cliente') {
                  Get.offAll(() => ClienteScreen());
                } else if (value_user['tipo'] == 'entrenador'){
                  Get.offAll(() => EntrenadorScreen());
                } else if (value_user['tipo'] == 'administrador') {
                  Get.offAll(() => AdministradorScreen());
                } else if (value_user['tipo'] == 'eliminado') {
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
        }).onError((error, stackTrace) async {
          await FirebaseFirestore.instance.collection("users").doc(result.user!.uid).set({
            "tipo": "cliente",
            "uid": result.user!.uid,
            "token_message": "null",
            "provider": "google",
          });

          String? nombreGoogle = result.user!.displayName;
          List<String>? nombreGoogleArray = nombreGoogle?.split(" ");

          List<String> registro_total = FirebaseAuth.instance.currentUser!.metadata.creationTime.toString().split(' ');
          String registro_fecha = registro_total[0];

          await FirebaseFirestore.instance.collection("clientes").doc(result.user!.uid).set({ 
            "email": result.user!.email,
            "nombre": nombreGoogleArray![0],
            "apellido": nombreGoogleArray[1],
            "edad": '??',
            "genero": 'Hombre',
            "imagenURL": result.user!.photoURL,
            "registro": registro_fecha,
            "uid": result.user!.uid,
            "rutina": false,
          });

          await FirebaseFirestore.instance.collection("providers").doc("google").collection(result.user!.email!).doc("uid").set({
            "uid": result.user!.uid,
          });

          await FirebaseFirestore.instance.collection('users').doc(result.user!.uid).get().then((DocumentSnapshot documentSnapshot) async { 
            String user_data = documentSnapshot.data().toString();
            List<String> user_data_array = user_data.split(',');
            Future.microtask(() async {
              await FirebaseMessaging.instance.getToken().then((value) {
                FirebaseFirestore.instance.collection('users').doc(user_data_array[0].toString().replaceAll('{uid: ', '')).update({"token_message": value});
              });
            });
          });
          
          storage.write(key: 'INFO', value: result.user!.uid + ',cliente');
          storage.write(key: 'TEMA', value: 'BRILLO');
          storage.write(key: 'INTRO', value: 'TRUE');

          Get.offAll(() => IntroduccionCliente());
        });
      } catch (e) {
        Get.snackbar(
          "Error al iniciar sesión", // title
          "Intente entrar mediante su correo y contraseña...", // message
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
      }
      
    } catch (e) {
      print('Error al iniciar sesion con Google: ');
    }
  }

  Future<String> readTheme() async {
    return await storage.read(key: 'TEMA') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);

    return Container(
      child: Form(
        key: loginForm.formKeyLogin,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormField(
              controller: _controllerEmail,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  hintStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                    color: Colors.black45,
                  ),
                  hintText: 'john.smith@gmail.com',
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.alternate_email_rounded,
                      color: Color.fromRGBO(4, 199, 82, 1)),
                  suffixIcon: (email.toString() == '')
                      ? null
                      : IconButton(
                          icon: Icon(Icons.close,
                              color: Color.fromRGBO(4, 199, 82, 1), size: 22.5),
                          onPressed: () {
                            loginForm.email = '';
                            email = '';
                            _controllerEmail.clear();
                            setState(() {});
                          },
                        ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  )),
              onChanged: (value) {
                loginForm.email = value;
                email = value;
                setState(() {});
              },
              validator: (value) {
                String pattern =
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regExp = new RegExp(pattern);

                return (value.toString() == '')
                    ? 'Ingrese una dirección de correo electrónico'
                    : regExp.hasMatch(value!)
                        ? null
                        : 'Ingrese una dirección correcta';
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              autocorrect: false,
              obscureText: _isObscure,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                  color: Colors.black45,
                ),
                hintText: '*******',
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock_outline_rounded,
                    color: Color.fromRGBO(4, 199, 82, 1)),
                suffixIcon: InkWell(
                  onTap: _togglePasswordView,
                  child: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                      color: Color.fromRGBO(4, 199, 82, 1)),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                labelStyle: TextStyle(
                  color: Colors.grey,
                ),
              ),
              onChanged: (value) => loginForm.password = value,
              validator: (value) {
                if ((value.toString() != '')) {
                  if (value!.length >= 6) {
                    return null;
                  } else {
                    return 'La contraseña debe de ser de 6 caracteres o más';
                  }
                } else {
                  return 'Ingrese una contraseña';
                }
              },
            ),
            SizedBox(height: 15),
            TextButton(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Olvidé mi contraseña",
                  style: TextStyle(
                    color: Color.fromRGBO(1, 29, 69, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    decoration: TextDecoration.underline,
                    decorationThickness: 0.8,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade,
                        child: ForgotPassScreen(),
                        duration: Duration(milliseconds: 250)));

                Future.delayed(const Duration(milliseconds: 750), () {
                  setState(() {
                    _controllerEmail.clear();
                    email = '';
                  });
                });
              },
            ),
            SizedBox(height: 15),
            MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                disabledColor: Colors.grey,
                elevation: 0,
                minWidth: 150,
                height: 45,
                color: Color.fromRGBO(4, 199, 82, 1),
                child: Container(
                    child: Text(
                  loginForm.isLoading ? 'Espere' : 'Ingresar',
                  style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                          fontStyle: FontStyle.normal,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                )),
                onPressed: loginForm.isLoading
                    ? null
                    : () async {
                        FocusScope.of(context)
                            .unfocus(); //Cerrar el teclado en pantalla al iniciar sesion

                        if (!loginForm.isValidForm()) return;

                        try {
                          final result =
                              await InternetAddress.lookup('example.com');

                          if (result.isNotEmpty &&
                              result[0].rawAddress.isNotEmpty) {
                            final authService = Provider.of<AuthService>(
                                context,
                                listen: false);

                            loginForm.isLoading = true;

                            showLoading();

                            final String? mensaje_login = await authService
                                .login(loginForm.email, loginForm.password);

                            print(mensaje_login);

                            if (mensaje_login == null ||
                                mensaje_login == 'Error') {
                              dismissLoadingWidget();
                              Get.snackbar(
                                "Credenciales incorrectas", // title
                                "Intente otra vez",
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

                              loginForm.isLoading = false;
                            } else {
                              if (mensaje_login.contains('UID:')) {
                                dismissLoadingWidget();

                                _controllerEmail.clear();
                                email = '';

                                List<String> snap_array = mensaje_login.split(':');
                                String uid = snap_array[1].toString().replaceAll(' ', '');

                                String user_data;

                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid)
                                    .get()
                                    .then((DocumentSnapshot documentSnapshot) {
                                  user_data = documentSnapshot.data().toString();

                                  List<String> user_data_array = user_data.split(',');
                                  String tipo = user_data_array[1].toString();

                                  if (tipo.contains('cliente')) {
                                    Get.offAll(() => IntroduccionCliente());
                                  } else if (tipo.contains('entrenador')) {
                                    Get.offAll(() => IntroduccionEntrenador());
                                  } else if (tipo.contains('administrador')) {
                                    Get.offAll(() => IntroduccionAdministrador());
                                  } else if (tipo.contains('eliminado')) {
                                    Get.snackbar(
                                      "Error al iniciar sesión", // title
                                      "Su cuenta ha sido suspendida, contacte con un administrador", // message
                                      icon: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Icon(Icons.error,
                                            color: Colors.white),
                                      ),
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10),
                                      snackStyle: SnackStyle.FLOATING,
                                      snackPosition: SnackPosition.BOTTOM,
                                      shouldIconPulse: true,
                                      barBlur: 0,
                                      isDismissible: true,
                                      duration: Duration(seconds: 8),
                                      colorText: Colors.white,
                                      backgroundColor: Colors.red[800],
                                      maxWidth: 350,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                    );

                                    authService.logout();
                                  } else {
                                    authService.logout();
                                    Get.offAll(LoginScreen());
                                  }
                                });
                              } else if (mensaje_login ==
                                  "Wrong password provided for that user") {
                                dismissLoadingWidget();
                                Get.snackbar(
                                  "Credenciales incorrectas", // title
                                  "Intente otra vez",
                                  icon: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child:
                                        Icon(Icons.error, color: Colors.white),
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
                              } else if (mensaje_login ==
                                  "No user found for that email") {
                                dismissLoadingWidget();
                                Get.snackbar(
                                  "Credenciales incorrectas", // title
                                  "Intente otra vez",
                                  icon: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child:
                                        Icon(Icons.error, color: Colors.white),
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
                              } else if (mensaje_login ==
                                  "User disabled by admin") {
                                dismissLoadingWidget();
                                Get.snackbar(
                                  "Usuario inhabilitado", // title
                                  "Contacte al administrador para más información",
                                  icon: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child:
                                        Icon(Icons.error, color: Colors.white),
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

                              loginForm.isLoading = false;
                            }
                          }
                        } catch (e) {
                          dismissLoadingWidget();
                          print(e.toString());
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
                                horizontal: 8, vertical: 8),
                          );
                        }
                      }),
            SizedBox(height: 7.5),
            Container(
              width: 250,
              height: 45,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    minWidth: 245,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                    ),
                    disabledColor: Colors.grey,
                    elevation: 5,
                    color: Color.fromRGBO(24, 119, 242, 1),
                    onPressed: () async {
                      try {
                        final result = await InternetAddress.lookup('example.com');
                        if(result.isNotEmpty && result[0].rawAddress.isNotEmpty){
                          loginWithFacebook();
            
                          _controllerEmail.clear();
                          email = '';
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
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/facebook-logo.png",
                          width: 25,
                        ),
                        SizedBox(width: 15),
                        Text(
                          "Entrar con Facebook",
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.white
                          )),
                        ),
                      ],
                    ),
                  ),
                  
                ],
              ),
            ),
            SizedBox(height: 7.5),
            Container(
              width: 250,
              height: 45,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    minWidth: 245,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    disabledColor: Colors.grey,
                    elevation: 5,
                    color: Color.fromARGB(255, 228, 230, 235),
                    onPressed: () async {
                      try {
                        final result = await InternetAddress.lookup('example.com');
                        if(result.isNotEmpty && result[0].rawAddress.isNotEmpty){
                          loginWithGoogle();
            
                          _controllerEmail.clear();
                          email = '';
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
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/google-logo.png",
                          width: 25,
                        ),
                        SizedBox(width: 15),
                        Text("Entrar con Google",
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.black)
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _togglePasswordView() {
    if (_isObscure == true) {
      _isObscure = false;
    } else {
      _isObscure = true;
    }
    setState(() {});
  }
}
