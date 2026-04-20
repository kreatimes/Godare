import 'package:flutter/material.dart';
import 'package:godare/models/user.dart';
import 'package:godare/services/user_service.dart';
import 'package:godare/values/colors_app.dart';
import 'package:godare/widgets/basics/user_element.dart';

/// Argumentos que recibe la página desde el router.
class FollowListArgs {
  final String userId;
  final bool showFollowers; // true = seguidores, false = seguidos

  const FollowListArgs({required this.userId, required this.showFollowers});
}

/// Página que muestra la lista de seguidores o seguidos de un usuario.
class FollowListPage extends StatefulWidget {
  final String userId;
  final bool showFollowers;

  const FollowListPage({
    super.key,
    required this.userId,
    required this.showFollowers,
  });

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  List<FollowUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final users = widget.showFollowers
          ? await UserService.getFollowers(widget.userId)
          : await UserService.getFollowing(widget.userId);
      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.showFollowers ? 'Seguidores' : 'Seguidos';
    final emptyText = widget.showFollowers
        ? 'Este usuario no tiene seguidores aún'
        : 'Este usuario no sigue a nadie aún';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsApp.baseBlackLogo,
        iconTheme: const IconThemeData(color: ColorsApp.basePink),
        title: Text(title, style: const TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? Center(
          child: Text(emptyText,
              style: const TextStyle(color: Colors.grey)))
          : RefreshIndicator(
        onRefresh: _fetch,
        child: ListView.builder(
          padding: EdgeInsets.only(
            top: 8,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          itemCount: _users.length,
          itemBuilder: (context, index) =>
              UserElement(user: _users[index]),
        ),
      ),
    );
  }
}