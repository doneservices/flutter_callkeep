import 'package:flutter_callkeep/flutter_callkeep.dart';

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
