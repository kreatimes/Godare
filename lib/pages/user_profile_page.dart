import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godare/common/my_routers.dart';
import 'package:godare/models/post.dart';
import 'package:godare/models/user.dart';
import 'package:godare/models/user_challenge.dart';
import 'package:godare/providers/user_provider.dart';
import 'package:godare/services/my_challenges_service.dart';
import 'package:godare/pages/follow_list_page.dart';
import 'package:godare/services/post_service.dart';
import 'package:godare/services/user_service.dart';
import 'package:godare/values/colors_app.dart';
import 'package:godare/widgets/basics/range_badge.dart';

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
  List<UserChallenge> _failedChallenges = [];
  List<PostComment> _userComments = [];
  bool _isLoading = true;
  bool _isFollowLoading = false;

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
      if (context.read<UserProvider>().profile == null) {
        await context.read<UserProvider>().loadProfile();
      }
      if (!mounted) return;

      final myId = context.read<UserProvider>().profile?.id ?? '';
      final targetId = widget.userId ?? myId;

      if (targetId.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final isOwn = widget.userId == null || widget.userId == myId;

      if (isOwn) {
        final results = await Future.wait([
          UserService.getMyProfile(),
          MyChallengesService.getMyChallenges(state: 'PASSED'),
          MyChallengesService.getMyChallenges(state: 'EXPIRED'),
          PostService.getUserComments(myId),
        ]);
        if (!mounted) return;
        final myProfile = results[0] as MyProfile;
        setState(() {
          _profile = UserProfile(
            id: myProfile.id,
            nick: myProfile.nick,
            name: myProfile.name,
            surnames: myProfile.surnames,
            userImageUrl: myProfile.userImageUrl,
            points: myProfile.points,
            rangeLevel: myProfile.rangeLevel,
            rangeName: myProfile.rangeName,
            rangeImageUrl: myProfile.rangeImageUrl,
            followersCount: myProfile.followersNumber,
            followingCount: myProfile.followedNumber,
            stats: myProfile.stats,
          );
          _completedChallenges = results[1] as List<UserChallenge>;
          _failedChallenges = results[2] as List<UserChallenge>;
          _userComments = results[3] as List<PostComment>;
          _isLoading = false;
        });
      } else {
        final profile = await UserService.getUserProfile(targetId);
        if (!mounted) return;

        List<UserChallenge> completed = [];
        List<UserChallenge> failed = [];
        List<PostComment> comments = [];
        try {
          final results = await Future.wait([
            MyChallengesService.getUserChallenges(targetId, state: 'PASSED'),
            MyChallengesService.getUserChallenges(targetId, state: 'EXPIRED'),
            PostService.getUserComments(targetId),
          ]);
          completed = results[0] as List<UserChallenge>;
          failed = results[1] as List<UserChallenge>;
          comments = results[2] as List<PostComment>;
        } catch (_) {}

        if (!mounted) return;
        setState(() {
          _profile = profile;
          _completedChallenges = completed;
          _failedChallenges = failed;
          _userComments = comments;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      debugPrint('UserProfilePage._fetchAll error: $e\n$stack');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
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
          ? const Center(
          child: Text('No se pudo cargar el perfil',
              style: TextStyle(color: Colors.grey)))
          : RefreshIndicator(
        onRefresh: _fetchAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              _buildStats(),
              _buildChallengesSection(),
              _buildCommentsSection(),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }

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
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RangeBadge(rangeImageUrl: _profile!.rangeImageUrl, size: 30),
              const SizedBox(width: 6),
              Text(_profile!.rangeName,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(width: 6),
              Text('· ${_profile!.points} pts',
                  style: const TextStyle(
                      color: ColorsApp.basePink,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFollowCount(
                label: 'Seguidores',
                count: _profile!.followersCount,
                onTap: () => Navigator.pushNamed(
                  context,
                  ROUTE_FOLLOW_LIST,
                  arguments: FollowListArgs(
                    userId: _profile!.id,
                    showFollowers: true,
                  ),
                ),
              ),
              const SizedBox(width: 32),
              _buildFollowCount(
                label: 'Seguidos',
                count: _profile!.followingCount,
                onTap: () => Navigator.pushNamed(
                  context,
                  ROUTE_FOLLOW_LIST,
                  arguments: FollowListArgs(
                    userId: _profile!.id,
                    showFollowers: false,
                  ),
                ),
              ),
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
              label: const Text('Editar perfil',
                  style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            )
          else
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: _isFollowLoading ? null : _toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isFollowing ? Colors.grey.shade700 : ColorsApp.basePink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: _isFollowLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : Text(isFollowing ? 'Siguiendo' : 'Seguir'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFollowCount({
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text('$count',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final stats = _profile!.stats;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ESTADISTICAS',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard(
                  icon: Icons.fitness_center,
                  color: ColorsApp.basePink,
                  label: 'Retos',
                  value: '${stats.completedDares}'),
              const SizedBox(width: 12),
              _buildStatCard(
                  icon: Icons.close,
                  color: Colors.red,
                  label: 'Fallados',
                  value: '${stats.failedDares}'),
              const SizedBox(width: 12),
              _buildStatCard(
                  icon: Icons.chat_bubble_outline,
                  color: Colors.blue,
                  label: 'Comentarios',
                  value: '${_userComments.length}'),
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
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // Sección de retos: completados (verde) y fallados (rojo)
  Widget _buildChallengesSection() {
    final total = _completedChallenges.length + _failedChallenges.length;

    final allChallenges = [
      ..._completedChallenges,
      ..._failedChallenges,
    ]..sort((a, b) => b.arrivalDate.compareTo(a.arrivalDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              const Text('RETOS',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey)),
              const SizedBox(width: 8),
              Text('($total)',
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const Spacer(),
              _buildLegendDot(Colors.green, 'Completado'),
              const SizedBox(width: 12),
              _buildLegendDot(Colors.red, 'Fallado'),
            ],
          ),
        ),
        if (total == 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: Text(
                _isOwnProfile
                    ? 'Todavia no tienes ningun reto'
                    : 'Este usuario no tiene retos aún',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: allChallenges.length,
            itemBuilder: (context, index) =>
                _ChallengeProfileCard(challenge: allChallenges[index]),
          ),
      ],
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  // Sección de comentarios — cada uno es tappable y lleva al post donde se escribió
  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              const Text('COMENTARIOS',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey)),
              const SizedBox(width: 8),
              Text('(${_userComments.length})',
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
        if (_userComments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: Text(
                _isOwnProfile
                    ? 'Todavia no has comentado nada'
                    : 'Este usuario no tiene comentarios',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: _userComments.length,
            itemBuilder: (context, index) =>
                _CommentProfileCard(comment: _userComments[index]),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tarjeta de reto — completado (verde, tappable al post) / fallado (rojo)
// ---------------------------------------------------------------------------
class _ChallengeProfileCard extends StatefulWidget {
  final UserChallenge challenge;

  const _ChallengeProfileCard({required this.challenge});

  @override
  State<_ChallengeProfileCard> createState() => _ChallengeProfileCardState();
}

class _ChallengeProfileCardState extends State<_ChallengeProfileCard> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    if (!widget.challenge.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este reto fue fallado, no tiene post en el feed'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final postId =
      await PostService.getPostIdByChallenge(widget.challenge.id);
      if (!mounted) return;
      Navigator.pushNamed(context, ROUTE_POST_DETAIL, arguments: postId);
    } on PostException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.message),
            duration: const Duration(seconds: 2)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.challenge.isCompleted;
    final borderColor = isCompleted ? Colors.green : Colors.red;
    final badgeColor = isCompleted ? Colors.green : Colors.red;
    final badgeLabel = isCompleted ? 'Completado' : 'Fallado';
    final badgeIcon =
    isCompleted ? Icons.check_circle_outline : Icons.cancel_outlined;

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.8),
          color: borderColor.withOpacity(0.04),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: badgeColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(badgeIcon, color: badgeColor, size: 13),
                        const SizedBox(width: 4),
                        Text(badgeLabel,
                            style: TextStyle(
                                color: badgeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  if (widget.challenge.isDaily) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.amber.withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, color: Colors.amber, size: 13),
                          SizedBox(width: 3),
                          Text('Diario',
                              style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(_formatDate(widget.challenge.arrivalDate),
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500)),
                  const SizedBox(width: 6),
                  if (_isLoading)
                    const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2))
                  else if (isCompleted)
                    Icon(Icons.arrow_forward_ios,
                        size: 13, color: Colors.grey.shade400),
                ],
              ),
              const SizedBox(height: 10),
              Text(widget.challenge.challengeQuestion,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              if (widget.challenge.finalScore > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text('${widget.challenge.finalScore} pts',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.amber,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ---------------------------------------------------------------------------
// Tarjeta de comentario en el perfil — tap navega al post donde fue escrito
// ---------------------------------------------------------------------------
class _CommentProfileCard extends StatelessWidget {
  final PostComment comment;

  const _CommentProfileCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        ROUTE_POST_DETAIL,
        arguments: comment.postId,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.4),
          color: Colors.blue.withOpacity(0.03),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono de comentario
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chat_bubble_outline,
                    color: Colors.blue, size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Texto del comentario
                    Text(
                      comment.commentText,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Fecha + likes
                    Row(
                      children: [
                        Text(
                          _formatDate(comment.createdAt),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                        if (comment.likesCount > 0) ...[
                          const SizedBox(width: 10),
                          Icon(Icons.favorite,
                              size: 11, color: Colors.red.shade300),
                          const SizedBox(width: 3),
                          Text('${comment.likesCount}',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade500)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Flecha indicando que es navegable
              Icon(Icons.arrow_forward_ios,
                  size: 13, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
    return '${date.day}/${date.month}/${date.year}';
  }
}