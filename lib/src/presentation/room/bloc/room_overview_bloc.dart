import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import 'peer_track_node_state.dart';
import 'room_observer.dart';
import 'room_overview_event.dart';
import 'room_overview_state.dart';

class RoomOverviewBloc extends Bloc<RoomOverviewEvent, RoomOverviewState> {
  final bool isVideoMute;
  final bool isAudioMute;
  final bool isScreenShareActive;
  HMSSDK hmsSdk = HMSSDK();

  String name;
  String url;
  late RoomObserver roomObserver;
  bool _isDisposed = false;
  StreamSubscription<List<HMSMessage>>? subscriptionMessage;
  StreamSubscription<List<PeerTrackNodeState>>? subscription;

  RoomOverviewBloc(this.isVideoMute, this.isAudioMute, this.name, this.url,
      this.isScreenShareActive)
      : super(RoomOverviewState(
            isAudioMute: isAudioMute,
            isVideoMute: isVideoMute,
            isScreenShareActive: isScreenShareActive)) {
    roomObserver = RoomObserver(this);
    on<RoomOverviewSubscriptionRequested>(_onSubscription);
    on<RoomOverviewSubscriptionMessage>(_onSubscriptionMessage);
    on<RoomOverviewLocalPeerAudioToggled>(_onLocalAudioToggled);
    on<RoomOverviewLocalPeerVideoToggled>(_onLocalVideoToggled);
    on<RoomOverviewLocalPeerScreenshareToggled>(_onScreenShareToggled);
    on<RoomOverviewOnJoinSuccess>(_onJoinSuccess);
    on<RoomOverviewOnPeerLeave>(_onPeerLeave);
    on<RoomOverviewOnPeerJoin>(_onPeerJoin);
    on<RoomOverviewLeaveRequested>(_leaveRequested);
    on<RoomOverviewSetOffScreen>(_setOffScreen);
    on<RoomOverviewSendMessage>(_sendMessage);
  }

  Future<void> _onSubscription(RoomOverviewSubscriptionRequested event,
      Emitter<RoomOverviewState> emit) async {
    if (!_isDisposed) {
      await emit.forEach<List<PeerTrackNodeState>>(
        roomObserver.getTracks(),
        onData: (tracks) {
          return state.copyWith(
              status: RoomOverviewStatus.success, peerTrackNodes: tracks);
        },
        onError: (_, __) => state.copyWith(
          status: RoomOverviewStatus.failure,
        ),
      );
    }
  }

  Future<void> _onLocalVideoToggled(RoomOverviewLocalPeerVideoToggled event,
      Emitter<RoomOverviewState> emit) async {
    if (!_isDisposed) {
      hmsSdk.toggleCameraMuteState();
      emit(state.copyWith(isVideoMute: !state.isVideoMute));
    }
  }

  void _onScreenShareToggled(RoomOverviewLocalPeerScreenshareToggled event,
      Emitter<RoomOverviewState> emit) async {
    if (!_isDisposed) {
      if (!state.isScreenShareActive) {
        hmsSdk.startScreenShare();
      } else {
        hmsSdk.stopScreenShare();
      }
      emit(state.copyWith(isScreenShareActive: !state.isScreenShareActive));
    }
  }

  Future<void> _onLocalAudioToggled(RoomOverviewLocalPeerAudioToggled event,
      Emitter<RoomOverviewState> emit) async {
    if (!_isDisposed) {
      hmsSdk.toggleMicMuteState();
      emit(state.copyWith(isAudioMute: !state.isAudioMute));
    }
  }

  Future<void> _onJoinSuccess(
      RoomOverviewOnJoinSuccess event, Emitter<RoomOverviewState> emit) async {
    if (!_isDisposed) {
      if (state.isAudioMute) {
        hmsSdk.toggleMicMuteState();
      }

      if (state.isVideoMute) {
        hmsSdk.toggleCameraMuteState();
      }
    }
  }

  void unsubscribe() {
    hmsSdk.removeUpdateListener(listener: roomObserver);
    subscription?.cancel();
    subscriptionMessage?.cancel();
    roomObserver.dispose();
  }

  Future<void> _onPeerLeave(
      RoomOverviewOnPeerLeave event, Emitter<RoomOverviewState> emit) async {
    if (!_isDisposed) {
      await roomObserver.deletePeer(event.hmsPeer.peerId);
    }
  }

  Future<void> _onPeerJoin(
      RoomOverviewOnPeerJoin event, Emitter<RoomOverviewState> emit) async {
    if (!_isDisposed) {
      await roomObserver.addPeer(event.hmsVideoTrack, event.hmsPeer);
    }
  }

  void _onSubscriptionMessage(RoomOverviewSubscriptionMessage event,
      Emitter<RoomOverviewState> emit) async {
    subscriptionMessage =
        roomObserver.messageStreamController.listen((message) {
      emit(state.copyWith(messages: message));
    }, onError: (error) {});

    await subscriptionMessage?.asFuture();
  }

  void sendMessage(String message, HMSPeer peer) async {
    await hmsSdk.sendBroadcastMessage(message: message);

    roomObserver.sendMessage(
      message,
      peer,
    );
  }

  Future<void> _leaveRequested(
      RoomOverviewLeaveRequested event, Emitter<RoomOverviewState> emit) async {
    if (!_isDisposed) {
      await roomObserver.leaveMeeting();
      emit(state.copyWith(leaveMeeting: true));
    }
  }

  Future<void> _setOffScreen(
      RoomOverviewSetOffScreen event, Emitter<RoomOverviewState> emit) async {
    if (!_isDisposed) {
      await roomObserver.setOffScreen(event.index, event.setOffScreen);
    }
  }

  Future<void> _sendMessage(
      RoomOverviewSendMessage event, Emitter<RoomOverviewState> emit) async {
    if (!_isDisposed) {
      sendMessage(event.message, event.hmsPeer);
    }
  }

  @override
  Future<void> close() {
    _isDisposed = true;
    unsubscribe();

    return super.close();
  }
}
