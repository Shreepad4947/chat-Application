import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class Constants {
  static String myNumber = "";
  static String userNumber = "";
  static String userName = "";
  static String currentUserUid = "";
}

final userRef = FirebaseFirestore.instance.collection('users');

class SettingProfileRoute extends StatefulWidget {
  SettingProfileRoute();

  @override
  SettingProfileRouteState createState() => new SettingProfileRouteState();
}

class SettingProfileRouteState extends State<SettingProfileRoute> {
  TextEditingController usernameController = new TextEditingController();
  TextEditingController userAboutController = new TextEditingController();
//  Constants.myNumber =SharedPrefrenceKeys.getUserPhone();
  Map<String, dynamic>? userMap;
  bool isLoading = true;
  bool isProfilePicSet = false;
  String imageUrl = "NotSet";
  File? imageFile;
  bool isUploading = false;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    // await _firestore
    //     .collection('users')
    //     .doc(_auth.currentUser!.uid)
    //     // .collection('chats')
    //     // .doc(fileName)
    //     .set({
    //   // "sendby": _auth.currentUser!.displayName,
    //   // "message": "",
    //   // "type": "img",
    //   "time": FieldValue.serverTimestamp(),
    // });
    setState(() {
      isUploading = true;
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(_auth.currentUser!.uid)
          // .collection('chats')
          // .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore.collection('users').doc(_auth.currentUser!.uid)
          // .collection('chats')
          // .doc(fileName)
          .update({"profilePic": imageUrl});
      setState(() {
        isUploading = false;
      });

      print(imageUrl);
    }
    setState(() {
      getUsers();
    });
  }

  @override
  void initState() {
    setState(() {
      getUserPhone();
      getUsers();
    });

    super.initState();
  }

  getUserPhone() async {
    String phoneKey = "USERPHONE";
    // ignore: await_only_futures
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.getString(phoneKey);
    Constants.myNumber = (prefs.getString(phoneKey))!;
    Constants.currentUserUid = _auth.currentUser!.uid;

    Constants.userName = usernameController.text;
    print(Constants.userName);
  }

