import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  FirebaseStorage get _storage => FirebaseStorage.instance;

  Future<String?> uploadResume(String uid, File file) async {
    try {
      print('DEBUG: Starting resume upload for $uid...');
      final ref =
          _storage.ref().child('resumes').child(uid).child('latest_resume.pdf');
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      print('DEBUG: Resume upload successful. URL: $url');
      return url;
    } on FirebaseException catch (e) {
      debugPrint('DEBUG: Firebase Storage Error: ${e.code} - ${e.message}');
      if (e.code == 'quota-exceeded') {
        debugPrint('CRITICAL: Storage quota exceeded. Upgrade to Blaze plan.');
      } else if (e.code == 'unauthorized') {
        debugPrint('CRITICAL: Permission denied. Check Storage rules.');
      } else if (e.code == 'canceled') {
        debugPrint('DEBUG: Upload canceled by user.');
      }
      rethrow;
    } catch (e) {
      debugPrint('DEBUG: Unexpected error during resume upload: $e');
      rethrow;
    }
  }
}
