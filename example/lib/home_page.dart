import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:flutter_callkeep_example/app_router.dart';
import 'package:flutter_callkeep_example/navigation_service.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  late final Uuid _uuid;
  String? _currentUuid;
  String textEvents = "";

  @override
  void initState() {
    super.initState();
    _uuid = Uuid();
    _currentUuid = "";
    textEvents = "";
    initCurrentCall();
    listenerEvent(onEvent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.call,
              color: Colors.white,
            ),
            onPressed: makeFakeCallInComing,
          ),
          IconButton(
            icon: Icon(
              Icons.call_end,
              color: Colors.white,
            ),
            onPressed: endCurrentCall,
          ),
          IconButton(
            icon: Icon(
              Icons.call_made,
              color: Colors.white,
            ),
            onPressed: startOutGoingCall,
          ),
          IconButton(
            icon: Icon(
              Icons.call_merge,
              color: Colors.white,
            ),
            onPressed: activeCalls,
          ),
          IconButton(
            icon: Icon(
              Icons.clear_all_sharp,
              color: Colors.white,
            ),
            onPressed: endAllCalls,
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          if (textEvents.isNotEmpty) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: Text('$textEvents'),
              ),
            );
          } else {
            return Center(
              child: Text('No Event'),
            );
          }
        },
      ),
    );
  }

  initCurrentCall() async {
    //check current call from pushkit if possible
    var calls = await CallKeep.instance.activeCalls();
    if (calls.isNotEmpty) {
      print('DATA: $calls');
      _currentUuid = calls[0].uuid;
      return calls[0];
    }
  }

  Future<void> makeFakeCallInComing() async {
    await Future.delayed(const Duration(seconds: 10), () async {
      _currentUuid = _uuid.v4();

      final config = CallKeepIncomingConfig(
        uuid: _currentUuid ?? '',
        callerName: 'Hien Nguyen',
        appName: 'CallKeep',
        avatar: 'https://i.pravatar.cc/100',
        handle: '0123456789',
        hasVideo: false,
        duration: 30000,
        acceptText: 'Accept',
        declineText: 'Decline',
        missedCallText: 'Missed call',
        callBackText: 'Call back',
        extra: <String, dynamic>{'userId': '1a2b3c4d'},
        headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
        androidConfig: CallKeepAndroidConfig(
          logo: "ic_logo",
          showCallBackAction: true,
          showMissedCallNotification: true,
          ringtoneFileName: 'system_ringtone_default',
          accentColor: '#0955fa',
          backgroundUrl: 'assets/test.png',
          incomingCallNotificationChannelName: 'Incoming Calls',
          missedCallNotificationChannelName: 'Missed Calls',
        ),
        iosConfig: CallKeepIosConfig(
          iconName: 'CallKitLogo',
          handleType: CallKitHandleType.generic,
          isVideoSupported: true,
          maximumCallGroups: 2,
          maximumCallsPerCallGroup: 1,
          audioSessionActive: true,
          audioSessionPreferredSampleRate: 44100.0,
          audioSessionPreferredIOBufferDuration: 0.005,
          supportsDTMF: true,
          supportsHolding: true,
          supportsGrouping: false,
          supportsUngrouping: false,
          ringtoneFileName: 'system_ringtone_default',
        ),
      );
      await CallKeep.instance.displayIncomingCall(config);
    });
  }

  Future<void> endCurrentCall() async {
    initCurrentCall();
    await CallKeep.instance.endCall(_currentUuid!);
  }

  Future<void> startOutGoingCall() async {
    _currentUuid = _uuid.v4();
    final params = CallKeepOutgoingConfig(
      uuid: _currentUuid ?? '',
      callerName: 'Hien Nguyen',
      handle: '0123456789',
      hasVideo: true,
      extra: <String, dynamic>{'userId': '1a2b3c4d'},
      iosConfig: CallKeepIosConfig(handleType: CallKitHandleType.number),
    );
    await CallKeep.instance.startCall(params);
  }

  Future<void> activeCalls() async {
    var calls = await CallKeep.instance.activeCalls();
    print(calls);
  }

  Future<void> endAllCalls() async {
    await CallKeep.instance.endAllCalls();
  }

  Future<void> getDevicePushTokenVoIP() async {
    var devicePushTokenVoIP = await CallKeep.instance.getDevicePushTokenVoIP();
    print(devicePushTokenVoIP);
  }

  Future<void> listenerEvent(Function? callback) async {
    try {
      CallKeep.instance.onEvent.listen((event) async {
        // TODO: Implement other events
        if (event == null) return;
        switch (event.type) {
          case CallKeepEventType.callAccept:
            final data = event.data as CallKeepCallData;
            print('call answered: ${data.toMap()}');
            NavigationService.instance
                .pushNamedIfNotCurrent(AppRoute.callingPage, args: data.toMap());
            if (callback != null) callback.call(event);
            break;
          case CallKeepEventType.callDecline:
            final data = event.data as CallKeepCallData;
            print('call declined: ${data.toMap()}');
            await requestHttp("ACTION_CALL_DECLINE_FROM_DART");
            if (callback != null) callback.call(data);
            break;
          default:
            break;
        }
      });
    } on Exception {}
  }

  //check with https://webhook.site/#!/2748bc41-8599-4093-b8ad-93fd328f1cd2
  Future<void> requestHttp(content) async {
    get(Uri.parse('https://webhook.site/2748bc41-8599-4093-b8ad-93fd328f1cd2?data=$content'));
  }

  onEvent(event) {
    if (!mounted) return;
    setState(() {
      textEvents += "${event.toString()}\n";
    });
  }
}
