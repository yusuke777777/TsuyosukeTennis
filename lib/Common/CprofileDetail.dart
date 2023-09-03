import 'dart:convert';

class CprofileDetail {
  late String USER_ID;
  late String PROFILE_IMAGE;
  late String NICK_NAME;
  late String TOROKU_RANK;
  late String AGE;
  late String GENDER;
  late String COMENT;
  late String KOUSHIN_TIME;
  late String MY_USER_ID;
  late List<dynamic> TODOFUKEN_LIST;
  late List<dynamic> SHICHOSON_LIST;
  late List<dynamic> TODOFUKEN_SHICHOSON_LIST;
  late String FIRST_TODOFUKEN_SICHOSON;
  late int TS_POINT;
  late int SHOKYU_WIN_SU;
  late int SHOKYU_LOSE_SU;
  late int SHOKYU_MATCH_SU;
  late int SHOKYU_WIN_RATE;
  late int CHUKYU_WIN_SU;
  late int CHUKYU_LOSE_SU;
  late int CHUKYU_MATCH_SU;
  late int CHUKYU_WIN_RATE;
  late int JYOKYU_WIN_SU;
  late int JYOKYU_LOSE_SU;
  late int JYOKYU_MATCH_SU;
  late int JYOKYU_WIN_RATE;
  late double STROKE_FOREHAND_AVE;
  late double STROKE_BACKHAND_AVE;
  late double VOLLEY_FOREHAND_AVE;
  late double VOLLEY_BACKHAND_AVE;
  late double SERVE_1ST_AVE;
  late double SERVE_2ND_AVE;
  late int RANK_NO;

  CprofileDetail(
      {required this.USER_ID,
      required this.PROFILE_IMAGE,
      required this.NICK_NAME,
      required this.TOROKU_RANK,
      required this.AGE,
      required this.GENDER,
      required this.COMENT,
      required this.MY_USER_ID,
      required this.TODOFUKEN_LIST,
      required this.SHICHOSON_LIST,
      required this.TODOFUKEN_SHICHOSON_LIST,
      required this.TS_POINT,
      required this.SHOKYU_WIN_SU,
      required this.SHOKYU_LOSE_SU,
      required this.SHOKYU_MATCH_SU,
      required this.SHOKYU_WIN_RATE,
      required this.CHUKYU_WIN_SU,
      required this.CHUKYU_LOSE_SU,
      required this.CHUKYU_MATCH_SU,
      required this.CHUKYU_WIN_RATE,
      required this.JYOKYU_WIN_SU,
      required this.JYOKYU_LOSE_SU,
      required this.JYOKYU_MATCH_SU,
      required this.JYOKYU_WIN_RATE,
      required this.STROKE_FOREHAND_AVE,
      required this.STROKE_BACKHAND_AVE,
      required this.VOLLEY_FOREHAND_AVE,
      required this.VOLLEY_BACKHAND_AVE,
      required this.SERVE_1ST_AVE,
      required this.SERVE_2ND_AVE,
      required this.FIRST_TODOFUKEN_SICHOSON,
      required this.KOUSHIN_TIME,required this.RANK_NO});
}
