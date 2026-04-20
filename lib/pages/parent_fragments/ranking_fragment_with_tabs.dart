import 'package:flutter/material.dart';
import 'package:godare/pages/fragments/followings_ranking.dart';
import 'package:godare/pages/fragments/global_ranking.dart';
import 'package:godare/values/colors_app.dart';

/// Pantalla de ranking con tabs Global / Seguidos
class RankingFragmentWithTabs extends StatelessWidget {
  const RankingFragmentWithTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: ColorsApp.basePink,
            labelColor: ColorsApp.basePink,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.travel_explore), text: 'Global'),
              Tab(icon: Icon(Icons.emoji_people), text: 'Seguidos'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                GlobalRanking(),
                FollowingsRanking(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}