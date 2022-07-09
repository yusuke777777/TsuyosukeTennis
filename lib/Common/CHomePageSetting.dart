import 'package:flutter/cupertino.dart';

import 'CactivityList.dart';

class CHomePageSetting{

  late String NICK_NAME;
  final String? TOROKU_RANK;

  CHomePageSetting(
      {
        Key? key,
        required this.NICK_NAME,
        this.TOROKU_RANK});
}