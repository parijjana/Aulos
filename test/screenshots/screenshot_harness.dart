// Widget-level screenshot capture harness for Aulos.
//
// `flutter test` runs on the Dart VM and never links native macOS pods, so
// the broken `flutter run -d macos` build (audiotags 1.4.5 frb-v1/frb-v2
// mismatch) is irrelevant here. This harness pumps real widgets with
// stubbed/fake data inside `flutter test` and rasterizes them via
// RepaintBoundary, exactly like a golden test but writing plain PNGs to
// screenshots/harness/ instead of comparing against a golden master.
//
// IMPORTANT: by default `flutter test` renders all text using the "Ahem"
// test font (every glyph is a box), because the widget tests never load the
// real font files from disk/asset-bundle. We fix that by loading real TTFs
// with FontLoader inside `tester.runAsync`, before pumping.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Canvas size used for every capture: a generous desktop frame at 2x DPI,
/// matching what the task asked for.
const Size kCaptureLogicalSize = Size(1440, 900);
const double kCaptureDevicePixelRatio = 2.0;

/// Locates the Flutter SDK's bundled Material fonts on disk. These are the
/// same font files that every Flutter app ships automatically (via
/// `uses-material-design: true`) when built for real — `flutter test` alone
/// does not load them, so we load them explicitly here.
///
/// Resolved relative to the `flutter` binary on PATH so this works on any
/// machine/CI without hardcoding a path.
Directory _materialFontsDir() {
  final flutterBin = Process.runSync(
    Platform.isWindows ? 'where' : 'which',
    ['flutter'],
  ).stdout.toString().trim().split('\n').first;
  final resolved = File(flutterBin).resolveSymbolicLinksSync();
  // resolved is .../flutter/bin/flutter -> flutter SDK root is two dirs up.
  final sdkRoot = File(resolved).parent.parent.path;
  return Directory('$sdkRoot/bin/cache/artifacts/material_fonts');
}

bool _fontsLoaded = false;

/// Loads real, legible fonts into the test binding.
///
/// The app's theme (see lib/presentation/theme/aulos_audio_theme.dart)
/// requests fontFamily "Inter", but no Inter font asset is bundled in
/// pubspec.yaml anywhere in this repo (verified: no fonts: section, no
/// google_fonts dependency, no *.ttf/*.otf under assets/). That means in a
/// real build, Flutter cannot find "Inter" either and silently falls back to
/// platform font resolution. To keep the harness deterministic and legible
/// (rather than depending on whatever fonts happen to be installed on the
/// machine that renders it), we register Flutter's own bundled Roboto
/// (which is what ships as the automatic Material default in every real
/// Flutter build) under BOTH the "Roboto" family name and an "Inter" alias,
/// so every TextStyle in the app -- whether it explicitly asks for "Inter"
/// or leaves fontFamily null (falling back to the MaterialApp default) --
/// resolves to a real, legible glyph set instead of Ahem boxes.
///
/// We also load the MaterialIcons icon font, since every Icon(...) in this
/// app (Icons.play_arrow_rounded, etc.) is a MaterialIcons glyph, and would
/// otherwise render as a tofu box too.
Future<void> loadAppFonts() async {

  if (_fontsLoaded) return;
  final dir = _materialFontsDir();
  final robotoRegular = File('${dir.path}/Roboto-Regular.ttf');
  final robotoBold = File('${dir.path}/Roboto-Bold.ttf');
  final materialIcons = File('${dir.path}/MaterialIcons-Regular.otf');

  if (!robotoRegular.existsSync() || !materialIcons.existsSync()) {
    throw StateError(
      'Could not locate bundled Material fonts under ${dir.path}. '
      'Expected Roboto-Regular.ttf and MaterialIcons-Regular.otf. '
      'Is `flutter` on PATH and has the SDK been fully downloaded?',
    );
  }

  Future<ByteData> loadTtf(File f) async =>
      ByteData.view((await f.readAsBytes()).buffer);

  for (final family in ['Roboto', 'Inter']) {
    final loader = FontLoader(family)
      ..addFont(loadTtf(robotoRegular))
      ..addFont(loadTtf(robotoBold));
    await loader.load();
  }

  final iconLoader = FontLoader('MaterialIcons')
    ..addFont(loadTtf(materialIcons));
  await iconLoader.load();

  _fontsLoaded = true;
}

/// Generates a synthetic-but-real (decodable) cover-art PNG: a radial
/// gradient disc over a solid background, seeded so different indices look
/// visually distinct. This is fed to real widgets as `Uint8List` coverArt --
/// it is not a screenshot of a mock-up, it's fake *data* for a real image
/// decode + Image.memory render path.
Uint8List syntheticCoverArt({
  required int seed,
  int size = 512,
}) {
  final colors = <List<int>>[
    [0, 240, 255],
    [255, 111, 0],
    [186, 104, 200],
    [0, 200, 120],
    [255, 82, 82],
    [255, 214, 0],
  ];
  final base = colors[seed % colors.length];
  final image = img.Image(width: size, height: size);
  img.fill(image, color: img.ColorRgb8(base[0] ~/ 4, base[1] ~/ 4, base[2] ~/ 4));
  img.fillCircle(
    image,
    x: size ~/ 2,
    y: size ~/ 2,
    radius: size ~/ 3,
    color: img.ColorRgb8(base[0], base[1], base[2]),
  );
  img.fillCircle(
    image,
    x: size ~/ 2 - size ~/ 8,
    y: size ~/ 2 - size ~/ 8,
    radius: size ~/ 8,
    color: img.ColorRgb8(255, 255, 255),
  );
  return Uint8List.fromList(img.encodePng(image));
}

