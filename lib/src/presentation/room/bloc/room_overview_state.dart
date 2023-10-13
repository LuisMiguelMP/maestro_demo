import 'package:equatable/equatable.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import 'peer_track_node_state.dart';

enum RoomOverviewStatus { initial, loading, success, failure }

class RoomOverviewState extends Equatable {
  final RoomOverviewStatus status;
  final List<PeerTrackNodeState> peerTrackNodes;
  final bool isVideoMute;
  final bool isAudioMute;
  final bool leaveMeeting;
  final bool isScreenShareActive;
  final List<HMSMessage> messages;

  const RoomOverviewState(
      {this.status = RoomOverviewStatus.initial,
      this.peerTrackNodes = const [],
      this.isVideoMute = false,
      this.isAudioMute = false,
      this.messages = const <HMSMessage>[],
      this.leaveMeeting = false,
      this.isScreenShareActive = false});

  @override
  List<Object?> get props => [
        status,
        peerTrackNodes,
        isAudioMute,
        messages,
        isVideoMute,
        leaveMeeting,
        isScreenShareActive
      ];

  RoomOverviewState copyWith(
      {RoomOverviewStatus? status,
      List<PeerTrackNodeState>? peerTrackNodes,
      bool? isVideoMute,
      bool? isAudioMute,
      List<HMSMessage>? messages,
      int? countNewMessages,
      bool? leaveMeeting,
      bool? isScreenShareActive}) {
    return RoomOverviewState(
        status: status ?? this.status,
        peerTrackNodes: peerTrackNodes ?? this.peerTrackNodes,
        isVideoMute: isVideoMute ?? this.isVideoMute,
        messages: messages ?? this.messages,
        isAudioMute: isAudioMute ?? this.isAudioMute,
        leaveMeeting: leaveMeeting ?? this.leaveMeeting,
        isScreenShareActive: isScreenShareActive ?? this.isScreenShareActive);
  }
}
