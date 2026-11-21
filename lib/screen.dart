import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'catalog.dart';
import 'routes.dart';

class ScreenView extends StatefulWidget {
  const ScreenView({
    super.key,
    required this.board,
    required this.open,
    required this.back,
    required this.index,
    required this.values,
    required this.messages,
    this.animate = true,
  });
  final Artboard board;
  final ValueChanged<String> open;
  final VoidCallback back, index;
  final Map<String, String> values;
  final List<String> messages;
  final bool animate;
  @override
  State<ScreenView> createState() => _ScreenViewState();
}

class _ScreenViewState extends State<ScreenView> {
  String get id => widget.board.id;
  Map<String, String> get values => widget.values;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    if (widget.animate && (id == 'A01' || id == 'D17')) {
      timer = Timer(
        Duration(seconds: id == 'A01' ? 2 : 4),
        () => widget.open(id == 'A01' ? 'A02' : 'D18'),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget hit(
    double x,
    double y,
    double w,
    double h,
    String label,
    VoidCallback onTap,
  ) => Positioned(
    left: x,
    top: y,
    width: w,
    height: h,
    child: Semantics(
      label: label,
      button: true,
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap),
    ),
  );

  String? target(String text, int y) {
    if (text == 'See all' && id == 'B01')
      return y < 800
          ? 'B02'
          : y < 1000
          ? 'B03'
          : 'B12';
    if (text == 'See all' && id == 'D01')
      return y < 900
          ? 'D02'
          : y < 1200
          ? 'D09'
          : 'D03';
    for (final entry in (actions[id] ?? {}).entries) {
      if (text.toLowerCase().contains(entry.key.toLowerCase()))
        return entry.value;
    }
    return null;
  }

  String? field(Map n) {
    final t = n['t'] as String, y = n['y'] as int;
    if (id == 'A06' || id == 'A07' || id == 'A08') {
      if (t.isEmpty || t.contains('@') || t.startsWith('•')) {
        if (id == 'A08' && y < 350) return 'Full name';
        return y > (id == 'A08' ? 460 : 390)
            ? 'Password'
            : 'Email or Phone number';
      }
    }
    if (t.isEmpty && id == 'E04')
      return y < 570
          ? 'Name in card'
          : y < 650
          ? 'Card number'
          : n['x'] < 180
          ? 'Expired date'
          : 'CVV';
    if (t.isEmpty && id == 'E07') return y < 520 ? 'Name' : 'Phone number';
    if (t.isEmpty && id == 'B19') return 'Review';
    if ((t == 'Type something…' && id == 'B12') ||
        (t == 'Rice' && id == 'B13') ||
        (t == 'Hamburger' && id == 'B14'))
      return 'Search food';
    if (t == 'Type address' && id == 'E08') return 'Type address';
    if (t == 'Type a message' && id == 'C06') return 'Type a message';
    if (t == 'Type voucher code') return 'Type voucher code';
    return null;
  }

  void submitField(String key, String value) {
    if (key == 'Search food') {
      final q = value.trim().toLowerCase();
      values[key] = value.trim();
      FocusManager.instance.primaryFocus?.unfocus();
      widget.open(
        q.isEmpty
            ? 'B12'
            : [
                'rice',
                'chicken',
                'grocery',
                'mamoo',
                'noodle',
                'food',
                'panda',
              ].any(q.contains)
            ? 'B13'
            : 'B14',
      );
    } else if (key == 'Type a message' && value.trim().isNotEmpty) {
      setState(() {
        widget.messages.add(value.trim());
        values[key] = '';
      });
    }
  }

  void follow(String text, String destination) {
    if (id == 'B12' && destination == 'B13' && text != 'Search') {
      values['Search food'] = text;
    }
    widget.open(destination);
  }

  Iterable<Widget> layer(Map<String, dynamic> n) sync* {
    final t = n['t'] as String;
    final x = (n['x'] as num).toDouble(),
        y = (n['y'] as num).toDouble(),
        w = (n['w'] as num).toDouble(),
        h = (n['h'] as num).toDouble();
    final k = field(n);
    if (k != null) {
      final editableWidth = k == 'Type a message'
          ? 222.0
          : k == 'CVV' || k == 'Expired date'
          ? 105.0
          : math.min(290.0, 353 - x);
      final preset =
          (k == 'Search food' && id != 'B12') ||
              (id == 'A07' && k == 'Email or Phone number')
          ? t
          : id == 'A07' && k == 'Password'
          ? 'sample'
          : '';
      yield Positioned(
        left: x - 3,
        top: y - 8,
        width: editableWidth,
        height: math.max(40, h + 16),
        child: TextFormField(
          key: ValueKey(
            '$id/$k/${k == "Type a message" ? widget.messages.length : ""}',
          ),
          initialValue: values[k] ?? preset,
          obscureText: k == 'Password' || k == 'CVV',
          autocorrect: k != 'Password',
          style: const TextStyle(fontSize: 15),
          keyboardType: k == 'Phone number' || k == 'Card number' || k == 'CVV'
              ? TextInputType.number
              : TextInputType.text,
          textInputAction: k == 'Search food'
              ? TextInputAction.search
              : TextInputAction.done,
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 3,
            ),
            hintText: t.startsWith('Type') ? t : null,
          ),
          onChanged: (v) => values[k] = v,
          onFieldSubmitted: (v) => submitField(k, v),
        ),
      );
      return;
    }
    String shown = t;
    if (id == 'D14' && t == r'$190.00') {
      final counts = [
        25,
        41,
        56,
      ].map((row) => int.parse(values['D14.qty.$row'] ?? '1')).toList();
      final subtotal = 150 * counts[0] + 20 * counts[1] + 12 * counts[2];
      shown = '\$${(subtotal == 0 ? 0 : subtotal + 8).toStringAsFixed(2)}';
    }
    if (RegExp(r'^\d+$').hasMatch(t) &&
        ['B07', 'D11', 'D12', 'D13', 'D14'].contains(id)) {
      shown = values['$id.qty.${(y / 10).round()}'] ?? t;
    }
    if (n.containsKey('s') && w > 0 && h > 0) {
      final align = n['a'] == 'C'
          ? Alignment.center
          : n['a'] == 'R'
          ? Alignment.centerRight
          : Alignment.centerLeft;
      yield Positioned(
        left: x,
        top: y,
        width: w,
        height: h,
        child: Align(
          alignment: align,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: align,
            child: SizedBox(
              width: h > n['s'] * 1.9 ? w : null,
              child: Text(
                shown,
                textAlign: align == Alignment.center
                    ? TextAlign.center
                    : align == Alignment.centerRight
                    ? TextAlign.right
                    : TextAlign.left,
                style: TextStyle(
                  fontSize: (n['s'] as num).toDouble(),
                  height: 1.12,
                  color: Color(0xff000000 | (n['c'] as int)),
                  fontWeight: n['b'] == true
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (t == '+' || t == '-') {
      yield hit(
        x - 6,
        y - 8,
        w + 12,
        h + 16,
        t == '+' ? 'Increase quantity' : 'Decrease quantity',
        () {
          final numbers = widget.board.layers
              .where(
                (v) =>
                    RegExp(r'^\d+$').hasMatch(v['t']) && (v['y'] - y).abs() < 5,
              )
              .toList();
          if (numbers.isEmpty) return;
          final item = numbers.first,
              key = '$id.qty.${(item["y"] / 10).round()}';
          setState(
            () => values[key] = math
                .max(
                  0,
                  int.parse(values[key] ?? item['t']) + (t == '+' ? 1 : -1),
                )
                .toString(),
          );
        },
      );
      return;
    }
    final dest = target(t, y.toInt());
    if (dest != null && t.length < 65) {
      yield hit(
        x - 4,
        y - 8,
        math.max(28, w + 8),
        h + 16,
        t,
        () => follow(t, dest),
      );
    }
    final option =
        t.endsWith(' kg') ||
        (id == 'B09' &&
            (t.contains('am') || t.contains('pm') || t.contains('Sep'))) ||
        (id == 'E07' && ['Home', 'Company', 'Others'].contains(t)) ||
        t == 'Remember me';
    if (option) {
      final key = '$id.option.${t.contains("Sep") ? "date" : "choice"}';
      yield Positioned(
        left: x - 4,
        top: y - 4,
        width: w + 8,
        height: h + 8,
        child: Semantics(
          button: true,
          label: t,
          selected: values[key] == t,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                setState(() => values[key] = values[key] == t ? '' : t),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: values[key] == t
                    ? Border.all(color: const Color(0xff10997d), width: 2)
                    : null,
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final board = widget.board, height = board.height;
    final art = Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: Image.asset(
            board.artwork,
            fit: BoxFit.fill,
            excludeFromSemantics: true,
          ),
        ),
        for (final z in graphics[id] ?? const <Zone>[])
          hit(z.$1, z.$2, z.$3, z.$4, z.$5, () => widget.open(z.$6)),
        for (final n in board.layers) ...layer(n),
        if (navPages.contains(id))
          for (final pair in ['B01', 'C01', 'E09', 'D01', 'E01'].indexed)
            hit(
              pair.$1 * 75,
              height - 94,
              75,
              62,
              titleOf(pair.$2),
              () => widget.open(pair.$2),
            ),
        if (!id.startsWith('A') &&
            (!navPages.contains(id) ||
                const {'B12', 'B14', 'D05'}.contains(id)))
          hit(2, 48, 43, 63, 'Back', widget.back),
        if (id == 'B13' || id == 'B14')
          Positioned(
            left: 305,
            top: 123,
            width: 40,
            height: 40,
            child: IconButton(
              tooltip: 'Clear search',
              icon: const Icon(
                Icons.cancel,
                size: 15,
                color: Color(0xff9093a1),
              ),
              onPressed: () => submitField('Search food', ''),
            ),
          ),
        if (id == 'D11') hit(334, 55, 41, 56, 'Cart', () => widget.open('D14')),
        if (id == 'B15' || id == 'B16')
          hit(316, 113, 56, 70, 'Close filter', () => widget.open('B13')),
        if (id == 'D13') hit(314, 445, 58, 62, 'Close', widget.back),
        if (id == 'C06') ...[
          hit(
            313,
            738,
            61,
            52,
            'Send message',
            () => submitField('Type a message', values['Type a message'] ?? ''),
          ),
          if (widget.messages.isNotEmpty)
            Positioned(
              left: 56,
              right: 28,
              top: 520,
              bottom: 80,
              child: ListView(
                reverse: true,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  for (final message in widget.messages.reversed)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(top: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xffd5f1e8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(message),
                      ),
                    ),
                ],
              ),
            ),
        ],
        Positioned(
          top: 6,
          right: 88,
          width: 34,
          height: 32,
          child: IconButton(
            padding: EdgeInsets.zero,
            tooltip: 'Browse screens',
            icon: const Icon(
              Icons.grid_view_rounded,
              size: 15,
              color: Color(0xff859b94),
            ),
            onPressed: widget.index,
          ),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, box) {
        final scale = box.maxWidth / 375;
        final page = SizedBox(
          width: box.maxWidth,
          height: height * scale,
          child: FittedBox(
            fit: BoxFit.fill,
            child: SizedBox(width: 375, height: height, child: art),
          ),
        );
        return ColoredBox(
          color: Colors.white,
          child: SingleChildScrollView(child: page),
        );
      },
    );
  }
}
