import 'package:flutter/material.dart';

class ExpandableSearch extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool expanded;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  final ValueChanged<String>? onChanged;

  const ExpandableSearch({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.expanded,
    required this.onToggle,
    required this.onSubmitted,
    required this.onClear,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final double targetWidth = expanded
        ? (screenWidth < 380 ? 120 : 200)
        : 40;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: targetWidth,
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              onToggle(!expanded);
              if (expanded) {
                onClear();
              } else {
                focusNode.requestFocus();
              }
            },
            child: SizedBox(
              width: 40,
              height: 36,
              child: Icon(
                Icons.search,
                size: 18,
                color: expanded ? theme.colorScheme.primary : null,
              ),
            ),
          ),
          if (expanded)
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 13),
                onSubmitted: onSubmitted,
                onChanged: onChanged,
              ),
            ),
        ],
      ),
    );
  }
}
