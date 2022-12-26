import 'package:flutter_callkeep/flutter_callkeep.dart';

class MuteToggleData extends CallKeepBaseData {
  final bool isMuted;

  MuteToggleData({
    required String callUuid,
    required this.isMuted,
  }) : super(uuid: callUuid);

  factory MuteToggleData.fromMap(Map<String, dynamic> map) {
    return MuteToggleData(
      callUuid: map['id'] ?? '',
      isMuted: map['isMuted'] ?? false,
    );
  }
}
