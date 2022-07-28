import 'dart:async';

import 'package:GymBook/api/firebase_api.dart';
import 'package:GymBook/screens/cliente_screens/introduccion_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:GymBook/services/services.dart';
import 'package:GymBook/widgets/widgets.dart';
import 'package:GymBook/screens/screens.dart';

import 'package:flutter/services.dart';
import 'package:gender_picker/source/enums.dart';
import 'package:gender_picker/source/gender_picker.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:path/path.dart' as path;

final storage = new FlutterSecureStorage();

final TextEditingController _controllerEmail = new TextEditingController();
final TextEditingController _controllerNombre = new TextEditingController();
final TextEditingController _controllerApellido = new TextEditingController();
final TextEditingController _controllerEdad = new TextEditingController();

bool _visibleCardbox1 = true;
bool _visibleCardbox2 = false;
bool _visibleCardbox3 = false;

int _numPag = 1;

bool _visibleAtras = false;
bool _visibleAdelante = true;

bool _isObscure1 = true;
bool _isObscure2 = true;

File? _filePic;
var _namePic;

XFile? _filePicked;

bool _isNullImage = true;

var task = null;


CollectionReference usuarios = FirebaseFirestore.instance.collection('clientes');

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreennState();
}

class _RegisterScreennState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: AuthBackground(
            child: SingleChildScrollView(
          child: Column(
            children: [
              Container(height: MediaQuery.of(context).size.height * 0.21),
              CardContainer(
                  child: Column(
                children: [
                  MultiProvider(providers: [
                    ChangeNotifierProvider(
                        create: (_) => RegisterFormProvider()),
                    ChangeNotifierProvider(
                        create: (_) => Register2FormProvider()),
                  ], child: _RegisterForm())
                ],
              )),
              Container(height: 10),
              TextButton(
                  onPressed: () {
                    if(task == null){
                      _visibleCardbox1 = true;
                      _visibleCardbox2 = false;
                      _visibleCardbox3 = false;

                      _numPag = 1;

                      _visibleAtras = false;
                      _visibleAdelante = true;

                      _controllerNombre.clear();
                      _controllerApellido.clear();
                      _controllerEdad.clear();
                      _controllerEmail.clear();

                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.leftToRightWithFade,
                          child: LoginScreen(),
                          duration: Duration(milliseconds: 500)
                        )
                      );
                    }
                  },
                  style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(
                          Colors.blueGrey.withOpacity(0.2)),
                      shape: MaterialStateProperty.all(StadiumBorder())),
                  child: Text('¿Ya tienes una cuenta?',
                      style:
                          TextStyle(fontSize: 16, color: Color.fromRGBO(1, 29, 69, 1),)))
            ],
          ),
        )),
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  var uid;
  var email = '';
  var password = '';
  var nombre = '';
  var apellido = '';
  var edad = '';
  var genero = 'Hombre';
  var _isFotoURL = '';

  int? edad_int;

  Gender genero_select = Gender.Male;
  
  @override
  Widget build(BuildContext context) {
    final registerForm1 = Provider.of<RegisterFormProvider>(context);
    final registerForm2 = Provider.of<Register2FormProvider>(context);

    final _namePic = _filePic != null ? path.basename(_filePic!.path) : '';

    return Container(
      child: Column(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _visibleCardbox3 ? 0 : 1,
            child: Visibility(
              visible: (_visibleCardbox1)
                  ? true
                  : (_visibleCardbox2)
                      ? true
                      : false,
              maintainInteractivity: false,
              maintainSize: false,
              maintainState: false,
              maintainSemantics: false,
              maintainAnimation: false,
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'Registro',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w300,
                        fontSize: 40,
                        color: Color.fromRGBO(1, 29, 69, 1),
                      ),
                    ),
                  ),
                  Container(height: 15)
                ],
              ),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _visibleCardbox3 ? 1 : 0,
            child: Visibility(
              visible: (_visibleCardbox3) ? true : false,
              maintainInteractivity: false,
              maintainSize: false,
              maintainState: false,
              maintainSemantics: false,
              maintainAnimation: false,
              child: Column(
                children: [
                  Text(
                    'Imagen de perfil',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w300,
                      fontSize: 30,
                      color: Color.fromRGBO(1, 29, 69, 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Form(
            key: registerForm1.formKeyRegister,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _visibleCardbox1 ? 1 : 0,
              child: Visibility(
                visible: _visibleCardbox1,
                maintainInteractivity: false,
                maintainSize: false,
                maintainState: true,
                maintainSemantics: false,
                maintainAnimation: false,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _controllerEmail,
                      autofocus: false,
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
                              color: Color.fromRGBO(4, 199, 82, 1),),
                          suffixIcon: (email.toString() == '')
                              ? null
                              : IconButton(
                                  icon: Icon(Icons.close,
                                      color: Color.fromRGBO(4, 199, 82, 1), size: 22.5),
                                  onPressed: () {
                                    email = '';
                                    registerForm1.email = '';
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
                      onChanged: (value_correo) {
                        email = value_correo;
                        registerForm1.email = value_correo;
                        setState(() {});
                      },
                      validator: (value_correo) {
                        String pattern_correo =
                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                        RegExp regExp_correo = new RegExp(pattern_correo);

                        return regExp_correo.hasMatch(value_correo ?? '')
                            ? null
                            : 'Ingrese una dirección correcta';
                      },
                    ),
                    Container(height: 20),
                    TextFormField(
                      autofocus: false,
                      autocorrect: false,
                      obscureText: _isObscure1,
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
                        suffixIcon: Tooltip(
                          message: (_isObscure1) ? 'Mostrar' : 'Ocultar',
                          child: InkWell(
                            onTap: _togglePasswordView,
                            child: Icon(
                                _isObscure1
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Color.fromRGBO(4, 199, 82, 1)),
                          ),
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
                      onChanged: (value_pass) {
                        registerForm1.password = value_pass;
                        password = value_pass;
                      },
                      validator: (value_pass) {
                        if ((value_pass.toString() != '')) {
                          if (value_pass!.length >= 6) {
                            return null;
                          } else {
                            return 'La contraseña debe de ser de 6 caracteres o más';
                          }
                        } else {
                          return 'Ingrese una contraseña';
                        }
                      },
                    ),
                    Container(height: 20),
                    TextFormField(
                      autofocus: false,
                      autocorrect: false,
                      obscureText: _isObscure2,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                        hintText: '*******',
                        labelText: 'Confirmar contraseña',
                        prefixIcon: Icon(Icons.restart_alt_rounded,
                            color: Color.fromRGBO(4, 199, 82, 1)),
                        suffixIcon: Tooltip(
                          message: (_isObscure2) ? 'Mostrar' : 'Ocultar',
                          child: InkWell(
                            onTap: _togglePasswordView2,
                            child: Icon(
                                _isObscure2
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Color.fromRGBO(4, 199, 82, 1)),
                          ),
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
                      onChanged: (value_pass2) => null,
                      validator: (value_pass2) {
                        if ((value_pass2.toString() != '')) {
                          if (value_pass2 == password) {
                            return null;
                          } else {
                            return 'Las contraseñas no coinciden';
                          }
                        } else {
                          return 'Ingrese una contraseña';
                        }
                      },
                    ),
                    Container(height: 15)
                  ],
                ),
              ),
            ),
          ),
          Form(
            key: registerForm2.formKeyRegister2,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _visibleCardbox2 ? 1 : 0,
              child: Visibility(
                visible: _visibleCardbox2,
                maintainInteractivity: false,
                maintainSize: false,
                maintainState: true,
                maintainSemantics: false,
                maintainAnimation: false,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _controllerNombre,
                      autofocus: false,
                      autocorrect: false,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                          hintStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w300,
                            fontSize: 14,
                            color: Colors.black45,
                          ),
                          hintText: 'Jhon',
                          labelText: 'Nombre',
                          prefixIcon: Icon(Icons.person_rounded,
                              color: Color.fromRGBO(4, 199, 82, 1)),
                          suffixIcon: (nombre.toString() == '')
                              ? null
                              : IconButton(
                                  icon: Icon(Icons.close_rounded,
                                      color: Color.fromRGBO(4, 199, 82, 1), size: 22.5),
                                  onPressed: () {
                                    nombre = '';
                                    registerForm2.nombre = '';
                                    _controllerNombre.clear();
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
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]*")),
                        LengthLimitingTextInputFormatter(15),
                      ],
                      onChanged: (value_nom) {
                        nombre = value_nom;
                        registerForm2.nombre = value_nom;
                        setState(() {});
                      },
                      validator: (value_nom) {
                        return (nombre != '')
                            ? null
                            : 'Ingrese un nombre correcto';
                      },
                    ),
                    Container(height: 15),
                    TextFormField(
                      controller: _controllerApellido,
                      autofocus: false,
                      autocorrect: false,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                          hintStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w300,
                            fontSize: 14,
                            color: Colors.black45,
                          ),
                          hintText: 'Smith',
                          labelText: 'Apellido',
                          prefixIcon: Icon(Icons.person_outline_rounded,
                              color: Color.fromRGBO(4, 199, 82, 1)),
                          suffixIcon: (apellido.toString() == '')
                              ? null
                              : IconButton(
                                  icon: Icon(Icons.close,
                                      color: Color.fromRGBO(4, 199, 82, 1), size: 22.5),
                                  onPressed: () {
                                    apellido = '';
                                    registerForm2.apellido = '';
                                    _controllerApellido.clear();
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
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z\u00f1\u00d1]*")),
                        LengthLimitingTextInputFormatter(15),
                      ],
                      onChanged: (value_ape) {
                        apellido = value_ape;
                        registerForm2.apellido = value_ape;
                        setState(() {});
                      },
                      validator: (value_ape) {
                        return (apellido != '')
                            ? null
                            : 'Ingrese un apellido correcto';
                      },
                    ),
                    Container(height: 15),
                    TextFormField(
                      controller: _controllerEdad,
                      autofocus: false,
                      autocorrect: false,
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: false, signed: false),
                      decoration: InputDecoration(
                          hintStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w300,
                            fontSize: 14,
                            color: Colors.black45,
                          ),
                          hintText: '21',
                          labelText: 'Edad',
                          prefixIcon: Icon(Icons.app_registration_rounded,
                              color: Color.fromRGBO(4, 199, 82, 1)),
                          suffixIcon: (edad.toString() == '')
                              ? null
                              : IconButton(
                                  icon: Icon(Icons.close,
                                      color: Color.fromRGBO(4, 199, 82, 1), size: 22.5),
                                  onPressed: () {
                                    edad = '';
                                    registerForm2.edad = '';
                                    _controllerEdad.clear();
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
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                        LengthLimitingTextInputFormatter(2),
                      ],
                      onChanged: (value_age) {
                        edad = value_age;
                        edad_int = int.tryParse(value_age);
                        registerForm2.edad = value_age;
                      },
                      validator: (value_age) {
                        if ((edad != '')) {
                          if (edad_int! <= 99 && edad_int! >= 1) {
                            return null;
                          } else {
                            return 'Ingrese una edad correcta';
                          }
                        } else {
                          return 'Ingrese una edad';
                        }
                      },
                    ),
                    Container(height: 20),
                    GenderPickerWithImage(
                      linearGradient: LinearGradient(colors: [
                        Colors.blueGrey.shade800,
                        Colors.blueGrey.shade800
                      ]),
                      showOtherGender: true,
                      verticalAlignedText: false,
                      selectedGender: genero_select,
                      selectedGenderTextStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.blueGrey[800],
                          fontWeight: FontWeight.bold),
                      unSelectedGenderTextStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.black45,
                          fontWeight: FontWeight.normal),
                      equallyAligned: true,
                      animationDuration: Duration(milliseconds: 150),
                      isCircular: true,
                      opacityOfGradient: 0.6,
                      maleText: 'Hombre',
                      femaleText: 'Mujer',
                      otherGenderText: 'Otro',
                      maleImage: AssetImage('assets/images/man.png'),
                      femaleImage: AssetImage('assets/images/woman.png'),
                      otherGenderImage: AssetImage('assets/images/other.png'),
                      size: 30,
                      onChanged: (value) {
                        FocusScope.of(context).unfocus();
                        if (value.toString() == 'Gender.Male') {
                          genero_select = Gender.Male;
                          genero = 'Hombre';
                        } else if (value.toString() == 'Gender.Female') {
                          genero_select = Gender.Female;
                          genero = 'Mujer';
                        } else if (value.toString() == 'Gender.Others') {
                          genero_select = Gender.Others;
                          genero = 'Otro';
                        }
                      },
                    ),
                    Container(height: 15),
                  ],
                ),
              ),
            ),
          ),
          Form(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _visibleCardbox3 ? 1 : 0,
              child: Visibility(
                visible: _visibleCardbox3,
                maintainInteractivity: false,
                maintainSize: false,
                maintainState: true,
                maintainSemantics: false,
                maintainAnimation: false,
                child: Column(
                  children: [
                    Container(height: 15),
                    Stack(alignment: AlignmentDirectional.center, children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 1000),
                        opacity: _isNullImage ? 1 : 0,
                        child: ClipOval(
                            child: (_filePic == null && _controllerNombre.text != '') 
                            ? Image.asset(
                          "assets/AtoZ/letter-" + _controllerNombre.text[0].toLowerCase() + ".png",
                          fit: BoxFit.cover,
                          width: 125.0,
                          height: 125.0,
                        )
                            : Image.asset(
                          "assets/images/account_default.png",
                          fit: BoxFit.cover,
                          width: 125.0,
                          height: 125.0,
                        )
                        ),
                      ),
                      AnimatedOpacity(
                          duration: const Duration(milliseconds: 1000),
                          opacity: _isNullImage ? 0 : 1,
                          child: Container(
                            constraints: new BoxConstraints(
                                maxHeight: 125.0, maxWidth: 125.0),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: new BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black26,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(200),
                                    color: Color.fromRGBO(253, 253, 253, 1),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: ClipOval(
                                      child: _filePic != null
                                          ? Image.file(
                                              _filePic!, //debug CAMBIAR IMAGEN SELECT
                                              fit: BoxFit.cover,
                                              width: 125.0,
                                              height: 125.0,
                                            )
                                          : null),
                                ),
                                new Positioned(
                                  right: 5,
                                  top: 5,
                                  child: Container(
                                    constraints: new BoxConstraints(
                                        maxHeight: 32.5, maxWidth: 32.5),
                                    decoration: new BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black38,
                                            offset: Offset(1, 1)),
                                      ],
                                      border: Border.all(
                                        color: Colors.black26,
                                        width: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      color: Color.fromRGBO(253, 253, 253, 1),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: GestureDetector(
                                      onTap: (){
                                        if(task == null){
                                          _deletePicture();
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 20,
                                          color: Colors.red[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ]),
                    Container(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(240, 240, 240, 1),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Material(
                                color: Colors.transparent,
                                child: new InkWell(
                                  customBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  splashColor: Colors.white38,
                                  onTap: () {
                                    if (task == null) {
                                      FocusScope.of(context).unfocus();
                                      _getFromGallery();
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    height: 135,
                                    width: 135,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                  colors: [
                                                    Color.fromRGBO(
                                                        148, 148, 148, 1),
                                                    Color.fromRGBO(
                                                        125, 125, 125, 1),
                                                    Color.fromRGBO(
                                                        107, 107, 107, 1),
                                                    Color.fromRGBO(
                                                        91, 91, 91, 0.75),
                                                    Color.fromRGBO(
                                                        77, 77, 77, 0.75),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight)),
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundColor: Colors.transparent,
                                            child: Container(
                                              child: Icon(Icons.photo_size_select_actual_rounded,
                                                  size: 30,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text('Elige una imagen de la galería',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.w300,
                                                    color: Color.fromRGBO(117, 117, 117, 1)),))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(240, 240, 240, 1),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Material(
                                color: Colors.transparent,
                                child: new InkWell(
                                  customBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  splashColor: Colors.white38,
                                  onTap: () {
                                    if (task == null) {
                                      FocusScope.of(context).unfocus();
                                      _getFromCamera();
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    height: 135,
                                    width: 135,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                  colors: [
                                                    Color.fromRGBO(
                                                        148, 148, 148, 1),
                                                    Color.fromRGBO(
                                                        125, 125, 125, 1),
                                                    Color.fromRGBO(
                                                        107, 107, 107, 1),
                                                    Color.fromRGBO(
                                                        91, 91, 91, 0.75),
                                                    Color.fromRGBO(
                                                        77, 77, 77, 0.75),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight)),
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundColor: Colors.transparent,
                                            child: Container(
                                              child: Icon(Icons.camera_alt,
                                                  size: 30,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text('Toma una foto con tu cámara',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                    fontStyle: FontStyle.normal,
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.w300,
                                                  color: Color.fromRGBO(
                                                      117, 117, 117, 1)),
                                            ))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 2,
                    child: Visibility(
                      visible: _visibleAtras,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Tooltip(
                        message: 'Atras',
                        child: RawMaterialButton(
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                          fillColor: Colors.white,
                          splashColor: Colors.grey[350],
                          highlightColor: Colors.white,
                          elevation: 0,
                          highlightElevation: 0,
                          focusElevation: 0,
                          hoverElevation: 0,
                          onPressed: () {
                            if(task == null){
                              FocusScope.of(context).unfocus();
                              Future.delayed(const Duration(milliseconds: 250),
                                  () {
                                _toggleAtras();
                                setState(() {});
                              });
                            }
                          },
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Color.fromRGBO(4, 199, 82, 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: task != null
                    ? buildUploadStatus(task!)
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 1000),
                              curve: Curves.fastOutSlowIn,
                              width: (_numPag == 1) ? 15 : 10,
                              height: (_numPag == 1) ? 15 : 10,
                              decoration: BoxDecoration(
                                color: (_numPag == 1) ? Color.fromRGBO(1, 29, 69, 1) : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(width: 15),

                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 1000),
                              curve: Curves.fastOutSlowIn,
                              width: (_numPag == 2) ? 15 : 10,
                              height: (_numPag == 2) ? 15 : 10,
                              decoration: BoxDecoration(
                                color: (_numPag == 2) ? Color.fromRGBO(1, 29, 69, 1) : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(width: 15),

                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 1000),
                              curve: Curves.fastOutSlowIn,
                              width: (_numPag == 3) ? 15 : 10,
                              height: (_numPag == 3) ? 15 : 10,
                              decoration: BoxDecoration(
                                color: (_numPag == 3) ? Color.fromRGBO(1, 29, 69, 1) : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),

                      ],
                    )
                  ),
                  Flexible(
                    flex: 2,
                    child: Visibility(
                      visible: true,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Tooltip(
                        message: _visibleCardbox3 ? 'Finalizar' : 'Siguiente',
                        child: RawMaterialButton(
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                          fillColor: Colors.white,
                          splashColor: Colors.grey[350],
                          highlightColor: Colors.white,
                          elevation: 0,
                          highlightElevation: 0,
                          focusElevation: 0,
                          hoverElevation: 0,
                          child: _visibleCardbox1
                              ? Icon(Icons.arrow_forward_ios_rounded,
                                  color: Color.fromRGBO(1, 29, 69, 1))
                              : _visibleCardbox2
                                  ? Icon(Icons.arrow_forward_ios_rounded,
                                      color: Color.fromRGBO(1, 29, 69, 1))
                                  : Icon(Icons.check,
                                      color: Color.fromRGBO(4, 199, 82, 1),
                                      size: 30),
                          onPressed: () {
                            if(task == null){
                            FocusScope.of(context).unfocus();
                            Future.delayed(const Duration(milliseconds: 250),
                                () async {
                              FocusScope.of(context).unfocus();

                              if (_visibleCardbox1) {
                                if (!registerForm1.isValidForm()) {
                                  return;
                                } else {
                                  _toggleAdelante();
                                }
                              } else if (_visibleCardbox2) {
                                if (!registerForm2.isValidForm()) {
                                  return;
                                } else {
                                  _toggleAdelante();
                                }
                              } else {
                                if (_visibleCardbox3) {
                                  try {
                                    showLoading();

                                    final result = await InternetAddress.lookup(
                                        'example.com');
                                    if (result.isNotEmpty &&
                                        result[0].rawAddress.isNotEmpty) {
                                      final authService =
                                          Provider.of<AuthService>(context,
                                              listen: false);

                                      _isFotoURL = 'https://firebasestorage.googleapis.com/v0/b/gymbook-services.appspot.com/o/user_letters%2Fletter-' + registerForm2.nombre.toString()[0].toLowerCase() + '.png?alt=media&token=c673b5d4-2d8f-4b5b-bc39-35cd9f82370a';

                                      final String? mensaje_createUser =
                                          await authService.createUser(
                                              registerForm1.email,
                                              registerForm1.password,
                                              registerForm2.nombre,
                                              registerForm2.apellido,
                                              registerForm2.edad,
                                              genero,
                                              _isFotoURL,
                                              'cliente');

                                      if (mensaje_createUser ==
                                          'The account already exists for that email') {
                                        dismissLoadingWidget();
                                        Get.snackbar(
                                          "Error", // title
                                          "La direccion de correo ya existe", // message
                                          icon: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Icon(Icons.error,
                                                color: Colors.white),
                                          ),
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10),
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

                                        _numPag = 2;
                                        _toggleAtras();
                                      } else if (mensaje_createUser ==
                                              'Information Required' ||
                                          mensaje_createUser ==
                                              'The password provided is too weak' ||
                                          mensaje_createUser ==
                                              'Error occurred') {
                                        dismissLoadingWidget();

                                        Get.snackbar(
                                          "Error en el registro", // title
                                          "Credenciales incorrectas", // message
                                          icon: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Icon(Icons.error,
                                                color: Colors.white),
                                          ),
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10),
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

                                        _numPag = 2;
                                        _toggleAtras();
                                      } else if (mensaje_createUser
                                          .toString()
                                          .contains('Created with UID:')) {
                                        List<String> mensaje_array =
                                            mensaje_createUser!.split(':');
                                        uid = mensaje_array[1]
                                            .toString()
                                            .replaceAll(' ', '');

                                        try {
                                          if (_filePic == null) {
                                            dismissLoadingWidget();
                                            _entrarDelay();
                                          } else {
                                            final destination =
                                                'users/$uid/foto_$uid.png';

                                            task = FirebaseApi.uploadFile(destination, _filePic!);
                                            setState(() {});

                                            if (task == null) return;

                                            try {
                                              final snapshot = await task!.whenComplete(() {task = null;});
                                              final urlDownload = await snapshot.ref.getDownloadURL();

                                              _isFotoURL = urlDownload;

                                              usuarios.doc(uid).update({
                                                'imagenURL': _isFotoURL
                                              }).catchError((error) => print(
                                                  'Error al agregar la imagen del nuevo usuario: $error'));

                                              dismissLoadingWidget();
                                            } on SocketException catch (e) {
                                              dismissLoadingWidget();

                                              Get.snackbar(
                                                "Error al subir la imagen", // title
                                                "Se perdió la conexión con el servidor", // message
                                                icon: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: Icon(
                                                      Icons
                                                          .signal_wifi_connected_no_internet_4,
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
                                                backgroundColor:
                                                    Colors.red[800],
                                                maxWidth: 350,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 8),
                                              );

                                              return;
                                            }

                                            Future.delayed(
                                              const Duration(
                                                  milliseconds: 2000),
                                              () {
                                                setState(() {
                                                  _entrarDelay();
                                                });
                                              },
                                            );
                                          }
                                        } on SocketException catch (_) {
                                          dismissLoadingWidget();

                                          Get.snackbar(
                                            "Error", // title
                                            "No hay conexión a Internet", // message
                                            icon: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Icon(Icons.error,
                                                  color: Colors.white),
                                            ),
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10),
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

                                      return;
                                    }
                                  } on SocketException catch (_) {
                                    dismissLoadingWidget();
                                    Get.snackbar(
                                      "Error", // title
                                      "No hay conexión a Internet", // message
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
                                      duration: Duration(seconds: 3),
                                      colorText: Colors.white,
                                      backgroundColor: Colors.red[800],
                                      maxWidth: 350,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                    );
                                  }
                                } else {
                                  _toggleAdelante();
                                }
                              }

                              setState(() {});
                            });
                            };
                          }
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
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
                '$percentage %',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                  color: Colors.black45,
                ),
              ),
            );
          } else {
            return Center();
          }
        },
      );

  void _getFromCamera() async {
    _filePicked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 15,
      preferredCameraDevice: CameraDevice.front
    );

    if (_filePicked == null) {
      _namePic = '';
      _filePic = null;
      _isNullImage = true;

      return;
    } else {
      int bytes = await _filePicked!.length();
      final kb = bytes / 1024;
      final mb = kb / 1024;

      if (mb > 5) {
        _namePic = '';
        _filePic = null;
        _isNullImage = true;

        Get.snackbar(
          "Se excedió el tamaño máximo", // title
          "Intente seleccionar una imagen no mayor a 5MB", // message
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

        return;
      } else {
        _isNullImage = false;
        _namePic = File(_filePicked!.name);
        _filePic = File(_filePicked!.path);
      }
    }
    setState(() {});
  }

  void _getFromGallery() async {
    _filePicked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if(_filePicked == null){
      _namePic = '';
      _filePic = null;
      _isNullImage = true;

      return;
    } else {
      int bytes = await _filePicked!.length();
      final kb = bytes / 1024;
      final mb = kb / 1024;

      if (mb > 5) {
      _namePic = '';
      _filePic = null;
      _isNullImage = true;

      Get.snackbar(
        "Se excedió el tamaño máximo", // title
        "Intente seleccionar una imagen no mayor a 5MB", // message
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

      return;
    } else {
      _isNullImage = false;
      _namePic = File(_filePicked!.name);
      _filePic = File(_filePicked!.path);
    }

    }

    setState(() {});
  }

  void _deletePicture() async {
    setState(() {
      _namePic = '';
      _filePic = null;
      _isNullImage = true;
    });
  }

  void _togglePasswordView() {
    setState(() {
      if (_isObscure1 == true) {
        _isObscure1 = false;
      } else {
        _isObscure1 = true;
      }
    });
  }

  void _togglePasswordView2() {
    setState(() {
      if (_isObscure2 == true) {
        _isObscure2 = false;
      } else {
        _isObscure2 = true;
      }
    });
  }

  Future<void> _toggleAdelante() async {
    setState(() {
      FocusScope.of(context).unfocus();
      _isObscure1 = true;
      _isObscure2 = true;

      if (_numPag >= 1 && _numPag <= 2) {
        _numPag++;
      }

      if (_numPag == 1) {
        _visibleCardbox1 = true;
        _visibleCardbox2 = false;
        _visibleCardbox3 = false;

        _visibleAdelante = true;
        _visibleAtras = false;
      } else if (_numPag == 2) {
        _visibleCardbox1 = false;
        _visibleCardbox2 = true;
        _visibleCardbox3 = false;

        _visibleAdelante = true;
        _visibleAtras = true;
      } else {
        _visibleCardbox1 = false;
        _visibleCardbox2 = false;
        _visibleCardbox3 = true;

        _visibleAdelante = true;
        _visibleAtras = true;
      }
    });
  }

  Future<void> _toggleAtras() async {
    setState(() {
      FocusScope.of(context).unfocus();
      if (_numPag >= 2 && _numPag <= 4) {
        _numPag--;
      }

      if (_numPag == 1) {
        _visibleCardbox1 = true;
        _visibleCardbox2 = false;
        _visibleCardbox3 = false;

        _visibleAdelante = true;
        _visibleAtras = false;
      } else if (_numPag == 2) {
        _visibleCardbox1 = false;
        _visibleCardbox2 = true;
        _visibleCardbox3 = false;

        _visibleAdelante = true;
        _visibleAtras = true;
      } else {
        _visibleCardbox1 = false;
        _visibleCardbox2 = false;
        _visibleCardbox3 = true;

        _visibleAdelante = true;
        _visibleAtras = true;
      }
    });
  }

  void _entrarDelay() {
    Get.snackbar(
      "¡Hola $nombre!", // title
      "Registrado con exito", // message
      icon: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Icon(Icons.mood, color: Colors.white),
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

    Get.offAll(() => IntroduccionCliente());
    
    setState(() {
      uid = '';
      email = '';
      password = '';
      nombre = '';
      apellido = '';
      edad = '';
      edad_int = null;
      genero = 'Hombre';

      _isFotoURL =
          'https://firebasestorage.googleapis.com/v0/b/gymbook-services.appspot.com/o/account_default.png?alt=media&token=374b407e-68e7-45d1-ab0e-ec8bd8ae881b';

      _visibleCardbox1 = true;
      _visibleCardbox2 = false;
      _visibleCardbox3 = false;

      _numPag = 2;

      _toggleAtras();

      _visibleAtras = false;
      _visibleAdelante = true;

      _filePicked = null;
      _filePic = null;

      _controllerNombre.clear();
      _controllerApellido.clear();
      _controllerEdad.clear();
      _controllerEmail.clear();

      _deletePicture();
    });
  }

  showLoading() {
    Get.defaultDialog(
        title: "Cargando...",
        content: CircularProgressIndicator(
          color: Colors.blueGrey[200],
          backgroundColor: Colors.black54,
        ),
        barrierDismissible: false);
  }

  dismissLoadingWidget() {
    Get.back();
  }
}
