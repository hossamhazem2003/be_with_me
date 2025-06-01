import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:be_with_me_new_new/core/utils/shared_preferences_manager.dart';
import 'package:be_with_me_new_new/features/auth/presentation/screens/auth_choice_screen.dart';
import 'package:be_with_me_new_new/features/helper/presintation/blocs/signalr/signalr_connect.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesManager.init();

  // Init cameras
  final cameras = await availableCameras();

  // Init awesome_notifications
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Notification channel for general alerts',
        defaultColor: Colors.blue,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      )
    ],
    debug: true,
  );

  // Connect SignalR
  final NotificationService notificationService = NotificationService();
  try {
    await notificationService.connect();
    log('SignalR connected successfully');
  } catch (e) {
    log('SignalR connection error: $e');
  }

  runApp(MyApp(
    cameras: cameras,
    notificationService: notificationService,
  ));
}

class MyApp extends StatefulWidget {
  final List<CameraDescription> cameras;
  final NotificationService notificationService;

  const MyApp({
    Key? key,
    required this.cameras,
    required this.notificationService,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _checkNewEvents();
  }

  void _checkNewEvents() async {
    if (widget.notificationService.isThereNewPost == true) {
      await _showAwesomeNotification();
    }

    Future.delayed(const Duration(seconds: 1), () {
      _checkNewEvents();
    });
  }

  Future<void> _showAwesomeNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: '🚨 حدث جديد',
        body: 'تم استلام منشور جديد!',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  @override
  void dispose() {
    widget.notificationService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Be With Me',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: AuthChoiceScreen(cameras: widget.cameras),
    );
  }
}
