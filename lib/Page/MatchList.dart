import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tsuyosuke_tennis_ap/Common/CtalkRoom.dart';
import 'package:tsuyosuke_tennis_ap/Page/MatchResult.dart';
import 'package:tsuyosuke_tennis_ap/Page/ProfileReference.dart';
import '../Common/CmatchList.dart';
import '../Common/CprofileSetting.dart';
import '../Common/TournamentQrPayload.dart';
import '../Component/native_dialog.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/GoogleAds.dart';
import '../FireBase/NotificationMethod.dart';
import '../PropSetCofig.dart';
import 'TalkRoom.dart';
import 'TournamentConfirmPage.dart';

class TournamentEntry {
  final String tournamentId;
  final String hostUserId;
  final String title;
  final String participantCount;
  final String format; // リーグ・トーナメント・リーグ/トーナメント
  final String description; // ルールや備考
  final List<String> participants;
  final String qrPayload;
  final int? participantLimit;
  final int? participantCountValue;

  const TournamentEntry({
    required this.tournamentId,
    required this.hostUserId,
    required this.title,
    required this.participantCount,
    required this.format,
    required this.description,
    this.participants = const [],
    this.qrPayload = '',
    this.participantLimit,
    this.participantCountValue,
  });
}

class MatchList extends StatefulWidget {
  const MatchList({Key? key}) : super(key: key);

  @override
  _MatchListState createState() => _MatchListState();
}

class _MatchListState extends State<MatchList> {
  static final FirebaseFirestore _firestoreInstance =
      FirebaseFirestore.instance;
  List<MatchListModel> matchListAll = [];
  List<TournamentEntry> joinedTournaments = [];
  List<TournamentEntry> hostedTournaments = [];
  DocumentSnapshot? lastDocument; // 最後のドキュメントを保持する変数
  bool _isLoadingMore = false;
  bool _isTournamentLoading = true;
  late ScrollController _scrollController;
  static final blockListRef = _firestoreInstance.collection('blockList');
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _joinedTournamentSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _hostedTournamentSub;

  //ローディング表示
  bool _isLoading = true;

  final List<Tab> _tabs = const [
    Tab(
        child: Text(
      '個人対戦',
      style: TextStyle(fontSize: 16),
    )),
    Tab(
        child: Text(
      '参加大会',
      style: TextStyle(fontSize: 16),
    )),
    Tab(
        child: Text(
      '主催大会',
      style: TextStyle(fontSize: 16),
    )),
  ];

