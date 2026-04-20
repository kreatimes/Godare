import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godare/models/pack_store.dart';
import 'package:godare/providers/user_provider.dart';
import 'package:godare/services/pack_service.dart';
import 'package:godare/values/colors_app.dart';

/// Tarjeta de un pack en la tienda.
/// Muestra imagen, nombre, tipo, cantidad y precio en coins.
/// Al pulsar comprar muestra un diálogo de confirmación.
class PackStoreCard extends StatefulWidget {
  final PackStore pack;

  const PackStoreCard({super.key, required this.pack});

  @override
  State<PackStoreCard> createState() => _PackStoreCardState();
}

class _PackStoreCardState extends State<PackStoreCard> {
  bool _isLoading = false;

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

      await context.read<UserProvider>().loadProfile();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Compra realizada! Se han generado ${result.generatedItems} items. '
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

  String _getTypeLabel(String type) {
    switch (type) {
      case 'DARE':
        return 'Reto';
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Text(
        widget.pack.typeLabel,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.inventory_2,
        color: Colors.grey,
      ),
    );
  }
}