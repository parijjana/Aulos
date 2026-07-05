import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aulos/domain/library/smart_playlist_rule.dart';
import 'package:aulos/presentation/viewmodels/playlist_view_model.dart';

class SmartPlaylistBuilderDialog extends StatefulWidget {
  const SmartPlaylistBuilderDialog({super.key});

  @override
  State<SmartPlaylistBuilderDialog> createState() => _SmartPlaylistBuilderDialogState();
}

class _SmartPlaylistBuilderDialogState extends State<SmartPlaylistBuilderDialog> {
  final _nameController = TextEditingController(text: 'Smart Playlist');
  final _limitController = TextEditingController();
  bool _matchAll = true;
  final List<SmartPlaylistRule> _rules = [];

  @override
  void initState() {
    super.initState();
    // Start with one empty rule
    _addEmptyRule();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _addEmptyRule() {
    setState(() {
      _rules.add(SmartPlaylistRule(
        field: RuleField.title,
        operator: RuleOperator.contains,
        value: '',
      ));
    });
  }

  void _removeRule(int index) {
    setState(() {
      _rules.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: Colors.grey[950]?.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'CREATE SMART PLAYLIST',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'PLAYLIST NAME',
                  labelStyle: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.0),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MATCH CRITERIA',
                    style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  DropdownButton<bool>(
                    value: _matchAll,
                    dropdownColor: Colors.grey[900],
                    style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: true, child: Text('ALL RULES (AND)')),
                      DropdownMenuItem(value: false, child: Text('ANY RULE (OR)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _matchAll = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(_rules.length, (index) => _buildRuleRow(index, theme)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _addEmptyRule,
                icon: const Icon(Icons.add, size: 14, color: Colors.cyanAccent),
                label: const Text('ADD RULE', style: TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _limitController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'LIMIT TRACK COUNT (OPTIONAL)',
                  labelStyle: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.0),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      if (_nameController.text.isNotEmpty) {
                        final limit = int.tryParse(_limitController.text);
                        final config = SmartPlaylistConfig(
                          rules: _rules.where((r) => r.operator == RuleOperator.isTrue || r.operator == RuleOperator.isFalse || r.value.isNotEmpty).toList(),
                          matchAll: _matchAll,
                          limit: limit,
                        );
                        final playlistVM = context.read<PlaylistViewModel>();
                        await playlistVM.saveSmartPlaylist(_nameController.text, config);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    child: Text('CREATE', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleRow(int index, ThemeData theme) {
    final rule = _rules[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<RuleField>(
              value: rule.field,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              ),
              items: RuleField.values.map((f) {
                return DropdownMenuItem(
                  value: f,
                  child: Text(f.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (field) {
                if (field != null) {
                  setState(() {
                    _rules[index] = SmartPlaylistRule(
                      field: field,
                      operator: rule.operator,
                      value: rule.value,
                    );
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<RuleOperator>(
              value: rule.operator,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              ),
              items: RuleOperator.values.map((op) {
                return DropdownMenuItem(
                  value: op,
                  child: Text(op.name.replaceAll('Operator.', '').toUpperCase()),
                );
              }).toList(),
              onChanged: (op) {
                if (op != null) {
                  setState(() {
                    _rules[index] = SmartPlaylistRule(
                      field: rule.field,
                      operator: op,
                      value: rule.value,
                    );
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          if (rule.operator != RuleOperator.isTrue && rule.operator != RuleOperator.isFalse)
            Expanded(
              flex: 3,
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(
                  hintText: 'Value',
                  hintStyle: TextStyle(color: Colors.white24),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                ),
                onChanged: (val) {
                  _rules[index] = SmartPlaylistRule(
                    field: rule.field,
                    operator: rule.operator,
                    value: val,
                  );
                },
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
            onPressed: () => _removeRule(index),
          ),
        ],
      ),
    );
  }
}
