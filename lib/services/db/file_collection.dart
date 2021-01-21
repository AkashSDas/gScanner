import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './image_url_collection.dart';
import '../auth/auth.dart';
import '../models/custom_file.dart';

class FileCollection {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User user;
  String path;
  CollectionReference ref;

  FileCollection() {
    user = AuthService().getUser;
    path = 'users/${user.uid}/files';
    ref = _db.collection(path);
  }

  /// Get all the files of current user as a future
  Future<List<CustomFile>> getData() {
    return ref.get().then((snap) => snap.docs.map((doc) {
          return CustomFile.fromMap(fileId: doc.id, data: doc.data());
        }).toList());
  }

  /// Get all the files of current user as a stream
  Stream<Iterable<CustomFile>> streamData() {
    return ref.snapshots().map((snap) => snap.docs.map((doc) {
          return CustomFile.fromMap(fileId: doc.id, data: doc.data());
        }));
  }

  /// Create file with filename as id
  Future<Map> createFile(List<File> images, String title) {
    DocumentReference fileRef = _db.doc('$path/$title');

    return fileRef.get().then((DocumentSnapshot snap) {
      if (!snap.exists)
        return fileRef
            .set({'title': title})
            .then((_) => {'success': true, 'fileExists': false})
            .catchError((_) => {'success': false, 'fileExists': false});
      return {'success': false, 'fileExists': true};
    });
  }

  /// Delete the file
  Future<Map> deleteFile(String fileId) async {
    DocumentReference fileRef = _db.doc('$path/$fileId');

    Map response = await fileRef
        .delete()
        .then((_) => {'success': true})
        .catchError((_) => {'sccess': false});

    if (response['success'] == true)
      return await ImageUrlCollection.deleteImgsFromStorage(fileId);
    return {'sccess': false};
  }
}
