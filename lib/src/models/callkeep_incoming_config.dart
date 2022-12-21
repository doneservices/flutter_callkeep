import 'package:flutter_callkeep/src/models/calkeep_base_data.dart';
import 'package:flutter_callkeep/src/models/callkeep_android_config.dart';
import 'package:flutter_callkeep/src/models/callkeep_ios_config.dart';

class CallKeepIncomingConfig extends CallKeepBaseData {
  /// Avatar's URL used for display for Android.
  /// i.e: /android/src/main/res/drawable-xxxhdpi/ic_default_avatar.png
  final String? avatar;

  /// Any data for custom header avatar/background image.
  final Map<String, dynamic>? headers;

  /// Android configuration needed to customize the UI.
  final CallKeepAndroidConfig androidConfig;

  /// iOS configuration needed for CallKit.
  final CallKeepIosConfig iosConfig;

  CallKeepIncomingConfig({
    required String uuid,
    String? callerName,
    this.avatar,
    String? handle,
    bool hasVideo = false,
    double duration = 180,
    Map<String, dynamic>? extra,
    this.headers,
    required this.androidConfig,
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
      'uuid': uuid,
      'callerName': callerName,
      'avatar': avatar,
      'handle': handle,
      'hasVideo': hasVideo,
      'duration': duration,
      'extra': extra ?? {},
      'headers': headers ?? {},
      'android': androidConfig.toMap(),
      'ios': iosConfig.toMap(),
    };
  }
}
