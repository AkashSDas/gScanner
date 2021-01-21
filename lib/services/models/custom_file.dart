/// This File model is the blueprint of the firbase file doc
/// inside files collection
class CustomFile {
  String id;
  String title; // filename

  CustomFile({this.id, this.title});

  factory CustomFile.fromMap({String fileId, Map data}) {
    return CustomFile(
      id: fileId ?? '',
      title: data['title'] ?? '',
    );
  }
}
