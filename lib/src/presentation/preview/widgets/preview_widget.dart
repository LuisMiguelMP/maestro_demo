part of '../view/preview_page.dart';

class _PreviewWidget extends StatefulWidget {
  final String meetingUrl;
  final String userName;

  const _PreviewWidget(this.meetingUrl, this.userName, {Key? key})
      : super(key: key);

  @override
  State<_PreviewWidget> createState() => __PreviewWidgetState();
}

class __PreviewWidgetState extends State<_PreviewWidget> {
  int _countdown = 15;

  @override
  void initState() {
    _startCountdown();
    super.initState();
  }

  void _startCountdown() {
    const oneSec = Duration(seconds: 1);
    Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_countdown == 0) {
          setState(() {
            timer.cancel();
          });
          Navigator.of(context).pushReplacement(
            RoomPage.route(
              widget.meetingUrl,
              widget.userName,
              false,
              false,
              false,
            ),
          );
        } else {
          setState(() {
            _countdown--;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PreviewCubit, PreviewState>(
        builder: (context, state) {
          return state.tracks.isEmpty
              ? _buildLoadingWidget(context)
              : _buildVideoPreview(context, state);
        },
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Lottie.asset('assets/animations/dots.json')),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Preparando áudio e vídeo...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVideoPreview(BuildContext context, PreviewState state) {
    final size = MediaQuery.of(context).size;
    final itemHeight = size.height;
    final itemWidth = size.width;

    return SizedBox(
      height: itemHeight,
      width: itemWidth,
      child: Stack(
        children: [
          Dialog(
            shape: const BeveledRectangleBorder(),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Stack(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child:
                              Lottie.asset('assets/animations/loading.json')),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        'A consulta começará em $_countdown segundos...',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
