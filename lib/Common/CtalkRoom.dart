import 'package:tsuyosuke_tennis_ap/Common/CprofileSetting.dart';

class TalkRoomModel{
  late String roomId;
  late CprofileSetting user;
  late String lastMessage;
  late int unReadCnt;

  TalkRoomModel({
    required this.roomId,required this.user,required this.lastMessage,required this.unReadCnt
  });
}