import 'dart:async';
import 'dart:io';
import 'package:GymBook/screens/screens.dart';
import 'package:GymBook/services/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
//import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class PantallaChatAdmin extends StatefulWidget {
  const PantallaChatAdmin({Key? key}) : super(key: key);
  @override
  State<PantallaChatAdmin> createState() => _PantallaChatAdminState();
}

final db = FirebaseFirestore.instance;

String? userdoc;
String? tipo;
String? nombre_user;
String? apellido_user;
String? imagenURL_user;

String? nombre;
String? apellido;
String? imagenURL;
String uid = '';

String? year;
String? month;
String? day;
String? month_letters;

bool _isSelected = false;
bool _isConnectedBool = true;

bool _verHora = false;
String? _textSelected;

bool _isPreview = false;

DateFormat formato_fecha = new DateFormat('d/M/y -').add_jm();
DateFormat formato_hora = new DateFormat.jm();
DateTime now = new DateTime.now();
DateTime ayer = DateTime.now().subtract(Duration(days:1));

final TextEditingController _controllerSearch = new TextEditingController();
final TextEditingController _controllerMessage = new TextEditingController();
String mensaje = '';

ScrollController _scrollController = ScrollController();

class _PantallaChatAdminState extends State<PantallaChatAdmin> {
  bool _isOscuro = false;

  Future<void> _isConnected() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final valor_isOscuro = await authService.readTheme();

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    User? user = _firebaseAuth.currentUser;

    userdoc = user!.uid;

    if (valor_isOscuro == 'OSCURO') {
      _isOscuro = true;
    } else {
      _isOscuro = false;
    }

    try {
      final result = await InternetAddress.lookup('example.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _isConnectedBool = true;
      }
    } catch (_) {
      _isConnectedBool = false;
    }

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

