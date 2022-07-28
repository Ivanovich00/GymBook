import 'package:GymBook/helpers/showLoading.dart';
import 'package:GymBook/providers/forgetpass_form_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:GymBook/screens/screens.dart';
import 'package:GymBook/services/services.dart';
import 'package:GymBook/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'dart:convert';

class ForgotPassScreen extends StatelessWidget{
@override
Widget build(BuildContext context){
  return SafeArea(
    child: Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [

              SizedBox(height: MediaQuery.of(context).size.height*0.21),

              CardContainer(
                child: Column(
                  children: [

                    Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Visibility(
                            visible: true,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: LoginScreen(), duration: Duration(milliseconds: 500)));
                                },
                                child: Icon(Icons.arrow_back_ios_rounded,
                                    color: Color.fromRGBO(4, 199, 82, 1),
                                    size: 27.5),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: Container(
                            child: Column(
                              children: [
                                Center(
                                    child: Text('Recuperar',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 35,
                                        color: Color.fromRGBO(1, 29, 69, 1),
                                      ),
                                    )
                                ),
                                Center(
                                    child: Text('contraseña',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 35,
                                        color: Color.fromRGBO(1, 29, 69, 1),
                                      ),
                                    )
                                ),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Visibility(
                            visible: false,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: Container(
                              child: InkWell(
                                onTap: () {},
                                child: Icon(Icons.arrow_forward_ios_rounded,
                                    color: Color.fromRGBO(4, 199, 82, 1),
                                    size: 27.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                    SizedBox(height: 20),

                    ChangeNotifierProvider(
                      create: ( _ ) => ForgotPassFormProvider(),
                      child: _ForgotForm(),
                    )

                  ],
                )
              ),

            ],
          ),
        )
      ),
      ),
  );
  }

}

class _ForgotForm extends StatefulWidget {
  @override
  State<_ForgotForm> createState() => _ForgotFormState();
}

class _ForgotFormState extends State<_ForgotForm> {
  @override
  Widget build(BuildContext context) {

  final forgotForm = Provider.of<ForgotPassFormProvider>(context);
    String buscar = '';
    return Container(
      child: Form(

        key: forgotForm.formForgotKey,

        autovalidateMode: AutovalidateMode.onUserInteraction,

        child: Column(
          children: [
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                  color: Colors.black45,
                ),
                hintText: 'john.doe@gmail.com',
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.alternate_email_rounded, color: Color.fromRGBO(4, 199, 82, 1)),

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
              onChanged: (value_email) => forgotForm.email = value_email,
              validator: (value_email) {

                String pattern_email = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regExp_email  = new RegExp(pattern_email);

                return regExp_email.hasMatch(value_email ?? '')
                  ? null
                  : 'Ingrese una dirección correcta';

              },
            ),

            SizedBox(height: 20),

            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  hintStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                    color: Colors.black45,
                  ),
                hintText: 'john.doe@gmail.com',
                labelText: 'Confirmar correo electrónico',
                prefixIcon: Icon(Icons.restart_alt_rounded, color: Color.fromRGBO(4, 199, 82, 1)),

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
              onChanged: (value_email2) => null,
              validator: (value_email2) {

                buscar = value_email2.toString();

                return (value_email2 != null && value_email2 != forgotForm.email)
                  ? 'Las direcciones no coinciden'
                  : (value_email2 == "")
                  ? 'Ingrese una dirección correcta'
                  : null;
              }
            ),

            SizedBox(height: 30),

            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              disabledColor: Colors.grey,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 55, vertical: 15),
              color: Color.fromRGBO(4, 199, 82, 1),
              child: Container(
                child: Text(
                  forgotForm.isLoading
                  ? 'Espere'
                  : 'Enviar',
                  style: TextStyle(color: Colors.white),)),
              onPressed: forgotForm.isLoading ? null : () async{
                FocusScope.of(context).unfocus(); //Cerrar el teclado en pantalla al iniciar sesion

                if(!forgotForm.isValidForm()) return;

                forgotForm.isLoading = true;

                showLoading();

                final firestoreInstance = FirebaseFirestore.instance;
                firestoreInstance.collection("providers").doc("facebook").collection(buscar).doc("uid").get().then((value) {
                  if(value.data().toString().contains("uid")){
                    dismissLoadingWidget();
                    Get.snackbar(
                      "Error", // title
                      "No se puede enviar un correo de restablecimiento a una cuenta registrada con Facebook", // message
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
                    final firestoreInstance = FirebaseFirestore.instance;
                    firestoreInstance.collection("providers").doc("google").collection(buscar).doc("uid").get().then((value) async {
                      if(value.data().toString().contains("uid")){
                        dismissLoadingWidget();
                        Get.snackbar(
                          "Error", // title
                          "No se puede enviar un correo de restablecimiento a una cuenta registrada con Google", // message
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
                        final authService = Provider.of<AuthService>(context, listen: false);
                        final String? mensaje_recuperar = await authService.forgotPass(forgotForm.requestType, forgotForm.email);
                        dismissLoadingWidget();
                        if(mensaje_recuperar == 'Email sent'){
                            Get.snackbar(
                                    "Recuperar contraseña", // title
                                    "Correo para el restablecimiento de contraseña enviado", // message
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
                                    backgroundColor: Color.fromRGBO(85, 139, 47, 1),
                                    maxWidth: 350,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                  );
                        } else if(mensaje_recuperar == "No user found for that email"){
                            Get.snackbar(
                                    "Error", // title
                                    "No se encontró la dirección de correo", // message
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
                        } else if(mensaje_recuperar == "Too many requests"){
                            Get.snackbar(
                              "Error", // title
                              "¡Se excedió el límite de correos enviados!", // message
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
                        } else if (mensaje_recuperar == "Error") {
                            dismissLoadingWidget();
                            Get.snackbar(
                              "Usuario inhabilitado", // title
                              "Contacte al administrador para más información",
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
                      }
                    });
                  }
                });

                forgotForm.isLoading = false;

              }
            )
          ],
        ),
      ),
    );
  }

}