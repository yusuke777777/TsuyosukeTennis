import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsuyosuke_tennis_ap/Common/CprofileSetting.dart';

class RankModel{
  late int rankNo;
  late CprofileSetting user;
  late int tpPoint;

  RankModel({
    required this.rankNo,required this.user,required this.tpPoint
  });
}