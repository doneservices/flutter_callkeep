import 'package:flutter_callkeep/src/models/calkeep_base_data.dart';
import 'package:flutter_callkeep/src/models/callkeep_android_config.dart';
import 'package:flutter_callkeep/src/models/callkeep_ios_config.dart';

class CallKeepIncomingConfig extends CallKeepBaseData {
  /// App's name. using for display inside Callkit.
  final String appName;

  /// Text Accept to be shown for the user to accept the call
  final String acceptText;

  /// Text Decline to be shown for the user to decline the call
  final String declineText;

  /// Text Missed Call to be shown for the user to indicate a missed call
  final String missedCallText;

  /// Text Call Back to be shown for the user to call back after a missed call
  final String callBackText;

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
    this.acceptText = 'Accept',
    this.declineText = 'Decline',
    this.missedCallText = 'Missed call',
    this.callBackText = 'Call back',
    required String uuid,
    required this.appName,
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
      'id': uuid,
      'callerName': callerName,
      'appName': appName,
      'acceptText': acceptText,
      'declineText': declineText,
      'missedCallText': missedCallText,
      'callBackText': callBackText,
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
