import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:maestro_demo/src/data/data.dart';
import 'package:maestro_demo/src/presentation/preview/view/preview_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class HomePage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isLoading = false;

  @override
  void initState() {
    initializePlugin();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isLoading)
                Column(
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Lottie.asset('assets/animations/home.json')),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<BeveledRectangleBorder>(
                            const BeveledRectangleBorder(),
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });

                          await _zonedScheduleNotification();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.health_and_safety_outlined, size: 48),
                              SizedBox(width: 8),
                              Text(
                                'Solicitar consulta',
                                style: TextStyle(height: 1, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_isLoading)
                Column(
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Lottie.asset('assets/animations/search.json')),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Aguarde, você receberá uma notificação quando a consulta estiver pronta...',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void initializePlugin() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (details, _, __, ___) async {
        Navigator.of(context).pushReplacement(PreviewPage.route(
          Constants.meetingUrl,
          'Paciente',
        ));
      },
    );

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        Navigator.of(context).pushReplacement(PreviewPage.route(
          Constants.meetingUrl,
          'Paciente',
        ));
      },
    );

    await setupPermissions();
  }

  Future<void> setupPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final iosPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestPermission();

      await _requestPermission(Permission.camera);
      await _requestPermission(Permission.microphone);
      await _requestPermission(Permission.bluetoothConnect);
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    while ((await permission.isDenied)) {
      await permission.request();
    }
  }

  Future<void> _zonedScheduleNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'A sala da consulta está pronta!',
      'Clique aqui para acessá-la!',
      tz.TZDateTime.now(tz.getLocation('America/Sao_Paulo'))
          .add(const Duration(seconds: 10)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'appointmentChannelId',
          'appointmentChannelName',
          channelDescription: 'appointmentChannelDescription',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
