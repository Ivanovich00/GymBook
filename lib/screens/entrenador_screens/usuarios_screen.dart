import 'dart:io';

import 'package:GymBook/screens/entrenador_screens/crear_rutinas_screen.dart';
import 'package:GymBook/screens/entrenador_screens/ver_rutinas_screen.dart';
import 'package:GymBook/screens/screens.dart';
import 'package:GymBook/services/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PantallaUsuarios extends StatefulWidget {
  const PantallaUsuarios({Key? key}) : super(key: key);
  @override
  State<PantallaUsuarios> createState() => _PantallaUsuariosState();
}

final db = FirebaseFirestore.instance;

bool _isOscuro = false;
bool _isConnectedBool = false;

String ua_micuenta = "";

String order_clientes = "nombre";
bool des_clientes = false;
bool sort_clientes = false;
List<bool> botsel_clientes = [false, true];
enum SortByClientes {nombre, apellido, rutina, registro}

String? userdoc, nombre, apellido, edad, email, imagenURL, registro, genero, uid, tipo, _modeUser, uid_f, fecha;

bool rutina = false;
bool _isSelected = false;

final TextEditingController _controllerSearchClientes = new TextEditingController();

class _PantallaUsuariosState extends State<PantallaUsuarios>{
  @override
  void initState() {
    super.initState();
    _initGetDetails();
    _isConnected();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initGetDetails() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    User? user = _firebaseAuth.currentUser;

    userdoc = user!.uid;

    final authService = Provider.of<AuthService>(context, listen: false);
    tipo = await authService.readUserInfo();
    final valor_isOscuro = await authService.readTheme();

    if (valor_isOscuro == 'OSCURO') {
      _isOscuro = true;
    } else {
      _isOscuro = false;
    }

    setState(() {});
  }

  Future<void> _isConnected() async {
    sort_clientes = false;
    if(order_clientes == "nombre"){
      _sortByClientes = SortByClientes.nombre;
    } else if(order_clientes == "apellido"){
      _sortByClientes = SortByClientes.apellido;
    } else if(order_clientes == "rutina"){
      _sortByClientes = SortByClientes.rutina;
    } else  {
      _sortByClientes = SortByClientes.registro;
    }

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    User? user = _firebaseAuth.currentUser;

    userdoc = user!.uid;

    await FirebaseFirestore.instance
        .collection('entrenadores')
        .doc(userdoc)
        .get()
        .then((value) {
      ua_micuenta = value['nombre'];
    });

    try {
      final result = await InternetAddress.lookup('example.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _isConnectedBool = true;
      }
    } catch (_) {
      _isConnectedBool = false;
    }
  }

