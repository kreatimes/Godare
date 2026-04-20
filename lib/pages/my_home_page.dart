import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godare/pages/fragments/store.dart';
import 'package:godare/pages/parent_fragments/friends_fragment_with_tabs.dart';
import 'package:godare/pages/parent_fragments/home_fragment_with_tabs.dart';
import 'package:godare/pages/parent_fragments/ranking_fragment_with_tabs.dart';
import 'package:godare/pages/fragments/my_challenges.dart';
import 'package:godare/values/colors_app.dart';
import 'package:godare/widgets/menu/my_circular_menu.dart';
import 'package:godare/widgets/menu/my_drawer.dart';

import '../common/my_routers.dart';
import '../providers/user_provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        setState(() => _selectedIndex = args);
      }
    });
  }

  void _onMenuItemSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  // Fragments del menú principal — el índice coincide con el botón del menú circular
  final List<Widget> _fragments = [
    HomeFragmentWithTabs(),    // 0 - Feed global y seguidos
    FriendsFragmentWithTabs(), // 1 - Amigos/seguidores
    MyChallenges(),            // 2 - Mis retos
    RankingFragmentWithTabs(), // 3 - Ranking
    Store(),                   // 4 - Tienda
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        backgroundColor: ColorsApp.baseBlackLogo,
        iconTheme: const IconThemeData(color: ColorsApp.basePink),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, ROUTE_NOTIFICATIONS),
              ),
              Consumer<UserProvider>(
                builder: (context, provider, _) {
                  final count = provider.unreadNotifications;
                  if (count == 0) return const SizedBox.shrink();
                  return Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: ColorsApp.basePink,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: MyCircularMenu(
        onItemSelected: _onMenuItemSelected,
        selectedItem: _selectedIndex,
      ),
      // Centra el FAB horizontalmente
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: _fragments[_selectedIndex],
      ),
    );
  }
}