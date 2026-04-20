import 'package:flutter/material.dart';
import 'package:godare/models/ranking.dart';
import 'package:godare/services/ranking_service.dart';
import 'package:godare/widgets/basics/ranking_element.dart';

/// Ranking solo entre los usuarios que sigue el usuario autenticado
class FollowingsRanking extends StatefulWidget {
  const FollowingsRanking({super.key});

  @override
  State<FollowingsRanking> createState() => _FollowingsRankingState();
}

class _FollowingsRankingState extends State<FollowingsRanking> {
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
      final entries = await RankingService.getFollowingRanking();
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
      return const Center(
        child: Text('Sigue a alguien para verlo en el ranking'),
      );
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