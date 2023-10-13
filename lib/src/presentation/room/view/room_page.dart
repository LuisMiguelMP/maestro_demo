import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:maestro_demo/src/presentation/home/home.dart';

import '../bloc/bloc.dart';

part '../widgets/room_widget.dart';
part '../widgets/video_widget.dart';
part '../widgets/bottom_navigation_bar_widget.dart';

class RoomPage extends StatelessWidget {
  final String meetingUrl;
  final String userName;
  final bool isVideoOff;
  final bool isAudioOff;
  final bool isScreenshareActive;

  const RoomPage(
    this.meetingUrl,
    this.userName,
    this.isVideoOff,
    this.isAudioOff,
    this.isScreenshareActive, {
    Key? key,
  }) : super(key: key);

  static Route route(String url, String name, bool v, bool a, bool ss) {
    return MaterialPageRoute<void>(
      builder: (_) => RoomPage(url, name, v, a, ss),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => RoomOverviewBloc(
              isVideoOff,
              isAudioOff,
              userName,
              meetingUrl,
              isScreenshareActive,
            )
              ..add(
                const RoomOverviewSubscriptionRequested(),
              )
              ..add(const RoomOverviewSubscriptionMessage()),
        child: Scaffold(
            body: Center(child: _RoomWidget(meetingUrl, userName)),
            bottomNavigationBar: _BottomNavigationBarWidget()));
  }
}
