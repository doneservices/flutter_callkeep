import 'package:flutter_callkeep/flutter_callkeep.dart';

class DmtfToggleData extends CallKeepBaseData {
  final String digits;
  final DmtfActionType actionType;

  DmtfToggleData({
    required String callUuid,
    required this.digits,
    required this.actionType,
  }) : super(uuid: callUuid);

  factory DmtfToggleData.fromMap(Map<String, dynamic> map) {
    return DmtfToggleData(
      callUuid: map['id'] ?? '',
      digits: map['digits'] ?? '',
      actionType: DmtfActionType.values[(map['type'] ?? 0) + 1],
    );
  }
}

enum DmtfActionType { singleTone, softPause, hardPause }
