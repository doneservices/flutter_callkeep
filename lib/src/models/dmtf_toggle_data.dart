class DmtfToggleData {
  final String callUuid;
  final String digits;
  final DmtfActionType actionType;
  DmtfToggleData({
    required this.callUuid,
    required this.digits,
    required this.actionType,
  });

  factory DmtfToggleData.fromMap(Map<String, dynamic> map) {
    return DmtfToggleData(
      callUuid: map['id'] ?? '',
      digits: map['digits'] ?? '',
      actionType: DmtfActionType.values[(map['type'] ?? 0) + 1],
    );
  }
}

enum DmtfActionType { singleTone, softPause, hardPause }
