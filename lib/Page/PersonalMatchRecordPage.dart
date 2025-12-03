import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Common/CmatchResult.dart';
import '../Common/CprofileSetting.dart';
import '../Component/native_dialog.dart';
import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';

class PersonalMatchRecordPage extends StatefulWidget {
  const PersonalMatchRecordPage({Key? key}) : super(key: key);

  @override
  State<PersonalMatchRecordPage> createState() =>
      _PersonalMatchRecordPageState();
}

class _PersonalMatchRecordPageState extends State<PersonalMatchRecordPage> {
  List<CmatchResult> matchResultList = [
    CmatchResult(No: "0", myGamePoint: 0, yourGamePoint: 0)
  ];
  int curTourokuNo = 0;
  int myGamePoint = 0;
  int yourGamePoint = 0;

  final inputTitle = TextEditingController();
  final opponentNameController = TextEditingController(text: "対戦相手");
  final memoController = TextEditingController();

  CprofileSetting? myProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    inputTitle.dispose();
    opponentNameController.dispose();
    memoController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await FirestoreMethod.getProfile();
      if (!mounted) return;
      setState(() {
        myProfile = profile;
        _isLoadingProfile = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "個人で記録");
    final deviceWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: HeaderConfig.backGroundColor,
          title: HeaderConfig.appBarText,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: HeaderConfig.backIcon,
        ),
        body: _isLoadingProfile
            ? const Center(child: CircularProgressIndicator())
            : Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            alignment: Alignment.center,
                            width: deviceWidth * 0.8,
                            height: 100,
                            child: TextField(
                              cursorColor: Colors.green,
                              decoration: const InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  labelText: "タイトル",
                                  labelStyle: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                  hintText: "（例）◯◯市民大会の1回戦"),
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.black),
                              controller: inputTitle,
                              maxLength: 20,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'テニスメモ',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: memoController,
                                maxLines: 4,
                                maxLength: 400,
                                decoration: const InputDecoration(
                                  hintText: '気づきや次回に活かすポイントをメモしましょう',
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _profileColumn(
                              deviceWidth,
                              name: myProfile?.NICK_NAME ?? '',
                              image: myProfile?.PROFILE_IMAGE ?? '',
                            ),
                            Column(
                              children: matchResultList
                                  .map((matchResult) => Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                width: deviceWidth * 0.12,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                ),
                                                child: TextButton(
                                                  child: Text(
                                                    '${matchResult.myGamePoint}',
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.black),
                                                  ),
                                                  onPressed: () {
                                                    _showModalMyPointPicker(
                                                        context,
                                                        int.parse(
                                                            matchResult.No));
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                              Container(
                                                width: deviceWidth * 0.1,
                                                child: const Center(
                                                  child: Text(
                                                    "-",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                width: deviceWidth * 0.12,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                ),
                                                child: TextButton(
                                                  child: Text(
                                                    '${matchResult.yourGamePoint}',
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.black),
                                                  ),
                                                  onPressed: () {
                                                    _showModalYourPointPicker(
                                                        context,
                                                        int.parse(
                                                            matchResult.No));
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ))
                                  .toList(),
                            ),
                            _opponentColumn(deviceWidth),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                activityListAdd(
                                    matchResultList.length.toString());
                                setState(() {});
                              },
                            ),
                            const SizedBox(
                              width: 40,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 20),
                            width: deviceWidth * 0.8,
                              child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.lightGreenAccent,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(80)),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  '登録',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                              onPressed: () async {
                                String errorFlg = "0";
                                for (final matchList in matchResultList) {
                                  if (matchResultList.length != 1 &&
                                      matchList.myGamePoint == 0 &&
                                      matchList.yourGamePoint == 0) {
                                  } else if (matchList.myGamePoint ==
                                      matchList.yourGamePoint) {
                                    errorFlg = "1";
                                  }
                                }
                                if (errorFlg == "1") {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title:
                                              const Text('対戦結果に引き分けは入力できません'),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.black,
                                                  backgroundColor:
                                                      Colors.lightGreenAccent),
                                              child: const Text('OK'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                  return;
                                }
                                if (inputTitle.text.isEmpty) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('タイトルが未記入です'),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.black,
                                                  backgroundColor:
                                                      Colors.lightGreenAccent),
                                              child: const Text('OK'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                  return;
                                }
                                if (myProfile == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('プロフィール取得に失敗しました')),
                                  );
                                  return;
                                }
                                final opponentName =
                                    opponentNameController.text.isEmpty
                                        ? '対戦相手'
                                        : opponentNameController.text.trim();
                                final dayKey = DateTime.now().toString();
                                try {
                                  await FirestoreMethod
                                      .makePersonalMatchResult(
                                          myProfile!,
                                          opponentName,
                                          matchResultList,
                                          dayKey,
                                          inputTitle.text);
                                  if (memoController.text.trim().isNotEmpty) {
                                    final memoTitle = inputTitle.text;
                                    await FirestoreMethod.addTodo(
                                        memoTitle,
                                        memoController.text.trim(),
                                        myProfile!.USER_ID,
                                        '試合メモ');
                                  }
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('登録しました')),
                                    );
                                    Navigator.of(context).pop();
                                  }
                                } catch (e) {
                                  if (!mounted) return;
                                  showDialog(
                                      context: context,
                                      builder: (_) => const AlertDialog(
                                            title: Text("エラー"),
                                            content: Text("登録に失敗しました"),
                                          ));
                                }
                              },
                            ),
                          ),
                        ),
                      ]),
                ),
              ),
      ),
    );
  }

  Widget _profileColumn(double deviceWidth,
      {required String name, required String image}) {
    return Container(
      padding: const EdgeInsets.only(right: 10),
      width: deviceWidth * 0.3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            width: deviceWidth * 0.3,
            child: image == ''
                ? const CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage("images/tenipoikun.png"),
                    radius: 30,
                  )
                : CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(image),
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
                name.isEmpty ? 'YOU' : name,
                style: const TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _opponentColumn(double deviceWidth) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      width: deviceWidth * 0.3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: AssetImage("images/tenipoikun.png"),
            radius: 30,
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: deviceWidth * 0.25,
            child: TextField(
              controller: opponentNameController,
              textAlign: TextAlign.center,
              maxLength: 12,
              cursorColor: Colors.green,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                labelText: '対戦相手',
                labelStyle: TextStyle(color: Colors.black54),
              ),
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickerItem(String str) {
    return Text(
      str,
      style: const TextStyle(fontSize: 20),
    );
  }

  void _showModalMyPointPicker(BuildContext context, int No) {
    curTourokuNo = No;
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
              children: _myPoint.map(_pickerItem).toList(),
              onSelectedItemChanged: _onSelectedMyPointChanged,
            ),
          ),
        );
      },
    );
  }

  final List<String> _myPoint = [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
  ];

  void _showModalYourPointPicker(BuildContext context, int No) {
    curTourokuNo = No;
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
              children: _yourPoint.map(_pickerItem).toList(),
              onSelectedItemChanged: _onSelectedYourPointChanged,
            ),
          ),
        );
      },
    );
  }

  final List<String> _yourPoint = [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
  ];

  void _onSelectedMyPointChanged(int index) {
    myGamePoint = int.parse(_myPoint[index]);
    matchResultList[curTourokuNo].myGamePoint = myGamePoint;
    setState(() {});
  }

  void _onSelectedYourPointChanged(int index) {
    yourGamePoint = int.parse(_yourPoint[index]);
    matchResultList[curTourokuNo].yourGamePoint = yourGamePoint;
    setState(() {});
  }

  void activityListAdd(String No) {
    if (int.parse(No) >= 5) {
      showDialog(
          context: context,
          builder: (BuildContext context) => const ShowDialogToDismiss(
                content: "一度に5セット以上の対戦結果の入力はできません",
                buttonText: "はい",
              ));
    } else {
      matchResultList
          .add(CmatchResult(No: No, myGamePoint: 0, yourGamePoint: 0));
      myGamePoint = 0;
      yourGamePoint = 0;
    }
  }
}
