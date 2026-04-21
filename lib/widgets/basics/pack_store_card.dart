import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godare/models/pack_store.dart';
import 'package:godare/providers/user_provider.dart';
import 'package:godare/services/pack_service.dart';
import 'package:godare/values/colors_app.dart';

// Tarjeta de un pack de retos en la tienda.
// Muestra imagen, nombre, cantidad y precio en coins.
// Al pulsar comprar muestra un dialogo de confirmacion antes de procesar.
class PackStoreCard extends StatefulWidget {
  final PackStore pack;

  const PackStoreCard({super.key, required this.pack});

  @override
  State<PackStoreCard> createState() => _PackStoreCardState();
}

class _PackStoreCardState extends State<PackStoreCard> {
  bool _isLoading = false;

  // confirmacion antes de comprar
  Future<void> _handleBuy() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(widget.pack.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.pack.description),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.pack.priceCoins} coins',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsApp.basePink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Comprar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final result = await PackService.buyPack(widget.pack.id);

      if (!mounted) return;

      // actualizar coins
      await context.read<UserProvider>().loadProfile();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Compra realizada! Se han generado ${result.generatedItems} retos. '
                'Te quedan ${result.remainingCoins} coins.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } on PackException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Etiqueta del tipo de pack
  String _getTypeLabel(String type) {
    switch (type) {
      case 'DARE':
        return 'Retos Fitness';
      default:
        return type;
    }
  }

  // Color del badge segun el tipo de pack
  Color _getTypeColor(String type) {
    return ColorsApp.basePink;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor(widget.pack.type);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                _getPackImage(widget.pack.priceCoins),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Text(
                      _getTypeLabel(widget.pack.type),
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    widget.pack.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    '${widget.pack.quantity} retos',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on,
                        color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.pack.priceCoins}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleBuy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsApp.basePink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('Comprar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Devuelve el asset local según el precio del pack
  String _getPackImage(int priceCoins) {
    switch (priceCoins) {
      case 35:
        return 'assets/images/presion.png';
      case 25:
        return 'assets/images/limite.png';
      case 18:
        return 'assets/images/desafio.png';
      case 10:
        return 'assets/images/apuesta.png';
      default:
        return 'assets/images/desafio.png';
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.fitness_center, color: Colors.grey),
    );
  }
}