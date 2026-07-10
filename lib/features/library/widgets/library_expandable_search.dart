import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';

class LibraryExpandableSearch extends StatefulWidget {
  final LibraryViewModel viewModel;
  const LibraryExpandableSearch({super.key, required this.viewModel});

  @override
  State<LibraryExpandableSearch> createState() => _LibraryExpandableSearchState();
}

class _LibraryExpandableSearchState extends State<LibraryExpandableSearch> {
  bool _expanded = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final double targetWidth = _expanded
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
              setState(() => _expanded = !_expanded);
              if (!_expanded) {
                _controller.clear();
                widget.viewModel.setSearchQuery('');
              } else {
                _focusNode.requestFocus();
              }
            },
            child: SizedBox(
              width: 40,
              height: 36,
              child: Icon(
                Icons.search,
                size: 18,
                color: _expanded ? theme.colorScheme.primary : null,
              ),
            ),
          ),
          if (_expanded)
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: 'Search library...',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 13),
                onChanged: (val) => widget.viewModel.setSearchQuery(val),
              ),
            ),
        ],
      ),
    );
  }
}
