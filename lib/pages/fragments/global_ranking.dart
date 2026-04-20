import 'package:flutter/material.dart';
import 'package:godare/models/ranking.dart';
import 'package:godare/services/ranking_service.dart';
import 'package:godare/widgets/basics/ranking_element.dart';

/// Ranking global de todos los usuarios ordenado por puntos
class GlobalRanking extends StatefulWidget {
  const GlobalRanking({super.key});

  @override
  State<GlobalRanking> createState() => _GlobalRankingState();
}

class _GlobalRankingState extends State<GlobalRanking> {
  List<RankingEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRanking();
  }

  Future<void> _fetchRanking() async {
    setState(() => _isLoading = true);
    try {
      final entries = await RankingService.getGlobalRanking();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_entries.isEmpty) {
      return const Center(child: Text('No hay datos de ranking todavía'));
    }

    return RefreshIndicator(
      onRefresh: _fetchRanking,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: _entries.length,
        itemBuilder: (context, index) =>
            RankingElement(entry: _entries[index]),
      ),
    );
  }
}