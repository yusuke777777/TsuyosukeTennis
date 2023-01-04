import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsuyosuke_tennis_ap/Common/CprofileSetting.dart';
import 'package:tsuyosuke_tennis_ap/Page/bk_ProfileSetting.dart';

class RankModel{
  late int rankNo;
  late CprofileSetting user;
  late int tpPoint;

  RankModel({
    required this.rankNo,required this.user,required this.tpPoint
  });
}