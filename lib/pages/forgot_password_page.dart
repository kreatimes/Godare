import 'package:flutter/material.dart';
import 'package:godare/common/my_routers.dart';
import 'package:godare/core/constants.dart';
import 'package:godare/models/auth.dart';
import 'package:godare/services/auth_service.dart';
import 'package:godare/values/colors_app.dart';
import 'package:godare/widgets/forms/elements/my_text_form_field.dart';

/// Pantalla de recuperación de contraseña.
/// [fromDrawer] indica si viene del drawer (con sesión) o del login (sin sesión).
class ForgotPasswordPage extends StatefulWidget {
  final bool fromDrawer;

  const ForgotPasswordPage({super.key, this.fromDrawer = false});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.forgotPassword(
        ForgotPasswordRequest(email: _emailController.text.trim()),
      );

      if (!mounted) return;

      _showDialog(
        title: '¡Código enviado!',
        content: 'Revisa tu email para obtener el código de verificación '
            'e introdúcelo en la siguiente pantalla.',
        onAccept: () => Navigator.of(context).pushReplacementNamed(
          ROUTE_RESET_PASSWORD,
          arguments: widget.fromDrawer,
        ),
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
                  Icon(Icons.lock_outline,
                      color: ColorsApp.baseBlackLogo, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'RECUPERAR CONTRASEÑA',
                    style: TextStyle(
                      color: ColorsApp.baseBlackLogo,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Introduce tu email y te enviaremos un código para restablecer tu contraseña.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    MyTextFormField(
                      labelText: 'Email',
                      hintText: 'Tu correo electrónico',
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El email es obligatorio';
                        }
                        final valid =
                        RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(value);
                        if (!valid) return 'El email no es válido';
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
                            : const Text('Enviar código'),
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