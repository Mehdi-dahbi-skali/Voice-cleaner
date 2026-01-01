import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'package:http_parser/http_parser.dart';

/// Recording Screen
/// 
/// Screen for recording audio
class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  // Mobile/Web upload logic (preserved from original)
  Future<void> _uploadAudioFileMobile(String filePath) async {
    final uri = Uri.parse('http://localhost:8085/audio/upload');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    try {
      final response = await request.send();
      debugPrint('Upload response: ${response.statusCode}');
    } catch (e) {
      debugPrint('Upload error: $e');
    }
  }

  Future<void> _uploadAudioFileWeb(String filePath) async {
    // Placeholder for web upload
    debugPrint('Web upload placeholder for $filePath');
  }

  // Recording state: 'idle', 'recording', 'paused', 'processing'
  String _recordingState = 'idle';
  Duration _recordingDuration = Duration.zero;
  Timer? _durationTimer;
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _recordingPath;
  DateTime? _recordingStartTime;
  Duration _accumulatedDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    await Permission.microphone.request();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _startTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _recordingState == 'recording') {
        setState(() {
          final now = DateTime.now();
          _recordingDuration = _accumulatedDuration + now.difference(_recordingStartTime!);
        });
      }
    });
  }

  void _stopTimer() {
    _durationTimer?.cancel();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        _recordingPath = '${directory.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(const RecordConfig(), path: _recordingPath!);
        _recordingStartTime = DateTime.now();
        _accumulatedDuration = Duration.zero;
        setState(() {
          _recordingState = 'recording';
        });
        _startTimer();
      }
    } catch (e) {
      debugPrint('Start error: $e');
    }
  }

  Future<void> _pauseRecording() async {
    await _audioRecorder.pause();
    _stopTimer();
    final now = DateTime.now();
    _accumulatedDuration += now.difference(_recordingStartTime!);
    setState(() {
      _recordingState = 'paused';
    });
  }

  Future<void> _resumeRecording() async {
    await _audioRecorder.resume();
    _recordingStartTime = DateTime.now();
    _startTimer();
    setState(() {
      _recordingState = 'recording';
    });
  }

  Future<void> _saveRecording() async {
    _stopTimer();
    final path = await _audioRecorder.stop();
    if (path != null) {
      setState(() {
        _recordingState = 'processing';
      });
      
      if (kIsWeb) {
        await _uploadAudioFileWeb(path);
      } else {
        await _uploadAudioFileMobile(path);
      }
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      });
    }
  }

  Future<void> _cancelRecording() async {
    _stopTimer();
    await _audioRecorder.stop();
    if (_recordingPath != null) {
      final file = File(_recordingPath!);
      if (await file.exists()) await file.delete();
    }
    setState(() {
      _recordingState = 'idle';
      _recordingDuration = Duration.zero;
      _accumulatedDuration = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recorder', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _recordingState == 'processing' ? _buildProcessingView() : _buildRecordingView(),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          const Text('Processing your audio...', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildRecordingView() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Text(
          _recordingState == 'recording' ? 'Recording' : 
          _recordingState == 'paused' ? 'Paused' : 'Ready',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          _formatDuration(_recordingDuration),
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w200,
            color: _recordingState == 'recording' ? Colors.red : Colors.black87,
          ),
        ),
        const Spacer(),
        
        // Waveform Visualizer
        Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(20, (index) {
              return Container(
                width: 3,
                height: _recordingState == 'recording' ? (index % 5 + 2) * 10.0 : 4.0,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _recordingState == 'recording' ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ),
        
        const Spacer(),
        
        // Controls (Figma PDF 6 & 7)
        Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: _buildControls(),
        ),
      ],
    );
  }

  Widget _buildControls() {
    if (_recordingState == 'idle') {
      return GestureDetector(
        onTap: _startRecording,
        child: Container(
          height: 100,
          width: 100,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mic, size: 50, color: Colors.white),
        ),
      );
    }

    if (_recordingState == 'recording') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSmallButton(Icons.close, Colors.grey, _cancelRecording, 'Cancel'),
          GestureDetector(
            onTap: _saveRecording,
            child: Container(
              height: 100,
              width: 100,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.stop, size: 50, color: Colors.white),
            ),
          ),
          _buildSmallButton(Icons.pause, Colors.orange, _pauseRecording, 'Pause'),
        ],
      );
    }

    // Paused State (Figma PDF 7)
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLabelButton('Delete', Icons.delete_outline, Colors.red, _cancelRecording),
        GestureDetector(
          onTap: _resumeRecording,
          child: Container(
            height: 100,
            width: 100,
            decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow, size: 50, color: Colors.white),
          ),
        ),
        _buildLabelButton('Save', Icons.check, Colors.green, _saveRecording),
      ],
    );
  }

  Widget _buildSmallButton(IconData icon, Color color, VoidCallback onTap, String tooltip) {
    return Container(
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onTap,
        iconSize: 32,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildLabelButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Column(
      children: [
        _buildSmallButton(icon, color, onTap, label),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
