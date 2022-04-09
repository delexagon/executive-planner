import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FileStorage {
  // TODO: Make sure SharedPreferences is not temporary and can store large strings.
  /// Gets SharedPreferences folder, a bank of strings.
  Future<SharedPreferences> get _prefs async {
    final prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  /// Reads 'events' string from SharedPreferences and decodes it into a JSON map.
  Future<String?> readFile() async {
    final prefs = await _prefs;

    // Read the file
    final contents = prefs.getString('events');
    if (contents != null) {
      return contents;
    }
    // If no preference, return null
    return null;
  }

  /// Writes a JSON map into the 'events' string in SharedPreferences.
  Future write(String jstr) async {
    final prefs = await _prefs;

    // Write the file
    prefs.setString('events', jstr);
  }
}
