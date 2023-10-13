import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../room/room.dart';
import '../cubit/preview_cubit.dart';

part '../widgets/preview_widget.dart';

class PreviewPage extends StatelessWidget {
  final String meetingUrl;
  final String userName;

  const PreviewPage(this.meetingUrl, this.userName, {Key? key})
      : super(key: key);

  static Route route(String url, String name) {
    return MaterialPageRoute<void>(builder: (_) => PreviewPage(url, name));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PreviewCubit(userName, meetingUrl),
      child: _PreviewWidget(meetingUrl, userName),
    );
  }
}
