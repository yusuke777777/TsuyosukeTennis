import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import '../Common/CTitle.dart';
import '../Common/CactivityList.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import '../Common/CprofileSetting.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/ProfileImage.dart';
import '../FireBase/userTicketMgmt.dart';
import '../PropSetCofig.dart';
import '../UnderMenuMove.dart';

class ProfileSetting extends StatefulWidget {
  late CprofileSetting myProfile;
  String koushinFlg = '0';
  late String myUserId;

  ProfileSetting.Edit(CprofileSetting myProfileWork) {
    myProfile = myProfileWork;
    koushinFlg = '1';
  }

  ProfileSetting.Make() {
    List<CativityList> activityList = [];
    myProfile = CprofileSetting(
      USER_ID: '',
      PROFILE_IMAGE: '',
      NICK_NAME: '',
      TOROKU_RANK: '',
      activityList: activityList,
      AGE: '',
      GENDER: '',
      COMENT: '',
      MY_USER_ID: '',
      TITLE: {},
    );
  }

  @override
  _ProfileSettingState createState() => _ProfileSettingState(myProfile);
}

/**
 * Title.yamlに記載されている称号を全て取得
 */
Future<void> getMyInitTitle(Map<String, dynamic> myTitleMap) async {
  final String yamlString = await rootBundle.loadString('assets/Title.yaml');
  final List<dynamic> yamlList = loadYaml(yamlString);

    for (var item in yamlList) {
      String no = item['no'].toString();
      myTitleMap?[no] = '0';
    }
}

class _ProfileSettingState extends State<ProfileSetting> {
  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;

  //ニックネーム
  late TextEditingController nickName = TextEditingController();

  //ユーザーID
  late TextEditingController inputUserID = TextEditingController();

  //プロフィール画像  画像を登録できるようにする
  String profileImage = '';

  //登録ランク
  String torokuRank = "中級";

  //性別
  String gender = "男性";

  late String myUserId;

  Map<String, dynamic> myTitleMap = {};

  //市区町村
  TextEditingController curShichoson = TextEditingController();

  //アクティビィリスト
  List<CativityList> activityList = [
    CativityList(
      No: "0",
      TODOFUKEN: "東京都",
      SHICHOSON: TextEditingController(),
    ),
  ];

  //都道府県登録数Index
  int todofukenTourokuNo = 0;

  //現在登録中の登録No
  int curTourokuNo = 0;

  //年齢
  String age = "20代";

  //コメント
  TextEditingController coment = TextEditingController();

  CprofileSetting myProfile;

  _ProfileSettingState(this.myProfile);

  // List<Widget> contentWidgets = [];

  @override
  void initState() {
    super.initState();
    String koushinFlg = widget.koushinFlg;

    //ニックネーム
    if (koushinFlg == "1") {
      nickName = TextEditingController(text: widget.myProfile.NICK_NAME);
    }

    //ニックネーム
    if (koushinFlg == "1") {
      inputUserID = TextEditingController(text: widget.myProfile.MY_USER_ID);
    }

    //プロフィール画像  画像を登録できるようにする
    if (koushinFlg == "1") {
      profileImage = widget.myProfile.PROFILE_IMAGE;
    }

    //登録ランク
    if (koushinFlg == "1") {
      torokuRank = widget.myProfile.TOROKU_RANK;
    }
    //年齢
    if (koushinFlg == "1") {
      age = widget.myProfile.AGE;
    }
    //性別
    if (koushinFlg == "1") {
      gender = widget.myProfile.GENDER;
    }
    //コメント
    if (koushinFlg == "1") {
      coment = TextEditingController(text: widget.myProfile.COMENT);
    }

    //アクティビティリスト
    if (koushinFlg == "1") {
      activityList = widget.myProfile.activityList;
    }

    //都道府県登録数Index更新
    if (koushinFlg == "1") {
      todofukenTourokuNo = widget.myProfile.activityList.length;
      todofukenTourokuNo = todofukenTourokuNo - 1;
    }

    //アクティビティリスト
    if (koushinFlg == "1") {
      myUserId = widget.myProfile.MY_USER_ID;
    }

    if (koushinFlg == "1") {
      myTitleMap = widget.myProfile.TITLE!;
    }
  }

