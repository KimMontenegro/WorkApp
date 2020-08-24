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
  final bool isBuffering = false;
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
        setState(() {});
      });
    _controller.addListener(() async {
      if (_controller.value.duration == _controller.value.position) {
        setState(() {
          finishedPlaying = true;
        });
      }
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

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Widget _buildPlayer() {
    return Center(
      child: _controller.value.initialized ? _buildPlayerStack() : Container(),
    );
  }

  Widget _buildPlayerStack() {
    return Stack(
      children: [
        _buildPlayerCore(),
        AnimatedOpacity(
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
        Align(
          alignment: Alignment.bottomCenter,
          child: VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
          ),
        ),
        Center(
            child: _controller.value.isBuffering
                ? const CircularProgressIndicator()
                : null),
      ],
    );
  }

  Widget _buildPlayerCore() {
    return Container(
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
