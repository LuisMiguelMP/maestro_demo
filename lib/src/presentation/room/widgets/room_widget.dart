part of '../view/room_page.dart';

class _RoomWidget extends StatelessWidget {
  final String meetingUrl;
  final String userName;

  const _RoomWidget(
    this.meetingUrl,
    this.userName, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomOverviewBloc, RoomOverviewState>(
      listener: (ctx, state) {
        if (state.leaveMeeting) {
          Navigator.of(context).pushReplacement(HomePage.route());
        }
      },
      builder: (ctx, state) {
        return ListView.builder(
          itemCount: state.peerTrackNodes.length,
          itemBuilder: (ctx, index) {
            return Card(
              shape: const BeveledRectangleBorder(),
              key: Key(state.peerTrackNodes[index].peer!.peerId.toString()),
              child: SizedBox(
                height: 250.0,
                child: _VideoWidget(index),
              ),
            );
          },
        );
      },
    );
  }
}
