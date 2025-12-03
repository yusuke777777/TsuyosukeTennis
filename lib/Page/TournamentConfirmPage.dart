import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../Common/TournamentQrPayload.dart';
import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';
import 'TournamentQrScanPage.dart';

class TournamentConfirmPage extends StatefulWidget {
  final bool isHost;
  final String tournamentId;
  final String hostUserId;
  final String title;
  final String participantSummary;
  final int? participantLimit;
  final int? participantCountValue;
  final String format;
  final String description;
  final List<String> initialParticipants;
  final String qrPayload;

  const TournamentConfirmPage({
    Key? key,
    required this.isHost,
    required this.tournamentId,
    required this.hostUserId,
    required this.title,
    required this.participantSummary,
    this.participantLimit,
    this.participantCountValue,
    required this.format,
    required this.description,
    this.initialParticipants = const [],
    this.qrPayload = '',
  }) : super(key: key);

  @override
  State<TournamentConfirmPage> createState() => _TournamentConfirmPageState();
}

class _TournamentConfirmPageState extends State<TournamentConfirmPage> {
  late final List<_Participant> _initialParticipants;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _participantStream;
  int? _liveCount;

  bool get _hasTournamentId => widget.tournamentId.isNotEmpty;
  int get _currentCount =>
      _liveCount ??
      widget.participantCountValue ??
      _initialParticipants.length;
  int? get _limit => widget.participantLimit;
  bool get _isFull => _limit != null && _currentCount >= _limit!;

  @override
  void initState() {
    super.initState();
    _initialParticipants = widget.initialParticipants
        .map((name) => _Participant(id: 'initial-${name.hashCode}', name: name))
        .toList();
    _liveCount =
        widget.participantCountValue ?? widget.initialParticipants.length;
    if (_hasTournamentId) {
      _participantStream =
          FirestoreMethod.tournamentParticipantsSnapshot(widget.tournamentId);
    }
  }

