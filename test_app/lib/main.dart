import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

void main() => runApp(VideoApp());

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
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
        FlatButton(
          onPressed: () => setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          }),
          child: Center(
            child: _controller.value.isPlaying
              ? Icon(Icons.pause, color: Colors.white)
              : Icon(Icons.play_arrow, color: Colors.white),
          ),
        ),
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

// floatingActionButton: FloatingActionButton(
//   onPressed: () {
//     setState(() {
//       _controller.value.isPlaying
//           ? _controller.pause()
//           : _controller.play();
//     });
//   },
//   child: Icon(
//     _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//   ),
// ),
