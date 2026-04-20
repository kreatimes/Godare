import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godare/common/my_routers.dart';
import 'package:godare/models/user.dart';
import 'package:godare/models/user_challenge.dart';
import 'package:godare/providers/user_provider.dart';
import 'package:godare/services/my_challenges_service.dart';
import 'package:godare/services/user_service.dart';
import 'package:godare/values/colors_app.dart';
import 'package:godare/widgets/basics/challenge_card.dart';
import 'package:godare/widgets/basics/range_badge.dart';

// Pagina de perfil de usuario.
// Si userId es null muestra el perfil del usuario autenticado.
// Si userId tiene valor muestra el perfil publico de ese usuario.
class UserProfilePage extends StatefulWidget {
  final String? userId;

  const UserProfilePage({super.key, this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  UserProfile? _profile;
  List<UserChallenge> _completedChallenges = [];
  bool _isLoading = true;
  bool _isFollowLoading = false;

  // Comprueba si estamos viendo nuestro propio perfil
  bool get _isOwnProfile {
    final myId = context.read<UserProvider>().profile?.id;
    return widget.userId == null || widget.userId == myId;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _fetchAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    setState(() => _isLoading = true);
    try {
      final myId = context.read<UserProvider>().profile?.id ?? '';
      final targetId = widget.userId ?? myId;

      final results = await Future.wait([
        UserService.getUserProfile(targetId),
        if (_isOwnProfile)
          MyChallengesService.getMyChallenges(state: 'PASSED'),
      ]);

      if (!mounted) return;
      setState(() {
        _profile = results[0] as UserProfile;
        if (_isOwnProfile && results.length > 1) {
          _completedChallenges = results[1] as List<UserChallenge>;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // Gestiona el seguir/dejar de seguir a un usuario
  Future<void> _toggleFollow() async {
    if (_profile == null) return;
    setState(() => _isFollowLoading = true);

    final myProfile = context.read<UserProvider>().profile;
    final isFollowing = myProfile?.isFollowing(_profile!.id) ?? false;

    try {
      if (isFollowing) {
        await UserService.unfollowUser(_profile!.id);
      } else {
        await UserService.followUser(_profile!.id);
      }
      await context.read<UserProvider>().loadProfile();
      await _fetchAll();
    } on UserException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _isFollowLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsApp.baseBlackLogo,
        iconTheme: const IconThemeData(color: ColorsApp.basePink),
        title: Text(
          _profile?.nick ?? '',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (_isOwnProfile)
            IconButton(
              icon: const Icon(Icons.edit, color: ColorsApp.basePink),
              onPressed: () async {
                await Navigator.pushNamed(context, ROUTE_EDIT_PROFILE);
                _fetchAll();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? const Center(child: Text('No se pudo cargar el perfil'))
              : RefreshIndicator(
                  onRefresh: _fetchAll,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildStats(),
                        if (_isOwnProfile) _buildChallengesSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  // Cabecera con avatar, nick, rango y boton de seguir
  Widget _buildHeader() {
    final myProfile = context.watch<UserProvider>().profile;
    final isFollowing = myProfile?.isFollowing(_profile!.id) ?? false;

    return Container(
      width: double.infinity,
      color: ColorsApp.baseBlackLogo,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: _profile!.userImageUrl != null
                ? NetworkImage(_profile!.userImageUrl!)
                : const NetworkImage(
                    'https://res.cloudinary.com/dfeqlfptc/image/upload/v1774389485/default_profile_k6ojop.png',
                  ),
          ),
          const SizedBox(height: 12),

          Text(
            _profile!.nick,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RangeBadge(rangeImageUrl: _profile!.rangeImageUrl, size: 30),
              const SizedBox(width: 6),
              Text(
                _profile!.rangeName,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 6),
              Text(
                '· ${_profile!.points} pts',
                style: const TextStyle(
                  color: ColorsApp.basePink,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFollowCount(label: 'Seguidores', count: _profile!.followersCount),
              const SizedBox(width: 32),
              _buildFollowCount(label: 'Seguidos', count: _profile!.followingCount),
            ],
          ),
          const SizedBox(height: 16),

          if (_isOwnProfile)
            OutlinedButton.icon(
              onPressed: () async {
                await Navigator.pushNamed(context, ROUTE_EDIT_PROFILE);
                _fetchAll();
              },
              icon: const Icon(Icons.edit, size: 16, color: Colors.white),
              label: const Text('Editar perfil', style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            )
          else
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: _isFollowLoading ? null : _toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing ? Colors.grey.shade700 : ColorsApp.basePink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: _isFollowLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(isFollowing ? 'Siguiendo' : 'Seguir'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFollowCount({required String label, required int count}) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  // Seccion de estadisticas — muestra retos completados, fallidos y posts
  Widget _buildStats() {
    final stats = _profile!.stats;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ESTADISTICAS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.fitness_center,
                color: ColorsApp.basePink,
                label: 'Retos',
                value: '${stats.completedDares}',
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.close,
                color: Colors.red,
                label: 'Fallados',
                value: '${stats.failedDares}',
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.photo_library,
                color: Colors.blue,
                label: 'Posts',
                value: '${stats.totalPosts}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // Lista de retos completados — solo se muestra en el perfil propio
  Widget _buildChallengesSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Text(
                'RETOS COMPLETADOS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${_completedChallenges.length})',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        _completedChallenges.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Todavia no has completado ningun reto',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: _completedChallenges.length,
                itemBuilder: (context, index) => ChallengeCard(
                  challenge: _completedChallenges[index],
                  onCompleted: _fetchAll,
                ),
              ),
      ],
    );
  }
}
