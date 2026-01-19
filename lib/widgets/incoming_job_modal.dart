import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../l10n/app_localizations.dart';
import '../core/app_colors.dart';
import '../core/localization_helper.dart';

class IncomingJobModal extends StatefulWidget {
  final Map<String, dynamic> job;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingJobModal({
    super.key,
    required this.job,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<IncomingJobModal> createState() => _IncomingJobModalState();
}

class _IncomingJobModalState extends State<IncomingJobModal> {
  int _secondsRemaining = 30;
  Timer? _timer;
  AudioPlayer? _ringtonePlayer;
  bool _isProcessingAction = false;
  bool _hasPlayedRingtone = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Play ringtone after frame renders (works on mobile)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playRingtone();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopRingtone();
    super.dispose();
  }

  Future<void> _stopRingtone() async {
    try {
      await _ringtonePlayer?.stop();
      await _ringtonePlayer?.dispose();
      _ringtonePlayer = null;
    } catch (e) {
      debugPrint('Error stopping ringtone: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        _handleAction(false);
      }
    });
  }

  Future<void> _playRingtone() async {
    // Skip audio on web due to format compatibility issues
    if (kIsWeb) {
      debugPrint('Skipping ringtone on web platform');
      return;
    }

    if (_hasPlayedRingtone) return;
    _hasPlayedRingtone = true;

    try {
      _ringtonePlayer = AudioPlayer();

      // Configure audio context for mobile to ensure sound plays even if muted
      await AudioPlayer.global.setAudioContext(
        const AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: [
              AVAudioSessionOptions.defaultToSpeaker,
              AVAudioSessionOptions.mixWithOthers,
            ],
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.alarm,
            audioFocus: AndroidAudioFocus.gainTransient,
          ),
        ),
      );

      // Loop the ringtone until action is taken
      await _ringtonePlayer!.setReleaseMode(ReleaseMode.loop);
      await _ringtonePlayer!.setSource(AssetSource('audio/incoming_job.mp3'));
      await _ringtonePlayer!.resume();
      debugPrint('Ringtone started playing');
    } catch (e) {
      debugPrint('Error playing ringtone: $e');
    }
  }

  Future<void> _handleAction(bool accepted) async {
    if (_isProcessingAction) return;
    _isProcessingAction = true;

    _timer?.cancel();

    // Stop the ringtone immediately
    await _stopRingtone();

    // Skip audio on web due to format compatibility issues
    if (!kIsWeb) {
      // Create a new player for the action sound
      final actionPlayer = AudioPlayer();

      try {
        // Configure audio context for mobile
        await AudioPlayer.global.setAudioContext(
          const AudioContext(
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.playback,
              options: [
                AVAudioSessionOptions.defaultToSpeaker,
                AVAudioSessionOptions.mixWithOthers,
              ],
            ),
            android: AudioContextAndroid(
              isSpeakerphoneOn: true,
              stayAwake: true,
              contentType: AndroidContentType.music,
              usageType: AndroidUsageType.notification,
              audioFocus: AndroidAudioFocus.gainTransient,
            ),
          ),
        );

        // Use the same sound for both accept and decline (per project specification)
        const String actionSoundPath = 'audio/accept.mp3';

        await actionPlayer.setReleaseMode(ReleaseMode.stop);
        await actionPlayer.setSource(AssetSource(actionSoundPath));
        await actionPlayer.resume();
        debugPrint('Action sound played: $actionSoundPath');

        // Delay to let the sound be heard before closing
        await Future.delayed(const Duration(milliseconds: 600));

        try {
          await actionPlayer.stop();
          await actionPlayer.dispose();
        } catch (e) {
          debugPrint('Error disposing action player: $e');
        }
      } catch (e) {
        debugPrint('Error playing action sound: $e');
        try {
          await actionPlayer.dispose();
        } catch (_) {}
      }
    }

    if (mounted) {
      if (accepted) {
        widget.onAccept();
      } else {
        widget.onDecline();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.only(
                top:
                    80, // Increased top padding to make more space for the timer section
                left: 24,
                right: 24,
                bottom: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.newJobRequest.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primaryOrangeStart,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildJobDetails(),
                    const SizedBox(height: 32),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -45,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 74,
                      height: 74,
                      child: CircularProgressIndicator(
                        value: _secondsRemaining / 30,
                        strokeWidth: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _secondsRemaining > 10
                              ? AppColors.primaryOrangeStart
                              : Colors.redAccent,
                        ),
                      ),
                    ),
                    Text(
                      '${LocalizationHelper.convertBengaliToEnglish(_secondsRemaining)}s',
                      style: TextStyle(
                        color: _secondsRemaining > 10
                            ? Colors.white
                            : Colors.redAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobDetails() {
    final l10n = AppLocalizations.of(context)!;
    final String serviceName = LocalizationHelper.getLocalizedServiceName(
      context,
      widget.job['serviceKey'] ?? widget.job['service'],
    );
    final String timeType = LocalizationHelper.getLocalizedTimeType(
      context,
      widget.job,
    );
    final String eta = LocalizationHelper.getLocalizedEta(context, widget.job);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.darkNavyStart.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          LocalizationHelper.getLocalizedCustomerName(
                            context,
                            widget.job['customer'],
                          ),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${LocalizationHelper.convertBengaliToEnglish(widget.job['price'] ?? '1,499')}',
                        style: const TextStyle(
                          color: AppColors.primaryOrangeStart,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        l10n.earning,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 40, color: Colors.white24),
              _buildInfoRow(
                Icons.location_on,
                LocalizationHelper.getLocalizedLocation(
                  context,
                  widget.job['location'],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(Icons.event_available, timeType),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      Icons.directions_car,
                      LocalizationHelper.convertBengaliToEnglish(
                        widget.job['distance'] ?? '2.4 km',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.timer, eta),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryOrangeStart, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              _handleAction(false);
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: Colors.white54),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.decline,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _handleAction(true);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: AppColors.primaryOrangeStart,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.accept,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
