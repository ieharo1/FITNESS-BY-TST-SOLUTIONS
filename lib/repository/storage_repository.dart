import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String> uploadProgressPhoto(String userId, File imageFile) async {
    try {
      final fileName = '${userId}_${_uuid.v4()}.jpg';
      final ref = _storage.ref().child('progress_photos').child(userId).child(fileName);
      
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );
      
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  Future<void> deleteProgressPhoto(String photoUrl) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete photo: $e');
    }
  }

  Future<String> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      final fileName = 'profile_${_uuid.v4()}.jpg';
      final ref = _storage.ref().child('profile_photos').child(userId).child(fileName);
      
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );
      
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }
}
