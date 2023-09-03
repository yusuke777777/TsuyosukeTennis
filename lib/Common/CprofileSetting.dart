import 'CactivityList.dart';

class CprofileSetting{
  late String USER_ID;
  late String PROFILE_IMAGE;
  late String NICK_NAME;
  late String TOROKU_RANK;
  late List<CativityList> activityList;
  late String AGE;
  late String GENDER;
  late String COMENT;
  late String MY_USER_ID;
  Map<String, dynamic>? TITLE;

  CprofileSetting({required this.USER_ID,required this.PROFILE_IMAGE,required this.NICK_NAME,required this.TOROKU_RANK,required this.activityList,required this.AGE,required this.GENDER,required this.COMENT,required this.MY_USER_ID,this.TITLE});
}