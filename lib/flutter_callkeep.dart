import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';

export 'package:flutter_callkeep/src/models/models.dart';

/// Instance to use library functions.
/// * displayIncomingCall(CallKeepIncomingConfig)
/// * startCall(CallKeepOutgoingConfig)
/// * showMissCallNotification(CallKeepIncomingConfig)
/// * endCall(String Uuid)
/// * endAllCalls()
///
class CallKeep {
  final _channel = const MethodChannel('flutter_callkeep');
  final _eventChannel = const EventChannel('flutter_callkeep_events');
  late final StreamSubscription _eventChannelSubscription;

  /// Listen to a [CallKeepEvent]
  ///
  /// CallKeep.onEvent.listen((event) {
  ///
  /// // event type => data runtime type - description
  ///
  /// [CallKeepEventType.callIncoming] => [CallKeepCallEvent] - Received an incoming call
  ///
  /// [CallKeepEventType.callStart] => [CallKeepCallEvent] - Started an outgoing call
  ///
  /// [CallKeepEventType.callAccept] => [CallKeepCallEvent] - Accepted an incoming call
  ///
  /// [CallKeepEventType.callDecline] => [CallKeepCallEvent] - Declined an incoming call
  ///
  /// [CallKeepEventType.callEnded] => [CallKeepCallEvent] - Ended an incoming/outgoing call
  ///
  /// [CallKeepEventType.callTimedOut] => [CallKeepCallEvent] - Missed an incoming call
  ///
  /// [CallKeepEventType.missedCallback] => [CallKeepCallEvent] - calling back after a missed call
  /// notification - Android only (click action `Call back` from missed call notification)
  ///
  /// [CallKeepEventType.holdToggled] => [CallKeepHoldEvent] - CallKit hold was toggled - iOS only
  ///
  /// [CallKeepEventType.muteToggled] => [CallKeepMuteEvent] - CallKit Mute was toggled - iOS only
  ///
  /// [CallKeepEventType.dmtfToggled] => [CallKeepDmtfEvent] - DMTF (Dual Tone Multi Frequency)
  /// was toggled - iOS only
  ///
  /// [CallKeepEventType.callGroupToggled] => [CallKeepCallGroupEvent] - Call group was toggled
  /// - iOS only
  ///
  /// [CallKeepEventType.audioSessionToggled] => [CallKeepAudioSessionEvent] - AVAudioSession
  /// was toggled (activated/deactivated) - iOS only
  ///
  /// [CallKeepEventType.audioSessionToggled] => [CallKeepVoipTokenEvent]- PushKit token was updated
  ///  for VoIP - iOS only
  ///
  /// }
  Stream<CallKeepEvent?> get onEvent =>
      _eventChannel.receiveBroadcastStream().map(_handleCallKeepEvent);

  CallKeep._internal();
  static final CallKeep _instance = CallKeep._internal();

  static CallKeep get instance => _instance;

  /// Show Incoming call UI.
  /// On iOS, using Callkit. On Android, using a custom UI.
  Future<void> displayIncomingCall(CallKeepIncomingConfig config) async {
    await _channel.invokeMethod("displayIncomingCall", config.toMap());
  }

  /// Show Miss Call Notification.
  /// On Android only
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
  /// On Android: return active calls from SharedPrefs
  ///
  /// Helpful when starting the app from terminated state to retrieve information about latest calls
  Future<List<CallKeepCallData>> activeCalls() async {
    final activeCallsRaw = await _channel.invokeMethod<List>("activeCalls");
    if (activeCallsRaw == null) return [];
    return activeCallsRaw
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .map((e) => CallKeepCallData.fromMap(e))
        .toList();
  }

  /// Get device push token VoIP.
  /// On iOS: return deviceToken for VoIP.
  /// On Android: returns empty String
  Future<String> getDevicePushTokenVoIP() async {
    return (await _channel.invokeMethod<String>("getDevicePushTokenVoIP")) ??
        '';
  }

  CallKeepEvent _handleCallKeepEvent(dynamic data) {
    if (data is Map) {
      try {
        return CallKeepEvent.fromMap(data);
      } catch (e) {
        rethrow;
      }
    } else {
      throw Exception('Incorrect CallKeep event data: $data');
    }
  }

  /// Closes the subscription for [onEvent]
  void close() {
    _eventChannelSubscription.cancel();
  }
}
