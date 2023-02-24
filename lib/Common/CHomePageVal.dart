import 'package:tsuyosuke_tennis_ap/Common/CSkilLevelSetting.dart';

class CHomePageVal {
  late String NAME;
  late String PROFILEIMAGE;
  late String MYUSERID;
  late String TOROKURANK;
  late int? SRANK;
  late int? ADVANCEDWINRATE;
  late int? MEDIUMWINRATE;
  late int? BEGINWINRATE;
  late CSkilLevelSetting SKILL;

  CHomePageVal(
      {required this.NAME,
        required this.PROFILEIMAGE,
        required this.MYUSERID,
        required this.TOROKURANK,
        this.SRANK,
        this.ADVANCEDWINRATE,
        this.MEDIUMWINRATE,
        this.BEGINWINRATE,
        required this.SKILL
      });
}