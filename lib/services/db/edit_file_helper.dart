import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import './file_collection.dart';
import './image_url_collection.dart';
import '../auth/auth.dart';
import '../models/custom_image.dart';

class EditFileHelper {
  User user;
  FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://gscanner-5e2a6.appspot.com',
  );

  EditFileHelper() {
    user = AuthService().getUser;
  }

  Future<Map> updateImages({
    String oldFilename,
    String newFilename,
    List<CustomImage> images,
    List<File> newImages,
  }) async {
    /// makeChangesForFilename func should only be used when the filename
    /// is changed but can also be used if the filename is not changed
    /// but in that case there will be a bit of load on the firebase
    /// just because of the way "makeChangesForFilename" work
    return await _makeChangesForFilename(
      oldFilename,
      newFilename,
      images,
      newImages,
    );
  }

  /// If the filename is changed then this func will be used to
  /// do the updation
  Future<Map> _makeChangesForFilename(
    String oldFilename,
    String newFilename,
    List<CustomImage> images,
    List<File> newImages,
  ) async {
    try {
      /// Place where the images will be downloaded
      Directory appDir = await getExternalStorageDirectory();

      /// Download all the images
      Map dwldRes = await downloadFile(images, appDir);
      if (dwldRes['success'] != true) return dwldRes;

      /// Deleting the images from firebase storage and also the firestore file doc
      /// and also the imageUrls collection inside the file doc
      Map res = await FileCollection().deleteFile(oldFilename);
      if (res['success'] != true) return res;

      /// Upload imgs
      List<File> addImgs = [...dwldRes['imgFiles'], ...newImages];
      res = await ImageUrlCollection.createFile(addImgs, newFilename);

      return res;
    } catch (e) {
      return {'success': false};
    }
  }

  /// Download the img files on to the local device in specified dir
  Future<Map> downloadFile(
    List<CustomImage> images,
    Directory appDir,
  ) async {
    File downloadToFile;
    List<File> imgFiles = [];

    /// Using for loop to make await work as it should
    for (CustomImage img in images) {
      try {
        http.Response _ = await http.get(img.url);
        downloadToFile = File('${appDir.path}/${img.id}.png');
        if (downloadToFile.existsSync()) downloadToFile.delete();
        downloadToFile.createSync();

        DownloadTask task = _storage
            .ref('files/${img.imageFilename}')
            .writeToFile(downloadToFile);
        TaskSnapshot snapshot = await task;
        imgFiles.add(downloadToFile);
      } catch (e) {
        return {'success': false, 'imgFiles': []};
      }
    }

    return {'success': true, 'imgFiles': imgFiles};
  }
}
