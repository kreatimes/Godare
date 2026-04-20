import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godare/models/pack_store.dart';
import 'package:godare/providers/user_provider.dart';
import 'package:godare/services/pack_service.dart';
import 'package:godare/values/colors_app.dart';
import 'package:godare/widgets/basics/pack_store_card.dart';

// Tienda de packs de retos fitness.
// El usuario puede comprar packs con las coins que gana al completar retos.
class Store extends StatefulWidget {
  const Store({super.key});

  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> {
  List<PackStore> _packs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPacks();
  }

  Future<void> _fetchPacks() async {
    setState(() => _isLoading = true);
    try {
      final packs = await PackService.getAvailablePacks();
      if (!mounted) return;
      setState(() {
        _packs = packs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // Filtra los packs de retos fitness
  List<PackStore> get _darePacks =>
      _packs.where((p) => p.type == 'DARE').toList();

  @override
  Widget build(BuildContext context) {
    final coins = context.watch<UserProvider>().profile?.coinsApp ?? 0;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchPacks,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                // Cabecera con el saldo de coins del usuario
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TIENDA',
                        style: TextStyle(
                          fontSize: 28,
                          fontFamily: 'Oswald',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/coin_money.png',
                            width: 34,
                            height: 34,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$coins coins disponibles',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Lista de packs disponibles
                if (_darePacks.isNotEmpty) ...[
                  _buildSectionHeader('PACKS DE RETOS FITNESS', ColorsApp.basePink),
                  ..._darePacks.map((p) => PackStoreCard(pack: p)),
                ],

                if (_packs.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('No hay packs disponibles'),
                    ),
                  ),
              ],
            ),
          );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
