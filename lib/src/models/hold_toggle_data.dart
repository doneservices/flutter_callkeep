class HoldToggleData {
  final bool isOnHold;
  final String callUuid;
  HoldToggleData({
    required this.isOnHold,
    required this.callUuid,
  });

  factory HoldToggleData.fromMap(Map<String, dynamic> map) {
    return HoldToggleData(
      isOnHold: map['isOnHold'] ?? false,
      callUuid: map['id'] ?? '',
    );
  }
}
