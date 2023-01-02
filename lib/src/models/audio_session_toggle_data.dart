import 'package:flutter_callkeep/flutter_callkeep.dart';

/// The data for audio session toggle event from CallKeep
///
/// It may hold data for [answerCall] or [outgoingCall]
class AudioSessionToggleData extends CallKeepBaseData {
  final bool isActivated;
  final CallKeepCallData? answerCall;
  final CallKeepCallData? outgoingCall;

  AudioSessionToggleData({
    required String callUuid,
    required this.answerCall,
    required this.outgoingCall,
    required this.isActivated,
  }) : super(uuid: callUuid);

  factory AudioSessionToggleData.fromMap(Map<String, dynamic> map) {
    return AudioSessionToggleData(
      callUuid: map['id'] ?? '',
      answerCall: map['answerCall'] != null
          ? CallKeepCallData.fromMap(
              Map<String, dynamic>.from(map['answerCall']))
          : null,
      outgoingCall: map['outgoingCall'] != null
          ? CallKeepCallData.fromMap(
              Map<String, dynamic>.from(map['outgoingCall']))
          : null,
      isActivated: map['isActivate'] ?? false,
    );
  }
}
