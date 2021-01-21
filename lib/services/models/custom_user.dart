import 'package:intl/intl.dart';

/// This is user doc inside the users collection and not the FirebaseUser
class CustomUser {
  String id;
  String createdAt;

  CustomUser({this.id, this.createdAt});

  factory CustomUser.fromMap({String uid, Map data}) {
    Function dateFormatter = DateFormat.yMMMd().add_jm().format;

    return CustomUser(
      id: uid ?? '',
      createdAt: dateFormatter(data['createdAt'].toDate()) ?? null,
    );
  }
}
