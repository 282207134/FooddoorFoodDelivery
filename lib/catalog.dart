import 'dart:convert';
import 'package:flutter/services.dart';

const groups = ['Welcome', 'Food', 'Orders', 'Market', 'Account'];
const titles = [
  "Splash|Browse food and groceries|Track a delivery|Welcome|Doorstep delivery|Sign in|Prefilled sign in|Sign up",
  "Home|Home collection|Collection highlights|Collection offers|Restaurant menu|Restaurant vouchers|Toppings|Dish details|Delivery slot|Nearby map|Nearby restaurant|Search|Search results|No results|Filters|Selected filters|Driver review|Food rating|Written review",
  "Active orders|Empty orders|Order timeline|Courier map|Delivery details|Courier messages|Call screen|Order history|Receipt",
  "Market|Market offers|Coupon|Location prompt|Favourite stores|Grocery products|Grocery store|Store categories|All categories|Vegetables|Product details|Product recommendations|Choose amount|Shopping cart|Apply voucher|Delivery address|Finding a courier|Courier assigned",
  "Account|Vouchers|Payment cards|Add card|Settings|Address book|Add address|Choose location|Favourites|Empty favourites|Voucher QR code",
];
String titleOf(String id) =>
    titles[id.codeUnitAt(0) - 65].split('|')[int.parse(id.substring(1)) - 1];

class Artboard {
  Artboard(this.id, Map<String, dynamic> json)
    : height = (json['h'] as num).toDouble(),
      layers = (json['nodes'] as List).cast<Map<String, dynamic>>();
  final String id;
  final double height;
  final List<Map<String, dynamic>> layers;
  String get artwork => 'assets/screens/$id.webp';
}

Future<Map<String, Artboard>> loadCatalog() async {
  final json =
      jsonDecode(await rootBundle.loadString('assets/layout.json'))
          as Map<String, dynamic>;
  return {for (final e in json.entries) e.key: Artboard(e.key, e.value)};
}
