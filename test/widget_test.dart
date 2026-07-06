import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taleem/data/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    final now = DateTime.now();
    final user = UserModel(
      id: 'test_id',
      email: 'test@example.com',
      displayName: 'Test User',
      photoUrl: 'https://example.com/photo.png',
      role: UserRole.admin,
      phone: '+1234567890',
      createdAt: now,
      lastLoginAt: now,
      fcmTokens: ['token1', 'token2'],
      isActive: true,
    );

    test('toJson serialization works correctly', () {
      final json = user.toJson();

      expect(json['id'], 'test_id');
      expect(json['email'], 'test@example.com');
      expect(json['displayName'], 'Test User');
      expect(json['photoUrl'], 'https://example.com/photo.png');
      expect(json['role'], 'admin');
      expect(json['phone'], '+1234567890');
      expect(json['createdAt'], isA<Timestamp>());
      expect(json['lastLoginAt'], isA<Timestamp>());
      expect(json['fcmTokens'], ['token1', 'token2']);
      expect(json['isActive'], true);
    });

    test('fromJson deserialization works correctly', () {
      final json = {
        'id': 'test_id',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'photoUrl': 'https://example.com/photo.png',
        'role': 'admin',
        'phone': '+1234567890',
        'createdAt': Timestamp.fromDate(now),
        'lastLoginAt': Timestamp.fromDate(now),
        'fcmTokens': ['token1', 'token2'],
        'isActive': true,
      };

      final deserializedUser = UserModel.fromJson(json);

      expect(deserializedUser.id, 'test_id');
      expect(deserializedUser.email, 'test@example.com');
      expect(deserializedUser.displayName, 'Test User');
      expect(deserializedUser.photoUrl, 'https://example.com/photo.png');
      expect(deserializedUser.role, UserRole.admin);
      expect(deserializedUser.phone, '+1234567890');
      // Strip millisecond precision differences if any, or check close matches
      expect(deserializedUser.createdAt.isAtSameMomentAs(now), true);
      expect(deserializedUser.lastLoginAt.isAtSameMomentAs(now), true);
      expect(deserializedUser.fcmTokens, ['token1', 'token2']);
      expect(deserializedUser.isActive, true);
    });
  });
}
