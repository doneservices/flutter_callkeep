import 'package:flutter_callkeep/flutter_callkeep.dart';

/// The base configuration of the package
///
/// Holding information about the package that doesn't usually change,
/// Useful for holding data about the package that can be used when creating
/// [CallKeepIncomingConfig] or [CallKeepOutgoingConfig]
class CallKeepBaseConfig {
  /// App's name. using for display inside Callkit.
  final String appName;

  /// A function that is the base for [CallKeepIncomingConfig.contentTitle]
  ///
  /// Good example would be "Call from $callerName" or "Call from $appName"
  ///
  /// The argument passed to it would be the [CallKeepIncomingConfig.callerName]
  /// or [appName] if the aformentioned is `null`
  final String Function(String argument)? contentTitle;

  /// Text Accept to be shown for the user to accept the call
  final String acceptText;

  /// Text Decline to be shown for the user to decline the call
  final String declineText;

  /// Text Missed Call to be shown for the user to indicate a missed call
  final String missedCallText;

  /// Text Call Back to be shown for the user to call back after a missed call
  final String callBackText;

  /// Any data for custom header avatar/background image.
  final Map<String, dynamic>? headers;

  /// Android configuration needed to customize the UI.
  final CallKeepAndroidConfig androidConfig;

  /// iOS configuration needed for CallKit.
  final CallKeepIosConfig iosConfig;

  CallKeepBaseConfig({
    required this.appName,
    this.contentTitle,
    this.acceptText = 'Accept',
    this.declineText = 'Decline',
    this.missedCallText = 'Missed call',
    this.callBackText = 'Call back',
    this.headers,
    required this.androidConfig,
    required this.iosConfig,
  });
}
