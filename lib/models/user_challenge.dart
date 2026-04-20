// Modelo que representa un reto asignado al usuario.
// Cuando el usuario compra un pack o recibe un reto diario, se crea
// un UserChallenge en la base de datos vinculado a su cuenta.
class UserChallenge {
  final String id;
  final String challengeId;
  final String challengeQuestion; // El texto del reto que tiene que completar
  final String state;
  final bool isDaily;
  final DateTime arrivalDate;
  final DateTime? expiresAt;
  final DateTime? datePassed;
  final String? fileUrl; // URL del video subido al completar el reto
  final int finalScore;

  const UserChallenge({
    required this.id,
    required this.challengeId,
    required this.challengeQuestion,
    required this.state,
    required this.isDaily,
    required this.arrivalDate,
    this.expiresAt,
    this.datePassed,
    this.fileUrl,
    required this.finalScore,
  });

  factory UserChallenge.fromJson(Map<String, dynamic> json) {
    return UserChallenge(
      id: json['id'],
      challengeId: json['challengeId'],
      challengeQuestion: json['challengeQuestion'] ?? '',
      state: json['state'],
      isDaily: json['isDaily'] ?? false,
      arrivalDate: DateTime.parse(json['arrivalDate']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      datePassed: json['datePassed'] != null ? DateTime.parse(json['datePassed']) : null,
      fileUrl: json['fileUrl'],
      finalScore: json['finalScore'] ?? 0,
    );
  }

  // Metodos de conveniencia para comprobar el estado sin comparar strings a mano
  bool get isPending => state == 'OPEN';
  bool get isCompleted => state == 'PASSED';
  bool get isExpired => state == 'EXPIRED';
  bool get isTransferred => state == 'TRANSFERRED';
  bool get isClosed => state == 'CLOSED';
}
