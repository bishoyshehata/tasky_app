import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:tasky/core/theme/app_sizes.dart';

class AlarmScreen extends StatefulWidget {
  final String taskId;
  final String title;
  final String description;
  final String alarmSound;
  final int snoozeDuration;
  final VoidCallback onSnooze;
  final VoidCallback onStop;

  const AlarmScreen({
    super.key,
    required this.taskId,
    required this.title,
    required this.description,
    required this.alarmSound,
    required this.snoozeDuration,
    required this.onSnooze,
    required this.onStop,
  });

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with SingleTickerProviderStateMixin {
  static const _pickerChannel = MethodChannel('com.bsh.tasky/ringtone_picker');
  
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
      if (Platform.isAndroid) {
        try {
          await _pickerChannel.invokeMethod('playRingtone', {'uri': uri});
        } catch (e) {
          FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true);
        }
      } else {
        try {
          await _audioPlayer.setReleaseMode(ReleaseMode.loop);
          await _audioPlayer.play(DeviceFileSource(uri));
        } catch (e) {
          FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true);
        }
      }
    } else {
      // Play default system alarm
      FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true);
    }
  }

  void _stopRingtone() {
    if (Platform.isAndroid) {
      _pickerChannel.invokeMethod('stopRingtone');
    }
    _audioPlayer.stop();
    FlutterRingtonePlayer().stop();
  }

  @override
  void dispose() {
    _stopRingtone();
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _stop() {
    _stopRingtone();
    widget.onStop();
    Navigator.of(context).pop();
  }

  void _snooze() {
    _stopRingtone();
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
                padding: EdgeInsets.all(AppW.w24),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.alarm,
                  size: AppSp.sp80,
                  color: colorScheme.primary,
                ),
              ),
            ),
            
            SizedBox(height: AppH.h40),
            
            // Current Time
            Text(
              DateFormat('h:mm a').format(DateTime.now()),
              style: TextStyle(
                fontSize: AppSp.sp64,
                fontWeight: FontWeight.w300,
                color: colorScheme.onSurface,
              ),
            ),
            
            SizedBox(height: AppH.h20),
            
            // Task Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppW.w24),
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSp.sp24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            
            SizedBox(height: AppH.h12),
            
            // Task Description
            if (widget.description.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppW.w32),
                child: Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppSp.sp16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              
            const Spacer(),
            
            // Action Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppW.w24, vertical: AppH.h32),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _snooze,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppH.h16),
                        side: BorderSide(color: colorScheme.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppR.r16),
                        ),
                      ),
                      child: Text(
                        'Snooze (${widget.snoozeDuration}m)',
                        style: TextStyle(fontSize: AppSp.sp18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(width: AppW.w16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _stop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: AppH.h16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppR.r16),
                        ),
                      ),
                      child: Text(
                        'Stop',
                        style: TextStyle(fontSize: AppSp.sp18, fontWeight: FontWeight.bold),
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
