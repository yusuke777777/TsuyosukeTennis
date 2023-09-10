/**
 * 対戦成績画面の対戦履歴部分の値を保持するクラス
 */
class CScoreRefHistory{
  late String TITLE;
  late String KOUSHIN_TIME;
  List<dynamic> SCORE_POINT;
  String? FEEDBACK_COMMENT;

  CScoreRefHistory({required this.TITLE, required this.KOUSHIN_TIME,
    required this.SCORE_POINT,
    this.FEEDBACK_COMMENT});
}