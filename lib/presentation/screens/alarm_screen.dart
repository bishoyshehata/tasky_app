import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

class AlarmScreen extends StatefulWidget {
  final String title;
  final String description;
  final String alarmSound;
  final VoidCallback onSnooze;
  final VoidCallback onStop;

  const AlarmScreen({
    super.key,
    required this.title,
    required this.description,
    required this.alarmSound,
    required this.onSnooze,
    required this.onStop,
  });

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playAlarmSound();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  Future<void> _playAlarmSound() async {
    final soundData = widget.alarmSound;
    if (soundData.contains('|')) {
      final uri = soundData.split('|')[0];
      try {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(UrlSource(uri));
      } catch (e) {
        // Fallback to default system alarm
        FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true);
      }
    } else {
      // Play default system alarm
      FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true);
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    FlutterRingtonePlayer().stop();
    _controller.dispose();
    super.dispose();
  }

  void _stop() {
    _audioPlayer.stop();
    FlutterRingtonePlayer().stop();
    widget.onStop();
    Navigator.of(context).pop();
  }

  void _snooze() {
    _audioPlayer.stop();
    FlutterRingtonePlayer().stop();
    widget.onSnooze();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            // Pulsing Alarm Icon
            ScaleTransition(
              scale: _animation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.alarm,
                  size: 80,
                  color: colorScheme.primary,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Current Time
            Text(
              DateFormat('HH:mm').format(DateTime.now()),
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w300,
                color: colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Task Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Task Description
            if (widget.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              
            const Spacer(),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _snooze,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: colorScheme.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Snooze (10m)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _stop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Stop',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
