import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TarjetaEjercicioIndae extends StatelessWidget {
  const TarjetaEjercicioIndae({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      
      child: Container(
        margin: EdgeInsets.only(top: 28.0, bottom: 30.0),
        width: double.infinity,
        height: 350,
        decoration: _DecorTarjeta(),
        child: Stack(
          
          alignment: Alignment.bottomLeft,
          children: [
            
            _ImagenFondo(),
            
            
            _DetallesEjercicio(),

            //Positioned(
              //top: 0,
              //right: 0,
              //child: _Descripcion())
              
          ],

        ),
      ),
    );
  }

  BoxDecoration _DecorTarjeta() => BoxDecoration(
    color: Color(0xFF424242),
    //borderRadius: BorderRadius.zero,
    borderRadius: BorderRadius.all(Radius.circular(20)),
    boxShadow: [
      BoxShadow(
        color: Colors.grey,
        blurRadius: 10,
        
      )
    ]
  );
}

class _Descripcion extends StatelessWidget {
  const _Descripcion({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child:FittedBox(
        fit: BoxFit.contain,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal:20, vertical:10),
          
          child: Text('Descripción',style: TextStyle(color: Colors.black,fontSize: 20.0)),
        ),
      ),
      
      width: 250.0,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.grey[400],
      )
    );
  }
}

class _DetallesEjercicio extends StatelessWidget {
  const _DetallesEjercicio({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: double.infinity,
      height: 100,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.grey[600],
      borderRadius: BorderRadius.all(Radius.circular(15)),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NOMBRE DEL EJERCICIO',  style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                            fontStyle:
                                                                FontStyle.normal,
                                                            fontSize: 17.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Colors.white)), 
          maxLines:1,
          overflow: TextOverflow.ellipsis,
          ),
           
          Text('Descripción:', style: GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                            fontStyle:
                                                                FontStyle.normal,
                                                            fontSize: 17.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Colors.white)), 
          maxLines:3,
          overflow: TextOverflow.ellipsis,
          ),
          
        ]
      )
    );
  }

}

class _ImagenFondo extends StatelessWidget {
  const _ImagenFondo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.blueGrey,
        borderRadius: BorderRadius.all(Radius.circular(20)),

        ),
        height: 600,
        child: Image(
          image: AssetImage('assets/images/loading.gif'),
          //placeholder: NetworkImage('https://via.placeholder.com/260x170/f6f6f6'),
          
          fit: BoxFit.cover,
          
        ),
        
      ),
    );
  }
}