import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();

  NotificationService._();

  /// Initialize OneSignal
  Future<void> initialize(String appId) async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(appId);

    // Request permission for notifications
    await OneSignal.Notifications.requestPermission(true);
  }

  /// Set external user ID
  Future<void> setExternalUserId(String userId) async {
    await OneSignal.login(userId);
  }

  /// Remove external user ID
  Future<void> removeExternalUserId() async {
    await OneSignal.logout();
  }

  /// Set notification opened handler
  void setNotificationOpenedHandler(
    void Function(OSNotificationClickEvent) handler,
  ) {
    OneSignal.Notifications.addClickListener(handler);
  }

  /// Set notification received handler
  void setNotificationReceivedHandler(
    OnNotificationWillDisplayListener handler,
  ) {
    OneSignal.Notifications.addForegroundWillDisplayListener(handler);
  }

  /// Send tag
  Future<void> sendTag(String key, String value) async {
    await OneSignal.User.addTagWithKey(key, value);
  }

  /// Remove tag
  Future<void> removeTag(String key) async {
    await OneSignal.User.removeTag(key);
  }
}
