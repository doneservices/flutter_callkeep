import 'package:flutter_callkeep/flutter_callkeep.dart';

/// The data for toggling call group event from CallKeep
class CallGroupToggleData extends CallKeepBaseData {
  final String callUuidToGroupWith;

  CallGroupToggleData({
    required String callUuid,
    required this.callUuidToGroupWith,
  }) : super(uuid: callUuid);

  factory CallGroupToggleData.fromMap(Map<String, dynamic> map) {
    return CallGroupToggleData(
      callUuid: map['id'] ?? '',
      callUuidToGroupWith: map['callUUIDToGroupWith'] ?? '',
    );
  }
}
