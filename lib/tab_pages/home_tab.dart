import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicab_drivers/global/global.dart';
import 'package:medicab_drivers/pushNotification/push_notification_system.dart';

import '../Assistants/assistant_methods.dart';
import '../Assistants/black_theme_google_map.dart';
class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer<GoogleMapController>();

  GoogleMapController?  NewGoogleMapcontroller;
  static final CameraPosition _kGooglePlex = const CameraPosition(target: LatLng(37.42796133580664, -122.085749655962),
      zoom: 14.4746);
  var geoLocator=Geolocator();
  LocationPermission? _locationPermission;

  String statusText="Now offline";
  Color buttonColor =Colors.grey;
  bool isDriveActive = false;

  checkIfLocationPermissionsAllowed() async{
    _locationPermission =await Geolocator.requestPermission();
    if(_locationPermission==LocationPermission.denied){
      _locationPermission=await Geolocator.requestPermission();
    }
  }
  locateDriverPosition () async {
    Position cposition=await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition=cposition;

    LatLng latLngPosition=LatLng(driverCurrentPosition!.latitude,driverCurrentPosition!.longitude);
    CameraPosition cameraPosition=CameraPosition(target: latLngPosition,zoom: 15);

    NewGoogleMapcontroller!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods.searchAddressforGeographicCoordinates(driverCurrentPosition!, context) ;
    print("This is our Address =$humanReadableAddress");
    AssistantMethods.readDriverRatings(context);

  }
  readCurrentDriverInformation() async{
    currentUser=fAuth.currentUser;
    FirebaseDatabase.instance.ref()
    .child("drivers")
    .child(currentUser!.uid)
    .once().then((snap) {
      if(snap.snapshot.value != null){
        onlineDriverData!.id =(snap.snapshot.value as Map)["id"];
        onlineDriverData!.name =(snap.snapshot.value as Map)["name"];
        onlineDriverData!.phone =(snap.snapshot.value as Map)["phone"];
        onlineDriverData!.email =(snap.snapshot.value as Map)["email"];
        onlineDriverData!.ratings=(snap.snapshot.value as Map)["ratings"];
        onlineDriverData!.Ambulance_Number =(snap.snapshot.value as Map)["Ambulance_Details"]["Ambulance_Model"];
        onlineDriverData!.Ambulance_Model =(snap.snapshot.value as Map)["Ambulance_Details"]["Ambulance_Number"];
        onlineDriverData!.Ambulance_type =(snap.snapshot.value as Map)["Ambulance_Details"]["type"];


       driverVehicleType = (snap.snapshot.value as Map)["Ambulance_Details"]["type"];


      }
    });
    AssistantMethods.readDriverEarnings(context);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLocationPermissionsAllowed();
    readCurrentDriverInformation();

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
  }
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Stack(
      children: [
        GoogleMap(
          padding: const EdgeInsets.only(top: 40),
          mapType:MapType.normal,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated:
    (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            NewGoogleMapcontroller = controller;
            if(darkTheme==true){
              setState(() {
                blackThemeGoogleMap(NewGoogleMapcontroller);
              });
            }
            locateDriverPosition();
          },
        ),
        //ui for status of driver
        statusText!= "Now Online"?
            Container(
    height: MediaQuery.of(context).size.height,
    width: double.infinity,
    color: Colors.black87,

    ):Container(),
        //button for driver status
       Positioned(
         top: statusText!="Now Online"? MediaQuery.of(context).size.height * 0.45:40,
         left: 0,
         right: 0,
         child: Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             ElevatedButton(onPressed: (){
    if(isDriveActive !=true){
    driverisOnlineNow();
    updateDriverLocationAtRealTime();
    setState(() {
    statusText="Now Online";
    isDriveActive=true;
    buttonColor=Colors.transparent;
    });
    }
    else{
    driverisOfflineNow();
    setState(() {
    statusText="Now Offline";
    isDriveActive=false;
    buttonColor=Colors.grey;
    });
    Fluttertoast.showToast(msg: "you are offline now");
    }
    },
               style:ElevatedButton.styleFrom(
    primary: buttonColor,
    padding: const EdgeInsets.symmetric(horizontal: 18),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(26)
    )
    ),
              child:statusText!="Now Online"?Text(statusText,
           style: const TextStyle(
             fontSize: 16,
             fontWeight: FontWeight.bold,
             color: Colors.white,
           ),
             ): const Icon(
                Icons.phonelink_ring,
                color: Colors.white,
                size: 26,
              )
             )
           ],
         ),

       )      ],
    );
  }
  driverisOnlineNow() async{
    Position Pos=await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    driverCurrentPosition=Pos;

    Geofire.initialize("activeDrivers");
    Geofire.setLocation(currentUser!.uid, driverCurrentPosition!.latitude,driverCurrentPosition!.longitude);
    DatabaseReference ref=FirebaseDatabase.instance.ref().child("drivers").child(currentUser!.uid).child("newRideStatus");
    ref.set("Idle");
    ref.onValue.listen((event) { });

  }
  updateDriverLocationAtRealTime(){
    streamSubscriptionPosition=Geolocator.getPositionStream().listen((Position position) {
      if(isDriveActive == true){
        Geofire.setLocation(currentUser!.uid, driverCurrentPosition!.latitude,driverCurrentPosition!.longitude);
      }
      LatLng latLng=LatLng(driverCurrentPosition!.latitude,driverCurrentPosition!.longitude);
      NewGoogleMapcontroller!.animateCamera(CameraUpdate.newLatLng(latLng));

    });
  }
  driverisOfflineNow() {
    Geofire.removeLocation(currentUser!.uid);
    DatabaseReference? ref=FirebaseDatabase.instance.ref().child("drivers").child(currentUser!.uid).child("newRideStatus");

    ref.onDisconnect();
    ref.remove();
    ref = null;

    Future.delayed(const Duration(milliseconds: 2000),(){
      SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    });
  }

}
