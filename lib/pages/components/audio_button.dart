import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class AudioRecordButton extends StatefulWidget {
  final Function(String)? onAudioSaved;
  final Function(String)? onAudioDeleted;
  final String?
      questionIdentifier; // To identify which question this belongs to

  //19-4
  final String
      questionId; // To identify which question this recording belongs to
  final Function(String, String)?
      onNewRecording; // Callback when a new recording is made

  const AudioRecordButton({
    Key? key,
    //19-4
    required this.questionId,
    this.onNewRecording,
    //19-4//
    this.onAudioSaved,
    this.onAudioDeleted,
    this.questionIdentifier,
  }) : super(key: key);

  @override
  _AudioRecordButtonState createState() => _AudioRecordButtonState();
}

class _AudioRecordButtonState extends State<AudioRecordButton> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _recordingPath;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayerListeners();
  }

  void _setupAudioPlayerListeners() {
    _playerStateSubscription =
        _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });
  }

  Future<void> startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      final directory = await getApplicationDocumentsDirectory();

      // Create filename with question identifier if provided
      String fileName =
          'recorded_audio_${DateTime.now().millisecondsSinceEpoch}';
      if (widget.questionIdentifier != null) {
        fileName = '${widget.questionIdentifier}_$fileName';
      }

      final path = '${directory.path}/$fileName.m4a';

      await _audioRecorder.start(const RecordConfig(), path: path);

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });

      // Start recording timer
      _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordingDuration = Duration(seconds: timer.tick);
          });
        }
      });
    } else {
      debugPrint("Microphone permission not granted");
    }
  }

  Future<void> stopRecording() async {
    _recordingTimer?.cancel();
    final path = await _audioRecorder.stop();

    setState(() {
      _isRecording = false;
      _recordingPath = path;
    });

    if (path != null) {
      // Notify parent widget about the new recording
      if (widget.onNewRecording != null) {
        widget.onNewRecording!(widget.questionId, path);
      }
    }
  }

  Future<void> playRecording() async {
    if (_recordingPath != null) {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        if (_position.inMilliseconds == 0 || _position >= _duration) {
          await _audioPlayer.play(DeviceFileSource(_recordingPath!));
        } else {
          await _audioPlayer.resume();
        }
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  void deleteRecording() {
    if (_recordingPath != null) {
      _audioPlayer.stop();
      final file = File(_recordingPath!);
      String deletedPath = _recordingPath!;
      file.delete().then((_) {
        setState(() {
          _recordingPath = null;
          _isPlaying = false;
          _position = Duration.zero;
          _duration = Duration.zero;
        });

        if (widget.onAudioDeleted != null) {
          widget.onAudioDeleted!(deletedPath);
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_recordingPath == null)
          // Circular recording button
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: _isRecording
                    ? Colors.red.withOpacity(0.3)
                    : Colors.purple.withOpacity(0.3),
                width: 8,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isRecording
                      ? Colors.red.withOpacity(0.2)
                      : Colors.purple.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: _isRecording ? Colors.red : Colors.purple,
                size: 30,
              ),
              onPressed: _isRecording ? stopRecording : startRecording,
            ),
          )
        else
          // Audio playback interface
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[100],
            ),
            child: Row(
              children: [
                // Play/Pause button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: playRecording,
                  ),
                ),
                const SizedBox(width: 12),
                // Waveform and progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Simplified waveform visualization
                      Container(
                        height: 24,
                        child: Row(
                          children: List.generate(20, (index) {
                            final height = 4.0 + (index % 3) * 4.0;
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 1),
                              width: 3,
                              height: height,
                              color: _position.inMilliseconds > 0 &&
                                      _duration.inMilliseconds > 0 &&
                                      index / 20 <
                                          _position.inMilliseconds /
                                              _duration.inMilliseconds
                                  ? Colors.purple
                                  : Colors.grey[400],
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Audio duration
                      Text(
                        '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.grey,
                    size: 24,
                  ),
                  onPressed: deleteRecording,
                ),
              ],
            ),
          ),
        if (_isRecording)
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Recording... ${_formatDuration(_recordingDuration)}',
              style: TextStyle(fontSize: 14, color: Colors.red),
            ),
          ),
      ],
    );
  }
}
