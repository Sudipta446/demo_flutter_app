import 'package:demo_flutter_project/bottom_menu%20_pages/heart_rate_page.dart';
import 'package:demo_flutter_project/login.dart';
import 'package:demo_flutter_project/model/data_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/src/client.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'helpers/http_request.dart';
import 'package:health/health.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final List<Widget> _items = [
    const HeartRatePage()
  ];

  Widget? currentScreen;

  final pageStorageBucket = PageStorageBucket();

  String photoUrl = "https://srcwap.com/wp-content/uploads/2022/08/profile-pic-blank-facebook-profile.jpg";
  String name = "";
  String email = "";
  String uid = "";

  int index = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    currentScreen = _items[0];
    getData();
  }

  getData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString("name")!;
      email = prefs.getString("email")!;
      photoUrl = prefs.getString("photoUrl")!;
      uid = prefs.getString("uid")!;
    });
  }

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
        //backgroundColor: Colors.white,
        bottomNavigationBar:
        BottomAppBar(
          elevation: 3,
          color: Colors.white,
          child: SizedBox(
            height: 74,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: (){
                    setState(() {
                      index = 0;
                      currentScreen = _items[index];
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: index == 0
                              ? Color(0xFFf4f3f3)
                              : Colors.transparent,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                              topRight: Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 25,
                            height: 25,
                            child: Image.asset('images/heart.png'),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        "Heart Rate",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF151515)),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    signOut();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: index == 1
                              ? Color(0xFFf4f3f3)
                              : Colors.transparent,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                              topRight: Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 25,
                            height: 25,
                            child: Image.asset('images/logout.png'),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        "Sign Out",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF151515)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Welcome",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xFF151515)),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Icon(
                                          FontAwesomeIcons.handsClapping,
                                          color: Color(0xFF151515),
                                          size: 15,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 230,
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color:
                                            Color(0xFF151515).withOpacity(0.5)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            PhysicalModel(
                              color: Colors.black,
                              elevation: 5.0,
                              shape: BoxShape.circle,
                              child: CircleAvatar(
                                  backgroundColor: Color(0xFF302f33),
                                  radius: 23,
                                  child: CircleAvatar(
                                      backgroundColor: Color(0xFF302f33),
                                      radius: 20.5,
                                      backgroundImage: NetworkImage(photoUrl),)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 75),
                  child: PageStorage(
                      bucket: pageStorageBucket,
                      child: Center(child: currentScreen)))
            ],
          ),
        ),
      ),
    );
  }

  signOut() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Sign out!'),
        content: Text('Do you want to sign out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () async {
              await googleSignIn.disconnect();
              await _auth.signOut();

              final prefs = await SharedPreferences.getInstance();

              _auth.authStateChanges().listen((User? user) {
                if (user == null) {
                  // User is logged out
                  print('Logout successful');

                  prefs.setString("email", "");
                  prefs.setString("name", "");
                  prefs.setString("photoUrl", "");
                  prefs.setString("uid", "");

                  Get.offAll(() => const Login());

                } else {
                  // User is logged in
                  print('User is still logged in');
                }
              });

            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

}
