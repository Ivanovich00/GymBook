import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputDecorations {

  static InputDecoration authInputDecoration({
    required String hintText,
    required String labelText,
    IconData? prefixIcon
  }){

    return InputDecoration(
      enabledBorder:  UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
          
        ),
      ),
      focusedBorder:  UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
         // width: 2,
        )
      ),
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                            fontStyle:
                                                                FontStyle.normal,
                                                            fontSize: 17.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Colors.black)),
      labelText: labelText,
      labelStyle: GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                            fontStyle:
                                                                FontStyle.normal,
                                                            fontSize: 17.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black)),
      prefixIcon: prefixIcon != null 
      ? Icon(Icons.alternate_email_sharp, color: Colors.black)
      : null
    );
  }
}