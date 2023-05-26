import 'package:demo_flutter_project/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Color for Android status bar
      statusBarBrightness: Brightness.dark, // Brightness for iOS status bar
      statusBarIconBrightness: Brightness.dark, // Icon brightness for both Android and iOS
    ));
    return WillPopScope(
      onWillPop: ()async{

        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text(
              'Quit!',
              style: TextStyle(
                  fontFamily: 'RobotoCondensed-Regular',
                  fontWeight: FontWeight.bold),
            ),
            content: const Text(
                'Do you want to quit the app?',
                style: TextStyle(
                  fontFamily: 'Poppins-Regular',
                )),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Get.back();
                },
                child: const Text('No',
                    style: TextStyle(
                        fontFamily: 'RobotoCondensed-Regular',
                        fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () async {
                  SystemNavigator.pop();
                },
                child: const Text('Yes',
                    style: TextStyle(
                        fontFamily: 'RobotoCondensed-Regular',
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );

        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Container(
              height: 200,
              margin: EdgeInsets.only(left: 20, right: 20),
              padding: EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(
                color:Color(0xFFf5f5f5),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    topRight: Radius.circular(30)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      children: [
                        Text(
                          "Let's sign you in",
                          style: TextStyle(
                            color: Color(0xFF151515),
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      signInWithGoogle();
                    },
                    child: Container(
                      height: 57,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color:Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                            topRight: Radius.circular(10)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 10,),
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: Image.asset("images/google.png"),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            "Continue with Google",
                            style: TextStyle(
                                color: Color(0xFF151515).withOpacity(0.5),
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      // Getting users credential
      UserCredential result = await auth.signInWithCredential(authCredential);
      User? user = result.user;

      final prefs = await SharedPreferences.getInstance();

      String? email = result.user?.email;
      String? name  = result.user?.displayName;
      String? photoUrl = result.user?.photoURL;
      String? uid = result.user?.uid;

      prefs.setString("email", email ?? "");
      prefs.setString("name", name ?? "");
      prefs.setString("photoUrl", photoUrl ?? "");
      prefs.setString("uid", uid ?? "");

      print(result.user?.email);
      print(result.user?.displayName);
      print(result.user?.photoURL);
      print(result.user?.uid);

      Get.to(() => Home());

    }
  }

}
