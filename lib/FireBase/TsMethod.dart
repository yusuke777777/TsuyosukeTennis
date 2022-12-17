class FirestoreMethod {
  static int tsPointCalculation(
      String myLevel, String yourLevel, int myRank, int yourRank) {
    int tsPoint = 0;
    int NormalTsPoint = 0;
    int RankTsPoint = 0;
    //通常ポイント算出
    switch (myLevel) {
      case '初級':
        switch (yourLevel) {
          case '初級':
            NormalTsPoint = 10;
            break;
          case '中級':
            NormalTsPoint = 20;
            break;
          case '上級':
            NormalTsPoint = 30;
            break;
        }
        break;
      case '中級':
        switch (yourLevel) {
          case '初級':
            NormalTsPoint = 5;
            break;
          case '中級':
            NormalTsPoint = 10;
            break;
          case '上級':
            NormalTsPoint = 15;
            break;
        }
        break;
      case '上級':
        switch (yourLevel) {
          case '初級':
            NormalTsPoint = 3;
            break;
          case '中級':
            NormalTsPoint = 7;
            break;
          case '上級':
            NormalTsPoint = 10;
            break;
        }
        break;
    }

    //ランキングボーナスポイント
    if (myRank == 0 || yourRank == 0) {
      RankTsPoint = 0;
    } else {
      //自分のランキングより上の相手に勝利した場合、10ポイント
      if (yourRank > myRank) {
        RankTsPoint = RankTsPoint + 10;
      }
      //自分のランキングより2倍以上、上の相手に勝利した場合、50ポイント
      int rankRate = (myRank / yourRank).floor();
      if (rankRate >= 2) {
        RankTsPoint = RankTsPoint + 50;
      }
      //TOP10以上の相手に勝利した場合は100ポイント
      if (yourRank > 0 && yourRank <= 10) {
        RankTsPoint = RankTsPoint + 100;
      }
    }
    return tsPoint;
  }
}
