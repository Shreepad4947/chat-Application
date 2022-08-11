import 'package:chat_app/Authenticate/Autheticate.dart';
import 'package:chat_app/Authenticate/LoginScree.dart';
import 'package:chat_app/Screens/HomeScreen.dart';
import 'package:chat_app/Screens/setting_profile.dart';
import 'package:chat_app/Screens/tabs_basic.dart';
// import 'package:chatapp/Data/constants.dart';
// import 'package:chatapp/Data/sharedPreferance.dart';
// import 'package:chatapp/Screens/home.dart';
// import 'package:chatapp/Screens/profileAfterInstallation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:shared_preferences/shared_preferences.dart';

enum LoginScreen { ShowEnterMobileNo, ShowEnterOtp }

class SignInNum extends StatefulWidget {
  @override
  _SignInNumState createState() => _SignInNumState();
}

class _SignInNumState extends State<SignInNum> {
  bool isloading = false;
  bool verificationCompleted = false;
  bool usersignedIn = false;
  String userNumber = "";

  LoginScreen currentState = LoginScreen.ShowEnterMobileNo;
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationID = "";

  verifyPhoneNum() async {
    setState(() {
      isloading = true;
    });

    await _auth.verifyPhoneNumber(
        phoneNumber: "+91${mobileNoController.text}",
        verificationCompleted: (AuthCredential phoneAuthCredential) async {
          setState(() {
            isloading = false;
            verificationCompleted = true;
          });
          print(phoneAuthCredential.providerId);
        },
        verificationFailed: (verificationFailed) {
          setState(() {
            isloading = false;
          });
          print(verificationFailed);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("OTP limit Exeeded"),
          ));
        },
        codeSent: (verificationID, resendingToken) async {
          setState(() {
            isloading = false;
            currentState = LoginScreen.ShowEnterOtp;
            this.verificationID = verificationID;
          });
        },
        codeAutoRetrievalTimeout: (verificationID) async {});
  }

  verifyOtp() {
    setState(() {
      isloading = true;
    });
    AuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
      verificationId: verificationID,
      smsCode: otpController.text,
    );
    signInwithPhoneAuthCred(phoneAuthCredential, usernameController.text);
  }

  Future<User?> signInwithPhoneAuthCred(
      AuthCredential phoneauthCredential, String usernameController) async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      Map<String, String> userInfoMap = {
        "phone": mobileNoController.text,
      };

      UserCredential userCrendetial =
          await _auth.signInWithCredential(phoneauthCredential);

      userCrendetial.user!.updateDisplayName(usernameController);

      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        "name": usernameController,
        "profilePic": "NotSet",
        "status": "Unavalible",
        "About": "Hey there! I am Using ChatApp",
        "phone": mobileNoController.text,
        "uid": _auth.currentUser!.uid,
      });

// addd user to firebase phonenumber
      // FirebaseFirestore.instance
      //     .collection("users")
      //     .add(userInfoMap)
      //     .then((value) => null);

      if (userCrendetial.user != null) {
        setState(() {
          isloading = false;
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('phone', '');
        Constants.userNumber = mobileNoController.text;
        userNumber = mobileNoController.text;
        Navigator.pushReplacement(
            // context, MaterialPageRoute(builder: (context) => Authenticate()));
            context,
            MaterialPageRoute(builder: (context) => TabsBasicRoute()));
        setState(() {
          usersignedIn = true;
        });
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Some Error occured ,Try Again"),
      ));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SignInNum()));
    }
  }

  indicator() {
    return Center(child: CircularProgressIndicator());
  }

  // getUserPhoneNumber() async {
  //   Constants.userNumber = mobileNoController.text;
  // }

  showMobileNowidget(context) {
    return ListView(
        padding: EdgeInsets.all(0.0),
        shrinkWrap: true,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 200,
                  child: Column(
                    children: <Widget>[
                      Container(height: 30),
                      Container(
                        child:
                            Image.asset('assets/images/NumberVerification.png'),
                        width: 220,
                        height: 220,
                      ),
                      Text("Verify Your Number",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      Container(height: 15),
                      Container(
                        width: 220,
                        child: Text(
                          "Please enter your mobile number to receive a verification code. Carrier rates may apply.",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(height: 15),
                      Column(
                        children: [
                          Container(
                            child: TextFormField(
                              keyboardType: TextInputType.name,
                              controller: usernameController,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: "Enter Your Name",
                                hintStyle: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                          Container(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: mobileNoController,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: "Enter Number",
                                hintStyle: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(height: 15),
                      Container(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isloading = true;
                              verifyPhoneNum();
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.cyan[300],
                            ),
                            child: Text(
                              "SEND OTP",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 200,
                        child: FlatButton(
                          child: Text(
                            "NO, OTHER TIME",
                            style: TextStyle(color: Colors.grey),
                          ),
                          color: Colors.transparent,
                          onPressed: () {},
                        ),
                      )
                    ],
                    mainAxisSize: MainAxisSize.min,
                  ),
                ),
              )
            ],
          ),
        ]);
  }

  showOTPWidget(context) {
    return ListView(
        padding: EdgeInsets.all(0.0),
        shrinkWrap: true,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 200,
                  child: Column(
                    children: <Widget>[
                      Container(height: 30),
                      Container(
                        child: Image.asset(('assets/images/otpimage.png')),
                        width: 200,
                        height: 200,
                      ),
                      Row(
                        children: [
                          Text("Verify  ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          Text(mobileNoController.text,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ],
                      ),
                      Container(height: 15),
                      Container(
                        width: 220,
                        child: Text(
                          "OTP has been sent to you on your mobile Number. Please enter it below.",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(height: 15),
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              controller: otpController,
                            ),
                          ),
                        ],
                      ),
                      Container(height: 30),
                      Container(
                          width: double.infinity,
                          child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(18.0)),
                              child: Text(
                                "VERIFY",
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Colors.cyan[300],
                              onPressed: () {
                                verifyOtp();
                              }))
                    ],
                    mainAxisSize: MainAxisSize.min,
                  ),
                ),
              )
            ],
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("CHAT", style: TextStyle(color: Colors.black)),
              Text("APP", style: TextStyle(color: Colors.cyan[800])),
            ],
          ),
          elevation: 0.0,
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Container(
            child: isloading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : currentState == LoginScreen.ShowEnterMobileNo
                    ? showMobileNowidget(context)
                    : showOTPWidget(context)));
  }
}
