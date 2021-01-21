import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

import './edit_file.dart';
import '../constants.dart';
import '../services/db/file_collection.dart';
import '../services/db/image_url_collection.dart';
import '../services/db/user_doc.dart';
import '../services/models/custom_file.dart';
import '../services/models/custom_image.dart';
import '../services/models/custom_user.dart';
import '../shared/app_bar.dart';
import '../shared/bottom_nav.dart';
import '../shared/dialog_box.dart';
import '../shared/drawer.dart';
import '../shared/loader.dart';

class Home extends StatelessWidget {
  /// Using a GlobalKey for the Custom Drawer to work
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: _streamProviders(),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Theme.of(context).primaryColor,
          appBar: CustomAppBar(
            currentPath: '/home',
            scaffoldKey: _scaffoldKey,
            title: 'home',
          ),
          bottomNavigationBar: AppBottomNav(),
          drawer: AppDrawer(),
          body: FileList(),
        ),
      );

  /// FUNCTIONS

  /// These providers need authenticated user
  List<StreamProvider<dynamic>> _streamProviders() => [
        StreamProvider<CustomUser>.value(value: UserDoc().streamData()),
        StreamProvider<Iterable<CustomFile>>.value(
          value: FileCollection().streamData(),
        ),
      ];
}

class FileList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Iterable<CustomFile> fileIter = Provider.of<Iterable<CustomFile>>(context);

    if (fileIter == null) return Container(child: Center(child: Loader()));

    List<CustomFile> files = fileIter.toList();
    return Container(
      margin: EdgeInsets.only(top: Constants.space * 1.4),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: files.length,
        itemBuilder: (context, int idx) => FileListTile(file: files[idx]),
      ),
    );
  }
}

class FileListTile extends StatelessWidget {
  final CustomFile file;

  FileListTile({@required this.file});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditFile(
                fileId: file.id,
                oldFilename: file.title,
              ),
            ),
          );
        },
        child: _buildListTile(context),
      );

  /// BUILDER FUNCTIONS

  Widget _buildListTile(BuildContext context) {
    /// The splash color on the container won't be visible since the container's
    /// color covers it, but the outcome has cool effect in this case
    return Container(
      height: Constants.space * 20,
      padding: EdgeInsets.symmetric(
        vertical: Constants.space,
        horizontal: Constants.space,
      ),
      margin: EdgeInsets.symmetric(
        vertical: Constants.space,
        horizontal: Constants.space,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.circular(Constants.space),
        boxShadow: [Constants.boxShadow],
      ),
      child: Column(
        children: [
          _buildFileInfo(context),
          _buildFileImageView(),
        ],
      ),
    );
  }

  Widget _buildFileInfo(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              file.title,
              style: Theme.of(context).textTheme.headline3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildActionBtns(context),
        ],
      );

  Widget _buildActionBtn(
    IconData icon,
    Color bgColor,
    Color color,
    Function onPressed,
  ) =>
      Material(
        type: MaterialType.transparency,
        child: Container(
          margin: EdgeInsets.only(
            left: Constants.space * 0.4,
            right: Constants.space * 0.4,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(Constants.space * 10),
          ),
          child: IconButton(
            icon: Icon(icon),
            color: color,
            onPressed: onPressed,
          ),
        ),
      );

  Widget _buildActionBtns(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildActionBtn(
            AntDesign.delete,
            Colors.white,
            Colors.black,
            () {
              DialogBox.displayDeleteFileYesOrNoDialog(
                title: 'Delete',
                description: 'Are you sure you want to delete this file',
                context: context,
                onYesPressed: () => FileCollection().deleteFile(file.id),
              );
            },
          ),
        ],
      );

  /// Display atmost 4 imgs of the file
  Widget _buildFileImageView() {
    ImageUrlCollection collection = ImageUrlCollection(file.id);
    Stream<Iterable<CustomImage>> imgs = collection.streamData();

    return StreamBuilder(
      stream: imgs,
      builder: (context, snap) {
        if (!snap.hasData) return Container();

        List<CustomImage> imgList = snap.data.toList();

        /// if the num of imgs are less then 4
        int itemCount = imgList.length > 5 ? 4 : imgList.length;

        return Container(
          height: Constants.space * 12,
          margin: EdgeInsets.only(top: Constants.space),
          child: GridView.builder(
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.8,
              mainAxisSpacing: 15.0,
              crossAxisSpacing: 10.0,
            ),
            itemBuilder: (context, idx) => _buildImage(imgList[idx], context),
          ),
        );
      },
    );
  }

  Widget _buildImage(CustomImage img, BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(Constants.space),
          image: DecorationImage(
            image: NetworkImage(img.url),
            fit: BoxFit.cover,
          ),
        ),
      );
}
