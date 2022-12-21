class MuteToggleData {
  final String callUuid;
  final bool isMuted;

  MuteToggleData({
    required this.callUuid,
    required this.isMuted,
  });

  factory MuteToggleData.fromMap(Map<String, dynamic> map) {
    return MuteToggleData(
      callUuid: map['id'] ?? '',
      isMuted: map['isMuted'] ?? false,
    );
  }
}
