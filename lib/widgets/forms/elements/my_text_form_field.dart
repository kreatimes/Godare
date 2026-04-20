import 'package:flutter/material.dart';
import 'package:godare/values/colors_app.dart';

/// Campo de texto reutilizable con estilo unificado de la app.
/// Si obscureText es true, muestra automáticamente el ojito para ver/ocultar.
class MyTextFormField extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const MyTextFormField({
    super.key,
    required this.labelText,
    this.hintText,
    this.validator,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
  });

  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscure,
        keyboardType: widget.keyboardType,
        style: const TextStyle(color: ColorsApp.baseBlackLogo),
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: const TextStyle(color: ColorsApp.basePinkLight),
          hintText: widget.hintText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 25),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
            const BorderSide(color: ColorsApp.basePink, width: 2.0),
          ),
          // Ojito — solo aparece si el campo es de contraseña
          suffixIcon: widget.obscureText
              ? IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(
              _obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
          )
              : null,
        ),
        validator: widget.validator,
      ),
    );
  }
}