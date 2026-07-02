import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:engez/core/theme/app_sizes.dart';
import 'package:engez/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:engez/data/models/alarm_sound_model.dart';

class AlarmScreen extends StatefulWidget {
  final String taskId;
  final String title;
  final String description;
  final String alarmSound;
  final int snoozeDuration;
  final Future<void> Function() onSnooze;
  final Future<void> Function() onStop;

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

  Future<String> _getRealIosPath(String savedPath, String name) async {
    if (Platform.isIOS) {
      final libDir = await getLibraryDirectory();
      final safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9.\-_]'), '_');
      return '${libDir.path}/Sounds/$safeName';
    }
    return savedPath;
  }

  Future<void> _playAlarmSound() async {
    final soundModel = AlarmSoundModel.fromKey(widget.alarmSound);
    if (soundModel.type == AlarmSoundType.defaultSound) {
      FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true);
    } else {
      if (Platform.isAndroid) {
        try {
          await _pickerChannel.invokeMethod('playRingtone', {'uri': soundModel.uri});
        } catch (e) {
          FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true);
        }
      } else if (Platform.isIOS) {
        if (soundModel.type == AlarmSoundType.custom) {
          try {
            final realPath = await _getRealIosPath(soundModel.uri, soundModel.fileName ?? soundModel.title);
            await _audioPlayer.setReleaseMode(ReleaseMode.loop);
            await _audioPlayer.play(DeviceFileSource(realPath));
          } catch (e) {
            FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true);
          }
        } else {
          FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true);
        }
      }
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

  void _stop() async {
    _stopRingtone();
    await widget.onStop();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _snooze() async {
    _stopRingtone();
    await widget.onSnooze();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

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
                        '${l.alarmSnooze} (${widget.snoozeDuration}m)',
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
                        l.alarmStop,
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
