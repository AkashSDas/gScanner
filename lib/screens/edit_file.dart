import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../constants.dart';
import '../services/db/edit_file_helper.dart';
import '../services/db/image_url_collection.dart';
import '../services/models/custom_image.dart';
import '../shared/app_bar.dart';
import '../shared/dialog_box.dart';
import '../shared/drawer.dart';
import '../shared/loader.dart';

class EditFile extends StatefulWidget {
  final String fileId;
  final String oldFilename;

  EditFile({@required this.fileId, @required this.oldFilename});

  @override
  _EditFileState createState() => _EditFileState();
}

class _EditFileState extends State<EditFile> with TickerProviderStateMixin {
  /// Using a GlobalKey for the Custom Drawer to work
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final TextEditingController newFilenameCtrl = TextEditingController();
  String newFilename;

  /// This list will contain imgs that are newly added as well as
  /// img from firebase storage
  List<dynamic> images = [];

  /// New imgs that are intended to be added to the file
  List<File> newImages = [];

  List<CustomImage> networkImages = [];

  /// Speed Dial
  ScrollController _speedDialScrollCtrl;
  bool _dialVisible = true;

  /// Display loader to notify user that the certain task is in action
  bool _displaySaveLoader = false;
  bool _displayExportLoader = false;

  @override
  void initState() {
    super.initState();
    newFilenameCtrl.text = widget.oldFilename;
    _speedDialScrollCtrl = ScrollController()
      ..addListener(() {
        _setDialVisible(
          _speedDialScrollCtrl.position.userScrollDirection ==
              ScrollDirection.forward,
        );
      });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: CustomAppBar(
          currentPath: '/edit-images',
          scaffoldKey: _scaffoldKey,
          title: 'edit file',
        ),
        drawer: AppDrawer(),
        body: Container(
          margin: EdgeInsets.symmetric(
            horizontal: Constants.space,
            vertical: Constants.space * 2,
          ),
          child: Column(
            children: [
              _builtFilenameTextField(),
              Expanded(child: _buildGridImages()),
              _buildBottomBtns(),
            ],
          ),
        ),
        floatingActionButton: _buildSpeedDial(),
      );

  /// BUILDER FUNCTIONS

