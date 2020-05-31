library flutter_callkeep;

import 'dart:async' show Stream, StreamController;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show describeEnum, required;
import 'package:flutter/material.dart' show showDialog, AlertDialog, BuildContext, FlatButton, Navigator, Text, Widget;
import 'package:flutter/services.dart' show MethodCall, MethodChannel;

part './src/events.dart';

Future<bool> _showPermissionDialog(BuildContext context, {String alertTitle, String alertDescription, String cancelButton, String okButton}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(alertTitle ?? 'Permissions required'),
      content: Text(alertDescription ?? 'This application needs to access your phone accounts'),
      actions: <Widget>[
        FlatButton(
          child: Text(cancelButton ?? 'Cancel'),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
        ),
        FlatButton(
          child: Text(okButton ?? 'ok'),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
        ),
      ],
    ),
  );
}

enum HandleType {
  generic,
  number,
  email,
}

class CallKeep {
  static const MethodChannel _channel = const MethodChannel('co.doneservices/callkeep');

  static Future<bool> isCurrentDeviceSupported = _channel.invokeMethod<bool>('isCurrentDeviceSupported');

  static final _didReceiveStartCallAction = StreamController<StartCallAction>.broadcast();
  static final _performAnswerCallAction = StreamController<AnswerCallAction>.broadcast();
  static final _performEndCallAction = StreamController<EndCallAction>.broadcast();
  static final _didActivateAudioSession = StreamController<DidActivateAudioSessionEvent>.broadcast();
  static final _didDeactivateAudioSession = StreamController<DidDeactivateAudioSessionEvent>.broadcast();
  static final _didDisplayIncomingCall = StreamController<DidDisplayIncomingCallEvent>.broadcast();
  static final _didPerformSetMutedCallAction = StreamController<DidPerformSetMutedCallAction>.broadcast();
  static final _didToggleHoldAction = StreamController<DidToggleHoldAction>.broadcast();
  static final _didPerformDTMFAction = StreamController<DidPerformDTMFAction>.broadcast();
  static final _providerReset = StreamController<ProviderResetEvent>.broadcast();
  static final _checkReachability = StreamController<CheckReachabilityEvent>.broadcast();

  static Stream<StartCallAction> get didReceiveStartCallAction => _didReceiveStartCallAction.stream;
  static Stream<AnswerCallAction> get performAnswerCallAction => _performAnswerCallAction.stream;
  static Stream<EndCallAction> get performEndCallAction => _performEndCallAction.stream;
  static Stream<DidActivateAudioSessionEvent> get didActivateAudioSession => _didActivateAudioSession.stream;
  static Stream<DidDeactivateAudioSessionEvent> get didDeactivateAudioSession => _didDeactivateAudioSession.stream;
  static Stream<DidDisplayIncomingCallEvent> get didDisplayIncomingCall => _didDisplayIncomingCall.stream;
  static Stream<DidPerformSetMutedCallAction> get didPerformSetMutedCallAction => _didPerformSetMutedCallAction.stream;
  static Stream<DidToggleHoldAction> get didToggleHoldAction => _didToggleHoldAction.stream;
  static Stream<DidPerformDTMFAction> get didPerformDTMFAction => _didPerformDTMFAction.stream;
  static Stream<ProviderResetEvent> get providerReset => _providerReset.stream;
  static Stream<CheckReachabilityEvent> get checkReachability => _checkReachability.stream;

  static Future<void> _emit(MethodCall call) async {
    print('[CallKeep] INFO: received event "${call.method}" ${call.arguments}');

    switch (call.method) {
      case "didReceiveStartCallAction":
        _didReceiveStartCallAction.add(StartCallAction._new(call.arguments));
        break;
      case "performAnswerCallAction":
        _performAnswerCallAction.add(AnswerCallAction._new(call.arguments));
        break;
      case "performEndCallAction":
        _performEndCallAction.add(EndCallAction._new(call.arguments));
        break;
      case "didActivateAudioSession":
        _didActivateAudioSession.add(DidActivateAudioSessionEvent());
        break;
      case "didDeactivateAudioSession":
        _didDeactivateAudioSession.add(DidDeactivateAudioSessionEvent());
        break;
      case "didDisplayIncomingCall":
        _didDisplayIncomingCall.add(DidDisplayIncomingCallEvent._new(call.arguments));
        break;
      case "didPerformSetMutedCallAction":
        _didPerformSetMutedCallAction.add(DidPerformSetMutedCallAction._new(call.arguments));
        break;
      case "didToggleHoldAction":
        _didToggleHoldAction.add(DidToggleHoldAction._new(call.arguments));
        break;
      case "didPerformDTMFAction":
        _didPerformDTMFAction.add(DidPerformDTMFAction._new(call.arguments));
        break;
      case "providerReset":
        _providerReset.add(ProviderResetEvent());
        break;
      case "checkReachability":
        _checkReachability.add(CheckReachabilityEvent());
        break;
      default:
        print('[CallKeep] WARN: received unknown event "${call.method}"');
    }
  }

  static Future<void> setup({String imageName}) async {
    _channel.setMethodCallHandler(CallKeep._emit);

    await _channel.invokeMethod('setup', {
      'imageName': imageName,
    });
  }

