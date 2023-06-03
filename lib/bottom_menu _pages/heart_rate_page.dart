import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import '../helpers/http_request.dart';
import '../model/data_model.dart';

class HeartRatePage extends StatefulWidget {
  const HeartRatePage({Key? key}) : super(key: key);

  @override
  State<HeartRatePage> createState() => _HeartRatePageState();
}

class _HeartRatePageState extends State<HeartRatePage> {

  String stepsCount = "0";
  String heart = "0";

  String date = "";

  bool isDataLoaded = false;

  late double lat, lng;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getCurrentLocationLatLng();
    var now = DateTime.now().toLocal();
    var formatter = DateFormat('dd MMM yyyy');
    var formattedDate = formatter.format(now);

    setState(() {
      date = formattedDate;
    });

    getCurrentLocationLatLng();
    getActivityRecognitionPermission();

    Timer.periodic(const Duration(minutes: 1), (timer) {
      uploadLocationToServer(lat, lng);
    });

  }

  getActivityRecognitionPermission() async {

    if(await Permission.activityRecognition.isGranted){
      getPermission();
    }else{
      PermissionStatus status = await Permission.activityRecognition.request();
      if (status.isGranted) {
        // Permission granted, you can now access step count data
        getPermission();
      } else {
        // Permission denied. Handle the situation accordingly.
        Fluttertoast.showToast(
            msg: "Permission not granted",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }

  }

  Future<void> getPermission() async {
    HealthFactory health = HealthFactory();
    List<HealthDataType> types = [
      HealthDataType.HEART_RATE,
      HealthDataType.STEPS
      // Add other data types you need
    ];
    bool isAuthorized = await health.requestAuthorization(types);
    if (isAuthorized) {
      // Permission granted
      print("permission granted");
      List<HealthDataPoint> todayData = await getTodayHealthData();
      if (todayData.isNotEmpty) {
        // Process the retrieved data
        for (HealthDataPoint dataPoint in todayData) {
          if (dataPoint.type == HealthDataType.STEPS) {
            String steps = dataPoint.value.toString();
            DateTime date = dataPoint.dateFrom;
            // Process steps data
            setState(() {
              stepsCount = steps;
              isDataLoaded = true;
            });
            print('Steps: $steps, Date: $date');
          } else if (dataPoint.type == HealthDataType.HEART_RATE) {
            String heartRate = dataPoint.value.toString();
            DateTime date = dataPoint.dateFrom;
            // Process heart rate data
            setState(() {
              heart = heartRate;
              isDataLoaded = true;
            });
            print('Heart Rate: $heartRate, Date: $date');
          }
          // Add processing logic for other data types if needed
        }
      } else {
        setState(() {
          stepsCount = "0";
          heart = "0";
          isDataLoaded = true;
        });
        print('No health data available for today');
        Fluttertoast.showToast(
            msg: "No health data available for today",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    } else {
      // Permission denied
      print("permission denied");
      Fluttertoast.showToast(
          msg: "Permission denied",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  Future<List<HealthDataPoint>> getTodayHealthData() async {
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, now.day);
    DateTime endDate = now;

    HealthFactory health = HealthFactory();
    List<HealthDataType> types = [
      HealthDataType.HEART_RATE,
      HealthDataType.STEPS,
      // Add other data types you need
    ];

    List<HealthDataPoint> healthDataPoints = await health.getHealthDataFromTypes(startDate, endDate, types);

    return healthDataPoints;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFf4f3f3),
      child: isDataLoaded ? Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 15, top: 15, right: 7.5),
                  height: 170,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        topRight: Radius.circular(20)),

                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                          radius: 23,
                          backgroundColor: Color(0xFFf4f3f3),
                          child: SizedBox(
                              width: 27,
                              height: 27,
                              child: Image.asset("images/heart.png")
                          )
                      ),
                      SizedBox(height: 5,),
                      Text(
                        "Heart Rate",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF151515)),
                      ),
                      Text(
                        date,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Color(0xFF151515).withOpacity(0.5)),
                      ),
                      SizedBox(height: 8,),
                      Text(
                        heart,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF151515)),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7.5, top: 15, right: 15),
                  height: 170,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        topRight: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 23,
                          backgroundColor: Color(0xFFf4f3f3),
                          child: SizedBox(
                            width: 27,
                              height: 27,
                              child: Image.asset("images/footprint.png")
                          )
                      ),
                      SizedBox(height: 5,),
                      Text(
                        "Steps Count",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF151515)),
                      ),
                      Text(
                        date,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Color(0xFF151515).withOpacity(0.5)),
                      ),
                      SizedBox(height: 8,),
                      Text(
                        stepsCount,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF151515)),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ) : Center(child: SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: const Color(0xFF3d4359),))),
    );
  }

  Future<Position> getUserLocation() async {
    return await Geolocator.getCurrentPosition();
  }

  Future<void> getCurrentLocationLatLng() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text(
              'Location Permission Turned Off!',
              style: TextStyle(
                  fontFamily: 'RobotoCondensed-Regular',
                  fontWeight: FontWeight.bold),
            ),
            content: const Text(
                'Please give location permission for accurate location',
                style: TextStyle(
                  fontFamily: 'Poppins-Regular',
                )),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  await Geolocator.openAppSettings();
                },
                child: const Text('Ok',
                    style: TextStyle(
                        fontFamily: 'RobotoCondensed-Regular',
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    }

    Geolocator.getPositionStream().listen((value) async {
     setState(() {
       lat = value.latitude;
       lng = value.longitude;
     });
    });

  }

  uploadLocationToServer(double lat, double lng) async {
    var dataModel = DataModel(lat: lat.toString(), longt: lng.toString(), userId: 333444555);
    var response = await sendPostData("https://wsfttestapi.withstandfitness.com/DatatSync/syncLocation", dataModel).catchError((err){
      print(err.toString());
    });

    print(response);

    if(response == "true"){
      Fluttertoast.showToast(
          msg: "Latitude and Longitude updated to server",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );

    }else{
      Fluttertoast.showToast(
          msg: "Server error!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  showCustomDialog(BuildContext dialogContext) {
    try {
      showDialog(
          context: dialogContext,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                //this right here
                child: SizedBox(
                  height: 80,
                  child: Center(
                    child: Row(
                      children: [
                        Lottie.asset('assets/image_loading.json'),
                        const Text(
                          'Getting user location...',
                          style: TextStyle(
                              fontSize: 15, fontFamily: 'JosefinSans-Regular'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
    } catch (e) {
      print(e.toString());
    }
  }

}
