import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui; // dart:ui を alias で指定

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tsuyosuke_tennis_ap/Common/CSkilLevelSetting.dart';
import '../Common/CmatchResult.dart';
import '../Common/CprofileSetting.dart';
import '../PropSetCofig.dart';

class MatchResultSansho extends StatefulWidget {
  late CprofileSetting myProfile;
  late CprofileSetting yourProfile;
  late List<CmatchResult> matchResultList;
  String? feedBackMessage;
  late CSkilLevelSetting SkillLevel;
  late String matchTitle;
  String? shereScreenFlg ="0";

  MatchResultSansho(this.myProfile, this.yourProfile, this.matchResultList,
      this.feedBackMessage, this.SkillLevel, this.matchTitle,{this.shereScreenFlg = "0"});

  @override
  _MatchResultSanshoState createState() => _MatchResultSanshoState();
}

class _MatchResultSanshoState extends State<MatchResultSansho> {
  @override
  void dispose() {
    super.dispose(); // 親クラスのdisposeを呼び出す
  }

  @override
  void initState() {
    super.initState();

    // 画面が描画された後にダイアログを表示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(widget.shereScreenFlg=="1"){
        _showShareDialog();
      }
    });
  }

  //スクリーンショットを撮るウィジェットを選択するためのグローバル変数
  //得点・スキル・フィードバック全て
  final GlobalKey _allScreen_globalKey = GlobalKey();

  //得点のみ
  final GlobalKey _scoreScreen_globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "対戦結果参照");
    final deviceWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          appBar: AppBar(
              backgroundColor: HeaderConfig.backGroundColor,
              title: HeaderConfig.appBarText,
              iconTheme: const IconThemeData(color: Colors.black),
              leading: HeaderConfig.backIcon,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.share,
                    color: Colors.black,
                    size: 40.0,
                  ),
                  onPressed: _showShareDialog,
                )
              ]),
          body: RepaintBoundary(
            key: _allScreen_globalKey, //X投稿用のスクリーンショット(All)保存
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RepaintBoundary(
                        key: _scoreScreen_globalKey, //X投稿用のスクリーンショット(Score)保存
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 80,
                              ),
                              Center(
                                child: Container(
                                  alignment: Alignment.center,
                                  width: deviceWidth * 0.8,
                                  height: 100,
                                  child: Text(
                                    widget.matchTitle,
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(right: 10),
                                    width: deviceWidth * 0.3,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          width: deviceWidth * 0.3,
                                          child: widget.myProfile
                                                      .PROFILE_IMAGE ==
                                                  ''
                                              ? const CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  backgroundImage: AssetImage(
                                                      "images/tenipoikun.png"),
                                                  radius: 30,
                                                )
                                              : CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  backgroundImage: NetworkImage(
                                                      widget.myProfile
                                                          .PROFILE_IMAGE),
                                                  radius: 30,
                                                ),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          width: deviceWidth * 0.3,
                                          child: FittedBox(
                                            alignment: Alignment.bottomCenter,
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              widget.myProfile.NICK_NAME,
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: widget.matchResultList
                                        .map((matchResult) => Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: deviceWidth * 0.12,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.grey),
                                                      ),
                                                      child: Text(
                                                        '${matchResult.myGamePoint}',
                                                        style: const TextStyle(
                                                            fontSize: 20,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: deviceWidth * 0.1,
                                                      child: const Center(
                                                        child: Text(
                                                          "-",
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: deviceWidth * 0.12,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.grey),
                                                      ),
                                                      child: Text(
                                                        '${matchResult.yourGamePoint}',
                                                        style: const TextStyle(
                                                            fontSize: 20,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ))
                                        .toList(),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(left: 10),
                                    width: deviceWidth * 0.3,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          width: deviceWidth * 0.3,
                                          child: widget.yourProfile
                                                      .PROFILE_IMAGE ==
                                                  ''
                                              ? const CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  backgroundImage: AssetImage(
                                                      "images/tenipoikun.png"),
                                                  radius: 30,
                                                )
                                              : CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  backgroundImage: NetworkImage(
                                                      widget.yourProfile
                                                          .PROFILE_IMAGE),
                                                  radius: 30,
                                                ),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          width: deviceWidth * 0.3,
                                          child: FittedBox(
                                            alignment: Alignment.bottomCenter,
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              widget.yourProfile.NICK_NAME,
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ]),
                      ),
                      //レビュー集計機能
                      Column(
                        children: [
                          const Text('------------------------',
                              style: TextStyle(fontSize: 20)),
                          const SizedBox(
                            height: 20,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('ストローク', style: TextStyle(fontSize: 20)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('フォア：',
                                  style: TextStyle(fontSize: 20)),
                              RatingBar.builder(
                                ignoreGestures: true,
                                allowHalfRating: true,
                                initialRating:
                                    widget.SkillLevel.STROKE_FOREHAND.isNaN
                                        ? 0
                                        : widget.SkillLevel.STROKE_FOREHAND,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                ),
                                onRatingUpdate: (rating) {
                                  //評価が更新されたときの処理を書く
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('バック：',
                                  style: TextStyle(fontSize: 20)),
                              RatingBar.builder(
                                ignoreGestures: true,
                                allowHalfRating: true,
                                initialRating:
                                    widget.SkillLevel.STROKE_BACKHAND.isNaN
                                        ? 0
                                        : widget.SkillLevel.STROKE_BACKHAND,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                ),
                                onRatingUpdate: (rating) {
                                  //評価が更新されたときの処理を書く
                                },
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          //ボレー
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('ボレー', style: TextStyle(fontSize: 20)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('フォア：',
                                  style: TextStyle(fontSize: 20)),
                              RatingBar.builder(
                                ignoreGestures: true,
                                allowHalfRating: true,
                                initialRating:
                                    widget.SkillLevel.VOLLEY_FOREHAND.isNaN
                                        ? 0
                                        : widget.SkillLevel.VOLLEY_FOREHAND,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                ),
                                onRatingUpdate: (rating) {
                                  //評価が更新されたときの処理を書く
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('バック：',
                                  style: TextStyle(fontSize: 20)),
                              RatingBar.builder(
                                ignoreGestures: true,
                                allowHalfRating: true,
                                initialRating:
                                    widget.SkillLevel.VOLLEY_BACKHAND.isNaN
                                        ? 0
                                        : widget.SkillLevel.VOLLEY_BACKHAND,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                ),
                                onRatingUpdate: (rating) {
                                  //評価が更新されたときの処理を書く
                                },
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 20,
                          ),
                          //サーブ
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('サーブ', style: TextStyle(fontSize: 20)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('１ｓｔ：',
                                  style: TextStyle(fontSize: 20)),
                              RatingBar.builder(
                                ignoreGestures: true,
                                allowHalfRating: true,
                                initialRating: widget.SkillLevel.SERVE_1ST.isNaN
                                    ? 0
                                    : widget.SkillLevel.SERVE_1ST,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                ),
                                onRatingUpdate: (rating) {
                                  //評価が更新されたときの処理を書く
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('２ｎｄ：',
                                  style: TextStyle(fontSize: 20)),
                              RatingBar.builder(
                                ignoreGestures: true,
                                allowHalfRating: true,
                                initialRating: widget.SkillLevel.SERVE_2ND.isNaN
                                    ? 0
                                    : widget.SkillLevel.SERVE_2ND,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                ),
                                onRatingUpdate: (rating) {
                                  //評価が更新されたときの処理を書く
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: const Text('感想・フィードバック',
                            style: TextStyle(fontSize: 20)),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        color: Colors.white,
                        width: deviceWidth * 0.8,
                        height: 100,
                        child: SingleChildScrollView(
                          child: Text(
                            widget.feedBackMessage ?? "",
                            textAlign: TextAlign.start,
                            softWrap: true,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ]),
              ),
            ),
          )),
    );
  }

  // スクリーンショットを撮る関数
  Future<File?> _capturePng(GlobalKey globalKey) async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // `ui.ByteData` を使用する
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        print("Error: Failed to convert image to ByteData.");
        return null;
      }

      Uint8List pngBytes = byteData?.buffer.asUint8List() ?? Uint8List(0);

      // 画像を保存
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/match_result.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      return file;
    } catch (e) {
      print("Error capturing screenshot: $e");
      return null;
    }
  }

  // 画像をXに共有
  Future<void> _shareOnX(GlobalKey globalKey) async {
    File? imageFile = await _capturePng(globalKey);
    if (imageFile != null) {
      await Share.shareXFiles([XFile(imageFile.path)],
          text: "試合結果をシェアしました！ 🎾");
    }
  }


  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("SNSで試合結果を共有しよう！"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("どの情報を共有しますか？"),
              SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.lightGreenAccent,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await _shareOnX(_scoreScreen_globalKey);
                },
                icon: Icon(Icons.sports_tennis),
                label: Text("スコアのみ共有"),
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.lightGreenAccent,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await _shareOnX(_allScreen_globalKey);
                },
                icon: Icon(Icons.share),
                label: Text("表示画面すべて共有"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("後で"),
            ),
          ],
        );
      },
    );

  }
}
