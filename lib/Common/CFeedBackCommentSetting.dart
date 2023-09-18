import 'CHomePageVal.dart';

/**
 * スキルレベルの星数と評価相手の情報をもつクラスです
 */
class CFeedBackCommentSetting{
  String? OPPONENT_ID;
  String? OPPONENT_NAME;
  String? OPPONENT_IMAGE;
  String? FEED_BACK;
  String? DATE_TIME;
  String? MATCH_TITLE;

  CFeedBackCommentSetting({this.OPPONENT_ID, this.OPPONENT_NAME,this.OPPONENT_IMAGE,this.FEED_BACK, this.DATE_TIME, this.MATCH_TITLE});
}