import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

/// Recording Screen
/// 
/// Screen for recording audio
class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  // Recording state: 'idle', 'recording', 'paused', 'processing'
  String _recordingState = 'idle';
  
  // Recording duration (for display)
  Duration _recordingDuration = Duration.zero;
  
  // Timer for updating duration display
  Timer? _durationTimer;
  
  // Audio recorder instance
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  // Recording file path
  String? _recordingPath;
  
  // Start time of recording
  DateTime? _recordingStartTime;
  
  // Accumulated duration when paused
  Duration _accumulatedDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _checkMicrophonePermission();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  /// Check and request microphone permission
  Future<void> _checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      final result = await Permission.microphone.request();
      if (!result.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission is required to record audio'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Start recording timer
  void _startTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _recordingState == 'recording') {
        setState(() {
          final now = DateTime.now();
          _recordingDuration = _accumulatedDuration + 
              now.difference(_recordingStartTime!);
        });
      }
    });
  }

  /// Stop recording timer
  void _stopTimer() {
    _durationTimer?.cancel();
  }

  /// Handle start/stop recording
  Future<void> _handleStartStop() async {
    // Check permission before starting
    final hasPermission = await Permission.microphone.isGranted;
    if (!hasPermission) {
      await _checkMicrophonePermission();
      return;
    }

    setState(() {
      if (_recordingState == 'idle') {
        _startRecording();
      } else if (_recordingState == 'recording' || _recordingState == 'paused') {
        _stopRecording();
      }
    });
  }

  /// Start recording
  Future<void> _startRecording() async {
    try {
      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'recording_$timestamp.m4a';
      
      // Try to get directory, but fallback to letting record package handle it
      try {
        final directory = await getApplicationDocumentsDirectory();
        _recordingPath = '${directory.path}/$fileName';
      } catch (e) {
        // If path_provider fails, use a simple path (record package will handle it)
        _recordingPath = fileName;
      }

      // Check if recorder is available
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _recordingPath!,
        );

        _recordingStartTime = DateTime.now();
        _accumulatedDuration = Duration.zero;
        _recordingState = 'recording';
        _startTimer();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission denied'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Stop recording
  Future<void> _stopRecording() async {
    try {
      _stopTimer();
      
      if (_recordingState == 'recording') {
        // Save accumulated duration
        final now = DateTime.now();
        _accumulatedDuration += now.difference(_recordingStartTime!);
      }
      
      final path = await _audioRecorder.stop();
      
      if (path != null && path.isNotEmpty) {
        _recordingPath = path;
        // Show processing screen
        setState(() {
          _recordingState = 'processing';
        });
        
        // TODO: Here you can upload the file to your Spring Boot backend
        // Example:
        // final apiService = ApiService();
        // await apiService.uploadAudio(_recordingPath!);
        
        // After 5 seconds, navigate to home screen
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          }
        });
      } else {
        // If recording was cancelled or failed
        setState(() {
          _recordingState = 'idle';
          _recordingDuration = Duration.zero;
          _accumulatedDuration = Duration.zero;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _recordingState = 'idle';
        _recordingDuration = Duration.zero;
        _accumulatedDuration = Duration.zero;
      });
    }
  }

  /// Handle pause/resume recording
  Future<void> _handlePause() async {
    try {
      if (_recordingState == 'recording') {
        // Pause recording
        await _audioRecorder.pause();
        _stopTimer();
        
        // Save accumulated duration
        final now = DateTime.now();
        _accumulatedDuration += now.difference(_recordingStartTime!);
        
        setState(() {
          _recordingState = 'paused';
        });
      } else if (_recordingState == 'paused') {
        // Resume recording
        await _audioRecorder.resume();
        _recordingStartTime = DateTime.now();
        _startTimer();
        
        setState(() {
          _recordingState = 'recording';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error pausing/resuming: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle cancel recording
  Future<void> _handleCancel() async {
    try {
      _stopTimer();
      
      // Stop and discard recording
      await _audioRecorder.stop();
      
      // Delete the recording file if it exists
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      setState(() {
        _recordingState = 'idle';
        _recordingDuration = Duration.zero;
        _accumulatedDuration = Duration.zero;
        _recordingPath = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Format duration as MM:SS
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Build processing view (loading screen)
  Widget _buildProcessingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              strokeWidth: 4,
            ),
            
            const SizedBox(height: 32),
            
            // Processing message
            Text(
              'Audio is processing',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Please wait...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build recording view (normal recording interface)
  Widget _buildRecordingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              'Recording',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Recording duration display
            if (_recordingState != 'idle')
              Text(
                _formatDuration(_recordingDuration),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            
            const SizedBox(height: 64),
            
            // Main action button (Start/Stop)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _recordingState == 'recording'
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: (_recordingState == 'recording'
                            ? Colors.red
                            : Theme.of(context).colorScheme.primary)
                        .withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _handleStartStop,
                icon: Icon(
                  _recordingState == 'idle'
                      ? Icons.mic
                      : Icons.stop,
                  size: 48,
                  color: Colors.white,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action buttons row (Pause and Cancel)
            if (_recordingState != 'idle' && _recordingState != 'processing')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cancel button
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    child: IconButton(
                      onPressed: _handleCancel,
                      icon: const Icon(
                        Icons.close,
                        size: 28,
                        color: Colors.black87,
                      ),
                      tooltip: 'Cancel',
                    ),
                  ),
                  
                  const SizedBox(width: 40),
                  
                  // Pause/Resume button
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange[300],
                    ),
                    child: IconButton(
                      onPressed: _handlePause,
                      icon: Icon(
                        _recordingState == 'paused'
                            ? Icons.play_arrow
                            : Icons.pause,
                        size: 28,
                        color: Colors.white,
                      ),
                      tooltip: _recordingState == 'paused'
                          ? 'Resume'
                          : 'Pause',
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 32),
            
            // Status text
            Text(
              _recordingState == 'idle'
                  ? 'Tap the microphone to start recording'
                  : _recordingState == 'recording'
                      ? 'Recording in progress...'
                      : 'Recording paused',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo and title (same as home screen)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Mic logo
                  Icon(
                    Icons.mic,
                    size: 32,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  // Title
                  Text(
                    'Voice Recorder',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: _recordingState == 'processing'
                  ? _buildProcessingView()
                  : _buildRecordingView(),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar (hidden during processing)
      bottomNavigationBar: _recordingState == 'processing' ? null : _buildBottomNavBar(),
    );
  }

  /// Build bottom navigation bar (same as home screen)
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Record is selected
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Record',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigate to home screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
              break;
            case 1:
              // Already on recording screen
              break;
            case 2:
              // Navigate to settings screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
              break;
            case 3:
              // Navigate to profile screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}
