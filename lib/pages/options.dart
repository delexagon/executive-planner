
import 'package:flutter/material.dart';

class OptionsMenu extends StatefulWidget {
  const OptionsMenu({
    Key? key,})
      : super(key: key);

  @override
  State<OptionsMenu> createState() => _OptionsMenuState();
}

class _OptionsMenuState extends State<OptionsMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Options'),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
      ),
      body: const SingleChildScrollView(

      ),
    );
  }

}
