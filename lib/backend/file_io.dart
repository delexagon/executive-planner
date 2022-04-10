import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Gets SharedPreferences folder, a bank of strings.
Future<SharedPreferences> get _prefs async {
  final prefs = await SharedPreferences.getInstance();
  return prefs;
}

/// Reads 'what' string from SharedPreferences and decodes it into a JSON map.
Future<String?> readString(String what) async {
  final prefs = await _prefs;

  // Read the file
  final contents = prefs.getString(what);
  if (contents != null) {
    return contents;
  }
  // If no preference, return null
  return null;
}

/// Writes a JSON map into the 'what' string in SharedPreferences.
Future write(String what, String jstr) async {
  final prefs = await _prefs;

  // Write the file
  prefs.setString(what, jstr);
}