  bool isDoubleUser = false;

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    HeaderConfig().init(context, "プロフィール設定");
    if (widget.koushinFlg == '0') {
      getMyInitTitle(myTitleMap);
    }
    return Scaffold(
          appBar: AppBar(
            title: HeaderConfig.appBarText,
            leading: widget.koushinFlg == '1'
                ? IconButton(
                    icon: const Icon(
                      Icons.reply,
                      color: Colors.black,
                      size: 40.0,
                    ),
                    onPressed: () => {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UnderMenuMove.make(0),
                        ),
                      )
                    },
                  )
                : null,
            elevation: 0.0,
            backgroundColor: HeaderConfig.backGroundColor,
            shadowColor: Colors.white,
          ),
          body: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Column(children: [
                        SizedBox(
                          height: 30,
                        ),
                        InkWell(
                            child: ClipOval(
                                child: Container(
                                    child: profileImage == ""
                                        ? Image.asset(
                                            'images/upper_body-2.png',
                                            height: 100,
                                            width: 100,
                                          )
                                        : Image.network(
                                            profileImage,
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          ))),
                            onTap: () async {
                              Future result = Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfileImage.image(
                                          profileImage, "1")));
                              profileImage = await result;
                              setState(() {});
                            }),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          width: deviceWidth * 0.8,
                          height: 50,
                          child: TextFormField(
                            controller: nickName,
                            decoration: InputDecoration(
                                labelText: '名前',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                fillColor: Colors.white,
                                filled: true),
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10)
                            ],
                          ),
                        ),

                        //ユーザID登録
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          width: deviceWidth * 0.8,
                          height: 50,
                          child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                //日本語入力禁止
                                  RegExp('[\u3040-\u309F]')),
                              LengthLimitingTextInputFormatter(20)
                            ],
                            controller: inputUserID,
                            decoration: InputDecoration(
                                labelText: 'ユーザーID',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                                fillColor: Colors.white,
                                filled: true),
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),

                      ]),
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                              Container(
                                padding: const EdgeInsets.all(5.0),
                                width: deviceWidth * 0.8,
                                child: Text(
                                  '●登録ランク',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5.0),
                                width: deviceWidth * 0.65,
                                height: 40,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  torokuRank,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                              Container(
                                width: deviceWidth * 0.1,
                                child: IconButton(
                                  icon:
                                      Icon(Icons.arrow_drop_down_circle_rounded),
                                  onPressed: () {
                                    _showModalRankPicker(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ]),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    SizedBox(
                      height: 30,
                    ),
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          width: deviceWidth * 0.8,
                          child: Text(
                            '●主な活動場所',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8),
                        // ②配列のデータ数分カード表示を行う
                        itemCount: activityList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                  Container(
                                    width: deviceWidth * 0.75,
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      '都道府県',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black),
                                    ),
                                  ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5.0),
                                    width: deviceWidth * 0.65,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Text(
                                      '${activityList[index].TODOFUKEN}',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black),
                                    ),
                                  ),
                                  Container(
                                    width: deviceWidth * 0.1,
                                    child: IconButton(
                                      icon: Icon(
                                          Icons.arrow_drop_down_circle_rounded),
                                      onPressed: () {
                                        _showModalLocationPicker(
                                            context,
                                            int.parse(activityList[index].No),
                                            activityList[index].SHICHOSON);
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                                  Container(
                                    width: deviceWidth * 0.75,
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      '市区町村',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black),
                                    ),
                                  ),
                                  Container(
                                      padding: const EdgeInsets.all(5.0),
                                      width: deviceWidth * 0.75,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: TextField(
                                        decoration: InputDecoration.collapsed(
                                            border: InputBorder.none,
                                            hintText: ''),
                                        controller:
                                            activityList[index].SHICHOSON,
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      ))
                            ],
                          );
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            //登録Noを更新
                            todofukenTourokuNo = todofukenTourokuNo + 1;
                            //都道府県ウィジェット追加
                            // _makeWidgets(todofukenTourokuNo);
                            if(todofukenTourokuNo <=4 ) {
                              activityListAdd(todofukenTourokuNo.toString());
                              setState(() {});
                            }else{
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('都道府県の設定は5つまで可能です'),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary:
                                              Colors.lightGreenAccent,
                                              onPrimary: Colors.black),
                                          child: Text('OK'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            }
                          },
                        ),
                        SizedBox(
                          width: 40,
                        ),
                      ],
                    ),
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          width: deviceWidth * 0.8,
                          child: Text(
                            '●年齢',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          width: deviceWidth * 0.65,
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            age,
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                        Container(
                          width: deviceWidth * 0.1,
                          child: IconButton(
                            icon: Icon(Icons.arrow_drop_down_circle_rounded),
                            onPressed: () {
                              _showModalAgePicker(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          width: deviceWidth * 0.8,
                          child: Text(
                            '●性別',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          width: deviceWidth * 0.65,
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            gender,
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                        Container(
                          width: deviceWidth * 0.1,
                          child: IconButton(
                            icon: Icon(Icons.arrow_drop_down_circle_rounded),
                            onPressed: () {
                              _showModalGenderPicker(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          width: deviceWidth * 0.8,
                          child: Text(
                            '●コメント',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          width: deviceWidth * 0.8,
                          height: 150,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: TextField(
                            maxLines: 20,
                            decoration: InputDecoration.collapsed(
                                border: InputBorder.none, hintText: ''),
                            controller: coment,
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                        Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 40),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.lightGreenAccent,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                              ),
                            ),
                            child: Text(
                              "登録",
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () async {
                              myProfile.USER_ID = auth.currentUser!.uid;
                              myProfile.PROFILE_IMAGE = profileImage;
                              myProfile.NICK_NAME = nickName.text;
                              myProfile.MY_USER_ID = inputUserID.text;
                              myProfile.TOROKU_RANK = torokuRank;
                              myProfile.activityList = activityList;
                              myProfile.AGE = age;
                              myProfile.GENDER = gender;
                              myProfile.COMENT = coment.text;
                              myProfile.TITLE = myTitleMap;
                              //必須入力項目のチェック
                              if (nickName.text.isNotEmpty && inputUserID.text.isNotEmpty) {
                                print(nickName.text);
                                print(inputUserID.text);
                                bool isDoubleMyUserId = await FirestoreMethod.checkDoubleMyUserID(inputUserID.text, isDoubleUser);
                                //ユーザーIDの重複確認
                                if (isDoubleMyUserId) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('このユーザーIDは既に使用されています'),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary: Colors.lightGreenAccent,
                                                  onPrimary: Colors.black),
                                              child: Text('OK'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                }
                                else if (inputUserID.text.length < 5 || inputUserID.text.length > 20) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('ユーザーIDは5文字以上20文字以内です'),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary: Colors.lightGreenAccent,
                                                  onPrimary: Colors.black),
                                              child: Text('OK'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                }
                                else {
                                  try{
                                    await FirestoreMethod.makeProfile(myProfile);
                                    await FirestoreMethod.makeProfileDetail(myProfile,widget.koushinFlg);
                                    await FirestoreMethod.putReviewFeatureEnabled(true);
                                    if(widget.koushinFlg == 0){
                                      //新規ユーザー情報の登録時にチケット発行する
                                      await makeTicket(auth.currentUser!.uid);
                                    }
                                  }catch(e){
                                    print("XXXXXXここでエラーに対する処理を入れるXXXXXX");
                                  }
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UnderMenuMove.make(0),
                                    ),
                                  );
                                }
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('必須項目を入力してください'),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.lightGreenAccent,
                                                onPrimary: Colors.black),
                                            child: Text('OK'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              }
                            },
                          ),
                        ),
                  ]),
            ),
          ));
  }

  void _showModalRankPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: CupertinoPicker(
              itemExtent: 40,
              children: _Rank.map(_pickerItem).toList(),
              onSelectedItemChanged: _onSelectedRankChanged,
            ),
          ),
        );
      },
    );
  }

  void _showModalLocationPicker(
      BuildContext context, int No, TextEditingController shichoson) {
    curTourokuNo = No;
    curShichoson = shichoson;
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: CupertinoPicker(
              itemExtent: 40,
              children: _Location.map(_pickerItem).toList(),
              onSelectedItemChanged: _onSelectedLocationChanged,
            ),
          ),
        );
      },
    );
  }

  final List<String> _Location = [
    "",
    "北海道",
    "青森県",
    "岩手県",
    "宮城県",
    "秋田県",
    "山形県",
    "福島県",
    "茨城県",
    "栃木県",
    "群馬県",
    "埼玉県",
    "千葉県",
    "東京都",
    "神奈川県",
    "新潟県",
    "富山県",
    "石川県",
    "福井県",
    "山梨県",
    "長野県",
    "岐阜県",
    "静岡県",
    "愛知県",
    "三重県",
    "滋賀県",
    "京都府",
    "大阪府",
    "兵庫県",
    "奈良県",
    "和歌山県",
    "鳥取県",
    "島根県",
    "岡山県",
    "広島県",
    "山口県",
    "徳島県",
    "香川県",
    "愛媛県",
    "高知県",
    "福岡県",
    "佐賀県",
    "長崎県",
    "熊本県",
    "大分県",
    "宮崎県",
    "鹿児島県",
    "沖縄県",
  ];
  final List<String> _Rank = [
    "初級",
    "中級",
    "上級",
  ];

  final List<String> _Age = [
    "10代",
    "20代",
    "30代",
    "40代",
    "50代",
    "60代",
    "70代",
    "80代",
    "90代"
  ];

  final List<String> _Gender = [
    "男性",
    "女性",
  ];

  void _showModalAgePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: CupertinoPicker(
              itemExtent: 40,
              children: _Age.map(_pickerItem).toList(),
              onSelectedItemChanged: _onSelectedAgeChanged,
            ),
          ),
        );
      },
    );
  }

  void _showModalGenderPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: CupertinoPicker(
              itemExtent: 40,
              children: _Gender.map(_pickerItem).toList(),
              onSelectedItemChanged: _onSelectedGenderChanged,
            ),
          ),
        );
      },
    );
  }

  Widget _pickerItem(String str) {
    return Text(
      str,
      style: const TextStyle(fontSize: 20),
    );
  }

  void _onSelectedLocationChanged(int index) {
    activityList[curTourokuNo] = CativityList(
      No: curTourokuNo.toString(),
      TODOFUKEN: _Location[index],
      SHICHOSON: curShichoson,
    );
    setState(() {});
  }

  void _onSelectedRankChanged(int index) {
    setState(() {
      torokuRank = _Rank[index];
    });
  }

  void _onSelectedAgeChanged(int index) {
    setState(() {
      age = _Age[index];
    });
  }

  void _onSelectedGenderChanged(int index) {
    setState(() {
      gender = _Gender[index];
    });
  }

  activityListAdd(String No) {
    activityList.add(
      CativityList(
        No: No,
        TODOFUKEN: "",
        SHICHOSON: TextEditingController(),
      ),
    );
  }

