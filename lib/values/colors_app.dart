import 'package:flutter/material.dart';

class ColorsApp {
  static const Color baseBlackLogo = Color(0xFF040404);
  static const Color baseBlackLogoLight = Color(0x77040404);
  static const Color basePink = Color(0xFFE54368);
  static const Color basePinkLight = Color(0xAAE54368);
  static const Color baseWhite = Colors.white;
}

Color get basePink => hexToColor("#e54368");

Color get baseBlackLogo => hexToColor("#040404");

Color get baseWhite => Colors.white;

Color get color1 => hexToColor("#eedcb7");

Color get color2 => hexToColor("#7b546c");

Color get color3 => hexToColor("#642b38");

//Convertir colores hexadecimales en Colors
Color hexToColor(String code) =>
    Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);

/*Ejemplos para establecer propiedades*/
//Establecer colores, tonalidad o opacidad
/*
Color? get colorPink2 => Colors.pink[600];
Color get textColor => Colors.blueGrey;
Color get textColorOpa => Colors.blueGrey.withOpacity(0.2);*/

//Definimos color con un hex
//Color get textColor2 => hexToColor("#1cba9a");
