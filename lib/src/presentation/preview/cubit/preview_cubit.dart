import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import 'preview_observer.dart';

part 'preview_state.dart';

class PreviewCubit extends Cubit<PreviewState> {
  HMSSDK hmsSdk = HMSSDK();
  String name;
  String url;
  bool _isDisposed = false;

  PreviewCubit(this.name, this.url)
      : super(const PreviewState(isMicOff: false, isVideoOff: false)) {
    PreviewObserver(this);
  }

  void toggleVideo() {
    if (!_isDisposed) {
      hmsSdk.toggleCameraMuteState();
      emit(state.copyWith(isVideoOff: !state.isVideoOff));
    }
  }

  void toggleAudio() {
    if (!_isDisposed) {
      hmsSdk.toggleMicMuteState();
      emit(state.copyWith(isMicOff: !state.isMicOff));
    }
  }

  void updateTracks(List<HMSVideoTrack> localTracks) {
    if (!_isDisposed) {
      emit(state.copyWith(tracks: localTracks));
    }
  }

  @override
  Future<void> close() {
    _isDisposed = true;
    return super.close();
  }
}
