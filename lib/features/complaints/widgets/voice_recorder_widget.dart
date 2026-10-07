import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geo_tag_camera/app/theme.dart';

/// Voice Recording Widget — uses record 5.1.2 + audioplayers ^5.x
class VoiceRecorderWidget extends StatefulWidget {
  final Function(String path) onAudioRecorded;
  final VoidCallback? onAudioDeleted;

  const VoiceRecorderWidget({
    super.key,
    required this.onAudioRecorded,
    this.onAudioDeleted,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
  // record v5 uses AudioRecorder()
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedPath;
  int _recordDurationSeconds = 0;

  @override
  void dispose() {
    _recorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    // Explicit mic permission request via permission_handler
    final status = await Permission.microphone.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) _showPermissionDeniedDialog();
      return;
    }

    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        if (mounted) _showPermissionDeniedDialog();
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // record v5 API: start(RecordConfig, path: ...)
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _recordDurationSeconds = 0;
        _recordedPath = null;
      });

      _runTimer();
    } catch (e) {
      debugPrint('Voice Record Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not start recording: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _runTimer() async {
    while (_isRecording) {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isRecording || !mounted) break;
      setState(() => _recordDurationSeconds++);
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
        _recordedPath = path;
      });

      if (path != null) {
        widget.onAudioRecorded(path);
      }
    } catch (e) {
      debugPrint('Stop Record Error: $e');
    }
  }

  Future<void> _togglePlay() async {
    if (_recordedPath == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(DeviceFileSource(_recordedPath!));
      setState(() => _isPlaying = true);

      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    }
  }

  void _deleteAudio() {
    if (_recordedPath != null) {
      try {
        final file = File(_recordedPath!);
        if (file.existsSync()) file.deleteSync();
      } catch (_) {}
    }

    setState(() {
      _recordedPath = null;
      _isPlaying = false;
      _recordDurationSeconds = 0;
    });

    widget.onAudioDeleted?.call();
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Microphone Permission Required'),
        content: const Text(
          'Please allow microphone access to record your voice complaint.\n\n'
          'गोष्ट बोलून सांगण्यासाठी मायक्रोफोन परवानगी द्या.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(ctx);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isRecording ? AppColors.error : AppColors.outline,
          width: _isRecording ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                color: _isRecording ? AppColors.error : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isRecording
                      ? 'Recording… ${_formatDuration(_recordDurationSeconds)}'
                      : _recordedPath != null
                          ? '✅ Voice Recorded (${_formatDuration(_recordDurationSeconds)})'
                          : 'Record Voice Complaint (बोलून सांगा)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _isRecording ? AppColors.error : AppColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Not yet recording, no file
          if (_recordedPath == null && !_isRecording)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _startRecording,
                icon: const Icon(Icons.mic),
                label: const Text('Tap to Start Recording'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  foregroundColor: AppColors.primary,
                ),
              ),
            )

          // Currently recording
          else if (_isRecording)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _stopRecording,
                icon: const Icon(Icons.stop_circle_outlined),
                label: Text('Stop  ${_formatDuration(_recordDurationSeconds)}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            )

          // Recording finished — show play/delete/re-record
          else if (_recordedPath != null)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _togglePlay,
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(_isPlaying ? 'Pause' : 'Play Recording'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _deleteAudio,
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                  tooltip: 'Delete voice note',
                ),
                TextButton.icon(
                  onPressed: _startRecording,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Re-record'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
