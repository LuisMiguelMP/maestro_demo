import 'package:flutter/foundation.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:maestro_demo/src/data/services/room_service.dart';

import 'preview_cubit.dart';

class PreviewObserver implements HMSPreviewListener {
  PreviewCubit previewCubit;

  List<HMSVideoTrack> localTracks = <HMSVideoTrack>[];

  PreviewObserver(this.previewCubit) {
    previewCubit.hmsSdk.addPreviewListener(listener: this);

    previewCubit.hmsSdk.build();
    RoomService()
        .getToken(user: previewCubit.name, room: previewCubit.url)
        .then((token) {
      if (token == null) return;
      if (token[0] == null) return;

      HMSConfig config = HMSConfig(
        authToken: token[0]!,
        userName: previewCubit.name,
      );

      previewCubit.hmsSdk.preview(config: config);
    });
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {}

  @override
  void onPreview({required HMSRoom room, required List<HMSTrack> localTracks}) {
    List<HMSVideoTrack> videoTracks = [];
    for (var track in localTracks) {
      if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
        videoTracks.add(track as HMSVideoTrack);
      }
    }
    this.localTracks.clear();
    this.localTracks.addAll(videoTracks);
    previewCubit.updateTracks(this.localTracks);
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  @override
  void onHMSError({required HMSException error}) {
    if (kDebugMode) {
      print("OnError ${error.message}");
    }
  }

  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice? currentAudioDevice,
      List<HMSAudioDevice>? availableAudioDevice}) {}
}
