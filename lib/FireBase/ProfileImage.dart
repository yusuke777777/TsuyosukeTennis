import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'FireBase.dart';
import 'ImagePicker.dart';

class ProfileImage extends StatefulWidget {
  late String myImagePath;
  late String stateFlg;

  ProfileImage.image(this.myImagePath, this.stateFlg);

  @override
  _ProfileImageState createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  File? imageFile;
  late String myImagePath;
  late String stateFlg;
  late String _base64ImageString = '';

  String get base64ImageString => _base64ImageString;

  @override
  void initState() {
    super.initState();
    this.myImagePath = widget.myImagePath;
    this.stateFlg = widget.stateFlg;
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        // 第2引数に渡す値を設定
        Navigator.pop(context, myImagePath);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
            leading: new IconButton(
                icon: new Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context, myImagePath);
                }),
            backgroundColor: Colors.white,
            title: Text("画像選択画面",
                style: TextStyle(
                  color: Color(0xFF212121),
                  fontSize: 18,
                )),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add_a_photo, color: Colors.black),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (childContext) {
                      return SimpleDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        children: <Widget>[
                          SimpleDialogOption(
                            onPressed: () async {
                              Navigator.pop(childContext);
                              await _pickImage();
                              await _cropImage();
                            },
                            child: Center(
                              child: Text(
                                "写真を選択する",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // Divider(color: Colors.black),
                          // SimpleDialogOption(
                          //   onPressed: () {
                          //     _cropImage();
                          //   },
                          //   child: Center(
                          //     child: Text(
                          //       "写真をトリミングする",
                          //       textAlign: TextAlign.center,
                          //     ),
                          //   ),
                          // ),
                          Divider(color: Colors.black),
                          SimpleDialogOption(
                            onPressed: () {
                              _clearImage();
                            },
                            child: Center(
                              child: Text(
                                "写真を削除する",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Divider(color: Colors.black),
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(childContext);
                            },
                            child: Center(
                              child: Text(
                                'キャンセル',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              )
            ]),
        body: Center(
          child: myImagePath != ""
              ? Image.network(myImagePath)
              : Image.asset('images/upper_body-2.png',
                  fit: BoxFit.cover),
        ),
      ),
    );
  }

  Future _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    imageFile = pickedImage != null ? File(pickedImage.path) : null;

    setState(() {
      // state = AppState.picked;
    });

    // final time = DateTime.now().millisecondsSinceEpoch;
    // final directory = await getApplicationDocumentsDirectory();
    // final path = directory.path;
    // final copiedImageFile = await imageFile!.copy('$path/$time.png');
    // notifyListeners();

    // DBへ保存する為、base64文字列へ変換
    // _base64ImageString =
    //     Base64Helper.base64String(copiedImageFile.readAsBytesSync());

    // 端末の一時ファイルを削除
    // _deleteFile(imageFile!);
  }

  /// 該当パスのファイルが存在しているときに、返却します
  Future<File?> _getLocalFile(File file) async {
    if (await File(file.path).exists()) {
      debugPrint('${file.path} deleted');
      return File(file.path);
    }
    return null;
  }

  /// 返却されたファイルパスが存在するときに、削除します
  void _deleteFile(
    File targetFile,
  ) async {
    try {
      final file = await _getLocalFile(targetFile);
      await file!.delete();
    } catch (e) {
      debugPrint('Delete file error: $e');
    }
    if (imageFile != null) {
      setState(() {
        // state = AppState.picked;
      });
    }
  }

  Future _cropImage() async {
    // final double deviceHeight = MediaQuery.of(context).size.height;
    // final double deviceWidth = MediaQuery.of(context).size.width;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile!.path,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'トリミング中',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'トリミング中',
        )
      ],
    );

    if (croppedFile != null) {
      imageFile = File(croppedFile.path);
      String imageURL = await FirestoreMethod.upload(imageFile);
      // 端末の一時ファイルを削除
      _deleteFile(imageFile!);

      // final time = DateTime.now().millisecondsSinceEpoch;
      // final directory = await getApplicationDocumentsDirectory();
      // final path = directory.path;
      // final copiedImageFile = await imageFile!.copy('$path/$time.png');
      // notifyListeners();

      // DBへ保存する為、base64文字列へ変換
      // _base64ImageString =
      //     Base64Helper.base64String(copiedImageFile.readAsBytesSync());

      setState(() {
        this.myImagePath = imageURL;
      });
    }
  }

  void _clearImage() {
    imageFile = null;
    this.myImagePath = "";
    setState(() {});
  }
}
