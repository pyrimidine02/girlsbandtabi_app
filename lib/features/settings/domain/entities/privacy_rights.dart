/// EN: Domain entities for privacy settings and rights requests.
/// KO: 개인정보 설정 및 권리행사 요청 도메인 엔티티입니다.
library;

import '../../data/dto/privacy_rights_dto.dart';

class PrivacySettings {
  const PrivacySettings({
    required this.allowAutoTranslation,
    this.version,
    this.updatedAt,
  });

  final bool allowAutoTranslation;
  final int? version;
  final DateTime? updatedAt;

  factory PrivacySettings.fromDto(PrivacySettingsDto dto) {
    return PrivacySettings(
      allowAutoTranslation: dto.allowAutoTranslation,
      version: dto.version,
      updatedAt: dto.updatedAt,
    );
  }
}

class PrivacyRequestRecord {
  const PrivacyRequestRecord({
    required this.requestType,
    required this.status,
    required this.requestedAt,
    this.reason,
  });

  final String requestType;
  final String status;
  final DateTime requestedAt;
  final String? reason;

  factory PrivacyRequestRecord.fromDto(PrivacyRequestRecordDto dto) {
    return PrivacyRequestRecord(
      requestType: dto.requestType,
      status: dto.status,
      requestedAt: dto.requestedAt,
      reason: dto.reason,
    );
  }
}