  /// Filename text field
  Widget _builtFilenameTextField() => Container(
        margin: EdgeInsets.only(top: Constants.space),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filename', style: Theme.of(context).textTheme.headline3),
            SizedBox(height: 10.0),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Constants.space),
                boxShadow: [Constants.boxShadow],
                color: Theme.of(context).accentColor,
              ),
              child: TextField(
                keyboardType: TextInputType.text,
                controller: newFilenameCtrl,
                onChanged: (value) => newFilename = newFilenameCtrl.text,
                style: Theme.of(context).textTheme.bodyText1,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: Constants.space * 0.4,
                    horizontal: Constants.space * 0.6,
                  ),
                  hintText: 'Enter the filename',
                  hintStyle: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildGridImages() => StreamBuilder<Iterable<CustomImage>>(
      stream: ImageUrlCollection(widget.fileId).streamData(),
      builder: (context, snap) {
        if (!snap.hasData) return Container(child: Center(child: Loader()));

        networkImages = snap.data.toList();
        images = [...networkImages, ...newImages];

        return Container(
          margin: EdgeInsets.symmetric(vertical: Constants.space * 2),
          child: GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 0.8, // 0 - 1
            mainAxisSpacing: 15.0,
            crossAxisSpacing: 15.0,
            children: List.generate(images.length, (int idx) {
              return _buildImage(images[idx]);
            }),
          ),
        );
      });

  Widget _buildImage(var img) {
    /// img here can be of two type CustomImage or File
    /// CustomImage => for imgs stored in firebase storage
    /// File => for imgs that are newly added to the file
    /// but not stored in the firebase storage

    var image =
        img.runtimeType == CustomImage ? NetworkImage(img.url) : FileImage(img);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(Constants.space),
        image: DecorationImage(image: image, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildSpeedDial() => SpeedDial(
        animatedIcon: AnimatedIcons.list_view,
        animatedIconTheme: IconThemeData(size: 22.0, color: Colors.black),
        backgroundColor: Colors.white,
        overlayColor: Theme.of(context).accentColor,
        visible: _dialVisible,
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
            child: Icon(FontAwesome.image, color: Colors.white),
            backgroundColor: Constants.purple2,
            onTap: () => _addImage(ImageSource.gallery),
            label: 'Gallery',
            labelStyle: Theme.of(context).textTheme.bodyText1,
            labelBackgroundColor: Theme.of(context).accentColor,
          ),
          SpeedDialChild(
            child: Icon(FontAwesome.video_camera, color: Colors.white),
            backgroundColor: Constants.purple2,
            onTap: () => _addImage(ImageSource.camera),
            label: 'Camera',
            labelStyle: Theme.of(context).textTheme.bodyText1,
            labelBackgroundColor: Theme.of(context).accentColor,
          ),
        ],
      );

  Widget _buildBtn(
    String label,
    Color color,
    Function onPressed,
    bool display,
  ) =>
      display
          ? FlatButton(
              color: color,
              child: Container(
                child: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              onPressed: () {},
              minWidth: Constants.space * 80,
              padding: EdgeInsets.symmetric(vertical: Constants.space * 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.space * 60),
              ),
            )
          : FlatButton(
              color: color,
              child: Text(label, style: Theme.of(context).textTheme.headline4),
              onPressed: onPressed,
              minWidth: Constants.space * 80,
              padding: EdgeInsets.symmetric(vertical: Constants.space * 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.space * 60),
              ),
            );

  Widget _buildBottomBtns() => Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          children: [
            _buildBtn(
              'Save',
              Constants.blue2,
              () async {
                setState(() => _displaySaveLoader = true);
                await _saveToFirebase();
                setState(() => _displaySaveLoader = false);
              },
              _displaySaveLoader,
            ),
            SizedBox(height: Constants.space),
            _buildBtn(
              'Export as PDF',
              Constants.purple2,
              () async {
                setState(() => _displayExportLoader = true);
                await _exportPdf();
                setState(() => _displayExportLoader = false);
              },
              _displayExportLoader,
            ),
          ],
        ),
      );

  /// FUNCTIONS

  void _setDialVisible(bool value) => setState(() => _dialVisible = value);

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

  Future<void> _addImage(ImageSource source) async {
    File img = await _pickImage(source);

    /// img will be null when user doesn't selects an img
    if (img != null) {
      /// cropping the img
      img = await _cropImage(img);

      /// If img == null i.e. the user cancel's the cropper
      /// In that case that img won't be added to images list
      if (img != null) setState(() => newImages = [...newImages, img]);
    }
  }

  Future<void> _saveToFirebase() async {
    Map response = await EditFileHelper().updateImages(
      oldFilename: widget.oldFilename,
      newFilename: newFilenameCtrl.text,
      images: networkImages,
      newImages: newImages,
    );

    if (response['success'] == true) {
      DialogBox.displayDialogBox(
        title: 'Success',
        description: 'Successfully saved the file in the cloud',
        context: context,
        // onPressed: () => Navigator.pushNamedAndRemoveUntil(
        //   context,
        //   '/',
        //   (route) => false,
        // ),
      );

      /// Once the newly added imgs are uploaded along with the imgs that are re-uploaded
      /// the state is newImage is set to empty list since the stream builder will on all imgs
      /// doc created in firestore will have the newly added imgs and if newImages state is not
      /// updated the grid will have duplicate img
      setState(() => newImages = []);
    } else {
      String msg = response['fileExists'] == true
          ? 'Filename already used, kindly change the filename'
          : 'There was an error, please try again later';
      DialogBox.displayDialogBox(
        title: 'Failed',
        description: msg,
        context: context,
      );
    }
  }

  /// To generate pdf (of the imgs loaded from gallery)
  pw.Document _generatePdf(List<File> storageImgs) {
    var pdf = pw.Document();
    [...storageImgs, ...newImages].forEach((img) async {
      var image = pw.MemoryImage(img.readAsBytesSync());
      pdf.addPage(pw.Page(
        build: (pw.Context context) => pw.Center(child: pw.Image(image)),
      ));
    });
    return pdf;
  }

  /// Save pdf
  Future<void> _exportPdf() async {
    /// Place where the images will be downloaded
    Directory appDir = await getExternalStorageDirectory();

    /// Download img that are stored in firebase storage
    Map res = await EditFileHelper().downloadFile(networkImages, appDir);

    if (res['success'] == true) {
      /// Creating the pdf
      pw.Document pdf = _generatePdf(res['imgFiles']);

      /// Saving pdf file to the device's location
      final output = await getExternalStorageDirectory();
      var file = File("${output.path}/${newFilenameCtrl.text}.pdf");
      await file.writeAsBytes(await pdf.save());
      DialogBox.displayDialogBox(
        title: 'Success',
        description: 'Successfully saved the file in your phone',
        context: context,
        // onPressed: () => Navigator.pushNamedAndRemoveUntil(
        //   context,
        //   '/',
        //   (route) => false,
        // ),
      );
    } else {
      DialogBox.displayDialogBox(
        title: 'Failed',
        description: 'There was an error, please try again later',
        context: context,
      );
    }
  }
}
