import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsuyosuke_tennis_ap/Common/CprofileSetting.dart';
import 'package:tsuyosuke_tennis_ap/Page/bk_ProfileSetting.dart';

class RankModel{
  late String rankNo;
  late CprofileSetting user;
  late int tpPoint;
  late String taishoShu;

  RankModel({
    required this.rankNo,required this.user,required this.tpPoint,required this.taishoShu
  });
}