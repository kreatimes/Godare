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
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _showResendVerificationModal,
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 14),
                children: [
                  TextSpan(
                    text: '¿No recibiste el email? ',
                    style: TextStyle(color: Colors.black54),
                  ),
                  TextSpan(
                    text: 'Reenviar verificación',
                    style: TextStyle(
                      color: ColorsApp.basePink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
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

  void _showResendVerificationModal() {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ResendVerificationModal(
        emailController: emailController,
        formKey: formKey,
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

// ---------------------------------------------------------------------------
// Modal para reenviar el email de verificación
// ---------------------------------------------------------------------------
class _ResendVerificationModal extends StatefulWidget {
  final TextEditingController emailController;
  final GlobalKey<FormState> formKey;

  const _ResendVerificationModal({
    required this.emailController,
    required this.formKey,
  });

  @override
  State<_ResendVerificationModal> createState() =>
      _ResendVerificationModalState();
}

class _ResendVerificationModalState extends State<_ResendVerificationModal> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _send() async {
    if (!widget.formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final emailOfuscado = await AuthService.resendVerification(
        widget.emailController.text,
      );

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Email de verificación enviado a $emailOfuscado. Revisa tu bandeja de entrada.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } on EmailNotFoundForVerificationException {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No existe ninguna cuenta con ese email.';
      });
    } on EmailAlreadyVerifiedException {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Esta cuenta ya está verificada. Puedes iniciar sesión.';
      });
    } on AuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 12,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).viewPadding.bottom +
            24,
      ),
      child: Form(
        key: widget.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Título
            const Text(
              'Reenviar verificación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Introduce tu email y te reenviaremos el enlace de verificación.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Campo email
            TextFormField(
              controller: widget.emailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'tu@email.com',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'El email es obligatorio';
                }
                if (!v.contains('@') || !v.contains('.')) {
                  return 'Introduce un email válido';
                }
                return null;
              },
            ),

            // Error
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                            color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Botón
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsApp.baseBlackLogo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Enviar verificación'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}