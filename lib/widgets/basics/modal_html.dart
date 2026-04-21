import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

// Modal que carga y muestra contenido HTML desde una URL externa.
class ModalHTML extends StatefulWidget {
  final String url;

  const ModalHTML({super.key, required this.url});

  @override
  State<ModalHTML> createState() => _ModalHTMLState();
}

class _ModalHTMLState extends State<ModalHTML> {
  late Future<String> _htmlContent;

  @override
  void initState() {
    super.initState();
    _htmlContent = _loadHtml(widget.url);
  }

  Future<String> _loadHtml(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) return response.body;
    throw Exception('Error al cargar el contenido');
  }

  @override
  Widget build(BuildContext context) {
    // En landscape la pantalla es más baja — usamos 0.85 del alto disponible
    final double maxH = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // insetPadding asegura margen lateral incluyendo safe area del sistema
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).padding.left + 24,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              FutureBuilder<String>(
                future: _htmlContent,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('No se pudo cargar el contenido'),
                    );
                  }
                  return SingleChildScrollView(
                    child: Html(data: snapshot.data ?? ''),
                  );
                },
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}