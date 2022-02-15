import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

// TODO: This does not work on web because the web browser cannot store local files.
class FileStorage {

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/events.json');
  }

  Future<Map<String, dynamic>?> readFile() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return jsonDecode(contents);
    } catch (e) {
      // If an error occurs (no file), return null
      return null;
    }
  }

  void write(Map<String, dynamic> json) async {
    final file = await _localFile;
    String jstr = jsonEncode(json);

    // Write the file
    file.writeAsString(jstr);
  }
}
