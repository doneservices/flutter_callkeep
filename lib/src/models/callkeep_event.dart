import 'package:flutter_callkeep/flutter_callkeep.dart';

/// The base class for a [CallKeepEvent]
///
/// Any [CallKeepEvent] will hold its own [type]
abstract class CallKeepEvent {
  /// The type of the current event
  final CallKeepEventType type;

  /// The data of the current event, it may require casting depending on event type
  ///
  /// The data for all CallKeep events is of [CallKeepCallData] type,
  /// only the CallKit related events have different types of data, namely:
  ///
  /// Data type => Event type
  ///
  /// [CallKeepHoldEvent] => [CallKeepEventType.holdToggled]
  ///
  /// [CallKeepMuteEvent] => [CallKeepEventType.muteToggled]
  ///
  /// [CallKeepDmtfEvent] => [CallKeepEventType.dmtfToggled]
  ///
  /// [CallKeepCallGroupEvent] => [CallKeepEventType.callGroupToggled]
  ///
  /// [CallKeepAudioSessionEvent] => [CallKeepEventType.audioSessionToggled]
  ///
  /// [CallKeepVoipTokenEvent] => [CallKeepEventType.devicePushTokenUpdated]
  final CallKeepBaseData data;

  factory CallKeepEvent.fromMap(Map data) {
    try {
      final event = callKeepEventTypeFromName(data['event']);
      final body = Map<String, dynamic>.from(data['body']);

      switch (event) {
        case CallKeepEventType.callIncoming:
        case CallKeepEventType.callStart:
        case CallKeepEventType.callAccept:
        case CallKeepEventType.callDecline:
        case CallKeepEventType.callEnded:
        case CallKeepEventType.callTimedOut:
        case CallKeepEventType.missedCallback:
          return CallKeepCallEvent(
              type: event, data: CallKeepCallData.fromMap(body));
        case CallKeepEventType.holdToggled:
          return CallKeepHoldEvent(data: HoldToggleData.fromMap(body));
        case CallKeepEventType.muteToggled:
          return CallKeepMuteEvent(data: MuteToggleData.fromMap(body));
        case CallKeepEventType.dmtfToggled:
          return CallKeepDmtfEvent(data: DmtfToggleData.fromMap(body));
        case CallKeepEventType.callGroupToggled:
          return CallKeepCallGroupEvent(
              data: CallGroupToggleData.fromMap(body));
        case CallKeepEventType.audioSessionToggled:
          return CallKeepAudioSessionEvent(
              data: AudioSessionToggleData.fromMap(body));
        case CallKeepEventType.devicePushTokenUpdated:
          return CallKeepVoipTokenEvent(data: VoipTokenData.fromMap(body));
      }
    } catch (e) {
      rethrow;
    }
  }

  CallKeepEvent({required this.type, required this.data});
}

/// The default [CallKeepEvent]
///
/// It holds a certain call's data
class CallKeepCallEvent extends CallKeepEvent {
  final CallKeepCallData data;

  CallKeepCallEvent({
    required CallKeepEventType type,
    required this.data,
  }) : super(type: type, data: data);
}

/// The event for iOS audio session activation
///
/// Useful for starting a call on iOS, as we probably need to wait for audio session activation
class CallKeepAudioSessionEvent extends CallKeepEvent {
  final AudioSessionToggleData data;

  CallKeepAudioSessionEvent({
    CallKeepEventType type = CallKeepEventType.audioSessionToggled,
    required this.data,
  }) : super(type: type, data: data);
}

/// The event for CallKit mute toggling
class CallKeepMuteEvent extends CallKeepEvent {
  final MuteToggleData data;

  CallKeepMuteEvent({
    CallKeepEventType type = CallKeepEventType.muteToggled,
    required this.data,
  }) : super(type: type, data: data);
}

/// The event for CallKit hold toggling
class CallKeepHoldEvent extends CallKeepEvent {
  final HoldToggleData data;

  CallKeepHoldEvent({
    CallKeepEventType type = CallKeepEventType.holdToggled,
    required this.data,
  }) : super(type: type, data: data);
}

/// The event for CallKit call group toggling
class CallKeepCallGroupEvent extends CallKeepEvent {
  final CallGroupToggleData data;

  CallKeepCallGroupEvent({
    CallKeepEventType type = CallKeepEventType.callGroupToggled,
    required this.data,
  }) : super(type: type, data: data);
}

/// The event for CallKit DMTF toggling
class CallKeepDmtfEvent extends CallKeepEvent {
  final DmtfToggleData data;

  CallKeepDmtfEvent({
    CallKeepEventType type = CallKeepEventType.dmtfToggled,
    required this.data,
  }) : super(type: type, data: data);
}

/// The event for CallKit device VoIP push token
class CallKeepVoipTokenEvent extends CallKeepEvent {
  final VoipTokenData data;

  CallKeepVoipTokenEvent({
    CallKeepEventType type = CallKeepEventType.devicePushTokenUpdated,
    required this.data,
  }) : super(type: type, data: data);
}
