import 'package:flutter_callkeep/flutter_callkeep.dart';

/// CallKit hold toggling information from CallKit
class HoldToggleData extends CallKeepBaseData {
  final bool isOnHold;

  HoldToggleData({
    required this.isOnHold,
    required String callUuid,
  }) : super(uuid: callUuid);

  factory HoldToggleData.fromMap(Map<String, dynamic> map) {
    return HoldToggleData(
      isOnHold: map['isOnHold'] ?? false,
      callUuid: map['id'] ?? '',
    );
  }
}
