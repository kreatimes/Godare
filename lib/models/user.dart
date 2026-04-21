// modelos de usuario
// MyProfile = autenticado, UserProfile = publico

// Perfil completo del usuario autenticado — respuesta de /api/users/me
class MyProfile {
  final String id;
  final String nick;
  final String name;
  final String? surnames;
  final String email; // Solo visible para el propio usuario
  final String? userImageUrl;
  final int points;
  final int coinsApp; // Monedas para comprar packs en la tienda
  final int rangeLevel;
  final String rangeName;
  final String? rangeImageUrl;
  final int followersNumber;
  final int followedNumber;
  final ProfileStats stats;
  final List<String> following; // IDs de usuarios a los que sigue

  const MyProfile({
    required this.id,
    required this.nick,
    required this.name,
    this.surnames,
    required this.email,
    this.userImageUrl,
    required this.points,
    required this.coinsApp,
    required this.rangeLevel,
    required this.rangeName,
    this.rangeImageUrl,
    required this.followersNumber,
    required this.followedNumber,
    required this.stats,
    required this.following,
  });

  factory MyProfile.fromJson(Map<String, dynamic> json) {
    return MyProfile(
      id: json['id'],
      nick: json['nick'],
      name: json['name'],
      surnames: json['surnames'],
      email: json['email'],
      userImageUrl: json['userImageUrl'],
      points: json['points'] ?? 0,
      coinsApp: json['coinsApp'] ?? 0,
      rangeLevel: json['rangeLevel'] ?? 1,
      rangeName: json['rangeName'] ?? '',
      rangeImageUrl: json['rangeImageUrl'],
      followersNumber: json['followersNumber'] ?? 0,
      followedNumber: json['followedNumber'] ?? 0,
      stats: ProfileStats.fromJson(json['stats'] ?? {}),
      following: List<String>.from(json['following'] ?? []),
    );
  }

  // Comprueba si el usuario autenticado sigue a otro usuario concreto
  bool isFollowing(String userId) => following.contains(userId);
}

// Perfil publico de cualquier usuario — respuesta de /api/users/{id}
class UserProfile {
  final String id;
  final String nick;
  final String? name;
  final String? surnames;
  final String? userImageUrl;
  final int points;
  final int rangeLevel;
  final String rangeName;
  final String? rangeImageUrl;
  final int followersCount;
  final int followingCount;
  final ProfileStats stats;

  const UserProfile({
    required this.id,
    required this.nick,
    this.name,
    this.surnames,
    this.userImageUrl,
    required this.points,
    required this.rangeLevel,
    required this.rangeName,
    this.rangeImageUrl,
    required this.followersCount,
    required this.followingCount,
    required this.stats,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      nick: json['nick'],
      name: json['name'],
      surnames: json['surnames'],
      userImageUrl: json['userImageUrl'],
      points: json['points'] ?? 0,
      rangeLevel: json['rangeLevel'] ?? 1,
      rangeName: json['rangeName'] ?? '',
      rangeImageUrl: json['rangeImageUrl'],
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      stats: ProfileStats.fromJson(json['stats'] ?? {}),
    );
  }
}

// Estadisticas de actividad del usuario — se muestran en el perfil
class ProfileStats {
  final int completedDares;  // Retos completados con exito
  final int failedDares;     // Retos que expiraron sin completar
  final int pendingDares;    // Retos que tiene pendientes ahora mismo
  final int totalCompleted;  // Total historico completados
  final int totalPosts;      // Posts publicados en el feed

  const ProfileStats({
    required this.completedDares,
    required this.failedDares,
    required this.pendingDares,
    required this.totalCompleted,
    required this.totalPosts,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      completedDares: json['completedDares'] ?? 0,
      failedDares: json['failedDares'] ?? 0,
      pendingDares: json['pendingDares'] ?? 0,
      totalCompleted: json['totalCompleted'] ?? 0,
      totalPosts: json['totalPosts'] ?? 0,
    );
  }
}

// Usuario simplificado para listas de seguidores y seguidos
class FollowUser {
  final String id;
  final String nick;
  final String? name;
  final String? surnames;
  final String? userImageUrl;

  const FollowUser({
    required this.id,
    required this.nick,
    this.name,
    this.surnames,
    this.userImageUrl,
  });

  factory FollowUser.fromJson(Map<String, dynamic> json) {
    return FollowUser(
      id: json['id'],
      nick: json['nick'],
      name: json['name'],
      surnames: json['surnames'],
      userImageUrl: json['userImageUrl'],
    );
  }
}
