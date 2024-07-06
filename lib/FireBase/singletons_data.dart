class AppData {
  static final AppData _appData = AppData._internal();

  bool entitlementIsActive = false;
  // bool isPurchasing = false;
  String appUserID = '';

  factory AppData() {
    return _appData;
  }
  AppData._internal();
}

final appData = AppData();
