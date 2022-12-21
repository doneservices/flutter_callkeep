class CallGroupToggleData {
  final String callUuid;
  final String callUuidToGroupWith;

  CallGroupToggleData({
    required this.callUuid,
    required this.callUuidToGroupWith,
  });

  factory CallGroupToggleData.fromMap(Map<String, dynamic> map) {
    return CallGroupToggleData(
      callUuid: map['id'] ?? '',
      callUuidToGroupWith: map['callUUIDToGroupWith'] ?? '',
    );
  }
}
