import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fooddoor/catalog.dart';
import 'package:fooddoor/screen.dart';

// Render the complete artboard, including scrollable content, at its design width.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final catalog = await loadCatalog();
  final dir = Directory('docs/screenshots')..createSync(recursive: true);
  FlutterError.onError = (e) {
    stderr.writeln(e.exceptionAsString());
    exit(2);
  };
  for (final board in catalog.values) {
    final key = GlobalKey();
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Material(
          child: FittedBox(
            child: RepaintBoundary(
              key: key,
              child: SizedBox(
                width: 375,
                height: board.height,
                child: ScreenView(
                  key: ValueKey(board.id),
                  board: board,
                  open: (_) {},
                  back: () {},
                  index: () {},
                  values: {},
                  messages: [],
                  animate: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await WidgetsBinding.instance.endOfFrame;
    await precacheImage(ExactAssetImage(board.artwork), key.currentContext!);
    WidgetsBinding.instance.scheduleFrame();
    await WidgetsBinding.instance.endOfFrame;
    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      '${dir.path}/${board.id}.png',
    ).writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  }
  stdout.writeln('Rendered ${catalog.length} artboards');
  exit(0);
}
