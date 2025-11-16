import 'package:flutter_test/flutter_test.dart';
import 'package:girlsbandtabi_app/features/auth/domain/entities/user.dart';

/// EN: Unit tests for User entity following Clean Architecture principles
/// KO: Clean Architecture 원칙을 따르는 User 엔티티 단위 테스트
void main() {
  group('User Entity', () {
    // EN: Test data setup
    // KO: 테스트 데이터 설정
    const testUser = User(
      id: 'test-user-id',
      email: 'test@example.com',
      displayName: 'Test User',
      avatarUrl: 'https://example.com/avatar.png',
      isEmailVerified: true,
      createdAt: null,
      updatedAt: null,
    );

    test('EN: should create User entity with all required fields / KO: 모든 필수 필드로 User 엔티티 생성해야 함', () {
      // Arrange & Act
      const user = User(
        id: 'user-123',
        email: 'john.doe@example.com',
        displayName: 'John Doe',
      );

      // Assert
      expect(user.id, equals('user-123'));
      expect(user.email, equals('john.doe@example.com'));
      expect(user.displayName, equals('John Doe'));
      expect(user.avatarUrl, isNull);
      expect(user.isEmailVerified, isFalse);
      expect(user.createdAt, isNull);
      expect(user.updatedAt, isNull);
    });

    test('EN: should generate correct initials from display name / KO: 표시 이름에서 올바른 이니셜 생성해야 함', () {
      // Test single word
      const singleWordUser = User(
        id: 'user1',
        email: 'user@test.com',
        displayName: 'John',
      );
      expect(singleWordUser.initials, equals('J'));

      // Test multiple words
      const multiWordUser = User(
        id: 'user2',
        email: 'user@test.com',
        displayName: 'John Doe',
      );
      expect(multiWordUser.initials, equals('JD'));

      // Test three words (should use first and last)
      const threeWordUser = User(
        id: 'user3',
        email: 'user@test.com',
        displayName: 'John Michael Doe',
      );
      expect(threeWordUser.initials, equals('JD'));

      // Test empty name
      const emptyNameUser = User(
        id: 'user4',
        email: 'user@test.com',
        displayName: '',
      );
      expect(emptyNameUser.initials, equals('U'));
    });

    test('EN: should return correct display text / KO: 올바른 표시 텍스트 반환해야 함', () {
      // Test with display name
      const userWithName = User(
        id: 'user1',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      expect(userWithName.displayText, equals('Test User'));

      // Test without display name
      const userWithoutName = User(
        id: 'user2',
        email: 'test@example.com',
        displayName: '',
      );
      expect(userWithoutName.displayText, equals('test@example.com'));
    });

    test('EN: should support copyWith functionality / KO: copyWith 기능 지원해야 함', () {
      const originalUser = User(
        id: 'original-id',
        email: 'original@email.com',
        displayName: 'Original User',
        isEmailVerified: false,
      );

      final updatedUser = originalUser.copyWith(
        displayName: 'Updated User',
        isEmailVerified: true,
      );

      // Original should be unchanged
      expect(originalUser.displayName, equals('Original User'));
      expect(originalUser.isEmailVerified, isFalse);

      // Updated should have new values
      expect(updatedUser.id, equals('original-id'));
      expect(updatedUser.email, equals('original@email.com'));
      expect(updatedUser.displayName, equals('Updated User'));
      expect(updatedUser.isEmailVerified, isTrue);
    });

    test('EN: should implement equality correctly / KO: 동등성을 올바르게 구현해야 함', () {
      const user1 = User(
        id: 'user-id',
        email: 'test@email.com',
        displayName: 'Test User',
      );

      const user2 = User(
        id: 'user-id',
        email: 'test@email.com',
        displayName: 'Test User',
      );

      const user3 = User(
        id: 'different-id',
        email: 'test@email.com',
        displayName: 'Test User',
      );

      // Same content should be equal
      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));

      // Different content should not be equal
      expect(user1, isNot(equals(user3)));
      expect(user1.hashCode, isNot(equals(user3.hashCode)));
    });

    test('EN: should have proper toString implementation / KO: 적절한 toString 구현을 가져야 함', () {
      final userString = testUser.toString();
      
      expect(userString, contains('User('));
      expect(userString, contains('test-user-id'));
      expect(userString, contains('test@example.com'));
      expect(userString, contains('Test User'));
      expect(userString, contains('isEmailVerified: true'));
    });
  });
}