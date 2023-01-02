/// The configurations needed for Android
///
/// Holding colors, flags and channel names
class CallKeepAndroidConfig {
  /// File name of the app logo to show inside full screen.
  ///
  /// No logo will be shown if this is empty
  final String logo;

  /// File name of the notification icon to show inside call notifications.
  ///
  /// Default notifications will be shown if this is empty
  final String notificationIcon;

  /// Show a missed call notification when calls timeout
  final bool showMissedCallNotification;

  /// Show call back action on missed call notifications
  final bool showCallBackAction;

  /// File name of the ringtone that is put into /android/app/src/main/res/raw/
  final String ringtoneFileName;

  /// Incoming call screen/notification accent color in hex
  ///
  /// example value: '#0955fa'
  final String accentColor;

  ///	Using image background for Incoming call screen. example: http://... https://... or 'assets/abc.png'
  final String? backgroundUrl;

  /// Notification channel name of incoming call.
  final String incomingCallNotificationChannelName;

  /// Notification channel name of missed call.
  final String missedCallNotificationChannelName;
  CallKeepAndroidConfig({
    this.logo = "",
    this.notificationIcon = "",
    this.showMissedCallNotification = true,
    this.showCallBackAction = true,
    this.ringtoneFileName = 'system_ringtone_default',
    this.accentColor = '#0955fa',
    this.backgroundUrl,
    this.incomingCallNotificationChannelName = 'Incoming Calls',
    this.missedCallNotificationChannelName = "Missed Calls",
  });

  Map<String, dynamic> toMap() {
    return {
      'logo': logo,
      'notificationIcon': notificationIcon,
      'showMissedCallNotification': showMissedCallNotification,
      'showCallBackAction': showCallBackAction,
      'ringtoneFileName': ringtoneFileName,
      'accentColor': accentColor,
      'backgroundUrl': backgroundUrl,
      'incomingCallNotificationChannelName':
          incomingCallNotificationChannelName,
      'missedCallNotificationChannelName': missedCallNotificationChannelName,
    };
  }
}
