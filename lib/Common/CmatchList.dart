import 'package:tsuyosuke_tennis_ap/Common/CprofileSetting.dart';

class MatchListModel{
  late String MATCH_ID;
  late String RECIPIENT_ID;
  late String SENDER_ID;
  late String SAKUSEI_YMD;
  late String MATCH_FLG;
  late CprofileSetting user;

  MatchListModel({
    required this.MATCH_ID,required this.RECIPIENT_ID,required this.SENDER_ID,required this.SAKUSEI_YMD,required this.MATCH_FLG,required this.user
  });
}