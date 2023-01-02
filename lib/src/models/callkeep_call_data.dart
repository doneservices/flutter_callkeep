import 'package:flutter_callkeep/flutter_callkeep.dart';

/// Holds the call data for CallKeep
///
/// This is used as base for both [CallKeepIncomingConfig], [CallKeepOutgoingConfig]
///
/// But it's also the data returned with multiple events in the package
class CallKeepCallData extends CallKeepBaseData {
  /// Caller's name.
  final String? callerName;

  /// The handle of the caller (Phone number/Email/Any.)
  final String? handle;

  /// Whether the call has video or audio only
  final bool hasVideo;

  /// Incoming/Outgoing call display time (in seconds). If the time is over, the call will be missed.
  final double duration;

  /// Any data added to the event when received.
  final Map<String, dynamic>? extra;

  /// Whether call is accepted or not, defaults to false
  final bool isAccepted;

  CallKeepCallData({
    required String uuid,
    this.callerName,
    this.handle,
    this.hasVideo = false,
    this.isAccepted = false,
    this.duration = 180,
    this.extra,
  }) : super(uuid: uuid);

  factory CallKeepCallData.fromMap(Map<String, dynamic> map) {
    return CallKeepCallData(
      uuid: map['id'] ?? '',
      callerName: map['callerName'],
      handle: map['handle'],
      hasVideo: map['hasVideo'] ?? false,
      duration: map['duration']?.toDouble() ?? 180.0,
      isAccepted: map['isAccepted'] ?? false,
      extra: (map['extra'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': uuid,
      'callerName': callerName,
      'handle': handle,
      'hasVideo': hasVideo,
      'duration': duration,
      'isAccepted': isAccepted,
      'extra': extra ?? {},
    };
  }

  @override
  String toString() {
    return 'CallKeepCallData(uuid: $uuid, callerName: $callerName, handle: $handle, hasVideo: $hasVideo, duration: $duration, extra: $extra, isAccepted: $isAccepted)';
  }
}
