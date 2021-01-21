import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../constants.dart';
import '../services/db/image_url_collection.dart';
import '../shared/app_bar.dart';
import '../shared/dialog_box.dart';
import '../shared/drawer.dart';

class ExportImages extends StatefulWidget {
  /// Images
  final List<File> images;

  ExportImages({@required this.images});

  @override
  _ExportImagesState createState() => _ExportImagesState();
}

class _ExportImagesState extends State<ExportImages> {
  /// Using a GlobalKey for the Custom Drawer to work
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final TextEditingController filenameCtrl = TextEditingController();
  String filename;

  /// Display loader to notify user that the certain task is in action
  bool _displaySaveLoader = false;
  bool _displayExportLoader = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: CustomAppBar(
          currentPath: '/export-images',
          scaffoldKey: _scaffoldKey,
          title: 'save file',
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
              _buildBottomBtns(context),
            ],
          ),
        ),
      );

  /// BUILDER FUNCTIONS

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
                controller: filenameCtrl,
                onChanged: (value) => filename = filenameCtrl.text,
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

  Widget _buildGridImages() => Container(
        margin: EdgeInsets.symmetric(vertical: Constants.space * 2),
        child: GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 0.8, // 0 - 1
          mainAxisSpacing: 15.0,
          crossAxisSpacing: 15.0,
          children: List.generate(widget.images.length, (int idx) {
            return _buildImage(widget.images[idx]);
          }),
        ),
      );

  Widget _buildImage(File img) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(Constants.space),
          image: DecorationImage(image: FileImage(img), fit: BoxFit.cover),
        ),
      );

  Widget _buildBtn(
    String label,
    Color color,
    Function onPressed,
    BuildContext context,
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

  Widget _buildBottomBtns(BuildContext context) => Align(
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
              context,
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
              context,
              _displayExportLoader,
            ),
          ],
        ),
      );

  /// FUNCTIONS

  Future<void> _saveToFirebase() async {
    /// While create new file we don't have any fileId nor we need it
    if (filenameCtrl.text.length > 0) {
      Map response = await ImageUrlCollection.createFile(
        widget.images,
        filename,
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
    } else {
      DialogBox.displayDialogBox(
        title: 'Warning',
        description: 'Kindly enter the filename',
        context: context,
      );
    }
  }

  /// To generate pdf (of the imgs loaded from gallery)
  pw.Document _generatePdf() {
    var pdf = pw.Document();
    widget.images.forEach((img) async {
      var image = pw.MemoryImage(img.readAsBytesSync());
      pdf.addPage(pw.Page(
        build: (pw.Context context) => pw.Center(child: pw.Image(image)),
      ));
    });
    return pdf;
  }

  /// Save pdf
  Future<void> _exportPdf() async {
    if (filenameCtrl.text.length > 0) {
      /// Creating the pdf
      pw.Document pdf = _generatePdf();

      /// Saving pdf file to the device's location
      final output = await getExternalStorageDirectory();
      var file = File("${output.path}/$filename.pdf");
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
        title: 'Warning',
        description: 'Kindly enter the filename',
        context: context,
      );
    }
  }
}
