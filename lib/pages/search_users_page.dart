import 'package:flutter/material.dart';
import 'package:godare/common/my_routers.dart';
import 'package:godare/models/user.dart';
import 'package:godare/services/user_service.dart';
import 'package:godare/values/colors_app.dart';
import 'package:godare/widgets/basics/user_element.dart';

/// Pantalla de búsqueda de usuarios por nick.
class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  final TextEditingController _controller = TextEditingController();

  List<FollowUser> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 2) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final results = await UserService.searchUsers(query.trim());
      if (!mounted) return;
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsApp.baseBlackLogo,
        iconTheme: const IconThemeData(color: ColorsApp.basePink),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Buscar por nick...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (value.trim().length >= 2) {
              _search(value);
            } else {
              setState(() {
                _results = [];
                _hasSearched = false;
              });
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_hasSearched
          ? const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Escribe al menos 2 caracteres',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : _results.isEmpty
          ? const Center(
        child: Text(
          'No se encontraron usuarios',
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: _results.length,
        itemBuilder: (context, index) =>
            UserElement(user: _results[index]),
      ),
    );
  }
}