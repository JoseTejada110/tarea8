import 'package:flutter/material.dart';

//SNACKBAR PERSONALIZADO (MUESTRA UN MENSAJE EN LA PARTE INFERIOR DE LA PANTALLA)
customSnackBar(BuildContext context, String message, {Duration duration = const Duration(milliseconds: 1000)}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      //backgroundColor: const Color(0XFF0E4799),
      duration: duration,
      content: Text(message, style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600
      )),
    ),
  );
}
