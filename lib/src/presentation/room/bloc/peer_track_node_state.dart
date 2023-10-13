import 'package:equatable/equatable.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

class PeerTrackNodeState extends Equatable {
  final HMSVideoTrack? hmsVideoTrack;
  final bool? isMute;
  final HMSPeer? peer;
  final bool isOffScreen;

  const PeerTrackNodeState(
      this.hmsVideoTrack, this.isMute, this.peer, this.isOffScreen);

  @override
  List<Object?> get props => [hmsVideoTrack, isMute, peer, isOffScreen];

  PeerTrackNodeState copyWith({
    HMSVideoTrack? hmsVideoTrack,
    bool? isMute,
    HMSPeer? peer,
    bool? isOffScreen,
  }) {
    return PeerTrackNodeState(
      hmsVideoTrack ?? this.hmsVideoTrack,
      isMute ?? this.isMute,
      peer ?? this.peer,
      isOffScreen ?? this.isOffScreen,
    );
  }
}
