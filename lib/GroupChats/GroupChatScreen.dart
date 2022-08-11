import 'package:chat_app/Screens/setting_profile.dart';
import 'package:chat_app/GroupChats/CreateGroup/AddMembers.dart';
import 'package:chat_app/GroupChats/GroupChatRoom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupChatHomeScreen extends StatefulWidget {
  const GroupChatHomeScreen({Key? key}) : super(key: key);

  @override
  _GroupChatHomeScreenState createState() => _GroupChatHomeScreenState();
}

class _GroupChatHomeScreenState extends State<GroupChatHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;

  List groupList = [];

  @override
  void initState() {
    super.initState();
    getAvailableGroups();
    print(Constants.userNumber);
  }

  void getAvailableGroups() async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('groups')
        .get()
        .then((value) {
      setState(() {
        groupList = value.docs;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Groups"),
      // ),
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
                  .doc(_auth.currentUser!.uid)
                  .collection('groups')
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
                  return 
                  (snapshot.data!.docs.isNotEmpty)?
                  ListView.builder(
                     padding: EdgeInsets.only(top:5),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => GroupChatRoom(
                                    groupName: groupList[index]['name'],
                                    groupChatId: groupList[index]['id'],
                                  ),
                                ),
                              );
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
                                    leading: Container(
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
                                    ),
                                    // title: Text(snapshot.data![index].data["name"]),
                                    title: Text(
                                      snapshot.data!.docs[index].get('name'),
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0,),
                                          child: Icon(
                                            Icons.check,
                                            size: 15,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                                                                       Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Text(
                                                  snapshot.data!.docs[index]
                                                      .get('messages'),
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  )),
                                            ),
                                          ],
                                        ),
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
                      }): Container(
                        padding: EdgeInsets.all(50),
                          color: Colors.white,
                          child: Center(
                            child: Column(
                              children: [
                                Image.asset('assets/images/chati.png',
                                width: 100,
                                height:100,), SizedBox(height: 20,),
                                Text("You Don't have any Groups.",style: TextStyle(fontWeight: FontWeight.bold),),
                                SizedBox(height: 20,),
                                Text("Create group by clicking on the below icon and enjoy chatting.",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                        );
                }
              }),
      // : Padding(
      //   padding: const EdgeInsets.all(6.0),
      //   child:

      // ListView.builder(
      //       itemCount: groupList.length,
      //       itemBuilder: (context, index) {
      //         return Container(
      //            decoration: BoxDecoration(
      //                         borderRadius: BorderRadius.circular(10),
      //                         color: Colors.white70,
      //                         boxShadow: [
      //                           BoxShadow(
      //                               color: Colors.grey.shade400,
      //                               blurRadius: 1.0,
      //                               offset: Offset(0.0, 1.0))
      //                         ]),
      //           child: Container(
      //             color: Colors.white70,
      //             child: ListTile(
      //                contentPadding: EdgeInsets.all(5),
      // onTap: () => Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (_) => GroupChatRoom(
      //       groupName: groupList[index]['name'],
      //       groupChatId: groupList[index]['id'],
      //     ),
      //   ),
      // ),
      //               leading: Container(
      //                  height: 50,width: 50,
      //                           decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(30),
      //                           boxShadow: [
      //                         BoxShadow(
      //                             color: Colors.cyan.shade900,
      //                             blurRadius: 3.0,
      //                             offset: Offset(0.0, 0.0))
      //                       ]
      //                           ),
      //                 child: Icon(Icons.group, color: Colors.black)),
      //               title: Text(
      //                 groupList[index]['name'],
      //                 style: TextStyle(
      //                   color: Colors.black,
      //                   fontSize: 17,
      //                   fontWeight: FontWeight.w500,
      //                 ),
      //               ),
      //               subtitle: Text(groupList[index]['messages'] ),
      //               trailing: Icon(Icons.chat, color: Colors.cyan[900]),
      //             ),
      //           ),
      //         );
      //       },
      //     ),
      // ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyan[800],
        child: Icon(Icons.create),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddMembersInGroup(),
          ),
        ),
        tooltip: "Create Group",
      ),
    );
  }
}
