import 'package:flutter/material.dart';
import 'package:godare/models/auth.dart';
import 'package:godare/services/auth_service.dart';
import 'package:godare/values/colors_app.dart';
import 'package:godare/widgets/forms/elements/my_text_form_field.dart';

/// Pantalla para cambiar la contraseña con sesión activa.
/// El usuario introduce la contraseña actual, la nueva y la confirmación.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
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
      await AuthService.changePassword(
        ChangePasswordRequest(
          currentPassword: _currentPasswordController.text.trim(),
          newPassword: _newPasswordController.text.trim(),
        ),
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(
            '¡Contraseña actualizada!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: const Text('Tu contraseña ha sido cambiada correctamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // cierra el dialog
                Navigator.of(context).pop(); // vuelve al drawer
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsApp.baseWhite,
      appBar: AppBar(
        backgroundColor: ColorsApp.baseBlackLogo,
        iconTheme: const IconThemeData(color: ColorsApp.basePink),
        title: const Text(
          'Cambiar contraseña',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Icono decorativo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ColorsApp.basePink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: ColorsApp.basePink,
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),

              MyTextFormField(
                labelText: 'Contraseña actual',
                hintText: 'Introduce tu contraseña actual',
                obscureText: true,
                controller: _currentPasswordController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La contraseña actual es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              MyTextFormField(
                labelText: 'Nueva contraseña',
                hintText: 'Mínimo 6 caracteres',
                obscureText: true,
                controller: _newPasswordController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La nueva contraseña es obligatoria';
                  }
                  if (value.trim().length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              MyTextFormField(
                labelText: 'Repite la nueva contraseña',
                hintText: 'Confirma tu nueva contraseña',
                obscureText: true,
                controller: _repeatPasswordController,
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              if (_errorMessage != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsApp.baseBlackLogo,
                    foregroundColor: Colors.white,
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
                      color: Colors.white,
                    ),
                  )
                      : const Text('Cambiar contraseña'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}