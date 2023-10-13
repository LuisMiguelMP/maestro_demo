import 'package:flutter/foundation.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:maestro_demo/src/data/services/room_service.dart';

import 'package:rxdart/subjects.dart';

import 'peer_track_node_state.dart';
import 'room_overview_bloc.dart';
import 'room_overview_event.dart';

class RoomObserver implements HMSUpdateListener, HMSActionResultListener {
  RoomOverviewBloc roomOverviewBloc;
  bool _isDisposed = false;

  RoomObserver(this.roomOverviewBloc) {
    roomOverviewBloc.hmsSdk.addUpdateListener(listener: this);

    roomOverviewBloc.hmsSdk.build();
    RoomService()
        .getToken(user: roomOverviewBloc.name, room: roomOverviewBloc.url)
        .then((token) {
      if (_isDisposed) return;
      if (token == null) return;
      if (token[0] == null) return;

      HMSConfig config = HMSConfig(
        authToken: token[0]!,
        userName: roomOverviewBloc.name,
      );

      roomOverviewBloc.hmsSdk.join(config: config);
    });
  }

  final _peerNodeStreamController =
      BehaviorSubject<List<PeerTrackNodeState>>.seeded(const []);

  Stream<List<PeerTrackNodeState>> getTracks() =>
      _peerNodeStreamController.asBroadcastStream();

  final messageStreamController =
      BehaviorSubject<List<HMSMessage>>.seeded(const []);

  Future<void> addPeer(HMSVideoTrack hmsVideoTrack, HMSPeer peer) async {
    if (_isDisposed) return;
    final tracks = [..._peerNodeStreamController.value];
    final todoIndex = tracks.indexWhere((t) => t.peer?.peerId == peer.peerId);
    if (todoIndex >= 0) {
      if (kDebugMode) {
        print("onTrackUpdate ${peer.name} ${hmsVideoTrack.isMute}");
      }
      tracks[todoIndex] =
          PeerTrackNodeState(hmsVideoTrack, hmsVideoTrack.isMute, peer, false);
    } else {
      tracks.add(
          PeerTrackNodeState(hmsVideoTrack, hmsVideoTrack.isMute, peer, false));
    }

    _peerNodeStreamController.add(tracks);
  }

  Future<void> deletePeer(String id) async {
    if (_isDisposed) return;
    final tracks = [..._peerNodeStreamController.value];
    final todoIndex = tracks.indexWhere((t) => t.peer?.peerId == id);
    if (todoIndex >= 0) {
      tracks.removeAt(todoIndex);
    }
    _peerNodeStreamController.add(tracks);
  }

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {}

  @override
  void onHMSError({required HMSException error}) {}

  @override
  void onJoin({required HMSRoom room}) {
    if (_isDisposed) return;
    roomOverviewBloc.add(RoomOverviewOnJoinSuccess(room));
  }

  Stream<List<HMSMessage>> get messages =>
      messageStreamController.asBroadcastStream();

  @override
  void onMessage({required HMSMessage message}) {
    final mes = [...messageStreamController.value];
    mes.add(message);
    messageStreamController.add(mes);
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {}

  void sendMessage(String message, HMSPeer? sender) {
    final mes = [...messageStreamController.value];
    mes.add(
      HMSMessage(
        messageId: '${DateTime.now().millisecondsSinceEpoch}-${sender?.peerId}',
        message: message,
        sender: sender,
        type: '',
        time: DateTime.now(),
      ),
    );
    messageStreamController.add(mes);
  }

  @override
  void onReconnected() {}

  @override
  void onReconnecting() {}

  @override
  void onRemovedFromRoom({
    required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer,
  }) {}

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  @override
  void onTrackUpdate(
      {required HMSTrack track,
      required HMSTrackUpdate trackUpdate,
      required HMSPeer peer}) {
    if (_isDisposed) return;

    if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
      if (trackUpdate == HMSTrackUpdate.trackRemoved) {
        roomOverviewBloc
            .add(RoomOverviewOnPeerLeave(track as HMSVideoTrack, peer));
      } else if (trackUpdate == HMSTrackUpdate.trackAdded ||
          trackUpdate == HMSTrackUpdate.trackMuted ||
          trackUpdate == HMSTrackUpdate.trackUnMuted) {
        roomOverviewBloc
            .add(RoomOverviewOnPeerJoin(track as HMSVideoTrack, peer));
      }
    }
  }

  Future<void> leaveMeeting() async {
    if (_isDisposed) return;
    roomOverviewBloc.hmsSdk.leave(hmsActionResultListener: this);
  }

  Future<void> setOffScreen(int index, bool setOffScreen) async {
    if (_isDisposed) return;
    final tracks = [..._peerNodeStreamController.value];

    if (index >= 0) {
      tracks[index] = tracks[index].copyWith(isOffScreen: setOffScreen);
    }
    _peerNodeStreamController.add(tracks);
  }

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  @override
  void onException(
      {HMSActionResultListenerMethod? methodType,
      Map<String, dynamic>? arguments,
      required HMSException hmsException}) {}

  @override
  void onSuccess(
      {HMSActionResultListenerMethod? methodType,
      Map<String, dynamic>? arguments}) {
    if (_isDisposed) return;
    _peerNodeStreamController.add([]);
  }

  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice? currentAudioDevice,
      List<HMSAudioDevice>? availableAudioDevice}) {}

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}

  void dispose() {
    _isDisposed = true;
  }
}
