import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

void main() => runApp(VideoApp());

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  bool _finishedPlaying = false;
  double _opacityLevel = 1.0;
  Duration vidDuration, vidPosition;
  VideoPlayerController _controller;
  TextEditingController _textController;

  String mediaURL =
      // 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
      'https://dash.akamaized.net/envivio/EnvivioDash3/manifest.mpd';

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(mediaURL)
      ..initialize().then((_) {
        setState(() {});
        // Ensure the first frame is shown after the video
        // is initialized, even before the play button has been pressed.
        setState(() => vidDuration = _controller.value.duration);
      });
    _controller.addListener(_videoListener);
    _textController = TextEditingController();
  }

  void _videoListener() {
    if (this._controller.value.duration == this._controller.value.position) {
      setState(() {
        this._finishedPlaying = true;
        this._opacityLevel = 1;
      });
    }
    setState(() => vidPosition = _controller.value.position);
  }

  void _changeOpacity() {
    setState(() => _opacityLevel = _opacityLevel == 0.0 ? 1.0 : 0.0);
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
          controller: _textController,
          decoration: InputDecoration(hintText: "Enter URL"),
        ),
        Container(
          alignment: Alignment.center,
          child: RaisedButton(
            onPressed: () async {
              mediaURL = _textController.text;
              setState(() async {
                _controller = VideoPlayerController.network(mediaURL);
                await _controller.initialize();
                setState(() => vidDuration = _controller.value.duration);
                _controller.addListener(_videoListener);
              });
            },
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
      opacity: _opacityLevel,
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
                    opacity: _opacityLevel,
                    duration: Duration(seconds: 3),
                    child: FlatButton(
                      onPressed: () => setState(() {
                        if (_finishedPlaying) {
                          _controller.seekTo(Duration.zero);
                          _controller.play();
                          setState(() {
                            _finishedPlaying = false;
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
                        child: _finishedPlaying
                            ? Icon(Icons.replay, color: Colors.white)
                            : (_controller.value.isPlaying)
                                ? Icon(Icons.pause, color: Colors.white)
                                : Icon(Icons.play_arrow, color: Colors.white),
                      ),
                    ),
                  ),
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

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _textController.dispose();
  }
}
