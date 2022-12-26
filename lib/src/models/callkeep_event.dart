import 'package:flutter_callkeep/flutter_callkeep.dart';

abstract class CallKeepEvent {
  final CallKeepEventType type;
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
          return CallKeepCallEvent(type: event, data: CallKeepCallData.fromMap(body));
        case CallKeepEventType.holdToggled:
          return CallKeepHoldEvent(data: HoldToggleData.fromMap(body));
        case CallKeepEventType.muteToggled:
          return CallKeepMuteEvent(data: MuteToggleData.fromMap(body));
        case CallKeepEventType.dmtfToggled:
          return CallKeepDmtfEvent(data: DmtfToggleData.fromMap(body));
        case CallKeepEventType.callGroupToggled:
          return CallKeepCallGroupEvent(data: CallGroupToggleData.fromMap(body));
        case CallKeepEventType.audioSessionToggled:
          return CallKeepAudioSessionEvent(data: AudioSessionToggleData.fromMap(body));
        case CallKeepEventType.devicePushTokenUpdated:
          return CallKeepVoipTokenEvent(data: VoipTokenData.fromMap(body));
      }
    } catch (e) {
      rethrow;
    }
  }

  CallKeepEvent({required this.type, required this.data});
}

class CallKeepCallEvent extends CallKeepEvent {
  final CallKeepEventType type;
  final CallKeepCallData data;

  CallKeepCallEvent({required this.type, required this.data}) : super(type: type, data: data);
}

class CallKeepAudioSessionEvent extends CallKeepEvent {
  final AudioSessionToggleData data;

  CallKeepAudioSessionEvent({
    CallKeepEventType type = CallKeepEventType.audioSessionToggled,
    required this.data,
  }) : super(type: type, data: data);
}

class CallKeepMuteEvent extends CallKeepEvent {
  final MuteToggleData data;

  CallKeepMuteEvent({
    CallKeepEventType type = CallKeepEventType.muteToggled,
    required this.data,
  }) : super(type: type, data: data);
}

class CallKeepHoldEvent extends CallKeepEvent {
  final HoldToggleData data;

  CallKeepHoldEvent({
    CallKeepEventType type = CallKeepEventType.holdToggled,
    required this.data,
  }) : super(type: type, data: data);
}

class CallKeepCallGroupEvent extends CallKeepEvent {
  final CallGroupToggleData data;

  CallKeepCallGroupEvent({
    CallKeepEventType type = CallKeepEventType.callGroupToggled,
    required this.data,
  }) : super(type: type, data: data);
}

class CallKeepDmtfEvent extends CallKeepEvent {
  final DmtfToggleData data;

  CallKeepDmtfEvent({
    CallKeepEventType type = CallKeepEventType.dmtfToggled,
    required this.data,
  }) : super(type: type, data: data);
}

class CallKeepVoipTokenEvent extends CallKeepEvent {
  final VoipTokenData data;

  CallKeepVoipTokenEvent({
    CallKeepEventType type = CallKeepEventType.devicePushTokenUpdated,
    required this.data,
  }) : super(type: type, data: data);
}
