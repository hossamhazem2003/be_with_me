import 'dart:async';
import 'dart:developer';

import 'package:be_with_me_new_new/core/utils/shared_preferences_manager.dart';
import 'package:signalr_netcore/signalr_client.dart';

typedef NotificationCallback = void Function(String message);

class NotificationService {
  late HubConnection hubConnection;
  late bool isThereNewPost = false;
  NotificationCallback? onNotificationReceived;
  Timer? _resetTimer;

  Future<void> connect({NotificationCallback? onNotification}) async {
    onNotificationReceived = onNotification;

    final serverUrl = 'https://bewtihme-001-site1.jtempurl.com/notificationHub';
    final token = SharedPreferencesManager.getToken();
    log(token!);
    final HttpConnectionOptions httpConnectionOptions;
    if(token == null){
      throw Exception('token is null');
    }else{
      httpConnectionOptions = HttpConnectionOptions(
        accessTokenFactory: () async => token,
      );
    }

    log('message 1');
    hubConnection = HubConnectionBuilder()
        .withUrl(serverUrl, options: httpConnectionOptions)
        .withAutomaticReconnect()
        .build();

    log('message 2');

    hubConnection.on('NewPostCreated', (arguments) {
      // إلغاء المؤقت السابق إذا كان موجودًا
      _resetTimer?.cancel();

      // تعيين القيمة إلى true
      isThereNewPost = true;
      print('Received notification: ${isThereNewPost}');

      // إنشاء مؤقت لتعيين القيمة إلى false بعد فترة (مثال: 5 ثواني)
      _resetTimer = Timer(const Duration(seconds: 1), () {
        isThereNewPost = false;
        print('Auto-reset notification status: ${isThereNewPost}');
      });
    });

    log('message 3');

    await hubConnection.start();
    log('message 4');
    await hubConnection.invoke('JoinOnlineHelpersGroup');
    log("message 5");
  }

  Future<void> disconnect() async {
    try {
      if (hubConnection.state == HubConnectionState.Connected) {
        await hubConnection.invoke('LeaveOnlineHelpersGroup');
        await hubConnection.stop();
      }
      // إلغاء المؤقت عند قطع الاتصال
      _resetTimer?.cancel();
      onNotificationReceived = null;
    } catch (e) {
      print('Error disconnecting: $e');
      rethrow;
    }
  }
}