class CallKeepAndroidConfig {
  /// Using custom notifications.
  final bool showCustomNotification;

  /// Show app's logo inside full screen. /android/src/main/res/drawable-xxxhdpi/ic_logo.png
  final bool showLogo;

  /// Show a missed call notification when calls timeout
  final bool showMissedCallNotification;

  /// Show call back action on missed call notifications
  final bool showCallBackAction;

  /// File name of the ringtone that is put into /android/app/src/main/res/raw/
  final String ringtoneFileName;

  /// Incoming call screen background color in hex
  ///
  /// example value: '#0955fa'
  final String backgroundColor;

  ///	Using image background for Incoming call screen. example: http://... https://... or 'assets/abc.png'
  final String? backgroundUrl;

  /// Color used in button/text on notification.
  ///
  /// example value: '#0955fa'
  final String actionColor;

  /// Notification channel name of incoming call.
  final String incomingCallNotificationChannelName;

  /// Notification channel name of missed call.
  final String missedCallNotificationChannelName;
  CallKeepAndroidConfig({
    this.showCustomNotification = false,
    this.showLogo = false,
    this.showMissedCallNotification = true,
    this.showCallBackAction = true,
    this.ringtoneFileName = 'system_ringtone_default',
    this.backgroundColor = '#0955fa',
    this.backgroundUrl,
    this.actionColor = '#4CAF50',
    this.incomingCallNotificationChannelName = 'Incoming Calls',
    this.missedCallNotificationChannelName = "Missed Calls",
  });

  Map<String, dynamic> toMap() {
    return {
      'showCustomNotification': showCustomNotification,
      'showLogo': showLogo,
      'showMissedCallNotification': showMissedCallNotification,
      'showCallBackAction': showCallBackAction,
      'ringtoneFileName': ringtoneFileName,
      'backgroundColor': backgroundColor,
      'backgroundUrl': backgroundUrl,
      'actionColor': actionColor,
      'incomingCallNotificationChannelName': incomingCallNotificationChannelName,
      'missedCallNotificationChannelName': missedCallNotificationChannelName,
    };
  }
}
