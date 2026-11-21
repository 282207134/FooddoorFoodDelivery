import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fooddoor/main.dart' as app;
import 'package:fooddoor/catalog.dart';
import 'package:fooddoor/screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (e) {
    stderr.writeln(e);
    exit(2);
  };
  final boards = await loadCatalog();
  Future<void> paint() async {
    WidgetsBinding.instance.scheduleFrame();
    await WidgetsBinding.instance.endOfFrame;
  }

  Iterable<Element> tree(Element e) sync* {
    yield e;
    final children = <Element>[];
    e.visitChildren(children.add);
    for (final c in children) {
      yield* tree(c);
    }
  }

  Iterable<Element> getTree() => tree(WidgetsBinding.instance.rootElement!);
  void expectPage(String id) {
    final screen = getTree()
        .map((e) => e.widget)
        .whereType<ScreenView>()
        .single;
    if (screen.board.id != id)
      throw StateError('Expected $id, got ${screen.board.id}');
  }

  Future<void> tap(String label) async {
    final e = getTree().firstWhere(
      (e) =>
          e.widget is Semantics &&
          (e.widget as Semantics).properties.label == label,
    );
    final box = e.findRenderObject() as RenderBox,
        pos = box.localToGlobal(box.size.center(Offset.zero));
    GestureBinding.instance.handlePointerEvent(
      PointerDownEvent(position: pos, pointer: 1),
    );
    GestureBinding.instance.handlePointerEvent(
      PointerUpEvent(position: pos, pointer: 1),
    );
    await paint();
  }

  Future<void> launch(String id) async {
    runApp(
      FittedBox(
        child: SizedBox(
          width: 375,
          height: 812,
          child: app.Fooddoor(key: ValueKey(id), catalog: boards, initial: id),
        ),
      ),
    );
    await paint();
    await paint();
  }

  try {
    await launch('A04');
    await tap('Get Started');
    expectPage('A06');
    await tap('Sign in');
    expectPage('B01');
    await launch('B12');
    TextField input() =>
        getTree().map((e) => e.widget).whereType<TextField>().first;
    input().onSubmitted!('chicken');
    await paint();
    expectPage('B13');
    if (input().controller!.text != 'chicken')
      throw StateError('Search term was lost');
    input().onSubmitted!('unknown');
    await paint();
    expectPage('B14');
    if (input().controller!.text != 'unknown')
      throw StateError('Empty result query was lost');
    await tap('Back');
    expectPage('B12');
    await launch('C06');
    Future<void> send(String text) async {
      final field = getTree()
          .map((e) => e.widget)
          .whereType<EditableText>()
          .single;
      field.controller.text = text;
      input().onChanged!(text);
      await tap('Send message');
      if (input().controller!.text.isNotEmpty)
        throw StateError('Composer did not clear');
    }

    await send('On my way');
    await send('On my way');
    if (getTree()
            .where(
              (e) => e.widget is Text && (e.widget as Text).data == 'On my way',
            )
            .length !=
        2)
      throw StateError('Chat history was lost');
    await launch('D14');
    await tap('Increase quantity');
    if (!getTree().any(
      (e) => e.widget is Text && (e.widget as Text).data == r'$340.00',
    ))
      throw StateError('Cart total did not update');
    await tap('Check out');
    expectPage('D17');
    await Future<void>.delayed(const Duration(milliseconds: 4200));
    await paint();
    expectPage('D18');
    await tap('Back');
    expectPage('D14');
    stdout.writeln(
      'PASS welcome, sign-in, search, empty results, repeat messages, quantity, checkout and back',
    );
    exit(0);
  } catch (e, stack) {
    stderr.writeln('$e\n$stack');
    exit(1);
  }
}
