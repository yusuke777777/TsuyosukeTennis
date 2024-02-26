import 'package:logger/logger.dart';

class RemoteLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) async {
    try {
      final logMessage = event.lines.join('\n');
      print(logMessage + "XXX");
      // 省略
      // Web Apiでログ送信処理
    } catch (e) {
      print('Failed to send log to remote server: $e');
    }
  }
}