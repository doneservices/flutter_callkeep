enum CallKeepEventType {
  /// PushKit token was updated for VoIP - iOS only
  devicePushTokenUpdated,

  /// Received an incoming call
  callIncoming,

  /// Started an outgoing call
  callStart,

  /// Accepted an incoming call
  callAccept,

  /// Declined an incoming call
  callDecline,

  /// Ended an incoming/outgoing call
  callEnded,

  /// Missed an incoming call due to timeout
  callTimedOut,

  /// Calling back after a missed call notification - Android only
  missedCallback,

  /// Call hold was toggled - iOS only
  holdToggled,

  /// Mute was toggled - iOS only
  muteToggled,

  /// DMTF (Dual Tone Multi Frequency) was toggled - iOS only
  dmtfToggled,

  /// Call group was toggled - iOS only
  callGroupToggled,

  /// AVAudioSession was toggled (activated/deactivated) - iOS only
  audioSessionToggled
}

CallKeepEventType callKeepEventTypeFromName(String eventName) {
  switch (eventName) {
    case 'co.doneservices.callkeep.DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP':
      return CallKeepEventType.devicePushTokenUpdated;
    case 'co.doneservices.callkeep.ACTION_CALL_INCOMING':
      return CallKeepEventType.callIncoming;
    case 'co.doneservices.callkeep.ACTION_CALL_START':
      return CallKeepEventType.callStart;
    case 'co.doneservices.callkeep.ACTION_CALL_ACCEPT':
      return CallKeepEventType.callAccept;
    case 'co.doneservices.callkeep.ACTION_CALL_DECLINE':
      return CallKeepEventType.callDecline;
    case 'co.doneservices.callkeep.ACTION_CALL_ENDED':
      return CallKeepEventType.callEnded;
    case 'co.doneservices.callkeep.ACTION_CALL_TIMEOUT':
      return CallKeepEventType.callTimedOut;
    case 'co.doneservices.callkeep.ACTION_CALL_CALLBACK':
      return CallKeepEventType.missedCallback;
    case 'co.doneservices.callkeep.ACTION_CALL_TOGGLE_HOLD':
      return CallKeepEventType.holdToggled;
    case 'co.doneservices.callkeep.ACTION_CALL_TOGGLE_MUTE':
      return CallKeepEventType.muteToggled;
    case 'co.doneservices.callkeep.ACTION_CALL_TOGGLE_DMTF':
      return CallKeepEventType.dmtfToggled;
    case 'co.doneservices.callkeep.ACTION_CALL_TOGGLE_GROUP':
      return CallKeepEventType.callGroupToggled;
    case 'co.doneservices.callkeep.ACTION_CALL_TOGGLE_AUDIO_SESSION':
      return CallKeepEventType.audioSessionToggled;
    default:
      throw Exception('Unknown CallKeep Event');
  }
}
