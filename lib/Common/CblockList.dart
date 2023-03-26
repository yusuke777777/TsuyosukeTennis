import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsuyosuke_tennis_ap/Common/CprofileSetting.dart';

class BlockListModel{
  late String BLOCK_USER_ID;
  late CprofileSetting YOUR_USER;

  BlockListModel({
    required this.BLOCK_USER_ID,required this.YOUR_USER});
}