import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godare/models/user.dart';
import 'package:godare/providers/user_provider.dart';
import 'package:godare/services/user_service.dart';
import 'package:godare/widgets/basics/user_element.dart';

/// Lista de seguidores del usuario autenticado
class Followers extends StatefulWidget {
  const Followers({super.key});

  @override
  State<Followers> createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  List<FollowUser> _followers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFollowers();
  }

  Future<void> _fetchFollowers() async {
    setState(() => _isLoading = true);
    try {
      final myId = context.read<UserProvider>().profile?.id ?? '';
      final followers = await UserService.getFollowers(myId);
      if (!mounted) return;
      setState(() {
        _followers = followers;
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

    if (_followers.isEmpty) {
      return const Center(child: Text('Todavía no tienes seguidores'));
    }

    return RefreshIndicator(
      onRefresh: _fetchFollowers,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: _followers.length,
        itemBuilder: (context, index) =>
            UserElement(user: _followers[index]),
      ),
    );
  }
}