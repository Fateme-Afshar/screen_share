import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScreenSharePage(),
    );
  }
}

class ScreenSharePage extends StatefulWidget {
  @override
  _ScreenSharePageState createState() => _ScreenSharePageState();
}


void startMediaProjectionService() async {
  const platform = MethodChannel("com.example.untitled1/media_projection");
  try {
    await platform.invokeMethod('startMediaProjectionService');
  } on PlatformException catch (e) {
    print("Failed to start service: '${e.message}'.");
  }
}

class _ScreenSharePageState extends State<ScreenSharePage> {
  final _localRenderer = RTCVideoRenderer();
  MediaStream? _localStream;

  @override
  void initState() {
    super.initState();
    _initRenderer();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _localStream?.dispose();
    super.dispose();
  }

  Future<void> _initRenderer() async {
    await _localRenderer.initialize();
  }

  Future<void> _startScreenCapture() async {
    try {
      // Get user media for screen capture

      final constraints = <String, dynamic>{
        'video':true,
        'audio': true,
      };

      _localStream = await navigator.mediaDevices.getDisplayMedia(constraints);
      _localRenderer.srcObject = _localStream;

      setState(() {});
    } catch (e) {
      print('Error starting screen capture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen Share Web Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_localRenderer.srcObject != null)
              Container(
                width: 800,
                height: 600,
                child: RTCVideoView(_localRenderer),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async{
                startMediaProjectionService();
                await _startScreenCapture();
              },
              child: Text('Start Screen Capture'),
            ),
          ],
        ),
      ),
    );
  }
}
