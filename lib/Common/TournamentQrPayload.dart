class TournamentQrPayload {
  final String tournamentId;
  final String hostUserId;

  const TournamentQrPayload({
    required this.tournamentId,
    required this.hostUserId,
  });

  String encode() => 'tournament:$tournamentId|host:$hostUserId';

  static TournamentQrPayload? parse(String raw) {
    final parts = raw.split('|');
    String? tournamentId;
    String? hostUserId;

    for (final part in parts) {
      if (part.startsWith('tournament:')) {
        tournamentId = part.substring('tournament:'.length);
      } else if (part.startsWith('host:')) {
        hostUserId = part.substring('host:'.length);
      }
    }

    if (tournamentId == null ||
        hostUserId == null ||
        tournamentId.isEmpty ||
        hostUserId.isEmpty) {
      return null;
    }
    return TournamentQrPayload(
        tournamentId: tournamentId, hostUserId: hostUserId);
  }
}