/// Pumps [child] at the standard capture size, settles, rasterizes the
/// [RepaintBoundary]-wrapped tree, and writes it to
/// `screenshots/harness/<name>.png`.
///
/// Must be called from within `tester.runAsync(() async { ... })` because
/// `toImage`/PNG encoding need real asset/image decoding.
///
/// Fails loudly (throws) if the resulting image is blank / a single flat
/// colour, instead of silently writing a useless PNG.
Future<File> captureWidget(
  WidgetTester tester, {
  required String name,
  required Widget child,
  Duration? settleTimeout,
}) async {
  tester.view.physicalSize = Size(
    kCaptureLogicalSize.width * kCaptureDevicePixelRatio,
    kCaptureLogicalSize.height * kCaptureDevicePixelRatio,
  );
  tester.view.devicePixelRatio = kCaptureDevicePixelRatio;
  addTearDown(tester.view.reset);

  final boundaryKey = GlobalKey();

  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: child,
    ),
  );

  // Let animations/tickers/async providers settle. Some screens (e.g. the
  // WinampVisualizer) run an infinite Ticker, so pumpAndSettle would hang --
  // give it a bounded number of frames instead.
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;

  // toImage()/toByteData() are real async engine round-trips (they depend on
  // a raster-thread callback), which never resolve inside flutter_test's
  // fake-async zone -- they MUST run inside tester.runAsync, or the awaited
  // Future simply never completes and the test hangs until the global
  // per-test timeout. File IO and PNG re-decoding for verification also need
  // real IO, so the whole tail of capture happens in one runAsync block.
  final file = await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(
      pixelRatio: kCaptureDevicePixelRatio,
    );
    final ByteData? pngBytes = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (pngBytes == null) {
      throw StateError('captureWidget($name): toByteData returned null');
    }

    _assertNotBlank(name: name, image: image, rawPng: pngBytes);

    final outDir = Directory(
      '${Directory.current.path}/screenshots/harness',
    );
    if (!outDir.existsSync()) {
      outDir.createSync(recursive: true);
    }
    final f = File('${outDir.path}/$name.png');
    await f.writeAsBytes(pngBytes.buffer.asUint8List());

    // Basic sanity on the dimensions we actually wrote.
    final decoded = img.decodePng(pngBytes.buffer.asUint8List());
    if (decoded == null) {
      throw StateError('captureWidget($name): wrote a file that is not a valid PNG');
    }
    final expectedW = (kCaptureLogicalSize.width * kCaptureDevicePixelRatio).round();
    final expectedH = (kCaptureLogicalSize.height * kCaptureDevicePixelRatio).round();
    if (decoded.width != expectedW || decoded.height != expectedH) {
      throw StateError(
        'captureWidget($name): expected ${expectedW}x$expectedH, got '
        '${decoded.width}x${decoded.height}',
      );
    }

    // ignore: avoid_print
    print('[capture] wrote ${f.path} (${decoded.width}x${decoded.height})');
    return f;
  });

  return file!;
}

/// Decodes the PNG and checks it is not a single flat colour (the classic
/// failure mode: a correctly-sized image that is entirely background
/// because the real content failed to render, or fonts came out blank).
void _assertNotBlank({
  required String name,
  required ui.Image image,
  required ByteData rawPng,
}) {
  final decoded = img.decodePng(rawPng.buffer.asUint8List());
  if (decoded == null) {
    throw StateError('captureWidget($name): could not decode PNG for blank-check');
  }

  // Sample a grid of pixels across the image and count distinct colours.
  final seen = <int>{};
  const samplesPerAxis = 40;
  for (var yi = 0; yi < samplesPerAxis; yi++) {
    for (var xi = 0; xi < samplesPerAxis; xi++) {
      final x = (decoded.width * xi / samplesPerAxis).floor();
      final y = (decoded.height * yi / samplesPerAxis).floor();
      final pixel = decoded.getPixel(x, y);
      seen.add(pixel.r.toInt() << 16 | pixel.g.toInt() << 8 | pixel.b.toInt());
      if (seen.length > 3) break; // early out, we only need to know > 1
    }
    if (seen.length > 3) break;
  }

  if (seen.length <= 1) {
    throw StateError(
      'captureWidget($name): image is a single flat colour '
      '(0x${seen.isEmpty ? '?' : seen.first.toRadixString(16)}) across '
      '$samplesPerAxis x $samplesPerAxis samples -- refusing to write a '
      'blank screenshot. This usually means the widget failed to render '
      'its real content (e.g. missing provider data) or is showing an '
      'empty/loading state.',
    );
  }
}
