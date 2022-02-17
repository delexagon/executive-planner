import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// TODO: Make sure that this is safe to do.
class FileStorage {

  Future<SharedPreferences> get _prefs async {
    final prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  Future<Map<String, dynamic>?> readFile() async {
    final prefs = await _prefs;

    // Read the file
    final contents = prefs.getString('events');
    if(contents != null) {
      return jsonDecode(contents);
    }
    // If no preference, return null
    return null;
  }

  void write(Map<String, dynamic> json) async {
    final prefs = await _prefs;
    String jstr = jsonEncode(json);

    // Write the file
    prefs.setString('events', jstr);
  }
}
