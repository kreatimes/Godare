import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

/// Modal que carga y muestra contenido HTML desde una URL externa.
/// Usado para mostrar política de privacidad, preguntas frecuentes, etc.
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
    if (response.statusCode == 200) {
      return response.body;
    }
    throw Exception('Error al cargar el contenido');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
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

              // Botón de cierre
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