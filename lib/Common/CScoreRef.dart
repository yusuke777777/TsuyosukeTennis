import 'CScoreRefHistory.dart';

class CScoreRef{
  late int MATCH_COUNT;
  late int WIN_COUNT;
  late int LOSE_COUNT;
  late int WIN_LATE;
  late List<CScoreRefHistory> HISTORYLIST;
  late List<String> TITLE;

  CScoreRef({required this.MATCH_COUNT,
    required this.WIN_COUNT,
    required this.LOSE_COUNT,
    required this.WIN_LATE,
    required this.HISTORYLIST,
    required this.TITLE,
  });

}