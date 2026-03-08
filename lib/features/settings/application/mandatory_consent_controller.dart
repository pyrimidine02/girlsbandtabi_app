/// EN: Mandatory consent gate controller for authenticated sessions.
/// KO: 인증 세션의 필수 동의 게이트 컨트롤러입니다.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/legal_policy_constants.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/result.dart';

enum RequiredConsentType { termsOfService, privacyPolicy }

extension RequiredConsentTypeX on RequiredConsentType {
  String get apiType {
    return switch (this) {
      RequiredConsentType.termsOfService => 'TERMS_OF_SERVICE',
      RequiredConsentType.privacyPolicy => 'PRIVACY_POLICY',
    };
  }

  String get currentVersion {
    return switch (this) {
      RequiredConsentType.termsOfService => LegalPolicyConstants.byType(
        LegalPolicyType.termsOfService,
      ).version,
      RequiredConsentType.privacyPolicy => LegalPolicyConstants.byType(
        LegalPolicyType.privacyPolicy,
      ).version,
    };
  }
}

class MandatoryConsentState {
  const MandatoryConsentState({
    required this.isLoading,
    required this.isRequired,
    required this.isSubmitting,
    required this.missingTypes,
    this.errorMessage,
  });

  const MandatoryConsentState.idle()
    : isLoading = false,
      isRequired = false,
      isSubmitting = false,
      missingTypes = const <RequiredConsentType>{},
      errorMessage = null;

  final bool isLoading;
  final bool isRequired;
  final bool isSubmitting;
  final Set<RequiredConsentType> missingTypes;
  final String? errorMessage;

