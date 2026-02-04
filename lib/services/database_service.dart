import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/career_role_model.dart';
import '../models/roadmap_model.dart';

class DatabaseService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // Generic wrapper for database operations to catch and log errors
  Future<T?> _handleDbOp<T>(Future<T> Function() op, String opName) async {
    try {
      return await op();
    } on FirebaseException catch (e) {
      print('DEBUG: Firestore Error during $opName: ${e.code} - ${e.message}');
      if (e.code == 'unavailable') {
        print(
            'CRITICAL: Firestore is unavailable. Check internet or if database is enabled.');
      } else if (e.code == 'permission-denied') {
        print(
            'CRITICAL: Firestore permission denied. Check security rules in Firebase Console.');
      } else if (e.code == 'failed-precondition') {
        print(
            'CRITICAL: Missing Firestore Index! Please check the debug console for the direct link to create the required composite index.');
      }
      rethrow;
    } catch (e) {
      print('DEBUG: Unexpected Error during $opName: $e');
      rethrow;
    }
  }

  // User Profile
  Future<void> saveUserProfile(UserModel user) async {
    return _handleDbOp<void>(() async {
      await _db
          .collection('users')
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    }, 'saveUserProfile');
  }

  Future<UserModel?> getUserProfile(String uid) async {
    return _handleDbOp<UserModel?>(() async {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    }, 'getUserProfile');
  }

  // Career Roles
  Future<List<CareerRoleModel>> getCareerRoles() async {
    final result = await _handleDbOp<List<CareerRoleModel>>(() async {
      final snapshot = await _db.collection('career_roles').get();
      return snapshot.docs
          .map((doc) => CareerRoleModel.fromMap(doc.data()))
          .toList();
    }, 'getCareerRoles');
    return result ?? [];
  }

  // Roadmaps
  Future<void> saveRoadmap(RoadmapModel roadmap) async {
    return _handleDbOp<void>(() async {
      await _db.collection('roadmaps').doc(roadmap.id).set(roadmap.toMap());
    }, 'saveRoadmap');
  }

  Future<RoadmapModel?> getRoadmap(String userId) async {
    return _handleDbOp<RoadmapModel?>(() async {
      final snapshot = await _db
          .collection('roadmaps')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return RoadmapModel.fromMap(snapshot.docs.first.data());
      }
      return null;
    }, 'getRoadmap');
  }

  // Progress Sync
  Future<void> updateRoadmapTask(
      String roadmapId, int weekIndex, int taskIndex, bool isCompleted) async {
    return _handleDbOp(() async {
      final docRef = _db.collection('roadmaps').doc(roadmapId);
      final doc = await docRef.get();
      if (doc.exists) {
        final roadmap = RoadmapModel.fromMap(doc.data()!);
        roadmap.weeks[weekIndex].tasks[taskIndex] = RoadmapTask(
          title: roadmap.weeks[weekIndex].tasks[taskIndex].title,
          isCompleted: isCompleted,
        );
        await docRef.update(roadmap.toMap());
      }
    }, 'updateRoadmapTask');
  }

  // Leaderboard
  Future<List<UserModel>> getLeaderboardUsers() async {
    final result = await _handleDbOp<List<UserModel>>(() async {
      final snapshot = await _db
          .collection('users')
          .orderBy('points', descending: true)
          .limit(20)
          .get();
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    }, 'getLeaderboardUsers');
    return result ?? [];
  }

  Future<int> getUserRank(int points) async {
    return _handleDbOp<int>(() async {
      final snapshot = await _db
          .collection('users')
          .where('points', isGreaterThan: points)
          .count()
          .get();
      return snapshot.count! + 1;
    }, 'getUserRank')
        .then((value) => value ?? 0);
  }
}
