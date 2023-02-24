/**
 * スキルレベルの星数と評価相手の情報をもつクラスです
 */
class CSkilLevelSetting{
  String? OPPONENT_ID;
  late double SERVE_1ST;
  late double SERVE_2ND;
  late double STROKE_BACKHAND;
  late double STROKE_FOREHAND;
  late double VOLLEY_BACKHAND;
  late double VOLLEY_FOREHAND;

  CSkilLevelSetting({this.OPPONENT_ID,
    required this.SERVE_1ST,
    required this.SERVE_2ND,
    required this.STROKE_BACKHAND,
    required this.STROKE_FOREHAND,
    required this.VOLLEY_BACKHAND,
    required this.VOLLEY_FOREHAND});
}