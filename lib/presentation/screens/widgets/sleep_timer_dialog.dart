import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';

class SleepTimerDialog extends StatefulWidget {
  const SleepTimerDialog({super.key});

  @override
  State<SleepTimerDialog> createState() => _SleepTimerDialogState();
}

class _SleepTimerDialogState extends State<SleepTimerDialog> {
  double _customMinutes = 30.0;

  @override
  Widget build(BuildContext context) {
    final playerVM = context.watch<PlayerViewModel>();
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final isActive = playerVM.isSleepTimerActive == true;
final remaining = playerVM.sleepTimeRemaining;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: AlertDialog(
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        title: Center(
          child: Text(
            'SLEEP TIMER',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive) ...[
              const Icon(
                Icons.snooze_rounded,
                size: 48,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              Text(
                'Timer Active',
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatDuration(remaining),
                style: TextStyle(
                  color: onSurface,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  playerVM.cancelSleepTimer();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text('CANCEL TIMER'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.redAccent, width: 1),
                  ),
                ),
              ),
            ] else ...[
              // Preset options
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [5, 15, 30, 45, 60].map((mins) {
                  return InkWell(
                    onTap: () {
                      playerVM.startSleepTimer(Duration(minutes: mins));
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${mins}m',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Divider(color: onSurface.withValues(alpha: 0.1)),
              const SizedBox(height: 16),
              Text(
                'Custom Duration: ${_customMinutes.toInt()} minutes',
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: theme.colorScheme.primary,
                  inactiveTrackColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                  thumbColor: theme.colorScheme.primary,
                  overlayColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                  valueIndicatorColor: theme.colorScheme.primary,
                  valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                ),
                child: Slider(
                  value: _customMinutes,
                  min: 1.0,
                  max: 120.0,
                  divisions: 119,
                  label: '${_customMinutes.toInt()}m',
                  onChanged: (val) {
                    setState(() {
                      _customMinutes = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'CLOSE',
                      style: TextStyle(color: onSurface.withValues(alpha: 0.5)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      playerVM.startSleepTimer(Duration(minutes: _customMinutes.toInt()));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('START TIMER'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
