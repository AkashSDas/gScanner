import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import './export_images.dart';
import '../constants.dart';
import '../shared/app_bar.dart';
import '../shared/dialog_box.dart';
import '../shared/drawer.dart';

/// This widget is reponsible for picking multiple (one img at
/// a time) from gallery/camera and then cropping it

class PickImages extends StatefulWidget {
  final String appBarTitle;
  final String currentPath;
  final ImageSource pickImgSource;

  PickImages({
    @required this.appBarTitle,
    @required this.currentPath,
    @required this.pickImgSource,
  });

  @override
  _PickImagesState createState() => _PickImagesState();
}

class _PickImagesState extends State<PickImages> {
  /// Using a GlobalKey for the Custom Drawer to work
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  /// List of all Images
  List<File> images = [];

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: CustomAppBar(
          currentPath: widget.currentPath,
          scaffoldKey: _scaffoldKey,
          title: widget.appBarTitle,
          rightIconBtn: _buildSaveBtn(),
        ),
        drawer: AppDrawer(),
        floatingActionButton: _buildFloatingActionBtn(),
        body: Container(
          margin: EdgeInsets.symmetric(
            horizontal: Constants.space,
            vertical: Constants.space * 2,
          ),
          child: _buildGridImages(),
        ),
      );

  /// BUILDER FUNCTIONS

  Widget _buildSaveBtn() => IconButton(
        icon: Icon(FontAwesome.check),
        color: Colors.white,
        onPressed: () {
          if (images.isNotEmpty) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ExportImages(images: images),
            ));
          } else {
            DialogBox.displayDialogBox(
              title: 'Warning',
              description: 'Please add images',
              context: context,
            );
          }
        },
      );

  Widget _buildFloatingActionBtn() => FloatingActionButton(
        backgroundColor: Constants.purple3,
        child: Icon(AntDesign.plus, color: Colors.white),
        onPressed: () async {
          File img = await _pickImage(widget.pickImgSource);

          /// img will be null when user doesn't selects an img
          if (img != null) {
            /// cropping the img
            img = await _cropImage(img);

            /// If img == null i.e. the user cancel's the cropper
            /// In that case that img won't be added to images list
            if (img != null) {
              setState(() {
                images = [...images, img];
              });
            }
          }
        },
      );

  Widget _buildGridImages() => GridView.builder(
        scrollDirection: Axis.vertical,
        itemCount: images.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8, // 0 - 1
          mainAxisSpacing: 15.0,
          crossAxisSpacing: 15.0,
        ),
        itemBuilder: (context, idx) => _buildImage(images[idx]),
      );

  Widget _buildImage(File img) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(Constants.space),
          image: DecorationImage(image: FileImage(img), fit: BoxFit.cover),
        ),
      );

  /// FUNCTIONS

  /// Select an image via camera or gallery tho this part
  /// will only select the image using camera
  Future<File> _pickImage(ImageSource source) async {
    PickedFile selected = await ImagePicker().getImage(source: source);
    if (selected != null) return File(selected.path);
    return null;
  }

  /// Cropping the image
  Future<File> _cropImage(File imageFile) async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Constants.purple2,
        toolbarWidgetColor: Colors.white,
        statusBarColor: Colors.black,
        backgroundColor: Theme.of(context).primaryColor,
        activeControlsWidgetColor: Constants.blue2,
      ),
    );

    /// This will return null if the user cancel's the cropper
    /// In that case that img won't be added to images list
    return cropped;
  }
}
