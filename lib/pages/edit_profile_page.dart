import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:godare/providers/user_provider.dart';
import 'package:godare/services/cloudinary_service.dart';
import 'package:godare/services/user_service.dart';
import 'package:godare/values/colors_app.dart';
import 'package:godare/widgets/forms/elements/my_text_form_field.dart';

/// Pantalla de edición de perfil.
/// Permite cambiar nick, nombre, apellidos y foto de perfil.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nickController;
  late TextEditingController _nameController;
  late TextEditingController _surnamesController;

  File? _selectedImage;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _errorMessage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProvider>().profile;
    _nickController = TextEditingController(text: profile?.nick ?? '');
    _nameController = TextEditingController(text: profile?.name ?? '');
    _surnamesController = TextEditingController(text: profile?.surnames ?? '');
  }

  @override
  void dispose() {
    _nickController.dispose();
    _nameController.dispose();
    _surnamesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library, color: ColorsApp.basePink),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: ColorsApp.basePink),
              title: const Text('Hacer una foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? imageUrl;

      if (_selectedImage != null) {
        setState(() => _isUploadingImage = true);

        // Borrar imagen anterior de Cloudinary si no es la default
        final currentImageUrl =
            context.read<UserProvider>().profile?.userImageUrl;
        if (currentImageUrl != null) {
          await CloudinaryService.deleteProfileImage(currentImageUrl);
        }

        // Subir la nueva imagen
        imageUrl = await CloudinaryService.uploadProfileImage(_selectedImage!);
        setState(() => _isUploadingImage = false);
      }

      final success = await context.read<UserProvider>().updateProfile(
        nick: _nickController.text.trim(),
        name: _nameController.text.trim(),
        surnames: _surnamesController.text.trim().isEmpty
            ? null
            : _surnamesController.text.trim(),
        userImageUrl: imageUrl,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage =
              context.read<UserProvider>().error ?? 'Error al guardar';
          _isLoading = false;
        });
      }
    } on CloudinaryException catch (e) {
      setState(() {
        _errorMessage = 'Error al subir la imagen: ${e.message}';
        _isLoading = false;
        _isUploadingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsApp.baseBlackLogo,
        iconTheme: const IconThemeData(color: ColorsApp.basePink),
        title: const Text(
          'Editar perfil',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: const Text(
              'Guardar',
              style: TextStyle(
                color: ColorsApp.basePink,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar con botón de edición
              GestureDetector(
                onTap: _showImagePicker,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!) as ImageProvider
                          : (profile?.userImageUrl != null
                          ? NetworkImage(profile!.userImageUrl!)
                          : const NetworkImage(
                        'https://res.cloudinary.com/dfeqlfptc/image/upload/v1774389485/default_profile_k6ojop.png',
                      )),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: ColorsApp.basePink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_isUploadingImage) ...[
                const SizedBox(height: 8),
                const Text(
                  'Subiendo imagen...',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],

              const SizedBox(height: 32),

              MyTextFormField(
                labelText: 'Nick',
                hintText: 'Tu nombre visible',
                controller: _nickController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nick es obligatorio';
                  }
                  if (value.trim().length < 3) return 'Mínimo 3 caracteres';
                  if (value.trim().length > 20) return 'Máximo 20 caracteres';
                  return null;
                },
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
                  onPressed: _isLoading ? null : _handleSave,
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
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}