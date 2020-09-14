part of flutter_callkeep;

class StartCallAction {
  final String callUUID;
  final String handle;
  final String name;

  StartCallAction._new(Map<dynamic, dynamic> arguments)
      : this.callUUID = arguments['callUUID'],
        this.handle = arguments['handle'],
        this.name = arguments['name'];
}

class AnswerCallAction {
  final String callUUID;

  AnswerCallAction._new(Map<dynamic, dynamic> arguments) : this.callUUID = arguments['callUUID'];
}

class EndCallAction {
  final String callUUID;

  EndCallAction._new(Map<dynamic, dynamic> arguments) : this.callUUID = arguments['callUUID'];
}

class DidActivateAudioSessionEvent {}

class DidDeactivateAudioSessionEvent {}

class DidDisplayIncomingCallEvent {
  final String callUUID;
  final String handle;
  final String localizedCallerName;
  final bool hasVideo;
  final bool fromPushKit;
  final String payload;

  DidDisplayIncomingCallEvent._new(Map<dynamic, dynamic> arguments)
      : this.callUUID = arguments['callUUID'],
        this.handle = arguments['handle'],
        this.localizedCallerName = arguments['localizedCallerName'],
        this.hasVideo = arguments['hasVideo'] == 'true',
        this.fromPushKit = arguments['fromPushKit'] == 'true',
        this.payload = arguments['payload'];
}

class DidPerformSetMutedCallAction {
  final String callUUID;
  final bool muted;

  DidPerformSetMutedCallAction._new(Map<dynamic, dynamic> arguments)
      : this.callUUID = arguments['callUUID'],
        this.muted = arguments['muted'];
}

class DidToggleHoldAction {
  final String callUUID;
  final bool hold;

  DidToggleHoldAction._new(Map<dynamic, dynamic> arguments)
      : this.callUUID = arguments['callUUID'],
        this.hold = arguments['hold'];
}

class DidPerformDTMFAction {
  final String callUUID;
  final String digits;

  DidPerformDTMFAction._new(Map<dynamic, dynamic> arguments)
      : this.callUUID = arguments['callUUID'],
        this.digits = arguments['digits'];
}

class ProviderResetEvent {}

class CheckReachabilityEvent {}
