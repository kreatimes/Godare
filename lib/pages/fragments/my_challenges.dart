import 'package:flutter/material.dart';
import 'package:godare/models/user_challenge.dart';
import 'package:godare/services/my_challenges_service.dart';
import 'package:godare/values/colors_app.dart';
import 'package:godare/widgets/basics/challenge_card.dart';

// Pantalla de mis retos con dos tabs: Pendientes y Completados.
// Carga los retos al iniciarse y permite refrescar tirando hacia abajo.
class MyChallenges extends StatefulWidget {
  const MyChallenges({super.key});

  @override
  State<MyChallenges> createState() => _MyChallengesState();
}

class _MyChallengesState extends State<MyChallenges>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<UserChallenge> _pendingChallenges = [];
  List<UserChallenge> _completedChallenges = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Carga en paralelo los retos pendientes y completados para reducir el tiempo de espera
  Future<void> _fetchAll() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        MyChallengesService.getMyChallenges(state: 'CLOSED'),
        MyChallengesService.getMyChallenges(state: 'OPEN'),
        MyChallengesService.getMyChallenges(state: 'PASSED'),
      ]);

      if (!mounted) return;
      setState(() {
        // Los retos pendientes incluyen los cerrados (no abiertos) y los abiertos
        _pendingChallenges = [
          ...results[0] as List<UserChallenge>,
          ...results[1] as List<UserChallenge>,
        ];
        _completedChallenges = results[2] as List<UserChallenge>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // Se llama desde ChallengeCard cuando el usuario completa o transfiere un reto
  void _onCompleted() => _fetchAll();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tabs con contador de items
        TabBar(
          controller: _tabController,
          indicatorColor: ColorsApp.basePink,
          labelColor: ColorsApp.basePink,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              text: 'Pendientes'
                  '${_pendingChallenges.isNotEmpty ? ' (${_pendingChallenges.length})' : ''}',
            ),
            Tab(
              text: 'Completados'
                  '${_completedChallenges.isNotEmpty ? ' (${_completedChallenges.length})' : ''}',
            ),
          ],
        ),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPendingTab(),
                    _buildCompletedTab(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildPendingTab() {
    if (_pendingChallenges.isEmpty) {
      return const Center(
        child: Text('No tienes retos pendientes'),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAll,
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        children: _pendingChallenges.map(
          (c) => ChallengeCard(
            challenge: c,
            onCompleted: _onCompleted,
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildCompletedTab() {
    if (_completedChallenges.isEmpty) {
      return const Center(
        child: Text('Todavia no has completado ningun reto'),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAll,
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        children: _completedChallenges.map(
          (c) => ChallengeCard(
            challenge: c,
            onCompleted: _onCompleted,
          ),
        ).toList(),
      ),
    );
  }
}
