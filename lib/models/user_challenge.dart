class UserChallenge {
  final String id;
  final String challengeId;
  final String challengeQuestion;
  final String state;
  final bool isDaily;
  final DateTime arrivalDate;
  final DateTime? expiresAt;
  final DateTime? datePassed;
  final String? fileUrl;
  final int finalScore;

  // Contadores de veredicto de la comunidad.
  // Se fijan al cerrar la votación (5 días) y ya no cambian.
  final int approvedCount;
  final int notApprovedCount;

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
    this.approvedCount = 0,
    this.notApprovedCount = 0,
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
      approvedCount: json['approvedCount'] ?? 0,
      notApprovedCount: json['notApprovedCount'] ?? 0,
    );
  }

  bool get isPending      => state == 'OPEN';
  bool get isCompleted    => state == 'PASSED';
  bool get isExpired      => state == 'EXPIRED';
  bool get isTransferred  => state == 'TRANSFERRED';
  bool get isClosed       => state == 'CLOSED';
  bool get isFailedByVote => state == 'FAILED_BY_VOTE';
  bool get isFailed       => isExpired || isFailedByVote;

  String get failedLabel    => isFailedByVote ? 'Rechazado' : 'Fallado';
  String get failedSubtitle => isFailedByVote ? 'La comunidad votó que no fue superado' : '';

  // true si hay votos
  bool get hasVerdictVotes => approvedCount > 0 || notApprovedCount > 0;
}