    try {
      final result = await InternetAddress.lookup('example.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FirebaseFirestore.instance
        .collection("entrenadores")
        .doc(userdoc)
        .snapshots()
        .listen((event) {
          nombre_user = event.get('nombre').toString();
          apellido_user = event.get('apellido').toString();
          imagenURL_user = event.get('imagenURL').toString();
        });
      }
    } catch (_) {
      _errorInternet();
    }
  }

  @override
  void initState() {
    super.initState();
    _initGetDetails();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final authService = Provider.of<AuthService>(context, listen: false);

    return SafeArea(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            width: width,
            height: height,
            color: (_isOscuro) ? Color.fromRGBO(31, 31, 31, 1) : Color.fromRGBO(255, 255, 255, 1) ,
          ),
          FutureBuilder(
              future: authService.readTheme(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('');
                }

                if (snapshot.data != '') {
                    return Scaffold(
                      resizeToAvoidBottomInset: true,
                      appBar: AppBar(
                        leading: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if(!_isSelected && uid == ''){
                                Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRight, child: AdministradorScreen(), duration: Duration(milliseconds: 250)));
                              } 
                              
                              uid = '';
                              nombre = '';
                              apellido = '';
                              imagenURL = '';
                              _isSelected = false;
                              _controllerSearch.clear();

                              setState(() {});

                            }),
                        backgroundColor: Color.fromRGBO(71, 83, 97, 1),
                        elevation: 0,
                        title: Text(
                          (!_isSelected && uid == '') ? 'CHAT CON CLIENTES' : '$nombre $apellido',
                          style: TextStyle(
                            color: Colors.white,
                          )
                        ),
                        actions: [
                          if (_isSelected && uid != '') Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: GestureDetector(
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
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(imagenURL ?? ''),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      body: (!_isSelected && uid == '') ? SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: Container(
                          color: (_isOscuro) ? Color.fromRGBO(31, 31, 31, 1) : Color.fromARGB(255, 212, 212, 212),
                          width: width,
                          height: height,
                          child: Column(
                             children: <Widget>[
                              Container(
                                child: Container(
                                  color: (_isOscuro) ? Color.fromRGBO(45, 44, 45, 1) : Color.fromARGB(255, 212, 212, 212),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(8,8,8,4),
                                    child: Container(
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(245, 245, 245, 1),
                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                        border: Border.all(color: Color.fromRGBO(245, 245, 245, 1),
                                      ),
                                      ),
                                      child: TextField(
                                        autocorrect: false,
                                        textAlignVertical: TextAlignVertical.center,
                      
                                        onTap: (){
                                          FocusScope.of(context).unfocus();
                                        },
                      
                                        onChanged: (value) {
                                          uid = '';
                                          nombre = '';
                                          apellido = '';
                                          imagenURL = '';
                                          _isSelected = false;
                                          setState(() {});
                                        },
                                        controller: _controllerSearch,
                                        decoration: InputDecoration(
                                            hintText: "Buscar",
                                            contentPadding: EdgeInsets.all(10.0),
                                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade700, size: 20),
                                            floatingLabelBehavior: FloatingLabelBehavior.never,
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15))
                                            ),
                                            focusedBorder:
                                              OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color.fromRGBO(245, 245, 245, 1),
                                                  width: 0
                                                ),
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                            enabledBorder:
                                              OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Color.fromRGBO(245, 245, 245, 1),
                                                  width: 0
                                                ),
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                        ),
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]"))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      
                              Expanded(
                                child: StreamBuilder<QuerySnapshot>(
                                    stream: db.collection('clientes').snapshots(),
                                    builder: (context, snapshot) {
                                      _isConnected();
                      
                                      if (_isConnectedBool == true) {
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
                                                              : Color.fromRGBO(1, 29, 69, 1)
                                                      )
                                                  )
                                              )
                                          );
                                        } else {
                                          if (!snapshot.data!.docs.isEmpty) {
                                            return Column(
                                              children: [
                                                Container(
                                                  color: (_isOscuro)
                                                          ? Color.fromRGBO(45, 45, 45, 1)
                                                          : Color.fromARGB(255, 212, 212, 212),
                                                  alignment: AlignmentDirectional.center,
                                                  height: 110,
                                                  child: ListView(
                                                    shrinkWrap: true,
                                                    scrollDirection: Axis.horizontal,
                                                    children:
                                                      snapshot.data!.docs.map((doc) {
                                                        return (doc['nombre'].toString().toLowerCase().contains(_controllerSearch.text.toLowerCase()) || doc['apellido'].toString().toLowerCase().contains(_controllerSearch.text.toLowerCase())) ? GestureDetector(
                                                          onTap: () {
                                                            _controllerMessage.clear();
                                                            if (doc.id != uid) {
                                                              _isSelected = true;
                                                              uid = doc['uid'];
                                                              nombre = doc['nombre'];
                                                              apellido = doc['apellido'];
                                                              imagenURL = doc['imagenURL'];
                                                            } else {
                                                              if (_isSelected == true) {
                                                                _isSelected = false;
                                                                uid = '';
                                                              } else {
                                                                _isSelected = true;
                                                                uid = doc['uid'];
                                                                nombre = doc['nombre'];
                                                                apellido = doc['apellido'];
                                                                imagenURL = doc['imagenURL'];
                                                              }
                                                            }
                      
                                                            setState(() {});
                                                          },
                                                          child: Container(
                                                            width: 65,
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                    color: (_isSelected && nombre == doc['nombre']) ? Color.fromRGBO(44, 181, 110, 1) : (_isOscuro) ? Colors.white : Color.fromRGBO(45, 45, 45, 1),
                                                                    borderRadius: BorderRadius.all(Radius.circular(25)),
                                                                    border: Border.all(
                                                                      color: (_isSelected && nombre == doc['nombre']) ? Color.fromRGBO(44, 181, 110, 1) : (_isOscuro) ? Colors.white : Color.fromRGBO(45, 45, 45, 1),
                                                                      width: 2,
                                                                    ),
                                                                  ),
                                                                  height: 50,
                                                                  child: ClipOval(
                                                                    child: (_isConnectedBool == true)
                                                                      ? CachedNetworkImage(
                                                                        imageUrl: doc['imagenURL'],
                                                                        placeholder: (context, url) => Column(
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                          children: [
                                                                            Container(
                                                                              width: 15,
                                                                              height: 15,
                                                                              child: new CircularProgressIndicator(strokeWidth: 2)
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        errorWidget: (context, url, error) => new Icon(
                                                                          Icons.error,
                                                                          color: Colors.red[800]
                                                                        ),
                                                                        fit: BoxFit.cover,
                                                                        width: 50.0,
                                                                        height: 50.0,
                                                                      )
                                                                      : Image.asset('assets/images/loading2.gif',
                                                                        fit: BoxFit.cover,
                                                                        width: 50.0,
                                                                        height: 50.0,
                                                                      )
                                                                  ),
                                                                ),
                      
                                                                SizedBox(height: 10),
                      
                                                                Text(
                                                                  doc['nombre'] + '\n' +  doc['apellido'],
                                                                  textScaleFactor: 0.85,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  textAlign: TextAlign.center,
                                                                  style: GoogleFonts.montserrat(
                                                                    fontSize: 14,
                                                                    color: (_isOscuro) ? Colors.white : Color.fromRGBO(45, 45, 45, 1),
                                                                    fontWeight: (_isSelected && nombre == doc['nombre']) ? FontWeight.bold : FontWeight.normal,
                                                                  )
                                                                ),
                      
                                                              ]
                                                            ),
                                                          ),
                                                        )
                                                        : Container();
                      
                                                      }).toList(),
                                                    )
                                                ),
                      
                                                Expanded(
                                                  child: StreamBuilder<QuerySnapshot>(
                                                    stream: db.collection('chats').doc('tipo').collection('entrenadores').doc(userdoc).collection('chateo').orderBy('timestamp', descending: true).snapshots(),
                                                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      
                                                      if (!snapshot.hasData) {
                                                        return Container(color: (_isOscuro) ? Color.fromRGBO(31, 31, 31, 1) : Colors.white, child: Center(child: Container(width: 100, height: 100, child: CircularProgressIndicator(color: (_isOscuro) ? Colors.white : Color.fromRGBO(1, 29, 69, 1)))));
                                                      } else {
                                                        if (!snapshot.data!.docs.isEmpty) {
                                                          return Container(
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  width: width,
                                                                  height: height - 243,
                                                                  color: (_isOscuro)
                                                                    ? Color.fromRGBO(31, 31, 31, 1)
                                                                    : Colors.white,
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: ListView(
                                                                      children: snapshot.data!.docs.map((doc) => Padding(
                                                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                                                        child: GestureDetector(
                                                                          onTap: () async {
                                                                            try {
                                                                              final result = await InternetAddress.lookup('example.com');
                                                                              if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                                                                                _controllerMessage.clear();
                      
                                                                            if (doc.id != uid) {
                                                                              _isSelected = true;
                                                                              uid = doc.id;
                                                                              nombre = doc['nombre'];
                                                                              apellido = doc['apellido'];
                                                                              imagenURL = doc['imagen'];
                      
                                                                              FirebaseFirestore.instance.collection('chats').doc('tipo').collection('entrenadores').doc(userdoc).collection('chateo').doc(uid).update({
                                                                                "visto": true,
                                                                              });
                                                                            } else {
                                                                              if (_isSelected == true) {
                                                                                _isSelected = false;
                                                                                uid = '';
                                                                              } else {
                                                                                _isSelected = true;
                                                                                uid = doc.id;
                                                                                nombre = doc['nombre'];
                                                                                apellido = doc['apellido'];
                                                                                imagenURL = doc['imagen'];
                      
                                                                                FirebaseFirestore.instance.collection('chats').doc('tipo').collection('entrenadores').doc(userdoc).collection('chateo').doc(uid).update({
                                                                                                "visto": true,
                                                                                              });
                                                                              }
                                                                            }
                                                                              }  
                                                                            } catch (_) {
                                                                              _errorInternet();
                                                                            }
                      
                                                                            setState(() {});
                                                                          },
                                                                          child: new Container(
                                                                              width: width - 50,
                                                                              height: 80,
                                                                              decoration: BoxDecoration(
                                                                                color: (_isOscuro)
                                                                                  ? Color.fromRGBO(41, 41, 41, 1)
                                                                                  : Color.fromARGB(255, 212, 212, 212),
                                                                                borderRadius: BorderRadius.all(Radius.circular(10))
                                                                              ),
                                                                              child: Padding(
                                                                                padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                                                                                child: Row(
                                                                                  children: [
                                                                        
                                                                                    ClipOval(
                                                                                      child: CachedNetworkImage(
                                                                                        imageUrl: doc['imagen'],
                                                                                        placeholder: (context, url) => Column(
                                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                                          children: [
                                                                                            Container(
                                                                                              width: 30,
                                                                                              height: 30,
                                                                                              child: new CircularProgressIndicator(strokeWidth: 1)
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        errorWidget: (context, url, error) => Container(
                                                                                          color: Colors.red[800],
                                                                                          child: new Icon(
                                                                                            Icons.error_outline_rounded, color: Colors.white, size: 50,
                                                                                          ),
                                                                                        ),
                                                                                        fit: BoxFit.cover,
                                                                                        width: 60.0,
                                                                                        height: 60.0,
                                                                                      )
                                                                                    ),
                                                                        
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                                                      child: Column(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Container(
                                                                                            width: width - 200,
                                                                                            child: Text(
                                                                                              doc['nombre'] + ' ' + doc['apellido'],
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              maxLines: 1,
                                                                                              softWrap: false,
                                                                                              textAlign: TextAlign.justify,
                                                                                              style: GoogleFonts.montserrat(
                                                                                                fontSize: 22,
                                                                                                color: (_isOscuro)
                                                                                                  ? Colors.white
                                                                                                  : Color.fromRGBO(31, 31, 31, 1),
                                                                                                  fontWeight: (doc['visto'] == false && doc['uid_remitente'] != userdoc) ? FontWeight.bold : FontWeight.w300
                                                                                              )
                                                                                            ),
                                                                                          ),
                                                                        
                                                                                          SizedBox(height: 5),
                                                                        
                                                                                          Container(
                                                                                            width: width - 200,
                                                                                            child: (doc['uid_remitente'] != userdoc) 
                                                                                            ? Text(
                                                                                              (DateFormat("yMd").format(doc['timestamp'].toDate()).toString() == DateFormat("yMd").format(DateTime.now()).toString()) ? doc['texto'] + " · " + DateFormat().add_jm().format(doc['timestamp'].toDate()) : doc['texto'] + " · " + DateFormat().add_yMMMd().format(doc['timestamp'].toDate()),
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              maxLines: 1,
                                                                                              softWrap: false,
                                                                                              textAlign: TextAlign.start,
                                                                                              style: GoogleFonts.montserrat(
                                                                                                fontSize: 14,
                                                                                                color: (_isOscuro)
                                                                                                  ? Colors.white
                                                                                                  : Color.fromRGBO(31, 31, 31, 1),
                                                                                                  fontWeight: (doc['visto'] == false && doc['uid_remitente'] != userdoc) ? FontWeight.bold : FontWeight.w300
                                                                                              )
                                                                                            )
                                                                                            : Text(
                                                                                              (DateFormat("yMd").format(doc['timestamp'].toDate()).toString() == DateFormat("yMd").format(DateTime.now()).toString()) ? 'Tu: ' + doc['texto'] + " · " + DateFormat().add_jm().format(doc['timestamp'].toDate()) : doc['texto'] + " · " + DateFormat().add_yMMMd().format(doc['timestamp'].toDate()),
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              maxLines: 1,
                                                                                              softWrap: false,
                                                                                              textAlign: TextAlign.start,
                                                                                              style: GoogleFonts.montserrat(
                                                                                                fontSize: 14,
                                                                                                color: (_isOscuro)
                                                                                                  ? Colors.white
                                                                                                  : Color.fromRGBO(31, 31, 31, 1),
                                                                                                  fontWeight: (doc['visto'] == false && doc['uid_remitente'] != userdoc) ? FontWeight.bold : FontWeight.w300
                                                                                              )
                                                                                            ),
                                                                                          ),
                                                                        
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
                                                                                              if (doc['visto'] == false && doc['uid_remitente'] != userdoc) Container(
                                                                                                width: 15,
                                                                                                height: 15,
                                                                                                decoration: BoxDecoration(
                                                                                                  color: Colors.blue,
                                                                                                  shape: BoxShape.circle
                                                                                                ),
                                                                                              )
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                        ),
                                                                      ),
                                                                      ).toList()),
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
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                      
                                                                Expanded(
                                                                  child: Container(
                                                                    alignment: AlignmentDirectional.center,
                                                                    child: SingleChildScrollView(
                                                                      child: Container(
                                                                        width: width,
                                                                        child: Column(
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                          children: [
                                                                            Icon(Icons.message_rounded, color: Color.fromRGBO(44, 181, 110, 1), size: 95),
                                                                            SizedBox(height: 15),
                                                                            Text('No tienes ningun\nchat reciente...',
                                                                              textAlign: TextAlign.center,
                                                                              style: GoogleFonts.montserrat(
                                                                                fontSize: 20,
                                                                                color: (_isOscuro)
                                                                                  ? Colors.white
                                                                                  : Color.fromRGBO(31, 31, 31, 1),
                                                                                  fontWeight: FontWeight.normal
                                                                              )
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
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
                                                    Icon(Icons.person_off_outlined, color: Color.fromRGBO(44, 181, 110, 1), size: 110),
                                                    SizedBox(height: 15),
                                                    Text('No existen clientes',
                                                        style: GoogleFonts.montserrat(
                                                            fontSize: 20,
                                                            color: (_isOscuro)
                                                                ? Colors.white
                                                                : Color.fromRGBO(
                                                                    31, 31, 31, 1),
                                                            fontWeight:
                                                                FontWeight.normal)),
                                                    SizedBox(height: 5),
                                                    Text('registrados actualmente',
                                                        style: GoogleFonts.montserrat(
                                                            fontSize: 20,
                                                            color: (_isOscuro)
                                                                ? Colors.white
                                                                : Color.fromRGBO(
                                                                    31, 31, 31, 1),
                                                            fontWeight:
                                                                FontWeight.normal)),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      } else {
                                        return Container(
                                          color: (_isOscuro)
                                              ? Color.fromRGBO(31, 31, 31, 1)
                                              : Colors.white,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(Icons.warning_rounded,
                                                    color: Colors.red[900], size: 110),
                                                SizedBox(height: 15),
                                                Text('No se ha podido establecer',
                                                    style: GoogleFonts.montserrat(
                                                        fontSize: 20,
                                                        color: (_isOscuro)
                                                            ? Colors.white
                                                            : Color.fromRGBO(
                                                                31, 31, 31, 1),
                                                        fontWeight: FontWeight.normal)),
                                                SizedBox(height: 5),
                                                Text('conexión con el servidor',
                                                    style: GoogleFonts.montserrat(
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
                                    }),
                              ),
                            ],
                          ),
                        ),
                      )
                      : Container(
                        width: width,
                        height: height,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: db.collection('chats').doc('tipo').collection('entrenadores').doc(userdoc).collection('chateo').doc(uid).collection('mensajes').orderBy('timestamp', descending: true).snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            
                            if (!snapshot.hasData) {
                              return Container(color: (_isOscuro) ? Color.fromRGBO(31, 31, 31, 1) : Colors.white, child: Center(child: Container(width: 100, height: 100, child: CircularProgressIndicator(color: (_isOscuro) ? Colors.white : Color.fromRGBO(1, 29, 69, 1)))));
                            } else {
                              if (!snapshot.data!.docs.isEmpty) {
                                return Column(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                      onTap: (){
                                        _textSelected = '';
                                        _verHora = false;
                                        setState(() {});
                                      },
                                        child: Container(
                                          padding: EdgeInsets.only(bottom: 10),
                                          alignment: FractionalOffset.bottomCenter,
                                          color: (_isOscuro)
                                            ? Color.fromRGBO(31, 31, 31, 1)
                                            : Colors.white,
                                          child: ListView(
                                          controller: _scrollController,
                                          reverse: true,
                                          children: snapshot.data!.docs.map((doc) => new ListTile(
                                            title: GestureDetector(
                                            onTap: (){
                                            
                                              if (_textSelected != doc['texto']) {
                                                _verHora = true;
                                                _textSelected = doc['texto'];
                                              } else {
                                                if (_verHora == true) {
                                                _verHora = false;
                                                _textSelected = '';
                                              } else {
                                                _verHora = true;
                                                _textSelected = doc['texto'];
                                              }
                                              }
                                                                                  
                                              setState(() {});
                                            },
                                              child: Container(
                                                                          alignment: (doc['uid_remitente'] == userdoc)
                                                                              ? AlignmentDirectional.centerEnd
                                                                              : AlignmentDirectional.centerStart,
                                                                          child: Padding(
                                                                              padding: (doc['uid_remitente'] == userdoc) ? EdgeInsets.only(top: 8, left: 70, bottom: (_textSelected == doc['texto']) ? 8 : 0, right: 5) : EdgeInsets.only(top: 8, left: 5, bottom: (_textSelected == doc['texto']) ? 8 : 0, right: 70),
                                                                              child: Container(
                                                                                padding: EdgeInsets.only(top: 8, left: 10, bottom: 8, right: 10),
                                                                                decoration: BoxDecoration(
                                                                                  color: (doc['uid_remitente'] == userdoc) ? Color.fromRGBO(44, 181, 110, 1) : Color.fromRGBO(110, 110, 110, 1),
                                                                                  borderRadius: (doc['uid_remitente'] == userdoc) ? BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(0.0), topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)) : BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0), topLeft: Radius.circular(0), bottomLeft: Radius.circular(10.0)),
                                                                                ),
                                                                                child: Text(doc["texto"], textAlign: TextAlign.justify, style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal)),
                                                                              )),
                                                                        ),
                                                                ),
                                                      subtitle: (_textSelected == doc['texto']) ? Container(
                                                      alignment: (doc['uid_remitente'] == userdoc)
                                                        ? AlignmentDirectional.centerEnd
                                                        : AlignmentDirectional.centerStart,
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(top: 0, left: 8, bottom: 0, right: 8),
                                                        child: Visibility(
                                                          visible: true,
                                                          maintainState: false,
                                                          maintainAnimation: false,
                                                          maintainSize: false,
                                                          maintainSemantics: false,
                                                          maintainInteractivity: false,
                                                          child: Text(
                                                            (doc['uid_remitente'] == userdoc)
                                                            ? toBeginningOfSentenceCase(timeago.format(doc['timestamp'].toDate(), locale: 'es'))! + ' - ' + toBeginningOfSentenceCase(formato_hora.format(doc['timestamp'].toDate()).toString())!
                                                            : formato_hora.format(doc['timestamp'].toDate()).toString() + ' - ' + toBeginningOfSentenceCase(timeago.format(doc['timestamp'].toDate(), locale: 'es'))!
                                                            , style: GoogleFonts.ubuntu(
                                                              fontSize: 14,
                                                              color: (_isOscuro)
                                                                ? Colors.white
                                                                : Color.fromRGBO(31, 31, 31, 0.7),
                                                              fontWeight: FontWeight.normal)
                                                          ),
                                                        )
                                                      ),
                                                                                              ) : null
                                                                                            ))
                                                                                            .toList()),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  decoration: BoxDecoration(
                                                                                    color: (_isOscuro) ? Color.fromRGBO(31, 31, 31, 1) : Colors.white,
                                                                                  ),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      Expanded(
                                                                                        child: Container(
                                                                                          margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                                                                          color: Colors.transparent,
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                                                              child: TextField(
                                                                                              controller: _controllerMessage,
                                                                                              style: GoogleFonts.ubuntu(
                                                                                                fontWeight: FontWeight.w300,
                                                                                                fontSize: 16,
                                                                                                color: Color.fromRGBO(0, 0, 0, 0.9),
                                                                                              ),
                                                                                              decoration: InputDecoration(
                                                                                                hintText: 'Escribe un mensaje...',
                                                                                                contentPadding: EdgeInsets.all(10.0),
                                                                                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                                filled: true,
                                                                                                fillColor: Colors.white,
                                                                                                border: OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.all(Radius.circular(15))
                                                                                                ),
                                                                                                focusedBorder:
                                                                                                  OutlineInputBorder(
                                                                                                    borderSide: const BorderSide(
                                                                                                      color: Color.fromRGBO(45, 44, 45, 1),
                                                                                                      width: 1
                                                                                                    ),
                                                                                                    borderRadius: BorderRadius.circular(15),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            )
                                                                                        )
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(right: 15),
                                                                                        child: ClipOval(
                                                                                          child: Material(
                                                                                            color: Colors.white, // Button color
                                                                                            child: InkWell(
                                                                                              splashColor: Colors.black54, // Splash color
                                                                                              onTap: () async {
                                                                                                FocusScope.of(context).unfocus();
                                                                                                try {
                                                                                                  final result = await InternetAddress.lookup('example.com');
                                                                                                    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                                                                                                      if (_controllerMessage.text != '') {
                                                                                                      FirebaseFirestore.instance.collection('chats').doc('tipo').collection('entrenadores').doc(userdoc).collection('chateo').doc(uid).set({
                                                                                                       "texto": _controllerMessage.text.trim(),
                                                                                                       "nombre": nombre,
                                                                                                       "apellido": apellido,
                                                                                                       "imagen": imagenURL,
                                                                                                       "timestamp": Timestamp.now(),
                                                                                                       "visto": true,
                                                                                                       "uid_remitente": userdoc,
                                                                                                      });

                                                                                                      FirebaseFirestore.instance.collection('chats').doc('tipo').collection('clientes').doc(uid).collection('chateo').doc(userdoc).set({
                                                                                                       "texto": _controllerMessage.text.trim(),
                                                                                                       "nombre": nombre_user,
                                                                                                       "apellido": apellido_user,
                                                                                                       "imagen": imagenURL_user,
                                                                                                       "timestamp": Timestamp.now(),
                                                                                                       "visto": false,
                                                                                                       "uid_remitente": userdoc,
                                                                                                      });

                                                                                                      FirebaseFirestore.instance.collection('chats').doc('tipo').collection('entrenadores').doc(userdoc).collection('chateo').doc(uid).collection('mensajes').add({
                                                                                                       "texto": _controllerMessage.text.trim(),
                                                                                                       "timestamp": Timestamp.now(),
                                                                                                       "uid_remitente": userdoc,
                                                                                                      });

                                                                                                      FirebaseFirestore.instance.collection('chats').doc('tipo').collection('clientes').doc(uid).collection('chateo').doc(userdoc).collection('mensajes').add({
                                                                                                       "texto": _controllerMessage.text.trim(),
                                                                                                       "timestamp": Timestamp.now(),
                                                                                                       "uid_remitente": userdoc,
                                                                                                      });

                                                                                                      FirebaseFirestore.instance.collection('chats').doc('tipo').collection('clientes').doc(uid).set({
                                                                                                       "visto": false,
                                                                                                      });
                                                                                                    _controllerMessage.clear();
                                                                                                  }
                                                                                                    }  
                                                                                                } catch (_) {
                                                                                                  _errorInternet();
                                                                                                }
                                                                                              },
                                                                                              child: SizedBox(width: 40, height: 40, child: Icon(Icons.send_rounded, color: Color.fromRGBO(44, 181, 110, 1))),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            );
                                                                          } else {
                                                                            
                                                                            return Container(
                                                                              color: (_isOscuro)
                                                                              ? Color.fromRGBO(31, 31, 31, 1)
                                                                              : Colors.white,
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  
                                                                                  Expanded(
                                                                                    child: Container(
                                                                                      alignment: AlignmentDirectional.center,
                                                                                      child: SingleChildScrollView(
                                                                                        child: Container(
                                                                                          width: width,
                                                                                          child: Column(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              Icon(Icons.mood_rounded, color: Color.fromRGBO(44, 181, 110, 1), size: 95),
                                                                                              SizedBox(height: 15),
                                                                                              Text('Empieza el chat\ncon un saludo!',
                                                                                                textAlign: TextAlign.center,
                                                                                                style: GoogleFonts.montserrat(
                                                                                                  fontSize: 20,
                                                                                                  color: (_isOscuro)
                                                                                                  ? Colors.white
                                                                                                  : Color.fromRGBO(
                                                                                                    31, 31, 31, 1),
                                                                                                    fontWeight: FontWeight.normal
                                                                                                )
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),

                                                                                  Container(
                                                                                  decoration: BoxDecoration(
                                                                          color: (_isOscuro)
                                                                              ? Color.fromRGBO(31, 31, 31, 1)
                                                                              : Colors.white,
                                                                                  ),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      Expanded(
                                                                                        child: Container(
                                                                                          margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                                                                          color: Colors.transparent,
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                                                              child: TextField(
                                                                                              controller: _controllerMessage,
                                                                                              style: GoogleFonts.ubuntu(
                                                                                                fontWeight: FontWeight.w300,
                                                                                                fontSize: 16,
                                                                                                color: Color.fromRGBO(0, 0, 0, 0.9),
                                                                                              ),
                                                                                              decoration: InputDecoration(
                                                                                                hintText: 'Escribe un mensaje...',
                                                                                                contentPadding: EdgeInsets.all(10.0),
                                                                                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                                                                                filled: true,
                                                                                                fillColor: Colors.white,
                                                                                                border: OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.all(Radius.circular(15))
                                                                                                ),
                                                                                                focusedBorder:
                                                                                                  OutlineInputBorder(
                                                                                                    borderSide: const BorderSide(
                                                                                                      color: Color.fromRGBO(45, 44, 45, 1),
                                                                                                      width: 1
                                                                                                    ),
                                                                                                    borderRadius: BorderRadius.circular(15),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            )
                                                                                        )
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(right: 15),
                                                                                        child: ClipOval(
                                                                                          child: Material(
                                                                                            color: Colors.white, // Button color
                                                                                            child: InkWell(
                                                                                              splashColor: Colors.black54, // Splash color
                                                                                              onTap: () async {
                                                                                                FocusScope.of(context).unfocus();
                                                                                                try {
                                                                                                  final result = await InternetAddress.lookup('example.com');
                                                                                                    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                                                                                                      if (_controllerMessage.text != '') {
                                                                                                     FirebaseFirestore.instance.collection('chats').doc('tipo').collection('entrenadores').doc(userdoc).collection('chateo').doc(uid).set({
                                                                                                       "texto": _controllerMessage.text.trim(),
                                                                                                       "nombre": nombre,
                                                                                                       "apellido": apellido,
                                                                                                       "imagen": imagenURL,
                                                                                                       "timestamp": Timestamp.now(),
                                                                                                       "visto": true,
                                                                                                       "uid_remitente": userdoc,
                                                                                                      });

                                                                                                      FirebaseFirestore.instance.collection('chats').doc('tipo').collection('clientes').doc(uid).collection('chateo').doc(userdoc).set({
                                                                                                       "texto": _controllerMessage.text.trim(),
                                                                                                       "nombre": nombre_user,
                                                                                                       "apellido": apellido_user,
                                                                                                       "imagen": imagenURL_user,
                                                                                                       "timestamp": Timestamp.now(),
                                                                                                       "visto": false,
                                                                                                       "uid_remitente": userdoc,
                                                                                                      });

                                                                                                      FirebaseFirestore.instance.collection('chats').doc('tipo').collection('entrenadores').doc(userdoc).collection('chateo').doc(uid).collection('mensajes').add({
                                                                                                       "texto": _controllerMessage.text.trim(),
                                                                                                       "timestamp": Timestamp.now(),
                                                                                                       "uid_remitente": userdoc,
                                                                                                      });

                                                                                                      FirebaseFirestore.instance.collection('chats').doc('tipo').collection('clientes').doc(uid).collection('chateo').doc(userdoc).collection('mensajes').add({
                                                                                                       "texto": _controllerMessage.text.trim(),
                                                                                                       "timestamp": Timestamp.now(),
                                                                                                       "uid_remitente": userdoc,
                                                                                                      });
                                                                                                      
                                                                                                      FirebaseFirestore.instance.collection('chats').doc('tipo').collection('clientes').doc(uid).set({
                                                                                                       "visto": false,
                                                                                                      });
                                                                                                      
                                                                                                    _controllerMessage.clear();
                                                                                                  }
                                                                                                    }  
                                                                                                } catch (_) {
                                                                                                  _errorInternet();
                                                                                                }
                                                                                              },
                                                                                              child: SizedBox(width: 40, height: 40, child: Icon(Icons.send_rounded, color: Color.fromRGBO(44, 181, 110, 1))),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                  
                                                                                  
                                                                                ],
                                                                              ),
                                                                            );
                                                                          }
                                                                        }
                                                                                            
                                                                      },
                                                                    ),
                      )
                    );
                } else {
                  return Container(color: (_isOscuro) ? Color.fromRGBO(31, 31, 31, 1) : Colors.white, child: Center(child: Container(width: 100, height: 100, child: CircularProgressIndicator(color: (_isOscuro) ? Colors.white : Color.fromRGBO(1, 29, 69, 1)))));
                }
              }),
          if (_isPreview) Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 300,
                  maxWidth: 300,
                ),
                child: CachedNetworkImage(
                  imageUrl: imagenURL!,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => Center(child: Container(width: 100, height: 100, child: CircularProgressIndicator(color: Colors.white))),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _errorInternet() {
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