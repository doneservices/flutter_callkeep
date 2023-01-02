/// The configurations needed for Android
///
/// Holding files info and flags needed for CallKit setup
class CallKeepIosConfig {
  /// App's Icon. used for being shown inside Callkit
  final String iconName;

  /// Call handle type
  final CallKitHandleType handleType;

  /// Whether calls support video or not
  final bool isVideoSupported;

  /// Maximum allowed call groups
  final int maximumCallGroups;

  /// Maximum calls allowed per each call group
  final int maximumCallsPerCallGroup;

  /// The AVAudioSession mode being used during calls
  final AvAudioSessionMode? audioSessionMode;

  /// If audio session should be active or not
  final bool audioSessionActive;

  /// The preferred sample rate for audio session
  final double audioSessionPreferredSampleRate;

  /// The preferred IO Buffer duration for audio session
  final double audioSessionPreferredIOBufferDuration;

  /// Whether DTMF is supported or not
  final bool supportsDTMF;

  /// Whether holding is supported or not
  final bool supportsHolding;

  /// Whether calls grouping is supported or not
  final bool supportsGrouping;

  /// Whether calls ungrouping is supported or not
  final bool supportsUngrouping;

  /// Ringtone file name of the file added  to root project xcode /ios/Runner/
  /// It should be Copy Bundle Resources(Build Phases)
  final String ringtoneFileName;
  CallKeepIosConfig({
    this.iconName = 'CallKeepLogo',
    this.handleType = CallKitHandleType.generic,
    this.isVideoSupported = true,
    this.maximumCallGroups = 2,
    this.maximumCallsPerCallGroup = 1,
    this.audioSessionMode,
    this.audioSessionActive = true,
    this.audioSessionPreferredSampleRate = 44100,
    this.audioSessionPreferredIOBufferDuration = 0.005,
    this.supportsDTMF = true,
    this.supportsHolding = true,
    this.supportsGrouping = true,
    this.supportsUngrouping = true,
    this.ringtoneFileName = 'system_ringtone_default',
  });

  Map<String, dynamic> toMap() {
    return {
      'iconName': iconName,
      'handleType': handleType.name,
      'isVideoSupported': isVideoSupported,
      'maximumCallGroups': maximumCallGroups,
      'maximumCallsPerCallGroup': maximumCallsPerCallGroup,
      'audioSessionMode': audioSessionMode?.name ?? 'default',
      'audioSessionActive': audioSessionActive,
      'audioSessionPreferredSampleRate': audioSessionPreferredSampleRate,
      'audioSessionPreferredIOBufferDuration':
          audioSessionPreferredIOBufferDuration,
      'supportsDTMF': supportsDTMF,
      'supportsHolding': supportsHolding,
      'supportsGrouping': supportsGrouping,
      'supportsUngrouping': supportsUngrouping,
      'ringtoneFileName': ringtoneFileName,
    };
  }
}

/// The CallKit handle type
enum CallKitHandleType { generic, number, email }

/// Parses a [CallKitHandleType] from a given string [name]
///
/// Returns [CallKitHandleType.generic] if no value found
CallKitHandleType callKitHandleTypeFromName(String name) {
  try {
    return CallKitHandleType.values.byName(name);
  } catch (e) {
    return CallKitHandleType.generic;
  }
}

/// AvAudioSession modes and descriptions can be found at
/// https://developer.apple.com/documentation/avfaudio/avaudiosession/mode
enum AvAudioSessionMode {
  gameChat,
  measurement,
  moviePlayback,
  spokenAudio,
  videoChat,
  videoRecording,
  voiceChat,
  voicePrompt
}
