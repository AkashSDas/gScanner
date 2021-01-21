import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/auth.dart';
import '../models/custom_user.dart';

class UserDoc {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User user;
  String path;
  DocumentReference ref;

  UserDoc() {
    user = AuthService().getUser;
    path = 'users/${user.uid}';
    ref = _db.doc(path);
  }

  /// Get doc data as a stream
  Stream<CustomUser> streamData() {
    return ref
        .snapshots()
        .map((doc) => CustomUser.fromMap(uid: doc.id, data: doc.data()));
  }

  /// Creating a user doc if it doesn't exists
  static bool createUser(String uid) {
    final FirebaseFirestore _db = FirebaseFirestore.instance;

    _db.doc('users/$uid').get().then((DocumentSnapshot snap) {
      if (!snap.exists)
        return _db
            .collection('users')
            .doc(uid)
            .set({'createdAt': FieldValue.serverTimestamp()})
            .then((_) => true)
            .catchError((_) => false);
      else
        return true;
    }).catchError((e) => false);
    return false;
  }
}
