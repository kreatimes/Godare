/// Entrada del ranking — usuario con su posición y puntos
class RankingEntry {
  final String userId;
  final String nick;
  final String? userImageUrl;
  final int points;
  final int rangeLevel;
  final String rangeName;
  final String? rangeImageUrl;
  final int position;

  const RankingEntry({
    required this.userId,
    required this.nick,
    this.userImageUrl,
    required this.points,
    required this.rangeLevel,
    required this.rangeName,
    this.rangeImageUrl,
    required this.position,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      userId: json['userId'],
      nick: json['nick'],
      userImageUrl: json['userImageUrl'],
      points: json['points'] ?? 0,
      rangeLevel: json['rangeLevel'] ?? 1,
      rangeName: json['rangeName'] ?? '',
      rangeImageUrl: json['rangeImageUrl'],
      position: json['position'] ?? 0,
    );
  }
}