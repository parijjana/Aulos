import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HtmlText extends StatelessWidget {
  final String html;
  final TextStyle? style;
  final Function(Duration)? onTimestampTap;

  const HtmlText(this.html, {super.key, this.style, this.onTimestampTap});

  @override
  Widget build(BuildContext context) {
    // 1. Basic cleaning of HTML tags but preserve structural line breaks
    String text = html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'</p>'), '\n\n')
        .replaceAll(RegExp(r'<p>'), '')
        .replaceAll(RegExp(r'<li>'), '• ')
        .replaceAll(RegExp(r'</li>'), '\n')
        .replaceAll(RegExp(r'<ul>|</ul>|<ol>|</ol>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), ''); // Strip remaining tags

    text = text.trim().replaceAll(RegExp(r'\n{3,}'), '\n\n');

    final defaultStyle = style ?? TextStyle(
      fontSize: 14,
      height: 1.6,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
    );

    final highlightStyle = defaultStyle.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    );

    // 2. Multi-pattern parsing: Timestamps and URLs
    final List<InlineSpan> spans = [];
    
    // Combined regex for Timestamps (MM:SS, HH:MM:SS) and Web URLs
    final combinedRegex = RegExp(
      r'(\d{1,2}:\d{2}(?::\d{2})?)|(https?:\/\/[^\s\n<>"]+)',
      caseSensitive: false,
    );
    
    int lastMatchEnd = 0;
    for (final match in combinedRegex.allMatches(text)) {
      // Add text before the match
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }

      final matchedStr = match.group(0)!;
      final isUrl = matchedStr.startsWith('http');

      if (isUrl) {
        // Handle URL
        spans.add(
          TextSpan(
            text: matchedStr,
            style: highlightStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final uri = Uri.tryParse(matchedStr);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
          ),
        );
      } else {
        // Handle Timestamp
        final duration = _parseDuration(matchedStr);
        spans.add(
          TextSpan(
            text: matchedStr,
            style: highlightStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (onTimestampTap != null) {
                  onTimestampTap!(duration);
                }
              },
          ),
        );
      }

      lastMatchEnd = match.end;
    }

    // Add remaining text
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return Text.rich(
      TextSpan(children: spans),
      style: defaultStyle,
    );
  }

  Duration _parseDuration(String timestamp) {
    try {
      final parts = timestamp.split(':').map(int.parse).toList();
      if (parts.length == 2) {
        // MM:SS
        return Duration(minutes: parts[0], seconds: parts[1]);
      } else if (parts.length == 3) {
        // HH:MM:SS
        return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
      }
    } catch (_) {}
    return Duration.zero;
  }
}
