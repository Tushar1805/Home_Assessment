import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tryapp/Assesment/Forms/basicoverlay.dart';
import 'package:tryapp/constants.dart';
import 'package:video_player/video_player.dart';

class ViewVideo extends StatefulWidget {
  String videoUrl, roomname;
  ViewVideo(this.videoUrl, this.roomname);

  @override
  _ViewVideoState createState() => _ViewVideoState();
}

class _ViewVideoState extends State<ViewVideo> {
  VideoPlayerController _videoController;
  Future<void> _initializedVideoPlayerFuture;
  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.network(widget.videoUrl)
      ..addListener(() {
        setState(() {});
      })
      ..setLooping(true)
      ..initialize().then((_) => _videoController.play());
  }

  @override
  void dispose() {
    super.dispose();
    _videoController.dispose();
  }

  // void _incrementCounter() {
  //   setState(() {
  //     _chewieController.value.isPlaying
  //         ? _chewieController.pause()
  //         : _chewieController.play();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final isMuted = _videoController.value.volume == 0;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color.fromRGBO(10, 80, 106, 1), // status bar color
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light, //status bar brigtness
        ),
        flexibleSpace: Container(
          width: MediaQuery.of(context).size.width,
          child: new Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 40, bottom: 10.0),
            child: Row(
              children: [
                IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                SizedBox(
                  width: 10.0,
                ),
                Text("${widget.roomname}", style: titleBarWhiteTextStyle()),
              ],
            ),
          ),
          decoration: new BoxDecoration(
            color: Color.fromRGBO(10, 80, 106, 1),
          ),
        ),
      ),
      body: _videoController != null && _videoController.value.initialized
          ? Container(
              alignment: Alignment.topCenter,
              child: buildVideo(),
            )
          : Container(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
      floatingActionButton: new FloatingActionButton(
        child: Icon(isMuted ? Icons.volume_mute : Icons.volume_up),
        foregroundColor: Colors.white,
        backgroundColor: Color.fromRGBO(10, 80, 106, 1),
        onPressed: () {
          _videoController.setVolume(isMuted ? 1 : 0);
        },
      ),
    );
  }

  Widget buildVideoPlayer() {
    return AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: VideoPlayer(_videoController));
  }

  Widget
      buildVideo() => /*OrientationBuilder(builder: (context, orientation) {*/
          // final isPotrait = orientation == Orientation.portrait;
          Stack(
            // fit: StackFit.expand,
            children: <Widget>[
              buildVideoPlayer(),
              Positioned.fill(
                child: BasicOverlayWidget(_videoController),
              )
            ],
          );
  // });
}
