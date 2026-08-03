// Diagnostic: where does the screenshot harness actually spend its time?
// Captures a trivial widget at three sizes, timing encode and pure-Dart decode
// separately. Not part of the harness; safe to delete.
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

Future<void> _run(WidgetTester tester, Size logical, double dpr) async {
  final key = GlobalKey();
  tester.view.physicalSize = Size(logical.width * dpr, logical.height * dpr);
  tester.view.devicePixelRatio = dpr;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          color: const Color(0xFF102030),
          child: const Center(child: Text('diag')),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));

  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;

  await tester.runAsync(() async {
    final t0 = DateTime.now();
    final ui.Image image = await boundary.toImage(pixelRatio: dpr);
    final t1 = DateTime.now();
    final ByteData? png = await image.toByteData(format: ui.ImageByteFormat.png);
    final t2 = DateTime.now();
    final ByteData? raw =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final t3 = DateTime.now();
    final decoded = img.decodePng(png!.buffer.asUint8List());
    final t4 = DateTime.now();

    int ms(DateTime a, DateTime b) => b.difference(a).inMilliseconds;
    // ignore: avoid_print
    print('  ${image.width}x${image.height} (${(image.width * image.height / 1e6).toStringAsFixed(1)}MP)'
        '  toImage=${ms(t0, t1)}ms'
        '  encodePNG=${ms(t1, t2)}ms'
        '  rawRGBA=${ms(t2, t3)}ms'
        '  decodePNG(pure-dart)=${ms(t3, t4)}ms'
        '  png=${(png.lengthInBytes / 1024).round()}KB'
        '  rawOk=${raw != null}  decodedOk=${decoded != null}');
  });
}

void main() {
  testWidgets('16.4MP — what the harness actually does', (t) async {
    await _run(t, const Size(2560, 1600), 2.0);
  });
  testWidgets('4.1MP — corrected size', (t) async {
    await _run(t, const Size(1280, 800), 2.0);
  });
  testWidgets('1.0MP — small', (t) async {
    await _run(t, const Size(640, 400), 2.0);
  });
}