  Future<void> createMatchList() async {
    setState(() => _isLoading = true);
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('matchList')
          .where('MATCH_USER_LIST',
              arrayContains: FirestoreMethod.auth.currentUser!.uid)
          .orderBy('SAKUSEI_TIME', descending: true)
          .limit(10)
          .get();

      final futures = querySnapshot.docs.map((doc) async {
        late CprofileSetting yourProfile;
        late CprofileSetting myProfile;
        if (doc
            .data()['RECIPIENT_ID']
            .contains(FirestoreMethod.auth.currentUser!.uid)) {
          yourProfile =
              await FirestoreMethod.getYourProfile(doc.data()['SENDER_ID']);
          myProfile =
              await FirestoreMethod.getYourProfile(doc.data()['RECIPIENT_ID']);
        } else if (doc
            .data()['SENDER_ID']
            .contains(FirestoreMethod.auth.currentUser!.uid)) {
          yourProfile =
              await FirestoreMethod.getYourProfile(doc.data()['RECIPIENT_ID']);
          myProfile =
              await FirestoreMethod.getYourProfile(doc.data()['SENDER_ID']);
        }
        return MatchListModel(
          MATCH_ID: doc.data()['MATCH_ID'],
          RECIPIENT_ID: doc.data()['RECIPIENT_ID'],
          SENDER_ID: doc.data()['SENDER_ID'],
          SAKUSEI_TIME: doc.data()['SAKUSEI_TIME'],
          MATCH_FLG: doc.data()['MATCH_FLG'],
          MY_USER: myProfile,
          YOUR_USER: yourProfile,
        );
      });
      final matchList = await Future.wait(futures);

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last; // 最後のドキュメントを設定
      }
      if (mounted) {
        setState(() {
          matchListAll.addAll(matchList);
        });
      }
    } catch (e) {
      print(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTournamentLists() async {
    if (!mounted) return;
    setState(() {
      _isTournamentLoading = true;
    });
    try {
      final uid = FirestoreMethod.auth.currentUser?.uid;
      if (uid == null) {
        setState(() {
          joinedTournaments = [];
          hostedTournaments = [];
        });
        return;
      }
      final results = await Future.wait([
        _fetchJoinedTournaments(uid),
        _fetchHostedTournaments(uid),
      ]);
      if (mounted) {
        setState(() {
          joinedTournaments = results[0];
          hostedTournaments = results[1];
        });
      }
    } catch (e) {
      print('大会一覧の取得に失敗しました: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isTournamentLoading = false;
        });
      }
    }
  }

  Future<List<TournamentEntry>> _fetchJoinedTournaments(String uid) async {
    final joinedDocs = await FirebaseFirestore.instance
        .collectionGroup('participants')
        .where('userId', isEqualTo: uid)
        .get();

    final futures = joinedDocs.docs.map((doc) async {
      final parent = doc.reference.parent.parent;
      if (parent == null) return null;
      final tDoc = await parent.get();
      final data = tDoc.data() ?? {};
      final hostUserId = data['hostUserId'] ?? doc.data()['hostUserId'] ?? '';
      if (hostUserId == uid) return null;
      final participantNames = await _loadParticipantNames(parent.id);
      final count = await _fetchParticipantCount(parent.id,
          cachedCount: data['participantCount']);
      final limit = _asInt(data['participantLimit']);
      return TournamentEntry(
        tournamentId: parent.id,
        hostUserId: hostUserId,
        title: (data['title'] ?? '大会ID: ${parent.id}').toString(),
        participantCount: _buildParticipantCountText(limit: limit),
        format: (data['format'] ?? '形式未設定').toString(),
        description: (data['description'] ?? '').toString(),
        participants: participantNames,
        qrPayload: (data['qrPayload'] ?? '').toString(),
        participantLimit: limit,
        participantCountValue: count,
      );
    });

    final list = await Future.wait(futures);
    return list.whereType<TournamentEntry>().toList();
  }

  Future<List<TournamentEntry>> _fetchHostedTournaments(String uid) async {
    Query<Map<String, dynamic>> baseQuery = FirestoreMethod.tournamentsRef
        .where('hostUserId', isEqualTo: uid);

    QuerySnapshot<Map<String, dynamic>> hostedSnap;
    try {
      hostedSnap = await baseQuery
          .orderBy('startAt', descending: false)
          .limit(_tournamentFetchLimit)
          .get();
    } catch (_) {
      hostedSnap = await baseQuery
          .orderBy('updatedAt', descending: true)
          .limit(_tournamentFetchLimit)
          .get();
    }

    final futures = hostedSnap.docs.map((doc) async {
      final data = doc.data();
      final participantNames = await _loadParticipantNames(doc.id);
      final count = await _fetchParticipantCount(
          doc.id, cachedCount: data['participantCount']);
      final limit = _asInt(data['participantLimit']);
      return TournamentEntry(
        tournamentId: doc.id,
        hostUserId: uid,
        title: (data['title'] ?? '大会ID: ${doc.id}').toString(),
        participantCount: _buildParticipantCountText(limit: limit),
        format: (data['format'] ?? '形式未設定').toString(),
        description: (data['description'] ?? '').toString(),
        participants: participantNames,
        qrPayload: (data['qrPayload'] ?? '').toString(),
        participantLimit: limit,
        participantCountValue: count,
      );
    });

    return Future.wait(futures);
  }

  Future<List<String>> _loadParticipantNames(String tournamentId) async {
    try {
      final snap = await FirestoreMethod.tournamentParticipantsRef(tournamentId)
          .orderBy('joinedAt', descending: false)
          .limit(5)
          .get();
      return snap.docs
          .map((d) => (d.data()['displayName'] ?? '').toString())
          .where((name) => name.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<int?> _fetchParticipantCount(String tournamentId,
      {dynamic cachedCount}) async {
    if (cachedCount is int) return cachedCount;
    try {
      final agg = await FirestoreMethod.tournamentParticipantsRef(tournamentId)
          .count()
          .get();
      return agg.count;
    } catch (_) {
      try {
        final snap =
            await FirestoreMethod.tournamentParticipantsRef(tournamentId).get();
        return snap.size;
      } catch (_) {
        return null;
      }
    }
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  String _buildParticipantCountText({int? limit}) {
    final l = limit;
    if (l != null && l > 0) {
      return '定員$l人';
    }
    if (l != null) {
      return '定員$l人';
    }
    return '定員未設定';
  }

  void _listenTournamentChanges() {
    final uid = FirestoreMethod.auth.currentUser?.uid;
    if (uid == null) return;
    _joinedTournamentSub?.cancel();
    _hostedTournamentSub?.cancel();

    _joinedTournamentSub = FirebaseFirestore.instance
        .collectionGroup('participants')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((event) {
      _loadTournamentLists();
    });

    _hostedTournamentSub = FirestoreMethod.tournamentsRef
        .where('hostUserId', isEqualTo: uid)
        .snapshots()
        .listen((event) {
      _loadTournamentLists();
      });
  }

  static const int _tournamentFetchLimit = 50;

  @override
  void initState() {
    super.initState();
    createMatchList();
    _loadTournamentLists();
    _listenTournamentChanges();
    _scrollController = ScrollController();
    // スクロール位置を監視してページネーションを実行
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!_isLoadingMore) {
          _loadMoreData();
        }
      }
    });
  }

  @override
  void dispose() {
    _joinedTournamentSub?.cancel();
    _hostedTournamentSub?.cancel();
    _scrollController.dispose(); // ScrollControllerの解放
    super.dispose();
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore) return;
    if (lastDocument == null) return;
    if (mounted) {
      setState(() {
        _isLoadingMore = true;
        print("loadMoreData");
        print(_isLoadingMore);
      });
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('matchList')
          .where('MATCH_USER_LIST',
              arrayContains: FirestoreMethod.auth.currentUser!.uid)
          .orderBy('SAKUSEI_TIME', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(10)
          .get();

      final futures = querySnapshot.docs.map((doc) async {
        late CprofileSetting yourProfile;
        late CprofileSetting myProfile;
        if (doc
            .data()['RECIPIENT_ID']
            .contains(FirestoreMethod.auth.currentUser!.uid)) {
          yourProfile =
              await FirestoreMethod.getYourProfile(doc.data()['SENDER_ID']);
          myProfile =
              await FirestoreMethod.getYourProfile(doc.data()['RECIPIENT_ID']);
        } else if (doc
            .data()['SENDER_ID']
            .contains(FirestoreMethod.auth.currentUser!.uid)) {
          yourProfile =
              await FirestoreMethod.getYourProfile(doc.data()['RECIPIENT_ID']);
          myProfile =
              await FirestoreMethod.getYourProfile(doc.data()['SENDER_ID']);
        }
        return MatchListModel(
          MATCH_ID: doc.data()['MATCH_ID'],
          RECIPIENT_ID: doc.data()['RECIPIENT_ID'],
          SENDER_ID: doc.data()['SENDER_ID'],
          SAKUSEI_TIME: doc.data()['SAKUSEI_TIME'],
          MATCH_FLG: doc.data()['MATCH_FLG'],
          MY_USER: myProfile,
          YOUR_USER: yourProfile,
        );
      });
      final matchList = await Future.wait(futures);

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;
      }
      if (mounted) {
        setState(() {
          matchListAll.addAll(matchList);
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print(e.toString());
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Widget _withBanner(Widget child) {
    return Stack(
      children: [
        Container(
            alignment: Alignment.center,
            height: 40,
            child: const AdBanner(size: AdSize.banner)),
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: child,
        )
      ],
    );
  }

  Widget _buildPersonalMatchList(double deviceWidth) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
        controller: _scrollController,
        physics: const RangeMaintainingScrollPhysics(),
        shrinkWrap: true,
        reverse: false,
        itemCount: matchListAll.length + 1,
        itemBuilder: (context, index) {
          if (index == matchListAll.length) {
            if (_isLoadingMore) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const SizedBox();
            }
          } else {
            return Slidable(
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (value) async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('本当に削除して宜しいですか'),
                                actions: <Widget>[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor:
                                            Colors.lightGreenAccent),
                                    child: const Text('はい'),
                                    onPressed: () async {
                                      try {
                                        await FirestoreMethod.delMatchList(
                                            matchListAll[index].MATCH_ID);
                                        Navigator.pop(context);
                                        setState(() {
                                          matchListAll.removeAt(index);
                                        });
                                      } catch (e) {
                                        showDialog(
                                            context: context,
                                            builder:
                                                (BuildContext context) =>
                                                    const ShowDialogToDismiss(
                                                      content:
                                                          "マッチングリストの削除に失敗しました",
                                                      buttonText: "はい",
                                                    ));
                                      }
                                    },
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor:
                                            Colors.lightGreenAccent),
                                    child: const Text('いいえ'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      backgroundColor: Colors.red,
                      icon: Icons.delete,
                      label: '削除',
                    ),
                  ],
                ),
                child: InkWell(
                    onTap: () async {
                      bool blockFlg = await FirestoreMethod.isBlock(
                          matchListAll[index].MY_USER.USER_ID,
                          matchListAll[index].YOUR_USER.USER_ID);
                      if (!blockFlg) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                  title: Text('ブロック中のユーザーです',
                                      style: TextStyle(fontSize: 18)),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor:
                                              Colors.lightGreenAccent),
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ]);
                            });
                      } else {
                        try {
                          final matchSnapshot = await FirebaseFirestore.instance
                              .collection('matchList')
                              .doc(matchListAll[index].MATCH_ID)
                              .get();

                          String LOCK_FLG =
                              matchSnapshot.data()?['LOCK_FLG'] ?? "0";
                          String LOCK_USER =
                              matchSnapshot.data()?['LOCK_USER'] ?? '';

                          if (matchSnapshot.exists) {
                            if (LOCK_FLG == '0' ||
                                LOCK_USER ==
                                    FirestoreMethod.auth.currentUser!.uid ||
                                LOCK_USER == '') {
                              await FirebaseFirestore.instance
                                  .collection('matchList')
                                  .doc(matchListAll[index].MATCH_ID)
                                  .set({
                                'LOCK_FLG': '1',
                                'LOCK_USER':
                                    FirestoreMethod.auth.currentUser!.uid,
                              }, SetOptions(merge: true));
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MatchResult(
                                          matchListAll[index].MY_USER,
                                          matchListAll[index].YOUR_USER,
                                          matchListAll[index].MATCH_ID)));
                              final matchDoc = await FirebaseFirestore.instance
                                  .collection('matchList')
                                  .doc(matchListAll[index].MATCH_ID)
                                  .get();

                              if (matchDoc.exists) {
                                await FirebaseFirestore.instance
                                    .collection('matchList')
                                    .doc(matchListAll[index].MATCH_ID)
                                    .set({
                                  'LOCK_FLG': '0',
                                  'LOCK_USER': '',
                                }, SetOptions(merge: true));
                              }
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      const ShowDialogToDismiss(
                                        content: '現在、他のユーザーが登録中です',
                                        buttonText: "はい",
                                      ));
                            }
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    const ShowDialogToDismiss(
                                      content:
                                          'この対戦は既に他ユーザーが登録済。又は削除されています',
                                      buttonText: "はい",
                                    ));
                          }
                        } catch (e) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  const ShowDialogToDismiss(
                                    content: 'エラーが発生しました',
                                    buttonText: "はい",
                                  ));
                        }
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFF43a047).withOpacity(0.35)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            InkWell(
                              child: matchListAll[index]
                                          .YOUR_USER
                                          .PROFILE_IMAGE ==
                                      ''
                                  ? const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage:
                                          AssetImage("images/tenipoikun.png"),
                                      radius: 28,
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(
                                          matchListAll[index]
                                              .YOUR_USER
                                              .PROFILE_IMAGE),
                                      radius: 28),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfileReference(
                                            matchListAll[index]
                                                .YOUR_USER
                                                .USER_ID)));
                              },
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          matchListAll[index]
                                              .YOUR_USER
                                              .NICK_NAME,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.75),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: const [
                                            Icon(Icons.sports_tennis,
                                                size: 14,
                                                color: Colors.black87),
                                            SizedBox(width: 6),
                                            Text(
                                              '対戦予定',
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule,
                                          size: 14, color: Colors.black54),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          matchListAll[index].SAKUSEI_TIME,
                                          style: const TextStyle(
                                              color: Colors.black87),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.75),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 4,
                                  )
                                ],
                              ),
                              child: IconButton(
                                  icon: const Icon(
                                    Icons.message,
                                    color: Colors.black,
                                    size: 26.0,
                                  ),
                                  onPressed: () async {
                                    bool BlockFlg =
                                        await FirestoreMethod.isBlock(
                                            matchListAll[index]
                                                .MY_USER
                                                .USER_ID,
                                            matchListAll[index]
                                                .YOUR_USER
                                                .USER_ID);
                                    if (!BlockFlg) {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                                title: Text('ブロック中のユーザーです',
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                                actions: <Widget>[
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            foregroundColor:
                                                                Colors.black,
                                                            backgroundColor:
                                                                Colors
                                                                    .lightGreenAccent),
                                                    child: const Text('OK'),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ]);
                                          });
                                    } else {
                                      TalkRoomModel room =
                                          await FirestoreMethod.makeRoom(
                                              matchListAll[index]
                                                  .MY_USER
                                                  .USER_ID,
                                              matchListAll[index]
                                                  .YOUR_USER
                                                  .USER_ID);

                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TalkRoom(room)));
                                      await NotificationMethod.unreadCountRest(
                                          matchListAll[index]
                                              .YOUR_USER
                                              .USER_ID);
                                    }
                                  }),
                            )
                          ],
                        ),
                      ),
                    )));
          }
        });
  }

  Widget _buildTournamentList(
      List<TournamentEntry> tournaments, String emptyMessage,
      {required bool isHostList}) {
    if (_isTournamentLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (tournaments.isEmpty) {
      return Center(
          child: Text(
        emptyMessage,
        style: const TextStyle(color: Colors.grey),
      ));
    }
    return ListView.separated(
        padding: const EdgeInsets.only(bottom: 16),
        itemBuilder: (context, index) {
          return _buildTournamentCard(
              context, tournaments[index], isHost: isHostList);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemCount: tournaments.length);
  }

  Widget _buildTournamentCard(BuildContext context, TournamentEntry tournament,
      {required bool isHost}) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TournamentConfirmPage(
                      isHost: isHost,
                      tournamentId: tournament.tournamentId,
                      hostUserId: tournament.hostUserId,
                      title: tournament.title,
                      participantSummary: tournament.participantCount,
                      participantLimit: tournament.participantLimit,
                      participantCountValue: tournament.participantCountValue,
                      format: tournament.format,
                      description: tournament.description,
                      initialParticipants: tournament.participants,
                      qrPayload: tournament.qrPayload.isNotEmpty
                          ? tournament.qrPayload
                          : TournamentQrPayload(
                                  tournamentId: tournament.tournamentId,
                                  hostUserId: tournament.hostUserId)
                              .encode(),
                    )));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: const Color(0xFF43a047).withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tournament.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.black.withOpacity(0.05), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.grid_view,
                            size: 14, color: Colors.black87),
                        const SizedBox(width: 6),
                        Text(
                          tournament.format,
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people,
                            size: 14, color: Colors.black87),
                        const SizedBox(width: 6),
                        Text(
                          tournament.participantCount,
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sports_tennis,
                            size: 14, color: Colors.black87),
                        const SizedBox(width: 6),
                        Text(
                          isHost ? '主催' : '参加',
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tournament.description.isNotEmpty
                            ? tournament.description
                            : '大会内容の記載はありません',
                        style: const TextStyle(
                            color: Colors.black87, height: 1.3),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    //必要コンフィグの初期化
    HeaderConfig().init(context, "予定一覧");
    DrawerConfig().init(context);
    return DefaultTabController(
      length: _tabs.length,
      child: PopScope(
        canPop: false,
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(80.0),
              child: AppBar(
                backgroundColor: HeaderConfig.backGroundColor,
                title: HeaderConfig.appBarText,
                iconTheme: const IconThemeData(color: Colors.black),
                bottom: TabBar(
                  tabs: _tabs,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black,
                  indicatorColor: Colors.black,
                ),
              ),
            ),
            drawer: DrawerConfig.drawer,
            body: TabBarView(children: [
              _withBanner(_buildPersonalMatchList(deviceWidth)),
              _withBanner(_buildTournamentList(
                  joinedTournaments, '参加中の大会はまだありません',
                  isHostList: false)),
              _withBanner(_buildTournamentList(
                  hostedTournaments, '主催中の大会はまだありません',
                  isHostList: true)),
            ])),
      ),
    );
  }
}
