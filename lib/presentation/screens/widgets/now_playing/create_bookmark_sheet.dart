import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';

class CreateBookmarkSheet extends StatefulWidget {
  final PlayerViewModel playerVM;

  const CreateBookmarkSheet({super.key, required this.playerVM});

  @override
  State<CreateBookmarkSheet> createState() => _CreateBookmarkSheetState();
}

class _CreateBookmarkSheetState extends State<CreateBookmarkSheet> {
  late RangeValues _values;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    final pos = widget.playerVM.position.inMilliseconds.toDouble();
    final dur = widget.playerVM.duration.inMilliseconds.toDouble();
    // Default to a 30 second clip or until end
    final end = (pos + 30000).clamp(pos, dur > 0 ? dur : pos + 30000);
    _values = RangeValues(pos, end);
    _titleController = TextEditingController(text: 'Clip from ${widget.playerVM.displayTitle}');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _formatMs(double ms) {
    final d = Duration(milliseconds: ms.toInt());
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dur = widget.playerVM.duration.inMilliseconds.toDouble();
    final maxDur = dur > 0 ? dur : _values.end + 1000;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'CREATE CLIP BOOKMARK', 
            style: theme.textTheme.labelMedium?.copyWith(
              letterSpacing: 2, 
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            )
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Bookmark Title',
              filled: true,
              fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('START', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                  Text(_formatMs(_values.start), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('END', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                  Text(_formatMs(_values.end), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _values,
            min: 0,
            max: maxDur,
            onChanged: (val) => setState(() => _values = val),
            activeColor: theme.colorScheme.primary,
            inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.playerVM.saveBookmark(
                  title: _titleController.text,
                  startMs: _values.start.toInt(),
                  endMs: _values.end.toInt(),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.all(16),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('SAVE BOOKMARK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