  SortByClientes? _sortByClientes;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return FutureBuilder(
      future: authService.readTheme(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SafeArea(
            child: DefaultTabController(
              length: 1,
              child: Scaffold(
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                floatingActionButton: IgnorePointer(
                  ignoring: !_isSelected,
                  child: AnimatedOpacity(
                    opacity: (_isSelected) ? 1 : 0,
                    duration: Duration(milliseconds: 250),
                    child: FloatingActionButton(
                      onPressed: () {},
                    child: SpeedDial(
                      elevation: 8.0,
                      overlayColor: Colors.black,
                      overlayOpacity: 0.3,
                      tooltip: 'Opciones',
                      animatedIcon: AnimatedIcons.menu_close,
                      animatedIconTheme: IconThemeData(
                        size: 22.0,
                        color: (_isOscuro)
                            ? Color.fromRGBO(31, 31, 31, 1)
                            : Colors.white,
                      ),
                      backgroundColor: (_isOscuro)
                          ? Colors.white
                          : Color.fromRGBO(31, 31, 31, 1),
                      foregroundColor: Colors.black,
                      visible: true,
                      curve: Curves.bounceIn,
                      spacing: 12.5,
                      children: [
                        (_modeUser == 'cliente')
                          ? SpeedDialChild(
                              child: Icon(
                                Icons.info,
                                color: (_isOscuro)
                                    ? Color.fromRGBO(31, 31, 31, 1)
                                    : Colors.white,
                              ),
                              backgroundColor: (_isOscuro)
                                  ? Colors.white
                                  : Color.fromRGBO(31, 31, 31, 1),
                              onTap: () {
                                verInfo();
                              },
                              label: 'Informacion del usuario',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: (_isOscuro)
                                  ? Color.fromRGBO(31, 31, 31, 1)
                                  : Colors.white,
                                fontSize: 16.0),
                              labelBackgroundColor: (_isOscuro)
                                ? Colors.white
                                : Color.fromRGBO(31, 31, 31, 1),
                            )
                          : SpeedDialChild(
                              child: null,
                              backgroundColor: Colors.transparent,
                            ),
                        (_modeUser == 'cliente')
                          ? SpeedDialChild(
                              child: Icon(
                                ((rutina))
                                    ? Icons.remove_red_eye_rounded
                                    : Icons.add_chart_rounded,
                                color: (_isOscuro)
                                    ? Color.fromRGBO(31, 31, 31, 1)
                                    : Colors.white,
                              ),
                              backgroundColor: (_isOscuro)
                                  ? Colors.white
                                  : Color.fromRGBO(31, 31, 31, 1),
                              onTap: () {
                                if (!rutina) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PantallaCrearRutinas(uid: uid, nombre: nombre, imagenURL: imagenURL),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PantallaVerRutinas(uid: uid, nombre: nombre, imagenURL: imagenURL),
                                    ),
                                  );
                                }
                              },
                              label: (!rutina) ? 'Asignar rutina' : 'Ver rutina',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: (_isOscuro)
                                  ? Color.fromRGBO(31, 31, 31, 1)
                                  : Colors.white,
                                fontSize: 16.0),
                              labelBackgroundColor: (_isOscuro)
                                ? Colors.white
                                : Color.fromRGBO(31, 31, 31, 1),
                            )
                          : SpeedDialChild(
                              child: null,
                              backgroundColor: Colors.transparent,
                            ),
                        (_modeUser == 'cliente' && rutina)
                          ? SpeedDialChild(
                              child: Icon(
                                Icons.edit,
                                color: (_isOscuro)
                                  ? Color.fromRGBO(31, 31, 31, 1)
                                  : Colors.white,
                              ),
                              backgroundColor: (_isOscuro)
                                ? Colors.white
                                : Color.fromRGBO(31, 31, 31, 1),
                              onTap: () {
                                Get.defaultDialog(
                                  title: 'MODIFICAR RUTINA',
                                  titlePadding: EdgeInsets.all(15),
                                  titleStyle: TextStyle(
                                    fontStyle: FontStyle.normal,
                                    fontSize: 19.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                  content: Padding(padding: const EdgeInsets.symmetric(horizontal: 25.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '¿Estas seguro de modificar la rutina de $nombre?',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              fontStyle: FontStyle.normal,
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.black)))
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
                                        backgroundColor: MaterialStateProperty.all<Color>(Colors.amber),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                            side: BorderSide(color: Colors.amber)))),
                                      child: Text("SI"),
                                      onPressed: () {
                                        Navigator.of(context).pop();

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PantallaCrearRutinas(uid: uid, nombre: nombre, imagenURL: imagenURL),
                                          ),
                                        );

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

                                setState(() {});
                              },
                              label: 'Modificar rutina',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: (_isOscuro)
                                  ? Color.fromRGBO(31, 31, 31, 1)
                                  : Colors.white,
                                  fontSize: 16.0),
                              labelBackgroundColor: (_isOscuro)
                                ? Colors.white
                                : Color.fromRGBO(31, 31, 31, 1),
                            )
                          : SpeedDialChild(
                              child: null,
                              backgroundColor: Colors.transparent,
                            ),
                        (_modeUser == 'cliente' && rutina)
                            ? SpeedDialChild(
                                child: Icon(
                                  Icons.delete_forever_sharp,
                                  color: (_isOscuro)
                                      ? Color.fromRGBO(31, 31, 31, 1)
                                      : Colors.white,
                                ),
                                backgroundColor: Colors.red[800],
                                onTap: () {
                                  Get.defaultDialog(
                                    title: 'ELIMINAR RUTINA',
                                    titlePadding: EdgeInsets.all(15),
                                    titleStyle: TextStyle(
                                        fontStyle: FontStyle.normal,
                                        fontSize: 19.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    content: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                              '¿Estas seguro de eliminar la rutina a $nombre?',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                  textStyle: TextStyle(
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      fontSize: 17.0,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors.black)))
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
                                              side: BorderSide(color: Colors.red)))),
                                        child: Text("SI"),
                                        onPressed: () async {
                                          Navigator.of(context).pop();

                                          FirebaseFirestore.instance.collection('clientes').doc(uid).update({
                                            "rutina": false,
                                          });

                                          FirebaseFirestore.instance.collection('rutinas').doc(uid).collection('ejercicios').get().then((snapshot) {
                                            for (DocumentSnapshot ds
                                                in snapshot.docs) {
                                              ds.reference.delete();
                                            };
                                          }).then((value) {
                                            FirebaseFirestore.instance.collection('rutinas').doc(uid).delete();
                                          });

                                          _isSelected = false;
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

                                  setState(() {});
                                },
                                label: 'Eliminar rutina',
                                labelStyle: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: (_isOscuro)
                                        ? Color.fromRGBO(31, 31, 31, 1)
                                        : Colors.white,
                                    fontSize: 16.0),
                                labelBackgroundColor: Colors.red[800],
                              )
                            : SpeedDialChild(
                                child: null,
                                backgroundColor: Colors.transparent,
                              ),
                      ],
                    ),
                    ),
                  ),
                ),
                appBar: AppBar(
                  leading: IconButton(
                    splashRadius: 25,
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _isSelected = false;
                      setState(() {});


                      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRight, child: EntrenadorScreen(), duration: Duration(milliseconds: 250)));
                    }),
                    backgroundColor: Color.fromRGBO(72, 83, 98, 1),
                    elevation: 0,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text('USUARIOS',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                        ),
                      ],
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(80.0),
                      child: TabBar(
                        isScrollable: true,
                        onTap: (index) {
                          _isConnected();
                          _controllerSearchClientes.clear();
                          sort_clientes = false;
                          _isSelected = false;
                          uid = '';
                          FocusScope.of(context).unfocus();
                          setState(() {});
                        },
                        tabs: [
                          Tab(
                            child: Container(
                              width: 110,
                              child: Text('Clientes',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13)),
                                ),
                                icon: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                )
                          ),
                        ],
                      ),
                    )),
                    body: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Container(
                          color: (_isOscuro)
                            ? Color.fromRGBO(31, 31, 31, 1)
                            : Colors.white,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: db.collection('clientes').orderBy(order_clientes, descending: des_clientes).snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container(
                                  color: (_isOscuro)
                                    ? Color.fromRGBO(31, 31, 31, 1)
                                    : Colors.white,
                                  child: Center(
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      child: CircularProgressIndicator(
                                        color: (_isOscuro)
                                          ? Colors.white
                                          : Color.fromRGBO(1, 29, 69, 1))
                                    )
                                  )
                                );
                              } else {
                                if (!snapshot.data!.docs.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 12.5),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: (!_isOscuro) ? Colors.white : Color.fromRGBO(31, 31, 31, 255),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                                bottomRight: Radius.circular(0),
                                                bottomLeft: Radius.circular(0)
                                              ),
                                              border: Border(
                                                top: BorderSide(color: Colors.grey.shade800, width: 0.5),
                                                bottom: BorderSide(color: Colors.grey.shade800, width: 0.5),
                                                left: BorderSide(color: Colors.grey.shade800, width: 0.5),
                                                right: BorderSide(color: Colors.grey.shade800, width: 0.5)
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: width - 65,
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: width - 100,
                                                        child: TextField(
                                                          style: TextStyle(color: (_isOscuro) ? Colors.white : Colors.black),
                                                          autocorrect: false,
                                                          textAlignVertical: TextAlignVertical.center,
                                                          controller: _controllerSearchClientes,
                                                          onChanged: (value) {
                                                            setState(() {});
                                                          },
                                                          decoration: InputDecoration(
                                                            contentPadding: EdgeInsets.all(10.0),
                                                            labelText: "Buscar un cliente...",
                                                            hintText: "Buscar un cliente...",
                                                            labelStyle: TextStyle(color: (_isOscuro) ? Colors.white : Colors.black),
                                                            hintStyle: TextStyle(color: (_isOscuro) ? Colors.white : Colors.black),
                                                            helperStyle: TextStyle(color: (_isOscuro) ? Colors.white : Colors.black),
                                                            floatingLabelStyle: TextStyle(color: (_isOscuro) ? Colors.white : Colors.black),
                                                            prefixIcon: Icon(Icons.search, color: (_isOscuro) ? Colors.white : Colors.grey[800]),
                                                            floatingLabelBehavior: FloatingLabelBehavior.never,
                                                            focusedBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.zero,
                                                              borderSide: BorderSide(
                                                                style: BorderStyle.none
                                                              )
                                                            ),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.zero,
                                                              borderSide: BorderSide(
                                                                style: BorderStyle.none
                                                              )
                                                            ),
                                                        ),
                                                        inputFormatters: <TextInputFormatter>[
                                                        FilteringTextInputFormatter.allow(
                                                            RegExp("[a-zA-Z\u00f1\u00d1]*"))
                                                        ],
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: (){
                                                          _controllerSearchClientes.text = "";
                                                          setState(() {});
                                                        },
                                                        child: Icon(
                                                          (_controllerSearchClientes.text != '')
                                                            ? Icons.backspace_outlined
                                                            : null,
                                                          size: 22.5,
                                                          color: (_isOscuro) ? Colors.white : Colors.grey[800]),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: (!sort_clientes) ? 'Ordenar por...' : 'Cerrar',
                                                  child: GestureDetector(
                                                    onTap: (){
                                                      sort_clientes = !sort_clientes;
                                                      setState(() {});
                                                    },
                                                    child: Icon(
                                                      sort_clientes
                                                        ? Icons.close
                                                        : Icons.menu,
                                                      color: (_isOscuro) ? Colors.white : Colors.grey[800]),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: AnimatedContainer(
                                            width: width - 25,
                                            height: sort_clientes ? 275 : 0,
                                            duration: Duration(milliseconds: 500),
                                            curve: Curves.fastOutSlowIn,
                                            decoration: BoxDecoration(
                                              color: (!_isOscuro) ? Colors.white : Color.fromRGBO(31, 31, 31, 255),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(0),
                                                topRight: Radius.circular(0),
                                                bottomRight: Radius.circular(10),
                                                bottomLeft: Radius.circular(10)
                                              ),
                                              border: Border(
                                                top: BorderSide(color: Colors.grey.shade800, width: 0.5),
                                                bottom: BorderSide(color: Colors.grey.shade800, width: 0.5),
                                                left: BorderSide(color: Colors.grey.shade800, width: 0.5),
                                                right: BorderSide(color: Colors.grey.shade800, width: 0.5)
                                              ),
                                            ),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    title: Text(
                                                      'Ordenar por Nombre',
                                                      style: TextStyle(color: (_isOscuro) ? Colors.white : Colors.black)
                                                    ),
                                                    leading: Radio<SortByClientes>(
                                                      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                                                        if (!states.contains(MaterialState.selected)) {
                                                          return (_isOscuro) ? Colors.white : Colors.black;
                                                        }
                                                        return Color.fromRGBO(4, 199, 82, 1);
                                                      }),
                                                      value: SortByClientes.nombre,
                                                      groupValue: _sortByClientes,
                                                      onChanged: (SortByClientes? value) {
                                                        setState(() {
                                                          _sortByClientes = value;
                                                        order_clientes = "nombre";
                                                        });
                                                      },
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        _sortByClientes = SortByClientes.nombre;
                                                        order_clientes = "nombre";
                                                      });
                                                    },
                                                  ),
                                                  ListTile(
                                                    title: Text(
                                                      'Ordenar por Apellido',
                                                      style: TextStyle(color: (_isOscuro) ? Colors.white : Colors.black)
                                                    ),
                                                    leading: Radio<SortByClientes>(
                                                      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                                                        if (!states.contains(MaterialState.selected)) {
                                                          return (_isOscuro) ? Colors.white : Colors.black;
                                                        }
                                                        return Color.fromRGBO(4, 199, 82, 1);
                                                      }),
                                                      value: SortByClientes.apellido,
                                                      groupValue: _sortByClientes,
                                                      onChanged: (SortByClientes? value) {
                                                        setState(() {
                                                          _sortByClientes = value;
                                                          order_clientes = "apellido";
                                                        });
                                                      },
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        _sortByClientes = SortByClientes.apellido;
                                                        order_clientes = "apellido";
                                                      });
                                                    },
                                                  ),
                                                  ListTile(
                                                    title: Text(
                                                      'Ordenar por Rutina',
                                                      style: TextStyle(color: (_isOscuro) ? Colors.white : Colors.black)
                                                    ),
                                                    leading: Radio<SortByClientes>(
                                                      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                                                        if (!states.contains(MaterialState.selected)) {
                                                          return (_isOscuro) ? Colors.white : Colors.black;
                                                        }
                                                        return Color.fromRGBO(4, 199, 82, 1);
                                                      }),
                                                      value: SortByClientes.rutina,
                                                      groupValue: _sortByClientes,
                                                      onChanged: (SortByClientes? value) {
                                                        setState(() {
                                                          _sortByClientes = value;
                                                          order_clientes = "rutina";
                                                        });
                                                      },
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        _sortByClientes = SortByClientes.rutina;
                                                        order_clientes = "rutina";
                                                      });
                                                    },
                                                  ),
                                                  ListTile(
                                                    title: Text(
                                                      'Ordenar por Fecha de Registro',
                                                      style: TextStyle(color: (_isOscuro) ? Colors.white : Colors.black)
                                                    ),
                                                    leading: Radio<SortByClientes>(
                                                      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                                                        if (!states.contains(MaterialState.selected)) {
                                                          return (_isOscuro) ? Colors.white : Colors.black;
                                                        }
                                                        return Color.fromRGBO(4, 199, 82, 1);
                                                      }),
                                                      value: SortByClientes.registro,
                                                      groupValue: _sortByClientes,
                                                      onChanged: (SortByClientes? value) {
                                                        setState(() {
                                                          _sortByClientes = value;
                                                          order_clientes = "registro";
                                                        });
                                                      },
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        _sortByClientes = SortByClientes.registro;
                                                        order_clientes = "registro";
                                                      });
                                                    },
                                                  ),
                                                  ToggleButtons(
                                                    color: (_isOscuro) ? Colors.white : Colors.black.withOpacity(0.70),
                                                    selectedColor: Color.fromRGBO(4, 199, 82, 1),
                                                    selectedBorderColor:Color.fromRGBO(4, 199, 82, 1),
                                                    fillColor: Color.fromRGBO(4, 199, 82, 1).withOpacity(0.08),
                                                    splashColor: Color.fromRGBO(4, 199, 82, 1).withOpacity(0.12),
                                                    hoverColor: Color.fromRGBO(4, 199, 82, 1).withOpacity(0.04),
                                                    borderRadius: BorderRadius.circular(4.0),
                                                    disabledColor: Colors.black.withOpacity(0.70),
                                                    disabledBorderColor: Colors.black.withOpacity(0.70),
                                                    borderColor: (_isOscuro) ? Colors.white : Colors.black.withOpacity(0.50),
                                                    constraints: BoxConstraints(minHeight: 36.0),
                                                    isSelected: botsel_clientes,
                                                    onPressed: (index) {
                                                      if(botsel_clientes[index] == false){
                                                        botsel_clientes[0] = !botsel_clientes[0];
                                                        botsel_clientes[1] = !botsel_clientes[1];
                                                      }
                                                      if(botsel_clientes[0] == true){
                                                        des_clientes = true;
                                                      } else {
                                                        des_clientes = false;
                                                      }
                                                      setState(() {});
                                                    },
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                                                        child: Text('Ascendente'),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                                                        child: Text('Descendente'),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 3),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: ListView(
                                                children: snapshot.data!.docs.map((doc) {

                                                  return (doc['nombre'].toString().toLowerCase().contains(_controllerSearchClientes.text.toLowerCase()) || doc['apellido'].toString().toLowerCase().contains(_controllerSearchClientes.text.toLowerCase()))
                                                    ? Card(
                                                      color: Color.fromRGBO(35, 59, 94, 1),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(
                                                          Radius.circular(15)),
                                                        ),
                                                      elevation: 0,
                                                      child: Stack(
                                                        alignment: AlignmentDirectional.center,
                                                        children: [
                                                          ListTile(
                                                            onTap: () async {
                                                              try {
                                                                final result = await InternetAddress.lookup('example.com');

                                                                if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                                                                  _isConnectedBool = true;
                                                                  sort_clientes = false;
                                                                  if (doc.id != uid) {
                                                                    _isSelected = true;
                                                                    uid = doc['uid'];
                                                                    _modeUser = 'cliente';
                                                                  } else {
                                                                    if (_isSelected == true) {
                                                                      _isSelected = false;
                                                                      uid = '';
                                                                    } else {
                                                                      _isSelected = true;
                                                                      uid = doc['uid'];
                                                                      _modeUser = 'cliente';
                                                                    }
                                                                  }

                                                                  tipo = 'cliente';
                                                                  nombre = doc['nombre'];
                                                                  apellido = doc['apellido'];
                                                                  edad = doc['edad'];
                                                                  email = doc['email'];
                                                                  imagenURL = doc['imagenURL'];
                                                                  registro = doc['registro'];
                                                                  genero = doc['genero'];
                                                                  rutina = doc['rutina'];

                                                                  uid_f = uid;

                                                                  getRealDate();

                                                                  setState(() {});
                                                                }
                                                              } catch (_) {
                                                                _isConnectedBool = false;
                                                                _noInternet();
                                                              }
                                                            },
                                                            selected: (doc.id == uid && _isSelected)
                                                              ? true
                                                              : false,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.all(Radius.circular(15)),
                                                            ),
                                                            selectedTileColor:(_isOscuro) ? Colors.white : Colors.grey[800],
                                                            tileColor: Colors.transparent,
                                                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                            leading: Container(
                                                              height: 100,
                                                              child: CircleAvatar(
                                                                backgroundColor:Color.fromRGBO(218, 218, 218, 1),
                                                                radius: 30,
                                                                child: ClipOval(
                                                                  child: (_isConnectedBool == true)
                                                                  ? CachedNetworkImage(
                                                                    imageUrl: doc['imagenURL'],
                                                                    placeholder: (context, url) => Column(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      children: [
                                                                        Container(width: 40, height: 40, child: new CircularProgressIndicator(strokeWidth: 2, color: Color.fromARGB(255, 35, 59, 94))),
                                                                      ],
                                                                    ),
                                                                    errorWidget: (context, url, error) => new Icon(Icons.error, color: Colors.red[800]),
                                                                    fit: BoxFit.cover,
                                                                    width: 60.0,
                                                                    height: 60.0,
                                                                  )
                                                                  : Image.asset('assets/images/account_default.png',
                                                                    fit: BoxFit.cover,
                                                                    width: 60.0,
                                                                    height: 60.0,
                                                                  )),
                                                              ),
                                                            ),
                                                            title: Text(
                                                              doc['nombre'][0].toString().toUpperCase() + doc['nombre'].toString().substring(1).toLowerCase(),
                                                              overflow: TextOverflow.ellipsis,
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 20,
                                                                color: (doc.id == uid && _isSelected && _isOscuro)
                                                                  ? Color.fromRGBO(31, 31, 31, 1)
                                                                  : (doc.id == uid && _isSelected && !_isOscuro)
                                                                  ? Colors.white
                                                                  : Colors.white,
                                                                fontWeight: FontWeight.normal)),
                                                                subtitle: Text(
                                                                  doc['apellido'][0].toString().toUpperCase() + doc['apellido'].toString().substring(1).toLowerCase(),
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize: 20,
                                                                    color: (doc.id == uid && _isSelected && _isOscuro)
                                                                      ? Color.fromRGBO(31, 31, 31, 1)
                                                                      : (doc.id == uid && _isSelected && !_isOscuro)
                                                                      ? Colors.white
                                                                      : Colors.white,
                                                                    fontWeight: FontWeight.normal)),
                                                                  trailing: AnimatedContainer(
                                                                    width: 50,
                                                                    duration: Duration(milliseconds: 500),
                                                                    child: SingleChildScrollView(
                                                                      scrollDirection: Axis.horizontal,
                                                                      child: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: [
                                                                          (doc['rutina'] == true) 
                                                                            ? Icon(Icons.how_to_reg_outlined, color: Colors.green, size: 17)
                                                                            : Icon(Icons.highlight_off, color: Colors.red[800], size: 17),
                                                                          SizedBox(height: 3),
                                                                          Text(
                                                                            (doc['rutina'] == true)
                                                                              ? 'TIENE\nRUTINA'
                                                                              : 'SIN\nRUTINA',
                                                                            textAlign: TextAlign.center,
                                                                            style: GoogleFonts.poppins(
                                                                              fontSize: 12,
                                                                              color: (doc['rutina'] == false)
                                                                                ? Colors.red[800]
                                                                                : Colors.green,
                                                                              fontWeight: FontWeight.w600
                                                                            )
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ]
                                                      ))
                                                    : Container();
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ),
                                  ],
                                ),
                              );
                            } else {
                              return Container(
                                color: (_isOscuro)
                                    ? Color.fromRGBO(31, 31, 31, 1)
                                    : Colors.white,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_off_outlined,
                                          color: Color.fromRGBO(44, 181, 110, 1),
                                          size: 120),
                                      SizedBox(height: 15),
                                      Text('No existen clientes',
                                          style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              color: (_isOscuro)
                                                  ? Colors.white
                                                  : Color.fromRGBO(
                                                      31, 31, 31, 1),
                                              fontWeight: FontWeight.normal)),
                                      SizedBox(height: 5),
                                      Text('registrados actualmente',
                                          style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              color: (_isOscuro)
                                                  ? Colors.white
                                                  : Color.fromRGBO(
                                                      31, 31, 31, 1),
                                              fontWeight: FontWeight.normal)),
                                    ],
                                  ),
                                ),
                              );
                            }
                          }
                            }
                          ),
                        ),
                      ],
                    ),
              ),
            )
          );
        } else {
          return Text('');
        }
      },

    );
  }

  void verInfo(){
    Get.defaultDialog(
        title: "Informacion del usuario ",
        titlePadding: EdgeInsets.fromLTRB(0, 10, 0, 5),
        backgroundColor: Colors.white,
        titleStyle: TextStyle(color: Colors.black54),
        textConfirm: "Aceptar",
        onConfirm: () => Get.back(),
        confirmTextColor: Colors.white,
        buttonColor: Color.fromRGBO(1, 29, 69, 1),
        barrierDismissible: false,
        radius: 15,
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  text: 'Nombre:  ',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: nombre![0].toString().toUpperCase() + nombre!.toString().substring(1).toLowerCase() + ' ' + apellido![0].toString().toUpperCase() + apellido!.toString().substring(1).toLowerCase(),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'Edad:  ',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: edad.toString(),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              (tipo == "cliente") 
              ? RichText(
                text: TextSpan(
                  text: 'Rutina:  ',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: (rutina) ? "Asignada" : "No asignada",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              )
              : SizedBox(),
              SizedBox(height: 15),
              Text(
                'Registrado el:',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black54,
                  ),
              ),
              Text(
                fecha!,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                    color: Colors.black54,
                  ),
              ),
            ],
          ),
        ));
  }

  getRealDate() async {
    try {
      final result = await InternetAddress.lookup('example.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (uid != '') {
          List<String> dirty_fecha = registro!.split('-');
          String mes;

          switch (dirty_fecha[1]) {
            case '01':
              mes = 'Enero';
              break;

            case '02':
              mes = 'Febrero';
              break;

            case '03':
              mes = 'Marzo';
              break;

            case '04':
              mes = 'Abril';
              break;

            case '05':
              mes = 'Mayo';
              break;

            case '06':
              mes = 'Junio';
              break;

            case '07':
              mes = 'Julio';
              break;

            case '08':
              mes = 'Agosto';
              break;

            case '09':
              mes = 'Septiembre';
              break;

            case '10':
              mes = 'Octubre';
              break;

            case '11':
              mes = 'Noviembre';
              break;

            case '12':
              mes = 'diciembre';
              break;
            default:
              mes = '';
          }
          fecha = dirty_fecha[2] + ' de ' + mes + ' del ' + dirty_fecha[0];
        }
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
  }

  _noInternet() {
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
