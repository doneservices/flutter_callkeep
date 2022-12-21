import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_callkeep/src/models/calkeep_base_data.dart';
import 'package:flutter_callkeep/src/models/call_group_toggle_data.dart';
import 'package:flutter_callkeep/src/models/callkeep_event_type.dart';
import 'package:flutter_callkeep/src/models/callkeep_incoming_config.dart';
import 'package:flutter_callkeep/src/models/callkeep_outgoing_config.dart';
import 'package:flutter_callkeep/src/models/dmtf_toggle_data.dart';
import 'package:flutter_callkeep/src/models/hold_toggle_data.dart';
import 'package:flutter_callkeep/src/models/mute_toggle_data.dart';

export 'package:flutter_callkeep/src/models/models.dart';

/// Instance to use library functions.
/// * displayIncomingCall(CallKeepIncomingConfig)
/// * startCall(CallKeepOutgoingConfig)
/// * endCall(String Uuid)
/// * endAllCalls()
///
class FlutterCallKeep {
  static const MethodChannel _channel = const MethodChannel('flutter_callkeep');
  static const EventChannel _eventChannel = const EventChannel('flutter_callkeep_events');

  FlutterCallKeep._internal() {
    _eventChannel.receiveBroadcastStream().map(_handleCallKeepEvent);
  }

  static final FlutterCallKeep _instance = FlutterCallKeep._internal();

  static FlutterCallKeep get instance => _instance;

  final StreamController<CallKeepBaseData> _incomingCallController = StreamController();
  final StreamController<CallKeepBaseData> _callStartController = StreamController();
  final StreamController<CallKeepBaseData> _callAcceptController = StreamController();
  final StreamController<CallKeepBaseData> _callDeclineController = StreamController();
  final StreamController<CallKeepBaseData> _callEndedController = StreamController();
  final StreamController<CallKeepBaseData> _callTimeOutController = StreamController();
  final StreamController<CallKeepBaseData> _callBackController = StreamController();
  final StreamController<HoldToggleData> _holdToggleController = StreamController();
  final StreamController<MuteToggleData> _muteToggleController = StreamController();
  final StreamController<DmtfToggleData> _dmtfToggleController = StreamController();
  final StreamController<CallGroupToggleData> _callGroupToggleController = StreamController();
  final StreamController<bool> _audioSessionToggleController = StreamController();
  final StreamController<String> _pushTokenUpdateController = StreamController();

  /// Received an incoming call
  Stream<CallKeepBaseData> get onIncomingCall => _incomingCallController.stream.asBroadcastStream();

  /// Started an outgoing call
  Stream<CallKeepBaseData> get onCallStarted => _callStartController.stream.asBroadcastStream();

  /// Accepted an incoming call
  Stream<CallKeepBaseData> get onCallAccepted => _callAcceptController.stream.asBroadcastStream();

  /// Declined an incoming call
  Stream<CallKeepBaseData> get onCallDeclined => _callDeclineController.stream.asBroadcastStream();

  /// Ended an incoming/outgoing call
  Stream<CallKeepBaseData> get onCallEnded => _callEndedController.stream.asBroadcastStream();

  /// Missed an incoming call due to timeout
  Stream<CallKeepBaseData> get onCallTimedOut => _callTimeOutController.stream.asBroadcastStream();

  /// Calling back after a missed call notification - Android only
  Stream<CallKeepBaseData> get onCallBack => _callBackController.stream.asBroadcastStream();

  /// CallKit hold was toggled - iOS only
  Stream<HoldToggleData> get onHoldToggled => _holdToggleController.stream.asBroadcastStream();

  /// CallKit Mute was toggled - iOS only
  Stream<MuteToggleData> get onMuteToggled => _muteToggleController.stream.asBroadcastStream();

  /// DMTF (Dual Tone Multi Frequency) was toggled - iOS only
  Stream<DmtfToggleData> get onDmtfToggled => _dmtfToggleController.stream.asBroadcastStream();

  /// Call group was toggled - iOS only
  Stream<CallGroupToggleData> get onCallGroupToggled =>
      _callGroupToggleController.stream.asBroadcastStream();

  /// AVAudioSession was toggled (activated/deactivated) - iOS only
  Stream<bool> get onAudioSessionToggled =>
      _audioSessionToggleController.stream.asBroadcastStream();

  /// PushKit token was updated for VoIP - iOS only
  Stream<String> get onPushTokenUpdated => _pushTokenUpdateController.stream.asBroadcastStream();

