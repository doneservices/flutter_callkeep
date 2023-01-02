import 'package:flutter_callkeep/flutter_callkeep.dart';

/// The device push token data for VoIP
///
/// [token] is always an empty String on Android
class VoipTokenData extends CallKeepBaseData {
  final String token;

  VoipTokenData({
    required this.token,
    required String callUuid,
  }) : super(uuid: callUuid);

  factory VoipTokenData.fromMap(Map<String, dynamic> map) {
    return VoipTokenData(
      token: map['deviceTokenVoIP'] ?? '',
      callUuid: map['id'] ?? '',
    );
  }
}
