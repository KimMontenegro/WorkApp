import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

void main() => runApp(VideoApp());

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  bool finishedPlaying = false;
  double opacityLevel = 1.0;
  bool isBuffering = true;
  Duration vidDuration;
  Duration vidPosition;
  VideoPlayerController _controller;
  TextEditingController _txtController;
  static const String MEDIA_URL =
      'https://dash.akamaized.net/envivio/EnvivioDash3/manifest.mpd';

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(MEDIA_URL)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video
        // is initialized, even before the play button has been pressed.
        setState(() {
          vidDuration = _controller.value.duration;
        });
      });
    _controller.addListener(() async {
      if (_controller.value.duration == _controller.value.position) {
        setState(() {
          finishedPlaying = true;
        });
      }
      setState(() {
        vidPosition = _controller.value.position;
      });
    });
    setState(() {
      _txtController = TextEditingController();
    });
  }

  void _changeOpacity() {
    setState(() => opacityLevel = opacityLevel == 0.0 ? 1.0 : 0.0);
  }

//not working lol
  void buffer() {
    setState(() {
      isBuffering = !isBuffering;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: _buildPlayer(),
      ),
    );
  }

  Widget _buildInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TextField(
          controller: _txtController,
          decoration: InputDecoration(hintText: "Enter URL"),
        ),
        Container(
          alignment: Alignment.center,
          child: RaisedButton(
            onPressed: () => print("pressed"),
            child: Text("load"),
          ),
        ),
      ],
    );
  }

  String convertMinToSec(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildPlayer() {
    return Center(
      child: _controller.value.initialized ? _buildPlayerStack() : Container(),
    );
  }

  Widget _buildText() {
    return Container(
        child: AnimatedOpacity(
      opacity: opacityLevel,
      duration: Duration(seconds: 3),
      child: Text(
        '${convertMinToSec(vidPosition)} / ${convertMinToSec(vidDuration)}',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    ));
  }

  Widget _buildPlayerStack() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: _buildInput(),
        ),
        Container(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              children: [
                Container(
                  child: VideoPlayer(_controller),
                ),
                Align(
                  alignment: Alignment.center,
                  child: AnimatedOpacity(
                    opacity: opacityLevel,
                    duration: Duration(seconds: 3),
                    child: FlatButton(
                      onPressed: () => setState(() {
                        if (finishedPlaying) {
                          _controller.seekTo(Duration.zero);
                          _controller.play();
                          setState(() {
                            finishedPlaying = false;
                          });
                          Icon(Icons.replay, color: Colors.white);
                        } else if (_controller.value.isPlaying) {
                          _controller.pause();
                          _changeOpacity();
                        } else {
                          _changeOpacity();
                          _controller.play();
                        }
                      }),
                      child: Center(
                        child: finishedPlaying
                            ? Icon(Icons.replay, color: Colors.white)
                            : (_controller.value.isPlaying)
                                ? Icon(Icons.pause, color: Colors.white)
                                : Icon(Icons.play_arrow, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: _controller.value.isBuffering
                      ? const CircularProgressIndicator()
                      : null,
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: _buildText(),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: VideoProgressIndicator(_controller,
              allowScrubbing: true, padding: EdgeInsets.all(0)),
        ),
      ],
    );
  }
}
