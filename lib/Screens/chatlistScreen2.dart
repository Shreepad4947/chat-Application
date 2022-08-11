import 'package:chat_app/GroupChats/CreateGroup/AddMembers.dart';
import 'package:chat_app/GroupChats/GroupChatRoom.dart';
import 'package:chat_app/Screens/ChatRoom.dart';
import 'package:chat_app/Screens/contact.dart';
import 'package:chat_app/Screens/setting_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

final userRef = FirebaseFirestore.instance.collection('chatroom');
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ChatHomeScreen2 extends StatefulWidget {
  // ChatHomeScreen({Key? key}) : super(key: key);

  @override
  _ChatHomeScreen2State createState() => _ChatHomeScreen2State();
}

class _ChatHomeScreen2State extends State<ChatHomeScreen2> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  Map<String, dynamic>? userMap;
  // Map<String, dynamic>? messages;
  String roomId = "";
  String uid = FirebaseAuth.instance.currentUser!.uid;
  List chat = [];
  List messages = [];

  @override
  void initState() {
    super.initState();
    getAvailableChats();
    print(Constants.userNumber);
  }

  void getAvailableChats() async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .get()
        .then((value) {
      setState(() {
        chat = value.docs;

        isLoading = false;
      });
    });

    _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .orderBy('time')
        .get()
        .then((value) {
      setState(() {
        messages = value.docs;
        print(messages);
        isLoading = false;
      });
    });
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('chats')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: size.height,
                    width: size.width,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return (snapshot.data!.docs.isNotEmpty)
                      ? ListView.builder(
                       padding: EdgeInsets.only(top:5),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: GestureDetector(
                                onTap: () async {
                                  String roomId = chatRoomId(
                                      _auth.currentUser!.uid,
                                      snapshot.data!.docs[index]
                                          .get('receiverUid'));
                                  await _firestore
                                      .collection('users')
                                      .where("name",
                                          isEqualTo: snapshot.data!.docs[index]
                                              .get('name'))
                                      .get()
                                      .then((value) {
                                    userMap = value.docs[0].data();
                                    if (userMap!.isNotEmpty) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ChatRoom(
                                              chatRoomId: roomId,
                                              userMap: userMap!,
                                              profilePic: snapshot
                                                  .data!.docs[index]
                                                  .get('profilePic'),
                                              receiverName: snapshot
                                                  .data!.docs[index]
                                                  .get('name'),
                                              receiverUid: snapshot
                                                  .data!.docs[index]
                                                  .get('receiverUid')),
                                        ),
                                      );
                                    }
                                    isLoading = false;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white70,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.shade300,
                                            blurRadius: 1.0,
                                            offset: Offset(0.0, 1.0))
                                      ]),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.all(5),
                                        leading: (snapshot.data!.docs[index]
                                                    .get("profilePic") ==
                                                "NotSet")
                                            ? Container(
                                                height: 50,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Colors
                                                              .cyan.shade900,
                                                          blurRadius: 3.0,
                                                          offset:
                                                              Offset(0.0, 0.0))
                                                    ]),
                                                child: Icon(Icons.account_box,
                                                    color:
                                                        Colors.cyan.shade900),
                                              )
                                            : CircleAvatar(
                                                backgroundColor:
                                                    Colors.cyan[800],
                                                radius: 27,
                                                child: CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: Colors.blueGrey[50],
                                                  backgroundImage: NetworkImage(
                                                      '${snapshot.data!.docs[index].get("profilePic")}'),
                                                ),
                                              ),
                                        title: Text(
                                          snapshot.data!.docs[index]
                                              .get('name'),
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0),
                                              child: Icon(
                                                Icons.check,
                                                size: 15,
                                              ),
                                            ),
                                            Text(
                                                snapshot.data!.docs[index]
                                                    .get('lastMessage'),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                )),
                                          ],
                                        ),
                                        trailing: Icon(Icons.chat,
                                            color: Colors.cyan.shade900),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          })
                      : Container(
                        padding: EdgeInsets.all(50),
                          color: Colors.white,
                          child: Center(
                            child: Column(
                              children: [
                                Image.asset('assets/images/chati.png',
                                width: 100,
                                height:100,),
                                SizedBox(height: 20,),
                                Text("You Don't have any chats.",style: TextStyle(fontWeight: FontWeight.bold),),
                                SizedBox(height: 20,),
                                Text("Find peoples in USERS section and enjoy chatting.",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                        );
                }
              }),

      // working
      // ListView.builder(
      //     itemCount: chat.length,
      //     itemBuilder: (context, index) {
      //       return Padding(
      //         padding: const EdgeInsets.all(6.0),
      //         child: Container(

      //           decoration: BoxDecoration(
      //               borderRadius: BorderRadius.circular(10),
      //               color: Colors.cyan[50],
      //               boxShadow: [
      //                 BoxShadow(
      //                     color: Colors.cyan.shade500,
      //                     blurRadius: 1.0,
      //                     offset: Offset(0.0, 1.0))
      //               ]),
      //           child: ListTile(
      //             onTap: () async {

      //               String roomId = chatRoomId(
      //                   _auth.currentUser!.uid, chat[index]['receiverUid']);
      //               await _firestore
      //                   .collection('users')
      //                   .where("name", isEqualTo: chat[index].get('name'))
      //                   .get()
      //                   .then((value) {
      //                 userMap = value.docs[0].data();

      //                 if (userMap!.isNotEmpty) {
      //                   Navigator.of(context).push(
      //                     MaterialPageRoute(
      //                       builder: (_) => ChatRoom(
      //                         chatRoomId: roomId,
      //                         userMap: userMap!,
      //                         receiverName: chat[index].get('name'),
      //                         receiverUid: chat[index].get('receiverUid'),
      //                       ),
      //                     ),
      //                   );
      //                 }

      //                 isLoading = false;
      //               });
      //             },
      //             leading: Icon(Icons.group, color: Colors.black),
      //             title: Text(
      //               chat[index]['name'],
      //               style: TextStyle(
      //                 color: Colors.black,
      //                 fontSize: 17,
      //                 fontWeight: FontWeight.w500,
      //               ),
      //             ),
      //             subtitle: Text(
      //               chat[index].get('lastMessage'),
      //               style: TextStyle(
      //                 color: Colors.black,
      //                 fontSize: 17,
      //                 fontWeight: FontWeight.w500,
      //               ),
      //             ),
      //             trailing: Icon(Icons.chat, color: Colors.black),
      //           ),
      //         ),
      //       );
      //     },
      //   ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.message),
          backgroundColor: Colors.cyan[800],
          onPressed: () {
            setState(() async {
              PermissionStatus permission = await Permission.contacts.status;
              if (permission == PermissionStatus.denied) {
                final Map<Permission, PermissionStatus> permissionStatus =
                    await [Permission.contacts].request();
              }

              if (permission == PermissionStatus.granted) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ContactPage()));
              }
            });
          }),
    );
  }
}
