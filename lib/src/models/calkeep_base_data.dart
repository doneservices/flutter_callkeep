/// Holds the base data for CallKeep
///
/// This is used as base for both [CallKeepIncomingConfig], [CallKeepOutgoingConfig]
///
/// But it's also the data returned from multiple events in the package
class CallKeepBaseData {
  /// A unique UUID identifier for each call
  /// and when the call is ended, the same UUID for that call to be used.
  final String uuid;

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

  CallKeepBaseData({
    required this.uuid,
    this.callerName,
    this.handle,
    this.hasVideo = false,
    this.duration = 180,
    this.extra,
  });

  factory CallKeepBaseData.fromMap(Map<String, dynamic> map) {
    return CallKeepBaseData(
      uuid: map['id'] ?? '',
      callerName: map['callerName'],
      handle: map['handle'],
      hasVideo: map['hasVideo'] ?? false,
      duration: map['duration']?.toDouble() ?? 180.0,
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
      'extra': extra ?? {},
    };
  }

  @override
  String toString() {
    return 'CallKeepBaseData(uuid: $uuid, callerName: $callerName, handle: $handle, hasVideo: $hasVideo, duration: $duration, extra: $extra)';
  }
}