  getUsers() async {
    await _firestore
        .collection('users')
        .where("uid", isEqualTo: _auth.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
      print(_auth.currentUser!.getIdToken().toString());
    });
  }

  upldateUserName() async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "name": usernameController.text,
    });
  }

  uploadUserAbout() async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "About": userAboutController.text,
    });
  }

  updateAboutInfo() {}

  bool isSwitched1 = true;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return isLoading
        ? Container(
            color: Colors.white,
            height: size.height,
            width: size.width,
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: Colors.cyan[800],
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 180.0,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.cyan[800],
                    flexibleSpace: FlexibleSpaceBar(),
                    bottom: PreferredSize(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                getImage();
                                setState(() {});
                              },
                              child: (isUploading)
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                          "${userMap!['profilePic']}"),
                                      child: CircularProgressIndicator())
                                  : CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                          "${userMap!['profilePic']}"),
                                      child: (userMap!['profilePic'] ==
                                              'NotSet')
                                          ? Container(
                                              height: 100,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors
                                                            .cyan.shade900,
                                                        blurRadius: 3.0,
                                                        offset:
                                                            Offset(0.0, 0.0))
                                                  ]),
                                              child: Icon(Icons.account_box,
                                                  size: 50,
                                                  color: Colors.cyan.shade900),
                                            )
                                          : Container(),
                                    ),
                            ),
                            Container(
                              color: Colors.cyan[800],
                              padding: EdgeInsets.fromLTRB(20, 0, 15, 2),
                              alignment: Alignment.bottomCenter,
                              constraints: BoxConstraints.expand(height: 50),
                              child: Text(userMap!['name'],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                            ),
                          ],
                        ),
                        preferredSize: Size.fromHeight(50)),
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ];
              },
              body: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Card(
                      margin: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(15, 30, 15, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Info",
                                    style: TextStyle(
                                        color: Colors.cyan[800],
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Container(height: 10),
                          InkWell(
                            highlightColor: Colors.black.withOpacity(0.1),
                            splashColor: Colors.black.withOpacity(0.1),
                            onTap: () => () {},
                            child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                        // "user phone",
                                        userMap!['phone'],
                                        style: TextStyle(
                                          color: Colors.grey,
                                        )),
                                    Text("Phone",
                                        style: TextStyle(
                                          color: Colors.black,
                                        )),
                                  ],
                                )),
                          ),
                          Divider(height: 0),
                          InkWell(
                            highlightColor: Colors.black.withOpacity(0.1),
                            splashColor: Colors.black.withOpacity(0.1),
                            onTap: () => () {},
                            child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: usernameController,
                                            decoration: InputDecoration(
                                                hintText:
                                                    // "user name",
                                                    userMap!['name'],
                                                border: InputBorder.none),
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                            onSubmitted: (term) {
                                              setState(() {
                                                upldateUserName();
                                              });
                                            },
                                          ),
                                        ),
                                        Icon(Icons.edit),
                                      ],
                                    ),
                                    Text("Username",
                                        style: TextStyle(
                                          color: Colors.black,
                                        )),
                                  ],
                                )),
                          ),
                          Divider(height: 0),
                          InkWell(
                            highlightColor: Colors.black.withOpacity(0.1),
                            splashColor: Colors.black.withOpacity(0.1),
                            onTap: () => () {},
                            child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: userAboutController,
                                            decoration: InputDecoration(
                                                hintText: userMap!['About'],
                                                border: InputBorder.none),
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                            onSubmitted: (term) {
                                              setState(() {
                                                uploadUserAbout();
                                              });
                                            },
                                          ),
                                        ),
                                        Icon(Icons.edit),
                                      ],
                                    ),
                                    Text("About",
                                        style: TextStyle(
                                          color: Colors.black,
                                        )),
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 10),
                    Card(
                      margin: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(15, 30, 15, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Settings",
                                    style: TextStyle(
                                        color: Colors.cyan[800],
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Container(height: 10),
                          InkWell(
                            highlightColor: Colors.black.withOpacity(0.1),
                            splashColor: Colors.black.withOpacity(0.1),
                            onTap: () => () {},
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              child: Text("Notification and Sound",
                                  style: TextStyle(
                                    color: Colors.black,
                                  )),
                            ),
                          ),
                          Divider(height: 0),
                          InkWell(
                            highlightColor: Colors.black.withOpacity(0.1),
                            splashColor: Colors.black.withOpacity(0.1),
                            onTap: () => () {},
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              child: Text("Privacy and Security",
                                  style: TextStyle(
                                    color: Colors.black,
                                  )),
                            ),
                          ),
                          Divider(height: 0),
                          InkWell(
                            highlightColor: Colors.black.withOpacity(0.1),
                            splashColor: Colors.black.withOpacity(0.1),
                            onTap: () => () {},
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              child: Text("Data and Storage",
                                  style: TextStyle(
                                    color: Colors.black,
                                  )),
                            ),
                          ),
                          Divider(height: 0),
                          InkWell(
                            highlightColor: Colors.black.withOpacity(0.1),
                            splashColor: Colors.black.withOpacity(0.1),
                            onTap: () => () {},
                            child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  children: <Widget>[
                                    Text("Enable Animation",
                                        style: TextStyle(
                                          color: Colors.black,
                                        )),
                                    Spacer(),
                                    Switch(
                                      value: isSwitched1,
                                      onChanged: (value) {
                                        setState(() {
                                          isSwitched1 = value;
                                        });
                                      },
                                      activeColor: Colors.cyan[800],
                                      inactiveThumbColor: Colors.grey,
                                    )
                                  ],
                                )),
                          ),
                          Divider(height: 0),
                          InkWell(
                            highlightColor: Colors.black.withOpacity(0.1),
                            splashColor: Colors.black.withOpacity(0.1),
                            onTap: () => () {},
                            child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                child: Row(
                                  children: <Widget>[
                                    Text("Theme",
                                        style: TextStyle(
                                          color: Colors.black,
                                        )),
                                    Spacer(),
                                    Text("Default",
                                        style: TextStyle(
                                          color: Colors.cyan[800],
                                        )),
                                  ],
                                )),
                          ),
                          Divider(height: 0),
                          InkWell(
                            highlightColor: Colors.black.withOpacity(0.1),
                            splashColor: Colors.black.withOpacity(0.1),
                            onTap: () => () {},
                            child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                child: Row(
                                  children: <Widget>[
                                    Text("Language",
                                        style: TextStyle(
                                          color: Colors.black,
                                        )),
                                    Spacer(),
                                    Text("English",
                                        style: TextStyle(
                                          color: Colors.cyan[800],
                                        )),
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 10),
                    Card(
                      margin: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(15, 30, 15, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Support",
                                    style: TextStyle(
                                        color: Colors.cyan[800],
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Container(height: 10),
                          InkWell(
                            highlightColor: Colors.black.withOpacity(0.1),
                            splashColor: Colors.black.withOpacity(0.1),
                            onTap: () => () {},
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              child: Text("Ask a Question",
                                  style: TextStyle(
                                    color: Colors.black,
                                  )),
                            ),
                          ),
                          Divider(height: 0),
                          InkWell(
                            highlightColor: Colors.black.withOpacity(0.1),
                            splashColor: Colors.black.withOpacity(0.1),
                            onTap: () => () {},
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              child: Text("F A Q",
                                  style: TextStyle(
                                    color: Colors.black,
                                  )),
                            ),
                          ),
                          Divider(height: 0),
                          InkWell(
                            highlightColor: Colors.black.withOpacity(0.1),
                            splashColor: Colors.black.withOpacity(0.1),
                            onTap: () => () {},
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              child: Text("Privacy Policy",
                                  style: TextStyle(
                                    color: Colors.black,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 15),
                    Text("Build Version 2.0.5",
                        style: TextStyle(
                          color: Colors.cyan[800],
                        )),
                    Container(height: 15),
                  ],
                ),
              ),
            ),
          );
  }
}
