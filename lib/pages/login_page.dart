import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godare/common/my_routers.dart';
import 'package:godare/core/constants.dart';
import 'package:godare/models/auth.dart';
import 'package:godare/providers/user_provider.dart';
import 'package:godare/values/colors_app.dart';
import 'package:godare/widgets/forms/elements/my_text_form_field.dart';
import 'package:godare/widgets/forms/elements/my_text_link.dart';

import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrNickController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailOrNickController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsApp.baseWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 80),
                _buildLogo(),
                const SizedBox(height: 30),
                const Text(
                  'LOGIN',
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
      ),
    );
  }

  /// Logo local como placeholder — carga rápida sin depender de red
  Widget _buildLogo() {
    return SizedBox(
      width: 300,
      height: 200,
      child: Image.asset(Constants.logoLocal),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          MyTextFormField(
            labelText: 'Usuario o Email',
            hintText: 'Introduce tu nick o email',
            controller: _emailOrNickController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El usuario o email es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          MyTextFormField(
            labelText: 'Contraseña',
            hintText: 'Introduce tu contraseña',
            obscureText: true,
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La contraseña es obligatoria';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          MyTextLink(
            firstText: '¿No tienes cuenta? ',
            linkText: 'Regístrate',
            navigateToRoute: ROUTE_REGISTER,
          ),
          const SizedBox(height: 10),
          MyTextLink(
            firstText: '¿Olvidaste tu contraseña? ',
            linkText: 'Recupérala',
            navigateToRoute: ROUTE_FORGOT_PASSWORD,
          ),
          const SizedBox(height: 30),

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

          // Botón de login
          SizedBox(
            width: 300,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
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
                  : const Text('Iniciar sesión'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final request = LoginRequest(
      emailOrNick: _emailOrNickController.text.trim(),
      password: _passwordController.text.trim(),
    );

    final provider = context.read<UserProvider>();

    try {
      final success = await provider.login(request);

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          ROUTE_HOME,
              (route) => false,
        );
      } else {
        setState(() {
          _errorMessage = provider.error ?? 'Error al iniciar sesión';
          _isLoading = false;
        });
      }
    } on EmailNotVerifiedException catch (e) {
      if (!mounted) return;
      if (!mounted) return;
      setState(() => _isLoading = false);

      // Mostrar dialog informando que se ha reenviado el email
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(
            'Cuenta sin verificar',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Tu cuenta aún no ha sido verificada.\n\n'
                'Hemos enviado un nuevo enlace de verificación a '
                '${e.emailOfuscado}\n\n'
                'Revisa tu bandeja de entrada y sigue el enlace para activar tu cuenta.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    }
  }
}