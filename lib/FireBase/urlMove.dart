import 'package:url_launcher/url_launcher.dart';

class UrlMove {
  void UrlMoving(String _setUrl) async {
    final String setUrl = _setUrl;
    if (await canLaunch(setUrl)) {
      await launch(setUrl);
    } else {
      throw 'Could not launch $setUrl';
    }
  }
}