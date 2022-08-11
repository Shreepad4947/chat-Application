import 'package:chat_app/Authenticate/SignInNum.dart';
import 'package:chat_app/GroupChats/GroupChatScreen2.dart';
import 'package:chat_app/Screens/HomeScreen.dart';
import 'package:chat_app/Screens/chatlistScreen.dart';
import 'package:chat_app/Screens/chatlistScreen2.dart';
import 'package:chat_app/Screens/setting_profile.dart';
import 'package:chat_app/Widget/HeaderName.dart';
import 'package:chat_app/Widget/PopupMenu.dart';
import 'package:chat_app/GroupChats/GroupChatScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:share/share.dart';
import 'package:nb_utils/nb_utils.dart';

class TabsBasicRoute extends StatefulWidget {
  TabsBasicRoute();

  @override
  TabsBasicRouteState createState() => new TabsBasicRouteState();
}

class TabsBasicRouteState extends State<TabsBasicRoute>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool popupmenu = false;

  @override
  void initState() {
    _tabController = TabController(length:3, vsync: this);
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScroller) {
          return <Widget>[
            SliverAppBar(
              title: Container(
                alignment:Alignment.centerLeft,child: headerName(context)),
              pinned: true,
              floating: true,
              backgroundColor: Colors.cyan[800],
              forceElevated: innerBoxIsScroller,
              leading: IconButton(
                  icon: const Icon(Icons.chat),
                  onPressed: () {
                    // Navigator.pop(context);
                  }),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                   Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                ), // overflow menu
                PopupMenuButton<MenuItem>(
                  color: Colors.grey[50],
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.white, width: 3),
                  ),
                  onSelected: (item) => onSelected(context, item),
                  itemBuilder: (context) => [
                    ...Menuitems.itemFirst.map(buildItem).toList(),
                  ],
                )
              ],
              bottom: TabBar(
                indicatorColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 5,
                tabs: [
                  Tab(icon: Text("CHATS",style: TextStyle(fontWeight: FontWeight.bold),),),
                  // Tab(icon: Text("ChatList")),
                  Tab(icon: Text("USERS",style: TextStyle(fontWeight: FontWeight.bold),)),
                  Tab(icon: Text("GROUPS",style: TextStyle(fontWeight: FontWeight.bold),)),
                ],
                controller: _tabController,
              ),
            )
          ];
        },
        body: TabBarView(
          children: <Widget>[
            // HomeScreen(),
            ChatHomeScreen2(),
            ChatHomeScreen(),
            GroupChatHomeScreen(),
            // GroupChatHomeScreen2(),
          ],
          controller: _tabController,
        ),
      ),
    );
  }
}

// popupMenu Items
PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem<MenuItem>(
    value: item,
    child: Row(
      children: [
        Icon(item.icon, color: Colors.black, size: 25),
        const SizedBox(width: 12),
        Text(item.text,style: TextStyle(fontWeight: FontWeight.w500),),
      ],
    ));

void onSelected(BuildContext context, MenuItem item) {
  switch (item) {
    case Menuitems.itemNewChat:
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
      break;

    case Menuitems.itemsetting:
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => SettingProfileRoute()));
      break;

    case Menuitems.itemShare:
      PackageInfo.fromPlatform().then((value) {
        String package = '';
        if (isAndroid) package = value.packageName;

        Share.share('Share ChatApp $package');
      });
      break;

    case Menuitems.itemSignOut:
      showDialog(
        context: (context),
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Are You Sure?"),
            content: new Text("Clicked Yes to SignOut"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("NO"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text("YES"),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignInNum()),
                  );
                },
              ),
            ],
          );
        },
      );

      break;
  }
}
