import 'package:chat_app/Screens/ChatRoom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final userRef = FirebaseFirestore.instance.collection('chatroom');
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class ChatHomeScreen extends StatefulWidget {
  // ChatHomeScreen({Key? key}) : super(key: key);

  @override
  _ChatHomeScreenState createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  Map<String, dynamic>? userMap;
  bool isLoading = true;
  // List groupList = [];
  String username = '';
  @override
  void initState() {
    setState(() {
      // getUsers();
    });

    super.initState();
  }

  // Future getUsersList() async {
  //   var firestore = FirebaseFirestore.instance;
  //   QuerySnapshot qn = await firestore.collection("users").get();
  //   print(qn.docs);
  //   return qn.docs;
  // }

  getUsers() {
// working final
    // userRef.get().then((QuerySnapshot snapshot) {
    //   snapshot.docs.forEach((DocumentSnapshot doc) {
    //     // userMap = doc.data() as Map<String, dynamic>?;
    //     userMap = doc.get('name');
    //     // print(userMap!['name']);
    //     print(userMap);
    //     isLoading = false;
    //     setState(() {});
    //   });
    // });

    _firestore
        .collection('users')
        .where("name", isEqualTo: username)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });

      print(userMap);
    });

    // working     get usermap with refrence to uid
    // await userRef.get().then((QuerySnapshot snapshot) {
    //   setState(() {
    //     snapshot.docs.forEach((DocumentSnapshot doc) {
    //       userMap = doc.data() as Map<String, dynamic>?;
    //     });
    //     print(userMap);
    //     // print(userMap!.length);
    //     isLoading = false;
    //   });
    // });
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

    return Container(
        color: Colors.white,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: size.height,
                  width: size.width,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView.builder(
                   padding: EdgeInsets.only(top:5),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: GestureDetector(
                          onTap: () async {
                            if (_auth.currentUser!.uid !=
                                snapshot.data!.docs[index].get('uid')) {
                              String roomId = chatRoomId(_auth.currentUser!.uid,
                                  snapshot.data!.docs[index].get('uid'));
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
                                          profilePic:snapshot
                                              .data!.docs[index]
                                              .get('profilePic'), 
                                          receiverName: snapshot
                                              .data!.docs[index]
                                              .get('name'),
                                          receiverUid: snapshot
                                              .data!.docs[index]
                                              .get('uid')),
                                    ),
                                  );
                                }
                                isLoading = false;
                              });
                            } else {
                              print("you cant send msgb yourself");
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white70 ,
                                boxShadow: [
                                  BoxShadow(
                                      // color: Colors.cyan.shade500,
                                      color: Colors.grey.shade300,
                                      blurRadius: 1.0,
                                      offset: Offset(0.0, 1.0))
                                ]),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.all(5),
                                  // horizontalTitleGap: 0,
                                  // minVerticalPadding: 10,
                                  leading:(snapshot.data!.docs[index].get("profilePic")=="NotSet")? Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.cyan.shade900,
                                                blurRadius: 3.0,
                                                offset: Offset(0.0, 0.0))
                                          ]),
                                      child: Icon(Icons.account_box,
                                          color: Colors.cyan.shade900),
                                    ):
                                        CircleAvatar(
                                          backgroundColor: Colors.cyan[800],
                                          radius: 27,
                                          child: CircleAvatar(
                                           radius: 25,
                                           backgroundColor: Colors.blueGrey[50],
                                           backgroundImage: NetworkImage('${snapshot.data!.docs[index].get("profilePic")}'),
                                                                              
                                           ),
                                        ),
                                    
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          snapshot.data!.docs[index]
                                              .get('name'),
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      (snapshot.data!.docs[index]
                                                  .get('status') ==
                                              "online")
                                          ? Padding(
                                            padding: const EdgeInsets.only(top:15.0),
                                            child: Icon(Icons.circle,
                                                size: 15,
                                                color: Colors.green.shade800),
                                          )
                                          : Padding(
                                            padding: const EdgeInsets.only(top:15.0),
                                            child: Icon(Icons.circle,
                                                size: 15,
                                                color: Colors.white),
                                          ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(left:8.0),
                                    child: Text(
                                        snapshot.data!.docs[index].get('phone')),
                                  ),
                                  trailing: Container(
                                      child: Icon(Icons.chat,
                                          color: Colors.cyan[900])),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              }
            }));
  }
}
