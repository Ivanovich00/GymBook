import 'package:GymBook/screens/cliente_screens/home_cliente.dart';
import 'package:GymBook/screens/screens.dart';
import 'package:GymBook/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BarraNavegacion extends StatefulWidget {
  @override
  State<BarraNavegacion> createState() => _BarraNavegacionState();
}

class _BarraNavegacionState extends State<BarraNavegacion> {
  int _current_index = 1;
  @override
  Widget build(BuildContext context) {

    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Colors.black,
      backgroundColor: Colors.black54,
      unselectedItemColor: Colors.black,
      currentIndex: _current_index,
      onTap: (int index) {// evento de clic
        setState (() {
          this._current_index = index; // Modifica el estado, actualizará automáticamente el widget
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: InkWell(
            onTap: (){},
            child: Icon(
              Icons.keyboard_return_outlined,
              size:25.0, color: Colors.white,
            ),
          ),
          label: 'Regresar'
        ),

        BottomNavigationBarItem(
          icon: InkWell(
          onTap: (){
            
          },
          child: Icon(
            Icons.refresh_outlined,size:25.0,
            color: Colors.white,
          )
          ),
          label: 'Refrescar'
        ),
      ],
    );
  }
}

class BarraNavegacionDos extends StatefulWidget {

  const BarraNavegacionDos({Key? key}) : super(key: key);

  @override
  State<BarraNavegacionDos> createState() => _BarraNavegacionDosState();
}

class _BarraNavegacionDosState extends State<BarraNavegacionDos> {
  int _current_indexDos = 1;

  final _pages = [AdministradorScreen()];

  @override

  Widget build(BuildContext context) {

    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Colors.black,
      backgroundColor: Colors.black54,
      unselectedItemColor: Colors.black,
      currentIndex: _current_indexDos,
      onTap: (int index) {// evento de clic
        setState (() {
          this._current_indexDos = index; // Modifica el estado, actualizará automáticamente el widget
        });
      },

      items: [
        BottomNavigationBarItem(
          icon: InkWell(
            onTap: (){
              Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, child: EntrenadorScreen(), duration: Duration(milliseconds: 500)));
            },
          child: Icon(
            Icons.keyboard_return_outlined,size: 25.0,
            color: Colors.white,
          )
          ),
          label: 'Regresar'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.refresh_outlined, size: 25.0, color: Colors.white),
          label: ''
        )
      ],
    );
  }
}