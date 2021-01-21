class CustomImage {
  String id;
  String url;

  /// This file is in the firebase storage, this will be used to
  /// delete the image from storage
  String imageFilename;

  CustomImage({this.id, this.url, this.imageFilename});

  factory CustomImage.fromMap({String imgId, Map data}) {
    return CustomImage(
      id: imgId ?? '',
      url: data['url'] ?? '',
      imageFilename: data['imageFilename'] ?? '',
    );
  }
}
