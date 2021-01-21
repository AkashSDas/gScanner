import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import './file_collection.dart';
import '../auth/auth.dart';
import '../models/custom_image.dart';

class ImageUrlCollection {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User user;
  String path;
  CollectionReference ref;

  ImageUrlCollection(String fileId) {
    user = AuthService().getUser;
    path = 'users/${user.uid}/files/$fileId/imageUrls';
    ref = _db.collection(path);
  }

  /// Get all the img urls of specified file as a stream
  Stream<Iterable<CustomImage>> streamData() {
    return ref.snapshots().map((snap) => snap.docs.map((doc) {
          return CustomImage.fromMap(imgId: doc.id, data: doc.data());
        }));
  }

  /// Get all the files of current user as a future
  Future<List<CustomImage>> getData() {
    return ref.get().then((v) => v.docs.map((d) {
          return CustomImage.fromMap(imgId: d.id, data: d.data());
        }).toList());
  }

  /// Save imgs in storage and add them in firestore
  static Future<Map> createFile(List<File> images, String title) async {
    Map response = await FileCollection().createFile(images, title);

    /// If file doesn't exists and it was successfully created then add imgs to it
    if (!response['fileExists'] && response['success']) {
      try {
        await _addImgsToFirebaseStorage(images, title);
        return {'success': true, 'fileExists': response['fileExists']};
      } catch (e) {
        return {'success': false, 'fileExists': response['fileExists']};
      }
    }
    return {'success': false, 'fileExists': response['fileExists']};
  }

  /// Add imgs to firebase storage and also add the img doc to firstore
  static Future<void> _addImgsToFirebaseStorage(
    List<File> images,
    String title,
  ) async {
    /// Get firebase static info
    Map info = _getStaticInfo(title);
    FirebaseStorage _storage = info['storage'];
    FirebaseFirestore _db = info['db'];
    User user = info['user'];
    String path = info['path'];

    images.forEach((img) async {
      bool foundUniqueName = false;
      Random rand = Random();
      int randNum;

      /// filename in firebase storage == userId-title-randomNum
      Reference imgRef = _storage.ref('files/');
      ListResult allImgs = await imgRef.listAll();

      String uniqueName;
      while (!foundUniqueName) {
        /// Here it is assumed that a pdf will have atmost 999 imgs
        /// This is done to give each file a unique name in firebase storage
        randNum = rand.nextInt(10000);
        uniqueName = '${user.uid}-$title-$randNum';
        if (!allImgs.items.contains(uniqueName)) break;
      }

      imgRef = imgRef.child(uniqueName);
      await imgRef.putFile(img);
      String url = await imgRef.getDownloadURL();
      await _addImgUrlToFirestore(_db, path, url, uniqueName);
    });
  }

  /// Add img doc to firestore
  static Future<void> _addImgUrlToFirestore(
    FirebaseFirestore db,
    String path,
    String url,
    String uniqueName,
  ) async {
    CollectionReference imgUrlCollection = db.collection(path);
    await imgUrlCollection.add({'url': url, 'imageFilename': uniqueName});
  }

  static Future<Map> deleteImgsFromStorage(String fileId) async {
    /// Get firebase static info
    Map info = _getStaticInfo(fileId);
    FirebaseStorage _storage = info['storage'];
    FirebaseFirestore _db = info['db'];
    String path = info['path'];

    CollectionReference imgUrlsRef = _db.collection(path);

    /// Get all the imgs urls of specified file
    List<CustomImage> imgList = await imgUrlsRef.get().then((snap) {
      return snap.docs.map((doc) {
        return CustomImage.fromMap(imgId: doc.id, data: doc.data());
      }).toList();
    });

    try {
      /// deleting imgs in firebase storage
      imgList.forEach((img) async {
        /// The filename for an img in firebase storage is stored
        /// in firestore individual img doc in "imageFilename"
        String filename = img.imageFilename;
        await _storage.ref('files/$filename').delete();

        /// Currently in firestore there isn't currently an
        /// operation that atomically deletes a collection, therefore
        /// looping through all the imgUrls's doc and deleting them
        await imgUrlsRef.doc('${img.id}').delete();
      });

      return {'success': true};
    } catch (e) {
      return {'success': false};
    }
  }

  static Map _getStaticInfo(String title) {
    FirebaseFirestore _db = FirebaseFirestore.instance;
    User user = AuthService().getUser;
    String path = 'users/${user.uid}/files/$title/imageUrls';
    FirebaseStorage _storage = FirebaseStorage.instanceFor(
      bucket: 'gs://gscanner-5e2a6.appspot.com',
    );
    return {'db': _db, 'user': user, 'path': path, 'storage': _storage};
  }
}
