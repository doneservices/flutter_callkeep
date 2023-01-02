import 'package:flutter_callkeep/flutter_callkeep.dart';

/// Holds the configuration for an outgoing call which is needed when starting an outgoing call
class CallKeepOutgoingConfig extends CallKeepCallData {
  /// iOS configuration needed for CallKit.
  final CallKeepIosConfig iosConfig;

  factory CallKeepOutgoingConfig.fromBaseConfig({
    required CallKeepBaseConfig config,
    required String uuid,
    String? callerName,
    String? handle,
    bool hasVideo = false,
    double duration = 180,
    Map<String, dynamic>? extra,
  }) {
    return CallKeepOutgoingConfig(
      uuid: uuid,
      callerName: callerName,
      handle: handle,
      hasVideo: hasVideo,
      duration: duration,
      extra: extra,
      iosConfig: config.iosConfig,
    );
  }
  CallKeepOutgoingConfig({
    required String uuid,
    String? callerName,
    String? handle,
    bool hasVideo = false,
    double duration = 180,
    Map<String, dynamic>? extra,
    required this.iosConfig,
  }) : super(
          uuid: uuid,
          callerName: callerName,
          handle: handle,
          hasVideo: hasVideo,
          duration: duration,
          extra: extra,
        );

  Map<String, dynamic> toMap() {
    return {
      'id': uuid,
      'callerName': callerName,
      'handle': handle,
      'hasVideo': hasVideo,
      'duration': duration,
      'extra': extra ?? {},
      'ios': iosConfig.toMap(),
    };
  }
}
