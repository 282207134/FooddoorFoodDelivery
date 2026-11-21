import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'catalog.dart';
import 'screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  final catalog = await loadCatalog();
  runApp(Fooddoor(catalog: catalog));
}

class Fooddoor extends StatelessWidget {
  const Fooddoor({super.key, required this.catalog, this.initial = 'A01'});
  final Map<String, Artboard> catalog;
  final String initial;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Fooddoor',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff116454)),
    ),
    home: FooddoorFlow(catalog, initial),
  );
}

class FooddoorFlow extends StatefulWidget {
  const FooddoorFlow(this.catalog, this.initial, {super.key});
  final Map<String, Artboard> catalog;
  final String initial;
  @override
  State<FooddoorFlow> createState() => _FooddoorFlowState();
}

class _FooddoorFlowState extends State<FooddoorFlow> {
  late final history = [widget.initial];
  final values = <String, String>{};
  final messages = <String>[];
  void open(String id) {
    if (id == history.last || !widget.catalog.containsKey(id)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      const results = {'B13', 'B14'};
      if ((history.last == 'A01' && id == 'A02') ||
          (history.last == 'D17' && id == 'D18') ||
          (results.contains(history.last) && (id == 'B12' || results.contains(id)))) {
        history.removeLast();
      }
      if (history.isEmpty || history.last != id) history.add(id);
    });
  }

  void back() {
    if (history.length > 1)
      setState(history.removeLast);
    else
      open('B01');
  }

  Future<void> index() async {
    final id = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: .84,
        child: ListView(
          children: [
            for (final group in groups.indexed)
              ExpansionTile(
                title: Text(group.$2),
                initiallyExpanded: history.last.codeUnitAt(0) == 65 + group.$1,
                children: [
                  for (final id in widget.catalog.keys.where(
                    (s) => s.codeUnitAt(0) == 65 + group.$1,
                  ))
                    ListTile(
                      leading: Text(id),
                      title: Text(titleOf(id)),
                      onTap: () => Navigator.pop(ctx, id),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
    if (mounted && id != null) open(id);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: history.length == 1,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) back();
    },
    child: Scaffold(
      backgroundColor: const Color(0xfff2f2ef),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ScreenView(
            key: ValueKey(history.last),
            board: widget.catalog[history.last]!,
            open: open,
            back: back,
            index: index,
            values: values,
            messages: messages,
          ),
        ),
      ),
    ),
  );
}