  /// Show Incoming call UI.
  /// On iOS, using Callkit. On Android, using a custom UI.
  Future<void> displayIncomingCall(CallKeepIncomingConfig config) async {
    await _channel.invokeMethod("displayIncomingCall", config.toMap());
  }

  /// Show Miss Call Notification.
  /// Only Android
  Future<void> showMissCallNotification(CallKeepIncomingConfig config) async {
    await _channel.invokeMethod("showMissCallNotification", config.toMap());
  }

  /// Start an Outgoing call.
  /// On iOS, using Callkit(create a history into the Phone app).
  /// On Android, Nothing(only callback event listener).
  Future<void> startCall(CallKeepOutgoingConfig config) async {
    await _channel.invokeMethod("startCall", config.toMap());
  }

  /// End an Incoming/Outgoing call.
  /// On iOS, using Callkit(update a history into the Phone app).
  /// On Android, Nothing(only callback event listener).
  Future<void> endCall(String uuid) async {
    await _channel.invokeMethod("endCall", {'id': uuid});
  }

  /// End all calls.
  Future<void> endAllCalls() async {
    await _channel.invokeMethod("endAllCalls");
  }

  /// Get active calls.
  /// On iOS: return active calls from Callkit.
  /// On Android: only return last call
  Future<List<CallKeepBaseData>> activeCalls() async {
    final activeCallsRaw = await _channel.invokeMethod<List>("activeCalls");
    if (activeCallsRaw == null) return [];
    return activeCallsRaw
        .cast<Map<String, dynamic>>()
        .map((e) => CallKeepBaseData.fromMap(e))
        .toList();
  }

  /// Get device push token VoIP.
  /// On iOS: return deviceToken for VoIP.
  /// On Android: return Empty
  Future<String> getDevicePushTokenVoIP() async {
    return (await _channel.invokeMethod<String>("getDevicePushTokenVoIP")) ?? '';
  }

  void _handleCallKeepEvent(dynamic data) {
    if (data is Map) {
      final event = callKeepEventTypeFromName('event');
      final body = data['body'] as Map<String, dynamic>;
      switch (event) {
        case CallKeepEventType.devicePushTokenUpdated:
          if (body['deviceTokenVoIP'] == null) return;
          _pushTokenUpdateController.add(body['deviceTokenVoIP'] as String);
          break;
        case CallKeepEventType.callIncoming:
          _incomingCallController.add(CallKeepBaseData.fromMap(body));
          break;
        case CallKeepEventType.callStart:
          _callStartController.add(CallKeepBaseData.fromMap(body));
          break;
        case CallKeepEventType.callAccept:
          _callAcceptController.add(CallKeepBaseData.fromMap(body));
          break;
        case CallKeepEventType.callDecline:
          _callDeclineController.add(CallKeepBaseData.fromMap(body));
          break;
        case CallKeepEventType.callEnded:
          _callEndedController.add(CallKeepBaseData.fromMap(body));
          break;
        case CallKeepEventType.callTimedOut:
          _callTimeOutController.add(CallKeepBaseData.fromMap(body));
          break;
        case CallKeepEventType.missedCallback:
          break;
        case CallKeepEventType.holdToggled:
          final holdToggleData = HoldToggleData.fromMap(body);
          _holdToggleController.add(holdToggleData);
          break;
        case CallKeepEventType.muteToggled:
          final muteToggleData = MuteToggleData.fromMap(body);
          _muteToggleController.add(muteToggleData);
          break;
        case CallKeepEventType.dmtfToggled:
          final dmtfToggleData = DmtfToggleData.fromMap(body);
          _dmtfToggleController.add(dmtfToggleData);
          break;
        case CallKeepEventType.callGroupToggled:
          final callGroupToggleData = CallGroupToggleData.fromMap(body);
          _callGroupToggleController.add(callGroupToggleData);
          break;
        case CallKeepEventType.audioSessionToggled:
          _audioSessionToggleController.add(body['isActivate']);
          break;
      }
    }
  }

  void close() {
    _incomingCallController.close();
    _callStartController.close();
    _callAcceptController.close();
    _callDeclineController.close();
    _callEndedController.close();
    _callTimeOutController.close();
    _callBackController.close();
    _holdToggleController.close();
    _muteToggleController.close();
    _dmtfToggleController.close();
    _callGroupToggleController.close();
    _audioSessionToggleController.close();
    _pushTokenUpdateController.close();
  }
}
