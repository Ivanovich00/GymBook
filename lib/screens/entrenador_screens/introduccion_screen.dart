import 'package:GymBook/screens/screens.dart';
import 'package:GymBook/services/auth_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

class IntroduccionEntrenador extends StatefulWidget {
  @override
  State<IntroduccionEntrenador> createState() => _IntroduccionEntrenadorState();
}

bool _isIntro = false;
bool _isPreview = false;
bool _isSkip = false;
bool _isDark = false;
bool _isDesplegado = false;

String _genero = '¡Bienvenido!';
String _seguro = 'seguro';

class _IntroduccionEntrenadorState extends State<IntroduccionEntrenador> {
  @override
  void initState() {
    _initGetDetails();
    super.initState();
  }

  Future<void> _initGetDetails() async {
  final authService = Provider.of<AuthService>(context, listen: false);
  final valor_isIntro = await authService.readIntro();

  try {
    await FirebaseFirestore.instance.collection("entrenadores").doc(authService.auth.currentUser!.uid).get().then((querySnapshot) {
      if(querySnapshot.get('genero').toString() == 'Hombre' || querySnapshot.get('genero').toString() == 'Otro'){
        _genero = "¡Bienvenido!";
        _seguro = 'seguro';
      } else {
        _genero = "¡Bienvenida!";
        _seguro = 'segura';
      }
    });
    
    setState(() {});
  } catch (e) {
    print('error');
  }

  if (valor_isIntro == 'FALSE') {
    _isIntro = true;
  } else {
    _isIntro = false;
  }
}

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            width: double.infinity,
            height: double.infinity,
            color: (_isDark) ? Color.fromARGB(255, 31, 31, 31) : Colors.white,
            duration: Duration(milliseconds: 500),
            child: IntroductionScreen(
              globalBackgroundColor: Colors.transparent,
              globalHeader: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, right: 16),
                  child: GestureDetector(
                    onTap: () async {
                      _isDark = !_isDark;

                      if(_isDark){
                        await storage.write(key: 'TEMA', value: 'OSCURO');
                      } else {
                        await storage.write(key: 'TEMA', value: 'BRILLO');
                      }

                      setState(() {});
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (_isDark) ? Color.fromARGB(255, 56, 56, 56) : Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        (_isDark) ? Icons.sunny : Icons.nightlight,
                        color: (_isDark) ? Colors.amber : Color.fromARGB(255, 56, 56, 56),
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              globalFooter: GestureDetector(
                onTap: () {
                  Get.defaultDialog(
                  title: 'SALTAR INTRODUCCIÓN',
                  titlePadding: EdgeInsets.all(15),
                  titleStyle: TextStyle(
                    fontStyle: FontStyle.normal,
                    fontSize: 19.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                  content: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '¿Estas $_seguro de completar la introducción?',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Poppins', fontStyle: FontStyle.normal, fontSize: 17.0, fontWeight: FontWeight.w300, color: Colors.black))
                      ],
                    ),
                  ),
                  barrierDismissible: false,
                  radius: 15.0,
                  confirm: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0),
                            side: BorderSide(color: Colors.red)
                          )
                        )
                      ),
                      child: Text("SI"),
                        onPressed: () async {
                          await storage.write(key: 'INTRO', value: 'FALSE');
                          Get.offAll(() => EntrenadorScreen());
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
                          side: BorderSide(color: Colors.black)
                          )
                        )
                      ),
                      child: Text("NO"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                );
                },
                child: AnimatedContainer(
                  alignment: Alignment.center,
                  color: Color.fromRGBO(107, 195, 130, 1),
                  width: double.infinity,
                  height: (_isSkip) ? 60 : 0,
                  duration: Duration(milliseconds: 500),
                  child: SingleChildScrollView(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Lo entiendo, ',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 16
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'adelante!',
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              onChange: (page) {
                if(page != 0 && page != 4){
                  _isSkip = true;
                } else {
                  _isSkip = false;
                }
          
                setState(() {});
              },
              pages: [
                PageViewModel(
                  title: _genero,
                  body:
                      "Asigna rutinas de ejercicio a cada uno de los cliente de una manera muy sencilla.",
                  image: Container(
                    child: Image.asset(
                      'assets/app_icon_transparent.png',
                      height: 200,
                    ),
                  ),
                  decoration: PageDecoration(
                    titleTextStyle: TextStyle(
                        color: (!_isDark)
                            ? Color.fromARGB(255, 31, 31, 31)
                            : Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 28.0,
                        fontWeight: FontWeight.w700),
                    bodyTextStyle: TextStyle(
                        color: (!_isDark)
                            ? Color.fromARGB(255, 31, 31, 31)
                            : Colors.white,
                        fontFamily: 'poppins',
                        fontSize: 19.0),
                    bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                    pageColor: Colors.transparent,
                    imagePadding: EdgeInsets.zero,
                  ),
                ),
                PageViewModel(
                  title: "Crea y visualiza rutinas",
                  body:
                      "Agrega ejercicios personalizados a las rutinas de cada cliente por separado.",
                  image: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      "assets/images/introduction/intro_entren_4.jpg",
                      width: 275,
                      height: 275,
                    ),
                  ),
                  decoration: PageDecoration(
                    titleTextStyle: TextStyle(
                        color: (!_isDark)
                            ? Color.fromARGB(255, 31, 31, 31)
                            : Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 28.0,
                        fontWeight: FontWeight.w700),
                    bodyTextStyle: TextStyle(
                        color: (!_isDark)
                            ? Color.fromARGB(255, 31, 31, 31)
                            : Colors.white,
                        fontFamily: 'poppins',
                        fontSize: 19.0),
                    bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                    pageColor: Colors.transparent,
                    imagePadding: EdgeInsets.zero,
                  ),
                ),
                PageViewModel(
                  title: "Crea y editar ejercicios",
                  body:
                      "Guarda cada ejercicio individualmente en las distintas categorías existentes.",
                  image: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      "assets/images/introduction/intro_entren_1.jpg",
                      width: 275,
                      height: 275,
                    ),
                  ),
                  decoration: PageDecoration(
                    titleTextStyle: TextStyle(
                        color: (!_isDark)
                            ? Color.fromARGB(255, 31, 31, 31)
                            : Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 28.0,
                        fontWeight: FontWeight.w700),
                    bodyTextStyle: TextStyle(
                        color: (!_isDark)
                            ? Color.fromARGB(255, 31, 31, 31)
                            : Colors.white,
                        fontFamily: 'poppins',
                        fontSize: 19.0),
                    bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                    pageColor: Colors.transparent,
                    imagePadding: EdgeInsets.zero,
                  ),
                ),
                PageViewModel(
                  title: "Chatea con tus clientes",
                  body:
                      "Necesitas hablar con algun cliente? Simple, solo selecciónalo y manda un mensaje!",
                  image: AnimatedContainer(
                    width: width - 50,
                    height: 250,
                    decoration: BoxDecoration(
                        color: (!_isDark)
                            ? Color.fromARGB(255, 54, 54, 54)
                            : Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    duration: Duration(milliseconds: 500),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                      child: Column(
                        children: [
                          SizedBox(height: 15),
                          ClipOval(
                            child: Image.asset(
                              'assets/images/man.png',
                              height: 125,
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: width - 200,
                                      child: Text('Luis Pérez',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          softWrap: false,
                                          textAlign: TextAlign.justify,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 22,
                                              color: (!_isDark)
                                                  ? Colors.white
                                                  : Color.fromRGBO(
                                                      31, 31, 31, 1),
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    SizedBox(height: 5),
                                    Container(
                                        width: width - 200,
                                        child: Text(
                                            'Hola, ¿como has estado?' +
                                                " · " +
                                                DateFormat()
                                                    .add_jm()
                                                    .format(DateTime.now()),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            softWrap: false,
                                            textAlign: TextAlign.start,
                                            style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                color: (!_isDark)
                                                    ? Colors.white
                                                    : Color.fromRGBO(
                                                        31, 31, 31, 1),
                                                fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              ),
                              Expanded(
                                  child: Container(
                                width: 20,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 15,
                                        height: 15,
                                        decoration: BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  decoration: PageDecoration(
                    titleTextStyle: TextStyle(
                        color: (!_isDark)
                            ? Color.fromARGB(255, 31, 31, 31)
                            : Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 28.0,
                        fontWeight: FontWeight.w700),
                    bodyTextStyle: TextStyle(
                        color: (!_isDark)
                            ? Color.fromARGB(255, 31, 31, 31)
                            : Colors.white,
                        fontFamily: 'poppins',
                        fontSize: 19.0),
                    bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                    pageColor: Colors.transparent,
                    imagePadding: EdgeInsets.zero,
                  ),
                ),
                PageViewModel(
                  title: "TIP:\nAmplia las imágenes",
                  body:
                      "Mantén presionada alguna imagen pequeña para poder tener una mejor vista de ella.",
                  image: GestureDetector(
                    onLongPress: () {
                      setState(() {
                        _isPreview = true;
                      });
                    },
                    onLongPressEnd: (details) {
                      setState(() {
                        _isPreview = false;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Image.asset(
                        "assets/images/introduction/vector-lupa.png",
                        width: 175,
                        height: 175,
                      ),
                    ),
                  ),
                  decoration: PageDecoration(
                    titleTextStyle: TextStyle(
                        color: (!_isDark)
                            ? Color.fromARGB(255, 31, 31, 31)
                            : Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 28.0,
                        fontWeight: FontWeight.w700),
                    bodyTextStyle: TextStyle(
                        color: (!_isDark)
                            ? Color.fromARGB(255, 31, 31, 31)
                            : Colors.white,
                        fontFamily: 'poppins',
                        fontSize: 19.0),
                    bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                    pageColor: Colors.transparent,
                    imagePadding: EdgeInsets.zero,
                  ),
                ),
              ],
              onDone: () async {
                await storage.write(key: 'INTRO', value: 'FALSE');
                Get.offAll(() => EntrenadorScreen());
              },
              showSkipButton: false,
              skipOrBackFlex: 0,
              nextFlex: 0,
              showBackButton: true,
              back: const Icon(Icons.arrow_back, color: Color.fromRGBO(107, 195, 130, 1)),
              next: const Icon(Icons.arrow_forward, color: Color.fromRGBO(107, 195, 130, 1)),
              done: const Text('Finalizar', style: TextStyle(fontFamily: 'poppins', color: Color.fromRGBO(107, 195, 130, 1), fontWeight: FontWeight.w500)),
              curve: Curves.fastLinearToSlowEaseIn,
              controlsMargin: const EdgeInsets.all(16),
              dotsDecorator: DotsDecorator(
                size: Size(10.0, 10.0),
                color: (!_isDark) ? Color.fromARGB(255, 71, 71, 71) : Color.fromARGB(255, 255, 255, 255),
                activeColor: Color.fromRGBO(107, 195, 130, 1),
                activeSize: Size(22.0, 10.0),
                activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
              dotsContainerDecorator: ShapeDecoration(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ),
          ),
          if (_isPreview) Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
            ),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 300,
                  maxWidth: 300,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  image: DecorationImage(image: AssetImage("assets/images/introduction/vector-lupa.png"), fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}