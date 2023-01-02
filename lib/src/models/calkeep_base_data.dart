/// Holds the base data for CallKeep
///
/// This is used as base for all callkeep event's data
class CallKeepBaseData {
  /// A unique UUID identifier for each call
  /// and when the call is ended, the same UUID for that call to be used.
  final String uuid;

  CallKeepBaseData({required this.uuid});
}
