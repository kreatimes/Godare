import 'package:flutter/material.dart';
import 'package:godare/common/my_routers.dart';
import 'package:godare/pages/fragments/followers.dart';
import 'package:godare/pages/fragments/followings.dart';
import 'package:godare/values/colors_app.dart';

/// Pantalla de amigos con tabs Seguidos / Seguidores y botón de búsqueda
class FriendsFragmentWithTabs extends StatelessWidget {
  const FriendsFragmentWithTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // AppBar personalizado con tabs y botón de búsqueda
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    indicatorColor: ColorsApp.basePink,
                    labelColor: ColorsApp.basePink,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(icon: Icon(Icons.group_add), text: 'Seguidos'),
                      Tab(icon: Icon(Icons.group), text: 'Seguidores'),
                    ],
                  ),
                ),
                // Botón lupa para buscar usuarios
                IconButton(
                  icon: const Icon(Icons.search, color: ColorsApp.basePink),
                  tooltip: 'Buscar usuarios',
                  onPressed: () => Navigator.pushNamed(
                    context,
                    ROUTE_SEARCH_USERS,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                Followings(),
                Followers(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}