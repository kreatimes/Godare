import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godare/common/my_routers.dart';
import 'package:godare/providers/user_provider.dart';
import 'package:godare/services/auth_service.dart';
import 'package:godare/services/user_service.dart';
import 'package:godare/values/colors_app.dart';
import 'package:godare/widgets/basics/modal_html.dart';
import 'package:godare/widgets/basics/range_badge.dart';

/// Drawer lateral con el perfil del usuario, navegación y ajustes de cuenta.
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: ColorsApp.baseBlackLogo),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                profile?.userImageUrl ??
                    'https://res.cloudinary.com/dfeqlfptc/image/upload/v1774389485/default_profile_k6ojop.png',
              ),
            ),
            accountName: Text(
              profile?.nick ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profile?.rangeName ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
               const SizedBox(width: 6),
               RangeBadge(rangeImageUrl: profile?.rangeImageUrl, size: 25),

              ],
            ),
          ),

          _tile(
            icon: Icons.home,
            iconColor: Colors.green,
            title: 'INICIO',
            onTap: () => Navigator.popAndPushNamed(context, ROUTE_HOME),
          ),

          _tile(
            icon: Icons.verified_user,
            iconColor: Colors.blue,
            title: 'PERFIL',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, ROUTE_USER_PROFILE);
            },
          ),

          const Divider(height: 1, color: Colors.grey),

          ExpansionTile(
            leading: const Icon(Icons.settings, color: Colors.orange),
            title: const Text(
              'CONFIGURACIÓN',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            children: [
              _tile(
                icon: Icons.help_outline,
                iconColor: Colors.teal,
                title: 'AYUDA',
                onTap: () => _showModalHTML(
                  context,
                  'https://godare.app/frequentQuestions.html',
                ),
              ),
              _tile(
                icon: Icons.lock_outline,
                iconColor: Colors.purple,
                title: 'MODIFICAR CONTRASEÑA',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, ROUTE_CHANGE_PASSWORD);
                },
              ),
              _tile(
                icon: Icons.privacy_tip_outlined,
                iconColor: Colors.indigo,
                title: 'POLÍTICA DE PRIVACIDAD',
                onTap: () => _showModalHTML(
                  context,
                  'https://godare.app/privacyPolicy.html',
                ),
              ),
              _tile(
                icon: Icons.delete_outline,
                iconColor: Colors.red,
                title: 'BORRAR CUENTA',
                onTap: () => _confirmDeleteAccount(context),
              ),
            ],
          ),

          const Divider(height: 1, color: Colors.grey),

          _tile(
            icon: Icons.logout,
            iconColor: Colors.red,
            title: 'CERRAR SESIÓN',
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Widget _tile({
    IconData? icon,
    Color iconColor = Colors.black,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: icon != null
          ? Icon(icon, color: iconColor)
          : const SizedBox(width: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showModalHTML(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => ModalHTML(url: url),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<UserProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      ROUTE_LOGIN,
          (route) => false,
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    // Primera confirmación — aviso general
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Eliminar cuenta',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar tu cuenta?\n\n'
              'Se borrarán todos tus datos, posts, retos y verdades. '
              'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    // Segunda confirmación — pedir contraseña
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (_) => _DeleteAccountPasswordDialog(
        controller: passwordController,
      ),
    );
    passwordController.dispose();

    if (password == null || password.isEmpty) return;
    if (!context.mounted) return;

    // Verificar contraseña antes de borrar
    try {
      final isValid = await AuthService.verifyPassword(password);
      if (!context.mounted) return;

      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña incorrecta'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Contraseña correcta — borrar cuenta
      await UserService.deleteAccount();
      if (!context.mounted) return;
      await context.read<UserProvider>().logout();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        ROUTE_LOGIN,
            (route) => false,
      );
    } on UserException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar la cuenta')),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Dialog de confirmación con contraseña
// ---------------------------------------------------------------------------

class _DeleteAccountPasswordDialog extends StatefulWidget {
  final TextEditingController controller;

  const _DeleteAccountPasswordDialog({required this.controller});

  @override
  State<_DeleteAccountPasswordDialog> createState() =>
      _DeleteAccountPasswordDialogState();
}

class _DeleteAccountPasswordDialogState
    extends State<_DeleteAccountPasswordDialog> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Confirma tu identidad',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Introduce tu contraseña para confirmar el borrado de cuenta.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.controller,
            obscureText: _obscure,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, widget.controller.text),
          child: const Text(
            'Confirmar',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}