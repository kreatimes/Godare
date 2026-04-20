import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:godare/models/user.dart';
import 'package:godare/models/user_challenge.dart';
import 'package:godare/providers/user_provider.dart';
import 'package:godare/services/cloudinary_service.dart';
import 'package:godare/services/my_challenges_service.dart';
import 'package:godare/services/user_service.dart';
import 'package:godare/values/colors_app.dart';

// Tarjeta que muestra un reto fitness del usuario.
// Puede estar en tres estados visuales: cerrado (candado), pendiente o completado.
class ChallengeCard extends StatelessWidget {
  final UserChallenge challenge;
  final VoidCallback onCompleted;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    // Si el reto esta cerrado mostramos una tarjeta con candado sin revelar el contenido
    if (challenge.isClosed) return _buildClosedCard(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTypeBadge(),
                if (challenge.isDaily) ...[
                  const SizedBox(width: 8),
                  _buildDailyBadge(),
                ],
                const Spacer(),
                _buildStateBadge(),
              ],
            ),
            const SizedBox(height: 12),

            // Texto del reto
            Text(
              challenge.challengeQuestion,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),

            Text(
              _formatDate(challenge.arrivalDate),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),

            // Botones de accion — solo si el reto esta pendiente
            if (challenge.isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showDareModal(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsApp.basePink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Realizar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () => _showTransferModal(context),
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('Transferir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Tarjeta cerrada — muestra el candado y oculta el contenido del reto
  Widget _buildClosedCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => _showClosedModal(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorsApp.basePink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.fitness_center, color: ColorsApp.basePink, size: 24),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildTypeBadge(),
                        if (challenge.isDaily) ...[
                          const SizedBox(width: 6),
                          _buildDailyBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pulsa para ver el reto',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(Icons.lock, color: ColorsApp.basePink.withOpacity(0.6), size: 28),
            ],
          ),
        ),
      ),
    );
  }

  // Modal que se abre al pulsar una tarjeta cerrada.
  // Muestra el contenido del reto y el boton para aceptarlo.
  void _showClosedModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ClosedModal(
        challenge: challenge,
        onOpened: onCompleted,
      ),
    );
  }

  // Modal para grabar o subir el video del reto completado
  void _showDareModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DareModal(challenge: challenge, onCompleted: onCompleted),
    );
  }

  // Modal para elegir a quien transferir el reto
  void _showTransferModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TransferModal(
        challengeId: challenge.id,
        challengeTitle: challenge.challengeQuestion,
        onTransferred: onCompleted,
      ),
    );
  }

  // Badge que identifica visualmente el tipo de item
  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ColorsApp.basePink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'RETO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Badge especial para los retos del dia
  Widget _buildDailyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'DAILY',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Badge con el estado actual del reto
  Widget _buildStateBadge() {
    Color color;
    String label;

    switch (challenge.state) {
      case 'OPEN':
        color = Colors.green;
        label = 'Pendiente';
        break;
      case 'PASSED':
        color = Colors.blue;
        label = 'Completado';
        break;
      case 'EXPIRED':
        color = Colors.grey;
        label = 'Expirado';
        break;
      case 'TRANSFERRED':
        color = Colors.orange;
        label = 'Transferido';
        break;
      default:
        color = Colors.grey;
        label = challenge.state;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ---------------------------------------------------------------------------
// Modal CERRADO — muestra el reto y permite aceptarlo
// ---------------------------------------------------------------------------

class _ClosedModal extends StatefulWidget {
  final UserChallenge challenge;
  final VoidCallback onOpened;

  const _ClosedModal({
    required this.challenge,
    required this.onOpened,
  });

  @override
  State<_ClosedModal> createState() => _ClosedModalState();
}

class _ClosedModalState extends State<_ClosedModal> {
  bool _isOpening = false;

  // Llama a la API para pasar el reto de CLOSED a OPEN
  Future<void> _open() async {
    setState(() => _isOpening = true);
    try {
      await MyChallengesService.openChallenge(id: widget.challenge.id);
      if (!mounted) return;
      Navigator.pop(context);
      widget.onOpened();
    } on MyChallengesException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle y boton de cerrar
          Row(
            children: [
              const Spacer(),
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
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorsApp.basePink.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.fitness_center, color: ColorsApp.basePink, size: 36),
          ),
          const SizedBox(height: 16),

          // Badges de tipo y daily
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorsApp.basePink,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'RETO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.challenge.isDaily) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'DAILY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          Text(
            widget.challenge.challengeQuestion,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Graba un video completando este reto y compartelo con todos.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isOpening ? null : _open,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsApp.basePink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isOpening
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Aceptar reto'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Modal de TRANSFERENCIA — permite enviar el reto a un seguido
// ---------------------------------------------------------------------------

class _TransferModal extends StatefulWidget {
  final String challengeId;
  final String challengeTitle;
  final VoidCallback onTransferred;

  const _TransferModal({
    required this.challengeId,
    required this.challengeTitle,
    required this.onTransferred,
  });

  @override
  State<_TransferModal> createState() => _TransferModalState();
}

class _TransferModalState extends State<_TransferModal> {
  List<FollowUser> _following = [];
  bool _isLoading = true;
  bool _isTransferring = false;

  @override
  void initState() {
    super.initState();
    _loadFollowing();
  }

  // Carga la lista de usuarios a los que sigue el usuario autenticado
  Future<void> _loadFollowing() async {
    try {
      final myId = context.read<UserProvider>().profile?.id ?? '';
      final list = await UserService.getFollowing(myId);
      if (!mounted) return;
      setState(() {
        _following = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // Muestra un dialogo de confirmacion antes de transferir
  Future<void> _confirmTransfer(FollowUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar transferencia'),
        content: Text(
          'Quieres transferir este reto a ${user.nick}?\n\n'
          '"${widget.challengeTitle}"\n\n'
          'Desaparecera de tu tablón.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Transferir',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _isTransferring = true);

    try {
      await MyChallengesService.transferChallenge(
        challengeId: widget.challengeId,
        targetUserId: user.id,
      );

      if (!mounted) return;
      Navigator.pop(context);
      widget.onTransferred();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reto transferido a ${user.nick}'),
          backgroundColor: Colors.green,
        ),
      );
    } on MyChallengesException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isTransferring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.send, color: Colors.orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transferir reto',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Elige un usuario al que sigues',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _following.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.group_off,
                                  size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              const Text(
                                'No sigues a nadie todavia',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _following.length,
                          itemBuilder: (context, index) {
                            final user = _following[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: user.userImageUrl != null
                                    ? NetworkImage(user.userImageUrl!)
                                    : const AssetImage(
                                            'assets/images/default_profile.png')
                                        as ImageProvider,
                              ),
                              title: Text(
                                user.nick,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: user.name != null
                                  ? Text(user.name!)
                                  : null,
                              trailing: _isTransferring
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : OutlinedButton(
                                      onPressed: () =>
                                          _confirmTransfer(user),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.orange,
                                        side: const BorderSide(
                                            color: Colors.orange),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text('Enviar'),
                                    ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Modal de completar RETO — permite subir el video de la prueba
// ---------------------------------------------------------------------------

class _DareModal extends StatefulWidget {
  final UserChallenge challenge;
  final VoidCallback onCompleted;
  const _DareModal({required this.challenge, required this.onCompleted});

  @override
  State<_DareModal> createState() => _DareModalState();
}

class _DareModalState extends State<_DareModal> {
  File? _selectedFile;
  bool _isLoading = false;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 1));
    if (picked != null) setState(() => _selectedFile = File(picked.path));
  }

  Future<void> _pickFromCamera() async {
    final picked = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 1));
    if (picked != null) setState(() => _selectedFile = File(picked.path));
  }

  // Sube el video a Cloudinary y luego llama a la API para marcar el reto como completado
  Future<void> _complete() async {
    if (_selectedFile == null) return;
    setState(() { _isLoading = true; _isUploading = true; });
    try {
      final fileUrl = await CloudinaryService.uploadFile(_selectedFile!);
      setState(() => _isUploading = false);
      await MyChallengesService.completeChallenge(
          id: widget.challenge.id, fileUrl: fileUrl);
      if (!mounted) return;
      Navigator.pop(context);
      widget.onCompleted();
    } on CloudinaryException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir el video: ${e.message}')));
    } on MyChallengesException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() { _isLoading = false; _isUploading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Completa el reto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(widget.challenge.challengeQuestion,
              style: const TextStyle(fontSize: 15, height: 1.5)),
          const SizedBox(height: 24),

          // Botones para seleccionar el video desde galeria o camara
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeria'),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _pickFromCamera,
                  icon: const Icon(Icons.videocam),
                  label: const Text('Camara'),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ],
          ),

          if (_selectedFile != null) ...[
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedFile!.path.split('/').last,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ],

          if (_isUploading) ...[
            const SizedBox(height: 12),
            const Row(children: [
              SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 10),
              Text('Subiendo video...',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
            ]),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedFile == null || _isLoading) ? null : _complete,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsApp.basePink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading && !_isUploading
                  ? const SizedBox(height: 20, width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Completar'),
            ),
          ),
        ],
      ),
    );
  }
}
