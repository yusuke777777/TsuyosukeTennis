import 'CHomePageVal.dart';

/**
 * スキルレベルの星数と評価相手の情報をもつクラスです
 */
class CFeedBackCommentSetting{
  String? OPPONENT_ID;
  String? FEED_BACK;
  String? DATE_TIME;
  String? MATCH_TITLE;
  CHomePageVal? HOME;
  CFeedBackCommentSetting({this.OPPONENT_ID, this.FEED_BACK, this.DATE_TIME, this.MATCH_TITLE,this.HOME});
}