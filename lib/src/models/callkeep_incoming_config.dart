import 'package:flutter_callkeep/src/models/callkeep_android_config.dart';
import 'package:flutter_callkeep/src/models/callkeep_base_config.dart';
import 'package:flutter_callkeep/src/models/callkeep_call_data.dart';
import 'package:flutter_callkeep/src/models/callkeep_ios_config.dart';

/// The configuration of an incoming call from CallKeep
class CallKeepIncomingConfig extends CallKeepCallData {
  /// App's name. using for display inside Callkit.
  final String appName;

  /// Call notification content title and full screen incoming call activity header
  ///
  /// If [contentTitle] on [CallKeepBaseConfig] is set up, it would default to be ContentTitle(callerName)
  /// or contentTitle(appName) if [callerName] is `null`
  ///
  /// If you override [contentTitle] it would superseed the [CallKeepBaseConfig.contentTitle]
  ///
  /// You can assign it to empty [String] to have notification content title be [callerName],
  /// and full screen header will be "Call from CallKeep", which you can override in your
  /// `android/app/src/main/res/values/strings.xml` with key `call_header`
  final String contentTitle;

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

  factory CallKeepIncomingConfig.fromBaseConfig({
    required CallKeepBaseConfig config,
    required String uuid,
    String? callerName,
    String? handle,
    String? contentTitle,
    String? avatar,
    bool hasVideo = false,
    Map<String, dynamic>? extra,
    double duration = 180,
  }) {
    return CallKeepIncomingConfig(
      uuid: uuid,
      callerName: callerName,
      avatar: avatar,
      appName: config.appName,
      contentTitle: contentTitle ??
          config.contentTitle?.call(callerName ?? config.appName) ??
          "",
      acceptText: config.acceptText,
      declineText: config.declineText,
      missedCallText: config.missedCallText,
      callBackText: config.callBackText,
      handle: handle,
      hasVideo: hasVideo,
      duration: duration,
      extra: extra,
      headers: config.headers,
      androidConfig: config.androidConfig,
      iosConfig: config.iosConfig,
    );
  }

  CallKeepIncomingConfig({
    this.contentTitle = "",
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
      'contentTitle': contentTitle,
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
