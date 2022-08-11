import 'package:flutter/material.dart';

Widget headerName(BuildContext context) {
  return

      // Text("CHATAPP",style:TextStyle(color: Colors.blueAccent)),
      Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text("CHAT", style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,)),
      Text("APP", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,)),
    ],
  );
  // elevation: 0.0,
  // centerTitle: true,
  // backgroundColor: Colors.white,
}
