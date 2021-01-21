import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../db/user_doc.dart';

/// Helper class to handle user auth
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Firebase user one-time fetch
  User get getUser => _auth.currentUser;

  /// Firebase user stream
  Stream<User> get user => _auth.authStateChanges();

  /// Sign in with Google
  Future<User> googleSignIn() async {
    try {
      GoogleSignInAccount gSignInAcc = await _googleSignIn.signIn();
      GoogleSignInAuthentication gSignInAuth = await gSignInAcc.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gSignInAuth.accessToken,
        idToken: gSignInAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User user = result.user;

      /// Cannot create new user if the user doesn't exist
      if (!UserDoc.createUser(user.uid)) return null;

      return user;
    } catch (e) {
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() => _auth.signOut();
}
