import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godare/models/user.dart';
import 'package:godare/providers/user_provider.dart';
import 'package:godare/services/user_service.dart';
import 'package:godare/widgets/basics/user_element.dart';

/// Lista de usuarios a los que sigue el usuario autenticado
class Followings extends StatefulWidget {
  const Followings({super.key});

  @override
  State<Followings> createState() => _FollowingsState();
}

class _FollowingsState extends State<Followings> {
  List<FollowUser> _followings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFollowings();
  }

  Future<void> _fetchFollowings() async {
    setState(() => _isLoading = true);
    try {
      final myId = context.read<UserProvider>().profile?.id ?? '';
      final followings = await UserService.getFollowing(myId);
      if (!mounted) return;
      setState(() {
        _followings = followings;
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

    if (_followings.isEmpty) {
      return const Center(child: Text('No sigues a nadie todavía'));
    }

    return RefreshIndicator(
      onRefresh: _fetchFollowings,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: _followings.length,
        itemBuilder: (context, index) =>
            UserElement(user: _followings[index]),
      ),
    );
  }
}