// List<Widget> _makeWidgets(int todofukenTourokuNoWk) {
//   contentWidgets.add(
//     Column(
//       children: [
//         Row(
//           children: [
//             SizedBox(
//               width: 50,
//             ),
//             Container(
//               child: Text(
//                 '都道府県',
//                 style: TextStyle(fontSize: 20, color: Colors.black),
//               ),
//             ),
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: 50,
//             ),
//             Container(
//               padding: const EdgeInsets.all(5.0),
//               width: 250,
//               height: 40,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//               ),
//               child: Text(
//                 ${todofuken + todofukenTourokuNoWk.toString()},
//                 style: TextStyle(fontSize: 20, color: Colors.black),
//               ),
//             ),
//             IconButton(
//               icon: Icon(Icons.arrow_drop_down_circle_rounded),
//               onPressed: () {
//                 _showModalLocationPicker(context);
//                 setState(() {});
//               },
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             SizedBox(
//               width: 50,
//             ),
//             Container(
//               child: Text(
//                 '市区町村',
//                 style: TextStyle(fontSize: 20, color: Colors.black),
//               ),
//             ),
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: 50,
//             ),
//             Container(
//                 padding: const EdgeInsets.all(5.0),
//                 width: 250,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                 ),
//                 child: TextField(
//                   controller: shichoson,
//                   style: TextStyle(fontSize: 20, color: Colors.black),
//                 ))
//           ],
//         ),
//       ],
//     ),
//   );
//   return contentWidgets;
// }
}
