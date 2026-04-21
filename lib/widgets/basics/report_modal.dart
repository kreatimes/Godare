import 'package:flutter/material.dart';
import 'package:godare/services/report_service.dart';

// Modal para reportar un post, usuario o comentario.
class ReportModal extends StatefulWidget {
  final String reportedId;
  final String type; // POST, USER, COMMENT

  const ReportModal({
    super.key,
    required this.reportedId,
    required this.type,
  });

  @override
  State<ReportModal> createState() => _ReportModalState();
}

class _ReportModalState extends State<ReportModal> {
  String? _selectedReason;
  bool _isLoading = false;

  static const List<_ReportReason> _reasons = [
    _ReportReason(code: 'SEXUAL_CONTENT', label: 'Contenido sexual'),
    _ReportReason(code: 'VIOLENCE',       label: 'Violencia'),
    _ReportReason(code: 'HARASSMENT',     label: 'Acoso o abuso'),
    _ReportReason(code: 'SPAM',           label: 'Spam'),
    _ReportReason(code: 'HATE_SPEECH',    label: 'Discurso de odio'),
    _ReportReason(code: 'MISINFORMATION', label: 'Información falsa'),
    _ReportReason(code: 'OTHER',          label: 'Otro motivo'),
  ];

  Future<void> _sendReport() async {
    if (_selectedReason == null) return;
    setState(() => _isLoading = true);

    try {
      await ReportService.createReport(
        reportedId: widget.reportedId,
        type: widget.type,
        reason: _selectedReason!,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte enviado. Gracias por ayudarnos a mejorar.'),
          backgroundColor: Colors.green,
        ),
      );
    } on ReportException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      final msg = e.message == 'ALREADY_REPORTED'
          ? 'Ya has reportado este contenido anteriormente'
          : 'Error al enviar el reporte. Inténtalo de nuevo.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaPadding = MediaQuery.of(context).padding;

    return Padding(
      padding: EdgeInsets.only(
        top: 12,
        // Suma el padding lateral del sistema (notch / botones táctiles en landscape)
        left:  mediaPadding.left  + 20,
        right: mediaPadding.right + 20,
        bottom: mediaPadding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.flag, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                'Reportar ${_typeLabel()}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
          const SizedBox(height: 8),

          const Text(
            '¿Por qué quieres reportar este contenido?',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          ..._reasons.map((reason) => RadioListTile<String>(
            value: reason.code,
            groupValue: _selectedReason,
            onChanged: (val) => setState(() => _selectedReason = val),
            title: Text(reason.label, style: const TextStyle(fontSize: 14)),
            activeColor: Colors.red,
            contentPadding: EdgeInsets.zero,
            dense: true,
          )),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedReason == null || _isLoading) ? null : _sendReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
                  : const Text('Enviar reporte'),
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel() {
    switch (widget.type) {
      case 'USER':    return 'usuario';
      case 'COMMENT': return 'comentario';
      default:        return 'post';
    }
  }
}

class _ReportReason {
  final String code;
  final String label;
  const _ReportReason({required this.code, required this.label});
}