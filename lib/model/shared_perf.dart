import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

SharedPreferences? preference;

class SharedPref {
  read() {
    return json.decode(preference!.getString("favoriteStockList")!);
  }

  save(dynamic value) async {
    preference!.setString("favoriteStockList", json.encode(value));
  }
}
