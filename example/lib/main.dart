import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_callkeep/flutter_callkeep.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CallKeep.setup();
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  Future<void> displayIncomingCall(BuildContext context) async {
    await CallKeep.askForPermissionsIfNeeded(context);
    final callUUID = '0783a8e5-8353-4802-9448-c6211109af51';
    final number = '+46 70 123 45 67';

    await CallKeep.displayIncomingCall(callUUID, number, number, HandleType.number, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          RaisedButton(
            child: Text('Display incoming call'),
            onPressed: () => this.displayIncomingCall(context),
          )
        ],
      )),
    );
  }
}
