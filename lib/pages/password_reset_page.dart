import 'package:flutter/material.dart';
import 'package:godare/common/my_routers.dart';
import 'package:godare/core/constants.dart';
import 'package:godare/models/auth.dart';
import 'package:godare/services/auth_service.dart';
import 'package:godare/values/colors_app.dart';
import 'package:godare/widgets/forms/elements/my_text_form_field.dart';

/// Pantalla de reset de contraseña.
/// Recibe [fromDrawer] como argumento de ruta para saber dónde navegar al terminar.
class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.resetPassword(
        ResetPasswordRequest(
          token: _tokenController.text.trim(),
          newPassword: _passwordController.text.trim(),
        ),
      );

      if (!mounted) return;

      // Saber si viene del drawer o del login
      final fromDrawer =
          ModalRoute.of(context)?.settings.arguments as bool? ?? false;

      _showDialog(
        title: '¡Contraseña actualizada!',
        content: 'Tu contraseña ha sido cambiada correctamente.',
        onAccept: () {
          if (fromDrawer) {
            // Viene del drawer — cerrar las pantallas de contraseña y volver a home
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            // Viene del login — ir al login limpiando la pila
            Navigator.of(context).pushNamedAndRemoveUntil(
              ROUTE_LOGIN,
                  (route) => false,
            );
          }
        },
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
      builder: (_) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
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
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_reset,
                      color: ColorsApp.baseBlackLogo, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'CAMBIAR CONTRASEÑA',
                    style: TextStyle(
                      color: ColorsApp.baseBlackLogo,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    MyTextFormField(
                      labelText: 'Código de verificación',
                      hintText: 'Código recibido por email',
                      controller: _tokenController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El código es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    MyTextFormField(
                      labelText: 'Nueva contraseña',
                      hintText: 'Mínimo 6 caracteres',
                      obscureText: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La contraseña es obligatoria';
                        }
                        if (value.trim().length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    MyTextFormField(
                      labelText: 'Repite la contraseña',
                      hintText: 'Confirma tu nueva contraseña',
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

                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
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
                            : const Text('Cambiar contraseña'),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}