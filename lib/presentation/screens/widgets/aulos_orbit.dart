import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

class AulosOrbit extends StatefulWidget {
  final List<dynamic> items;
  final Widget Function(dynamic item) itemBuilder;
  final Function(dynamic item) onTap;

  const AulosOrbit({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onTap,
  });

  @override
  State<AulosOrbit> createState() => _AulosOrbitState();
}

class _AulosOrbitState extends State<AulosOrbit> {
  late PageController _pageController;
  double _currentPage = 0.0;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.4, initialPage: 0);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        if (widget.items.isNotEmpty) {
          widget.onTap(
            widget.items[_currentPage.round() % widget.items.length],
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(child: Text('No items to display'));
    }

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Listener(
        onPointerSignal: (pointerSignal) {
          if (pointerSignal is PointerScrollEvent) {
            if (pointerSignal.scrollDelta.dy > 0) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            } else {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            }
          }
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final double relativePosition = index - _currentPage;

            final double scale = (1 - (relativePosition.abs() * 0.25)).clamp(
              0.4,
              1.0,
            );
            final double opacity = (1 - (relativePosition.abs() * 0.4)).clamp(
              0.1,
              1.0,
            );
            final double rotation = relativePosition * -0.6;
            final double translationX = relativePosition * 60;

            return Center(
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015)
                  ..translate(translationX, relativePosition.abs() * 40)
                  ..scale(scale)
                  ..rotateY(rotation),
                alignment: Alignment.center,
                child: Opacity(
                  opacity: opacity,
                  child: GestureDetector(
                    onTap: () => widget.onTap(widget.items[index]),
                    child: widget.itemBuilder(widget.items[index]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
