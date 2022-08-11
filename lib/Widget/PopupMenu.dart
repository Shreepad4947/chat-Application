
import 'package:flutter/material.dart';
class MenuItem {
  final String text;
  final IconData icon;

  const MenuItem({
    required this.text,
    required this.icon,
  });
}
class Menuitems {
  static const List<MenuItem> itemFirst = [
   itemNewChat,
    itemsetting,
     itemShare,
     itemSignOut];

  static const itemNewChat = MenuItem(
    text: "new chat",
    icon: Icons.chat,
  );
  static const itemsetting = MenuItem(
    text: "settings",
    icon: Icons.settings,
  );

  static const itemShare = MenuItem(
    text: "share",
    icon: Icons.share,
  );

  static const itemSignOut = MenuItem(
    text: "signout",
    icon: Icons.logout,
  );
}


