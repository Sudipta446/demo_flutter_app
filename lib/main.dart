import 'package:animate_do/animate_do.dart';
import 'package:demo_flutter_project/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    changeNavigationColor(Colors.white);
    checkLogin();
  }

  checkLogin(){
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (FirebaseAuth.instance.currentUser != null) {
        // signed in
        Get.to(() => const Home());
      } else {
        // signed out
        Get.to(() => const Login());
      }
    });
  }

  changeNavigationColor(Color color) async {
    try {
      await FlutterStatusbarcolor.setNavigationBarColor(color, animate: true);
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GetMaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 50, right: 50),
            child: ZoomIn(child: SizedBox(child: Image(image: AssetImage('images/app_icon.png')), width: 200, height: 200,), duration: Duration(milliseconds: 1000), animate: true,),
          ),
        ),
      ),
    );
  }
}
