import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CallKeep.setup();
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // try {
    //   platformVersion = await Callkeep.platformVersion;
    // } on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> displayIncomingCall() async {
    await CallKeep.askForPermissionsIfNeeded(context);
    final callUUID = '0783a8e5-8353-4802-9448-c6211109af51';
    final number = '+46 70 123 45 67';

    await CallKeep.displayIncomingCall(
        callUUID, number, number, HandleType.number, false);
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
            onPressed: () => this.displayIncomingCall(),
          )
        ],
      )),
    );
  }
}
