import 'package:flutter/material.dart';
import 'package:godare/pages/fragments/followings_home.dart';
import 'package:godare/pages/fragments/global_home.dart';
import 'package:godare/values/colors_app.dart';

/// Pantalla de inicio con tabs Global / Seguidos
class HomeFragmentWithTabs extends StatelessWidget {
  const HomeFragmentWithTabs({super.key});

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
                GlobalHome(),
                FollowingsHome(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}