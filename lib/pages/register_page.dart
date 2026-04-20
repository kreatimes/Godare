import 'package:flutter/material.dart';
import 'package:godare/common/my_routers.dart';
import 'package:godare/core/constants.dart';
import 'package:godare/models/auth.dart';
import 'package:godare/services/auth_service.dart';
import 'package:godare/values/colors_app.dart';
import 'package:godare/widgets/forms/elements/my_text_form_field.dart';
import 'package:godare/widgets/forms/elements/privacy_policy_checkbox.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nickController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnamesController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _privacyAccepted = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nickController.dispose();
    _nameController.dispose();
    _surnamesController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsApp.baseWhite,
      appBar: AppBar(
        backgroundColor: ColorsApp.baseBlackLogo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              SizedBox(
                width: 300,
                height: 150,
                child: Image.asset(Constants.logoLocal),
              ),
              const SizedBox(height: 20),
              const Text(
                'REGISTRO',
                style: TextStyle(
                  color: ColorsApp.baseBlackLogo,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          MyTextFormField(
            labelText: 'Nick',
            hintText: 'Tu nombre visible en la app',
            controller: _nickController,
            validator: _validateNick,
          ),
          const SizedBox(height: 20),
          MyTextFormField(
            labelText: 'Nombre',
            hintText: 'Tu nombre real',
            controller: _nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          MyTextFormField(
            labelText: 'Apellidos (opcional)',
            hintText: 'Tus apellidos',
            controller: _surnamesController,
          ),
          const SizedBox(height: 20),
          MyTextFormField(
            labelText: 'Email',
            hintText: 'Tu correo electrónico',
            controller: _emailController,
            validator: _validateEmail,
          ),
          const SizedBox(height: 20),
          MyTextFormField(
            labelText: 'Contraseña',
            hintText: 'Mínimo 6 caracteres',
            obscureText: true,
            controller: _passwordController,
            validator: _validatePassword,
          ),
          const SizedBox(height: 20),
          MyTextFormField(
            labelText: 'Repite la contraseña',
            hintText: 'Confirma tu contraseña',
            obscureText: true,
            controller: _repeatPasswordController,
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          PrivacyPolicyCheckbox(
            labelText: 'Acepto la ',
            privacyPolicyUrl: 'https://godare.app/privacyPolicy.html',
            onChanged: (value) =>
                setState(() => _privacyAccepted = value ?? false),
          ),
          const SizedBox(height: 10),

          // Mensaje de error
          if (_errorMessage != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Botón de registro
          SizedBox(
            width: 300,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsApp.baseBlackLogo,
                foregroundColor: ColorsApp.baseWhite,
                elevation: 3,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ColorsApp.baseWhite,
                ),
              )
                  : const Text('Registrarse'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_privacyAccepted) {
      _showDialog(
        title: 'Política de privacidad',
        content: 'Debes aceptar la política de privacidad para registrarte.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.register(RegisterRequest(
        nick: _nickController.text.trim(),
        name: _nameController.text.trim(),
        surnames: _surnamesController.text.trim().isEmpty
            ? null
            : _surnamesController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ));

      if (!mounted) return;

      // Registro correcto — avisar al usuario y llevarle al login
      _showDialog(
        title: '¡Registro completado!',
        content:
        'Te hemos enviado un email de verificación. Activa tu cuenta para poder iniciar sesión.',
        onAccept: () => Navigator.of(context)
            .pushNamedAndRemoveUntil(ROUTE_LOGIN, (route) => false),
      );
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    }
  }

  void _showDialog({
    required String title,
    required String content,
    VoidCallback? onAccept,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title,
            style:
            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onAccept?.call();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  String? _validateNick(String? value) {
    if (value == null || value.trim().isEmpty) return 'El nick es obligatorio';
    if (value.trim().length < 3) return 'Debe tener al menos 3 caracteres';
    if (value.trim().length > 20) return 'No puede superar 20 caracteres';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'El email es obligatorio';
    final valid = RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$').hasMatch(value);
    if (!valid) return 'El email no es válido';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.trim().length < 6) return 'Mínimo 6 caracteres';
    return null;
  }
}