  static Future<void> askForPermissionsIfNeeded(
    BuildContext context, {
    List<String> additionalPermissionsPermissions,
    String alertTitle,
    String alertDescription,
    String cancelButton,
    String okButton,
  }) async {
    if (!Platform.isAndroid) return;

    final showAccountAlert = await _hasPhoneAccountPermission(additionalPermissionsPermissions ?? []);
    if (!showAccountAlert) return;

    final shouldOpenAccounts = await _showPermissionDialog(context, alertTitle: alertTitle, alertDescription: alertDescription, cancelButton: cancelButton, okButton: okButton);
    if (!shouldOpenAccounts) return;

    await _openPhoneAccounts();
  }

  // /// Checks if the user has set a default [phone account](https://developer.android.com/reference/android/telecom/PhoneAccount).
  // ///
  // /// If the user has not set a default they will be prompted to do so with an alert.
  // ///
  // /// This is a workaround for an [issue](https://github.com/wazo-pbx/react-native-callkeep/issues/33) affecting some Samsung devices.
  // static Future<bool> hasDefaultPhoneAccount(BuildContext context, {String alertTitle, String alertDescription, String cancelButton, String okButton}) async {
  //   if (!Platform.isAndroid) return true;

  //   final hasDefault = await _channel.invokeMethod<bool>('checkDefaultPhoneAccount');
  //   if (!hasDefault) return true;

  //   final shouldOpenAccounts = await _showPermissionDialog(context, alertTitle: alertTitle, alertDescription: alertDescription, cancelButton: cancelButton, okButton: okButton);
  //   if (!shouldOpenAccounts) return false;

  //   await openPhoneAccounts();
  //   return true;
  // }

  static Future<bool> _hasPhoneAccountPermission([List<String> optionalPermissions]) async {
    if (!Platform.isAndroid) return true;

    return await _channel.invokeMethod<bool>('checkPhoneAccountPermission', {
      'optionalPermissions': optionalPermissions ?? [],
    });
  }

  static Future<void> _openPhoneAccounts() async {
    if (!Platform.isAndroid) return;

    await _channel.invokeMethod('openPhoneAccounts', {});
  }

  /// _This function only runs on Android._
  ///
  /// Mark the current call as active (eg: when the callee has answered). Necessary to set the correct Android capabilities (hold, mute) once the call is set as active. Be sure to set this only after your call is ready for two way audio; used both incoming and outgoing calls.
  static Future<void> setCurrentCallActive(String uuid) async {
    assert(uuid != null);

    await _channel.invokeMethod('setCurrentCallActive', {'uuid': uuid});
  }

  /// Display system UI for incoming calls
  static Future<void> displayIncomingCall(String uuid, [String number, String callerName, HandleType handleType, bool hasVideo, String payload]) async {
    assert(uuid != null);

    await _channel.invokeMethod('displayIncomingCall', {
      'uuid': uuid,
      'number': number,
      'callerName': callerName,
      'handleType': describeEnum(handleType),
      'hasVideo': hasVideo,
      'payload': payload,
    });
  }

  /// _This function only runs on Android._
  ///
  /// Use this to tell the sdk a user answered a call from the app UI.
  static Future<void> answerIncomingCall(String uuid) async {
    assert(uuid != null);

    if (!Platform.isAndroid) return;

    await _channel.invokeMethod('answerIncomingCall', {'uuid': uuid});
  }

  /// When you make an outgoing call, tell the device that a call is occurring.
  static Future<void> startCall(String uuid, [String number, String callerName, HandleType handleType, bool hasVideo]) async {
    assert(uuid != null);

    await _channel.invokeMethod('startCall', {
      'uuid': uuid,
      'number': number,
      'callerName': callerName,
      'handleType': describeEnum(handleType),
      'hasVideo': hasVideo,
    });
  }

  /// When you finish an incoming/outgoing call.
  static Future<void> endCall(String uuid) async {
    assert(uuid != null);

    await _channel.invokeMethod('endCall', {'uuid': uuid});
  }

  /// When you reject an incoming call.
  static Future<void> rejectCall(String uuid) async {
    assert(uuid != null);

    await _channel.invokeMethod('rejectCall', {'uuid': uuid});
  }

  /// Switch the mic on/off.
  static Future<void> setMutedCall(String uuid, bool muted) async {
    assert(uuid != null);
    assert(muted != null);

    await _channel.invokeMethod('setMutedCall', {'uuid': uuid, 'muted': muted});
  }

  /// Set a call on/off hold.
  static Future<void> setOnHold(String uuid, bool hold) async {
    assert(uuid != null);
    assert(hold != null);

    await _channel.invokeMethod('setOnHold', {'uuid': uuid, 'hold': hold});
  }

  static Future<void> backToForeground() async {
    await _channel.invokeMethod('backToForeground');
  }

  static Future<void> displayCustomIncomingCall(
    String packageName,
    String className, {
    @required String icon,
    Map<String, dynamic> extra,
    String contentTitle,
    String answerText,
    String declineText,
    String ringtoneUri,
  }) async {
    assert(packageName != null);
    assert(className != null);
    assert(icon != null);
    await _channel.invokeMethod('displayCustomIncomingCall', {
      'packageName': packageName,
      'className': className,
      'icon': icon,
      'extra': extra ?? Map(),
      'contentTitle': contentTitle ?? 'Incoming call',
      'answerText': answerText ?? 'Answer',
      'declineText': declineText ?? 'Decline',
      'ringtoneUri': ringtoneUri,
    });
  }

  static Future<void> dismissCustomIncomingCall() async {
    await _channel.invokeMethod('dismissCustomIncomingCall');
  }
}
