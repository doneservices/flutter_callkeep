import 'package:flutter_callkeep/flutter_callkeep.dart';

class AudioSessionToggleData extends CallKeepBaseData {
  final bool isActivated;

  AudioSessionToggleData({
    required String callUuid,
    required this.isActivated,
  }) : super(uuid: callUuid);

  factory AudioSessionToggleData.fromMap(Map<String, dynamic> map) {
    return AudioSessionToggleData(
      callUuid: map['id'] ?? '',
      isActivated: map['isActivate'] ?? false,
    );
  }
}
