import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';

/// Repository for handling user profile data in Firestore.
class UserProfileRepository {
  final FirebaseFirestore _db;

  /// Creates a [UserProfileRepository]. Optionally accepts a [FirebaseFirestore] instance for testing/mocking.
  UserProfileRepository({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  /// Saves the [profile] to Firestore under the user's UID.
  Future<void> saveProfile(UserProfileModel profile) async {
    try {
      await _db.collection('users').doc(profile.uid).set(profile.toJson());
    } catch (e) {
      throw 'Failed to save profile: $e';
    }
  }

  /// Retrieves the user profile for the given [uid]. Returns null if not found.
  Future<UserProfileModel?> getProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserProfileModel.fromJson(doc.data()!);
    } catch (e) {
      throw 'Failed to fetch profile: $e';
    }
  }
}
