import 'package:flutter_callkeep/src/models/calkeep_base_data.dart';
import 'package:flutter_callkeep/src/models/callkeep_ios_config.dart';

class CallKeepOutgoingConfig extends CallKeepBaseData {
  /// iOS configuration needed for CallKit.
  final CallKeepIosConfig iosConfig;

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
