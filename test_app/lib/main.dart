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
  //final bool allowScrubbing = true;
  VideoPlayerController _controller;
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

  String convertMinToSec(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds;
    return '$minutes:$seconds';
  }

  Widget _buildPlayer() {
    return Center(
      child: _controller.value.initialized ? _buildPlayerStack() : Container(),
    );
  }

  Widget _buildPlayerStack() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              children: [
                Container(
                  child: VideoPlayer(_controller),
                ),
                Container(
                  alignment: Alignment(0.9, 0.9),
                  child: AnimatedOpacity(
                    opacity: opacityLevel,
                    duration: Duration(seconds: 1),
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
                Container(
                  alignment: Alignment(1.1, 1.1),
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    padding: EdgeInsets.all(2.0),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