  String get _qrValue {
    if (widget.qrPayload.isNotEmpty) return widget.qrPayload;
    if (!_hasTournamentId || widget.hostUserId.isEmpty) {
      return 'tournament:${widget.title}';
    }
    return TournamentQrPayload(
      tournamentId: widget.tournamentId,
      hostUserId: widget.hostUserId,
    ).encode();
  }

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "大会確認");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HeaderConfig.backGroundColor,
        title: HeaderConfig.appBarText,
        leading: HeaderConfig.backIcon,
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          colors: [Color(0xFFe8f5e9), Color(0xFFc8e6c9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              const SizedBox(height: 16),
              _buildInfoCard(),
              const SizedBox(height: 16),
              _buildParticipantSection(),
              const SizedBox(height: 16),
              widget.isHost
                  ? (_isFull ? _buildFullMessage() : _buildQrSection())
                  : _buildWaitingMessage(),
              const SizedBox(height: 24),
              if (widget.isHost) _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final displayCount = _buildCountText(
        count: _currentCount,
        limit: _limit,
        fallbackText: widget.participantSummary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black12,
              ),
              child: Row(
                children: [
                  const Icon(Icons.grid_view, size: 16),
                  const SizedBox(width: 6),
                  Text(widget.format),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                const Icon(Icons.people, size: 16),
                const SizedBox(width: 4),
                Text(displayCount),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF43a047), width: 0.8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '大会内容',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              widget.description,
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantSection() {
    if (_participantStream == null) {
      return _participantsCard(_initialParticipants);
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _participantStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _participantsCard(_initialParticipants);
        }
        if (!snapshot.hasData) {
          return _participantsCard(_initialParticipants, isLoading: true);
        }
        final docs = snapshot.data!.docs;
        final participants = docs
            .map((doc) {
              final data = doc.data();
              final userId = (data['userId'] ?? doc.id).toString();
              final name = (data['displayName'] ?? '').toString();
              final image = (data['profileImage'] ?? '').toString();
              return _Participant(
                  id: userId,
                  name: name.isNotEmpty ? name : userId,
                  profileImage: image);
            })
            .toList();
        final newCount = participants.length;
        if (_liveCount != newCount) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _liveCount = newCount;
              });
            }
          });
        }
        return _participantsCard(participants);
      },
    );
  }

  Widget _participantsCard(List<_Participant> participants,
      {bool isLoading = false}) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF4caf50), width: 0.8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '参加者',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1b5e20)),
            ),
            const SizedBox(height: 8),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (participants.isEmpty)
              const Text(
                'まだ参加者がいません',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: participants
                    .map((participant) => InputChip(
                          avatar: participant.profileImage.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(participant.profileImage),
                                )
                              : const Icon(Icons.sports_tennis,
                                  size: 18, color: Color(0xFF2e7d32)),
                          label: Text(
                            participant.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1b5e20)),
                          ),
                          backgroundColor: const Color(0xFFE8F5E9),
                          shape: StadiumBorder(
                            side: BorderSide(
                                color: const Color(0xFF66bb6a)
                                    .withValues(alpha: 0.7),
                                width: 0.5),
                          ),
                          onDeleted: widget.isHost
                              ? () => _confirmRemove(participant)
                              : null,
                          deleteIcon: widget.isHost
                              ? const Icon(Icons.close, color: Color(0xFFc62828))
                              : null,
                          deleteButtonTooltipMessage:
                              widget.isHost ? '参加者を削除' : null,
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF43a047), width: 0.8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '参加確認QRコード',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1b5e20)),
            ),
            const SizedBox(height: 10),
            Center(
              child: QrImageView(
                data: _qrValue,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'このQRコードを読み込むとユーザー情報を取得し、参加者に即時反映します。',
              style: TextStyle(color: Colors.black54),
            ),
            if (_limit != null) ...[
              const SizedBox(height: 6),
              Text(
                '残り ${(_limit! - _currentCount).clamp(0, _limit!)} 人',
                style: const TextStyle(color: Color(0xFF1b5e20)),
              ),
            ],
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('主催者も参加者に追加'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade100,
                foregroundColor: Colors.green.shade900,
              ),
              onPressed: () async {
                try {
                  final profile = await FirestoreMethod.getProfile();
                  await FirestoreMethod.addTournamentParticipant(
                    tournamentId: widget.tournamentId,
                    hostUserId: widget.hostUserId,
                    profile: profile,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('主催者を参加者に追加しました')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('追加に失敗しました。通信状況をご確認ください')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButtonSection() {
    // 未使用（参加者側のQR読み取りUIは非表示）
    return const SizedBox.shrink();
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('大会を確定しました (仮実装)'),
          ));
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: const Color(0xFF1b5e20),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
        ),
        child: const Text(
          '大会確定',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildWaitingMessage() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF43a047), width: 0.8)),
      child: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Text(
          '人数が揃うまでお待ちください。',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1b5e20)),
        ),
      ),
    );
  }

  String _buildCountText(
      {int? count, int? limit, required String fallbackText}) {
    final c = count;
    if (c != null && limit != null) {
      return '$c/$limit人';
    }
    if (c != null) {
      return '$c人';
    }
    return fallbackText;
  }

  Widget _buildFullMessage() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFd32f2f), width: 0.8)),
      child: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '募集上限に達しました',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFb71c1c)),
            ),
            SizedBox(height: 6),
            Text(
              '参加枠が上限に達したため、このQRコードは一時停止中です。',
              style: TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemove(_Participant participant) async {
    if (!widget.isHost) return;
    final bool? ok = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('参加者を削除しますか？'),
            content: Text('${participant.name} を参加者から外します。'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('キャンセル')),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('削除')),
            ],
          );
        });
    if (ok != true) return;
    try {
      await FirestoreMethod.tournamentParticipantsRef(widget.tournamentId)
          .doc(participant.id)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${participant.name} を削除しました')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('削除に失敗しました。もう一度お試しください。')));
      }
    }
  }
}

class _Participant {
  final String id;
  final String name;
  final String profileImage;

  const _Participant(
      {required this.id, required this.name, this.profileImage = ''});
}
