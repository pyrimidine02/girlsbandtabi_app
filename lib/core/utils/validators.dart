import '../error/failure.dart';

/// EN: Utility class for input validation
/// KO: 입력 검증을 위한 유틸리티 클래스
class Validators {
  const Validators._();

  /// EN: Email validation regular expression
  /// KO: 이메일 검증 정규식
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
  );

  /// EN: Password validation regular expression (at least 8 chars, 1 letter, 1 number)
  /// KO: 비밀번호 검증 정규식 (최소 8자, 문자 1개, 숫자 1개)
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$',
  );

  /// EN: Korean phone number validation
  /// KO: 한국 전화번호 검증
  static final RegExp _phoneRegex = RegExp(
    r'^010-?[0-9]{4}-?[0-9]{4}$',
  );

  /// EN: Validate email address
  /// KO: 이메일 주소 검증
  static ValidationFailure? validateEmail(String? email, {String fieldName = 'email'}) {
    if (email == null || email.trim().isEmpty) {
      return ValidationFailure.required(fieldName);
    }

    final trimmedEmail = email.trim();
    if (!_emailRegex.hasMatch(trimmedEmail)) {
      if (fieldName == 'email') {
        return ValidationFailure.invalidEmail();
      }
      return ValidationFailure(
        message: 'Invalid $fieldName format',
        code: 'INVALID_EMAIL_FORMAT',
        fieldName: fieldName,
      );
    }

    return null;
  }

  /// EN: Validate password
  /// KO: 비밀번호 검증
  static ValidationFailure? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return ValidationFailure.required('password');
    }

    if (password.length < 8) {
      return const ValidationFailure(
        message: 'Password must be at least 8 characters long',
        code: 'PASSWORD_TOO_SHORT',
        fieldName: 'password',
      );
    }

    if (!_passwordRegex.hasMatch(password)) {
      return const ValidationFailure(
        message: 'Password must contain at least one letter and one number',
        code: 'PASSWORD_WEAK',
        fieldName: 'password',
      );
    }

    return null;
  }

  /// EN: Validate password confirmation
  /// KO: 비밀번호 확인 검증
  static ValidationFailure? validatePasswordConfirmation(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return ValidationFailure.required('confirmPassword');
    }

    if (password != confirmPassword) {
      return const ValidationFailure(
        message: 'Passwords do not match',
        code: 'PASSWORDS_DO_NOT_MATCH',
        fieldName: 'confirmPassword',
      );
    }

    return null;
  }

  /// EN: Validate display name
  /// KO: 표시 이름 검증
  static ValidationFailure? validateNickname(String? nickname) {
    if (nickname == null || nickname.trim().isEmpty) {
      return ValidationFailure.required('nickname');
    }

    final trimmedName = nickname.trim();
    if (trimmedName.length < 2) {
      return const ValidationFailure(
        message: 'Nickname must be at least 2 characters long',
        code: 'DISPLAY_NAME_TOO_SHORT',
        fieldName: 'nickname',
      );
    }

    if (trimmedName.length > 50) {
      return const ValidationFailure(
        message: 'Nickname must be less than 50 characters',
        code: 'DISPLAY_NAME_TOO_LONG',
        fieldName: 'nickname',
      );
    }

    return null;
  }

  /// EN: Backward compatible display name validation
  /// KO: 하위 호환을 위한 표시 이름 검증
  static ValidationFailure? validateDisplayName(String? displayName) {
    return validateNickname(displayName);
  }

  /// EN: Validate phone number (Korean format)
  /// KO: 전화번호 검증 (한국 형식)
  static ValidationFailure? validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      return null; // Phone number is optional
    }

    final trimmedPhone = phoneNumber.trim().replaceAll('-', '');
    if (!_phoneRegex.hasMatch(trimmedPhone)) {
      return const ValidationFailure(
        message: 'Invalid phone number format (use 010-XXXX-XXXX)',
        code: 'INVALID_PHONE_FORMAT',
        fieldName: 'phoneNumber',
      );
    }

    return null;
  }

  /// EN: Validate required field
  /// KO: 필수 필드 검증
  static ValidationFailure? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return ValidationFailure.required(fieldName);
    }
    return null;
  }

  /// EN: Validate string length
  /// KO: 문자열 길이 검증
  static ValidationFailure? validateLength(
    String? value,
    String fieldName, {
    int? minLength,
    int? maxLength,
  }) {
    if (value == null) return null;

    final length = value.length;

    if (minLength != null && length < minLength) {
      return ValidationFailure(
        message: '$fieldName must be at least $minLength characters',
        code: 'FIELD_TOO_SHORT',
        fieldName: fieldName,
      );
    }

    if (maxLength != null && length > maxLength) {
      return ValidationFailure(
        message: '$fieldName must be less than $maxLength characters',
        code: 'FIELD_TOO_LONG',
        fieldName: fieldName,
      );
    }

    return null;
  }

  /// EN: Validate latitude value
  /// KO: 위도 값 검증
  static ValidationFailure? validateLatitude(double? latitude) {
    if (latitude == null) {
      return ValidationFailure.required('latitude');
    }

    if (latitude < -90.0 || latitude > 90.0) {
      return const ValidationFailure(
        message: 'Latitude must be between -90 and 90',
        code: 'INVALID_LATITUDE',
        fieldName: 'latitude',
      );
    }

    return null;
  }

  /// EN: Validate longitude value
  /// KO: 경도 값 검증
  static ValidationFailure? validateLongitude(double? longitude) {
    if (longitude == null) {
      return ValidationFailure.required('longitude');
    }

    if (longitude < -180.0 || longitude > 180.0) {
      return const ValidationFailure(
        message: 'Longitude must be between -180 and 180',
        code: 'INVALID_LONGITUDE',
        fieldName: 'longitude',
      );
    }

    return null;
  }

  /// EN: Validate URL format
  /// KO: URL 형식 검증
  static ValidationFailure? validateUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return null; // URL is optional
    }

    try {
      final uri = Uri.parse(url.trim());
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return const ValidationFailure(
          message: 'Invalid URL format',
          code: 'INVALID_URL_FORMAT',
          fieldName: 'url',
        );
      }
    } catch (e) {
      return const ValidationFailure(
        message: 'Invalid URL format',
        code: 'INVALID_URL_FORMAT',
        fieldName: 'url',
      );
    }

    return null;
  }

  /// EN: Validate multiple fields and return first error
  /// KO: 여러 필드 검증 및 첫 번째 오류 반환
  static ValidationFailure? validateFields(
    List<ValidationFailure? Function()> validators,
  ) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// EN: Validate all fields and return all errors
  /// KO: 모든 필드 검증 및 모든 오류 반환
  static List<ValidationFailure> validateAllFields(
    List<ValidationFailure? Function()> validators,
  ) {
    final errors = <ValidationFailure>[];
    for (final validator in validators) {
      final result = validator();
      if (result != null) {
        errors.add(result);
      }
    }
    return errors;
  }
}
