part of '../view/room_page.dart';

class _BottomNavigationBarWidget extends StatefulWidget {
  @override
  State<_BottomNavigationBarWidget> createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState
    extends State<_BottomNavigationBarWidget> {
  TextEditingController messageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomOverviewBloc, RoomOverviewState>(
        builder: (ctx, state) {
      return BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).canvasColor,
        selectedItemColor: Theme.of(context).dividerColor,
        unselectedItemColor: Theme.of(context).dividerColor,
        items: <BottomNavigationBarItem>[
          _buildMicBottomNavigationBarItem(state, context),
          _buildCameraBottomNavigationBarItem(state, context),
          if (Platform.isAndroid)
            _buildScreenShareBottomNavigationBarItem(state, context),
          _buildChatBottomNavigationBarItem(state, context),
          const BottomNavigationBarItem(
            icon: Icon(Icons.cancel),
            label: 'Sair',
          ),
        ],
        onTap: (index) => _onItemTapped(index, context, state),
      );
    });
  }

  BottomNavigationBarItem _buildMicBottomNavigationBarItem(
      RoomOverviewState state, context) {
    return BottomNavigationBarItem(
      icon: Icon(
        state.isAudioMute ? Icons.mic_off : Icons.mic,
        color: state.isAudioMute
            ? Theme.of(context).dividerColor
            : Theme.of(context).primaryColor,
      ),
      label: state.isAudioMute ? 'Desligado' : 'Ligado',
    );
  }

  BottomNavigationBarItem _buildCameraBottomNavigationBarItem(
      RoomOverviewState state, context) {
    return BottomNavigationBarItem(
      icon: Icon(
        state.isVideoMute ? Icons.videocam_off : Icons.videocam,
        color: state.isVideoMute
            ? Theme.of(context).dividerColor
            : Theme.of(context).primaryColor,
      ),
      label: state.isVideoMute ? 'Desligada' : 'Ligada',
    );
  }

  BottomNavigationBarItem _buildChatBottomNavigationBarItem(
      RoomOverviewState state, context) {
    return BottomNavigationBarItem(
      icon: Icon(Icons.chat, color: Theme.of(context).dividerColor),
      label: 'Mensagens',
    );
  }

  BottomNavigationBarItem _buildScreenShareBottomNavigationBarItem(
      RoomOverviewState state, context) {
    return BottomNavigationBarItem(
      icon: Icon(
        Icons.screen_share,
        color: state.isScreenShareActive
            ? Theme.of(context).primaryColor
            : Theme.of(context).dividerColor,
      ),
      label: state.isScreenShareActive ? 'Compartilhando' : 'Compartilhar',
    );
  }

  void _onItemTapped(int index, BuildContext context, RoomOverviewState state) {
    final bloc = context.read<RoomOverviewBloc>();

    switch (index) {
      case 0:
        bloc.add(const RoomOverviewLocalPeerAudioToggled());
        break;
      case 1:
        bloc.add(const RoomOverviewLocalPeerVideoToggled());
        break;
      case 2:
        bloc.add(const RoomOverviewLocalPeerScreenshareToggled());
        break;
      case 3:
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          backgroundColor: Colors.white,
          builder: (context) => SafeArea(
            bottom: true,
            minimum: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.31,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: state.messages.isEmpty
                        ? const Center(
                            child: Text(
                              'Sem mensagens...',
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.messages.length,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemBuilder: (itemBuilder, index) {
                              if (index >= 0 && index < state.messages.length) {
                                final item = state.messages[index];
                                if (!(item.sender?.isLocal ?? true)) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16)
                                                  .copyWith(
                                            bottomLeft: Radius.zero,
                                          ),
                                          color: Colors.grey,
                                        ),
                                        child: Text(
                                          state.messages[index].message,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        state.messages[index].time.toString(),
                                        style: const TextStyle(
                                          color: Color(0xffABABAB),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16)
                                                  .copyWith(
                                            bottomRight: Radius.zero,
                                          ),
                                          color: const Color(0xffECECEC),
                                        ),
                                        child: Text(
                                          state.messages[index].message,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        state.messages[index].time.toString(),
                                        style: const TextStyle(
                                          color: Color(0xffABABAB),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16),
                    height: 48,
                    child: TextField(
                      autofocus: false,
                      controller: messageTextController,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            width: 1,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            width: 1,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            width: 1,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        suffixIcon: InkWell(
                          onTap: () {
                            if (messageTextController.text.trim().isNotEmpty) {
                              bloc.add(RoomOverviewSendMessage(
                                  messageTextController.text,
                                  state.peerTrackNodes.first.peer!));
                              messageTextController.text = '';
                            }
                          },
                          child: const Icon(
                            Icons.send,
                            size: 13,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ).copyWith(
                          right: 8,
                        ),
                        hintText: 'Digite aqui...',
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
        break;
      case 4:
        bloc.add(const RoomOverviewLeaveRequested());
        break;
    }
  }
}
