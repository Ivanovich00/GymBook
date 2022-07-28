import 'package:flutter/material.dart';

class EdicionEjercicioae extends StatelessWidget {
  const EdicionEjercicioae({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Container(
        decoration: _buidBoxDecoration(),
        width: double.infinity,
        height: 350,
        child: ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(45), topRight: Radius.circular(45)),
          child: Image(
            //image: NetworkImage('https://via.placeholder.com/400x300/green'),
            image: AssetImage('assets/images/add_picture.png'),
            fit: BoxFit.contain,
          ),
        )
      ),
    );
  }

  BoxDecoration _buidBoxDecoration() => BoxDecoration(
  color: Colors.grey[300],
  borderRadius: BorderRadius.only(topLeft: Radius.circular(45), topRight: Radius.circular(45)),
  boxShadow: [BoxShadow( color: Colors.black, blurRadius:5)]
  );
}