  MandatoryConsentState copyWith({
    bool? isLoading,
    bool? isRequired,
    bool? isSubmitting,
    Set<RequiredConsentType>? missingTypes,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return MandatoryConsentState(
      isLoading: isLoading ?? this.isLoading,
      isRequired: isRequired ?? this.isRequired,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      missingTypes: missingTypes ?? this.missingTypes,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

@immutable
class ConsentHistoryRecord {
  const ConsentHistoryRecord({
    required this.type,
    required this.version,
    required this.agreed,
    required this.agreedAt,
  });

  final String type;
  final String version;
  final bool agreed;
  final String agreedAt;

  factory ConsentHistoryRecord.fromJson(Map<String, dynamic> json) {
    final agreedRaw = json['agreed'];
    final agreed = switch (agreedRaw) {
      bool value => value,
      String value => value.toLowerCase() == 'true',
      _ => false,
    };
    return ConsentHistoryRecord(
      type: (json['type'] as String?)?.trim() ?? 'UNKNOWN',
      version: (json['version'] as String?)?.trim() ?? '-',
      agreed: agreed,
      agreedAt: (json['agreedAt'] as String?)?.trim() ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'version': version,
      'agreed': agreed,
      'agreedAt': agreedAt,
    };
  }
}

class MandatoryConsentController extends StateNotifier<MandatoryConsentState> {
  MandatoryConsentController(this._ref)
    : super(const MandatoryConsentState.idle());

  final Ref _ref;
  bool _refreshing = false;

  Future<void> refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      if (!_ref.read(isAuthenticatedProvider)) {
        state = const MandatoryConsentState.idle();
        return;
      }

      state = state.copyWith(isLoading: true, clearErrorMessage: true);

      final apiClient = _ref.read(apiClientProvider);
      final remoteResult = await apiClient.get<List<ConsentHistoryRecord>>(
        ApiEndpoints.userConsents,
        queryParameters: const {'page': 0, 'size': 50, 'sort': 'agreedAt,desc'},
        fromJson: parseConsentHistoryRecords,
      );

      final storage = await _ref.read(localStorageProvider.future);
      final localRecords = parseConsentHistoryRecords(
        storage.getJsonList(LocalStorageKeys.userConsents) ?? const [],
      );

      var remoteRecords = const <ConsentHistoryRecord>[];
      String? remoteErrorMessage;
      if (remoteResult is Success<List<ConsentHistoryRecord>>) {
        remoteRecords = remoteResult.data;
      } else if (remoteResult is Err<List<ConsentHistoryRecord>>) {
        remoteErrorMessage = remoteResult.failure.userMessage;
      }

      final mergedRecords = <ConsentHistoryRecord>[
        ...remoteRecords,
        ...localRecords,
      ];
      final missingTypes = resolveMissingRequiredConsents(
        records: mergedRecords,
      );

      state = MandatoryConsentState(
        isLoading: false,
        isRequired: missingTypes.isNotEmpty,
        isSubmitting: false,
        missingTypes: missingTypes,
        errorMessage: missingTypes.isNotEmpty ? remoteErrorMessage : null,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Mandatory consent refresh failed',
        error: e,
        stackTrace: stackTrace,
        tag: 'MandatoryConsentController',
      );
      state = state.copyWith(
        isLoading: false,
        isRequired: true,
        isSubmitting: false,
        missingTypes: RequiredConsentType.values.toSet(),
        errorMessage: '동의 상태를 확인하지 못했어요. 잠시 후 다시 시도해주세요.',
      );
    } finally {
      _refreshing = false;
    }
  }

  Future<bool> submitRequiredConsents({
    required bool agreeTermsOfService,
    required bool agreePrivacyPolicy,
  }) async {
    if (!_ref.read(isAuthenticatedProvider)) {
      state = state.copyWith(
        isRequired: true,
        errorMessage: '로그인 후 동의할 수 있어요.',
      );
      return false;
    }
    if (!agreeTermsOfService || !agreePrivacyPolicy) {
      state = state.copyWith(
        isRequired: true,
        errorMessage: '이용약관과 개인정보 처리방침에 모두 동의해야 합니다.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);

    try {
      final storage = await _ref.read(localStorageProvider.future);
      final now = DateTime.now().toUtc().toIso8601String();
      final existing =
          storage.getJsonList(LocalStorageKeys.userConsents) ??
          const <Map<String, dynamic>>[];

      final next = <Map<String, dynamic>>[
        ...existing,
        ConsentHistoryRecord(
          type: RequiredConsentType.termsOfService.apiType,
          version: RequiredConsentType.termsOfService.currentVersion,
          agreed: true,
          agreedAt: now,
        ).toJson(),
        ConsentHistoryRecord(
          type: RequiredConsentType.privacyPolicy.apiType,
          version: RequiredConsentType.privacyPolicy.currentVersion,
          agreed: true,
          agreedAt: now,
        ).toJson(),
      ];

      await storage.setJsonList(LocalStorageKeys.userConsents, next);
      await refresh();
      return !state.isRequired;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Mandatory consent submit failed',
        error: e,
        stackTrace: stackTrace,
        tag: 'MandatoryConsentController',
      );
      state = state.copyWith(
        isSubmitting: false,
        isRequired: true,
        errorMessage: '동의 저장에 실패했습니다. 다시 시도해주세요.',
      );
      return false;
    }
  }

  void clear() {
    state = const MandatoryConsentState.idle();
  }
}

List<ConsentHistoryRecord> parseConsentHistoryRecords(dynamic json) {
  if (json is List) {
    return json
        .whereType<Map<String, dynamic>>()
        .map(ConsentHistoryRecord.fromJson)
        .toList(growable: false);
  }

  if (json is Map<String, dynamic>) {
    final items =
        json['items'] ?? json['content'] ?? json['results'] ?? json['data'];
    if (items is List) {
      return items
          .whereType<Map<String, dynamic>>()
          .map(ConsentHistoryRecord.fromJson)
          .toList(growable: false);
    }
  }

  return const <ConsentHistoryRecord>[];
}

Set<RequiredConsentType> resolveMissingRequiredConsents({
  required List<ConsentHistoryRecord> records,
}) {
  final missing = <RequiredConsentType>{};

  for (final type in RequiredConsentType.values) {
    final latest = _findLatestByType(records, type.apiType);
    if (latest == null ||
        !latest.agreed ||
        latest.version != type.currentVersion) {
      missing.add(type);
    }
  }

  return missing;
}

ConsentHistoryRecord? _findLatestByType(
  List<ConsentHistoryRecord> records,
  String expectedType,
) {
  ConsentHistoryRecord? latest;
  DateTime? latestTime;
  for (final item in records) {
    if (item.type.trim().toUpperCase() != expectedType) {
      continue;
    }
    final candidateTime = DateTime.tryParse(item.agreedAt);
    if (latest == null) {
      latest = item;
      latestTime = candidateTime;
      continue;
    }
    if (latestTime == null && candidateTime == null) {
      continue;
    }
    if (latestTime == null && candidateTime != null) {
      latest = item;
      latestTime = candidateTime;
      continue;
    }
    if (latestTime != null &&
        candidateTime != null &&
        candidateTime.isAfter(latestTime)) {
      latest = item;
      latestTime = candidateTime;
    }
  }
  return latest;
}

final mandatoryConsentControllerProvider =
    StateNotifierProvider<MandatoryConsentController, MandatoryConsentState>((
      ref,
    ) {
      final controller = MandatoryConsentController(ref);

      ref.listen<AuthState>(authStateProvider, (_, next) {
        switch (next) {
          case AuthState.authenticated:
            unawaited(controller.refresh());
            break;
          case AuthState.unauthenticated:
          case AuthState.initial:
            controller.clear();
            break;
        }
      });

      if (ref.read(isAuthenticatedProvider)) {
        unawaited(controller.refresh());
      }

      return controller;
    });
