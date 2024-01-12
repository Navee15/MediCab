import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicab_drivers/Assistants/assistant_methods.dart';
import 'package:medicab_drivers/Assistants/black_theme_google_map.dart';
import 'package:medicab_drivers/global/global.dart';
import 'package:medicab_drivers/models/user_ride_request_information.dart';
import 'package:medicab_drivers/splashScreen/splash_screen.dart';
import 'package:medicab_drivers/widgets/progress_dialog.dart';

import '../widgets/fare_amount_collection_dialog.dart';

class NewTripScreen extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;

  NewTripScreen({this.userRideRequestDetails,});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {

  GoogleMapController? newTripGoogleMapController;

  final Completer<GoogleMapController>_controllerGoogleMap = Completer();
  static final CameraPosition _kGooglePlex = const CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962),
      zoom: 14.4746
  );
  String? buttonTitle = "Arrived";
  Color? buttonColor =Colors.green;

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polyLinPositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMarker;
  var geoLocator = Geolocator();
  Position? onlineDriverCurrentPosition;
  String rideRequestStatus = "accepted";
  String durationFromOriginToDestination = "";
  bool isRequestDirectionDetails = false;

  //step 1: When driver accepts the user ride request
  // originLatLng = driverCurrent location
  //destinationLatLng = user Pickup location

  //step 2: When driver picks up the user in his car
  //originLatLng = user current location which will be also the current location of the driver at that time
  //destinationLatLng = user's drop-off location

  Future<void> drawPolyLineFromOriginToDestination(LatLng originLatLng,
      LatLng destinationLatLng, bool darkTheme) async {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(message: "Please wait.....",),
    );
    var directionDetailsInfo = await AssistantMethods
        .obtainOriginToDestinationDirection(originLatLng, destinationLatLng);
    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(
        directionDetailsInfo.e_point!);
    polyLinPositionCoordinates.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        polyLinPositionCoordinates.add(
            LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    setOfPolyline.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: darkTheme ? Colors.amber.shade400 : Colors.blue,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLinPositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      setOfPolyline.add(polyline);
    });
    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    }
    else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }
    newTripGoogleMapController!.animateCamera(
        CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });
    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );
    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveAssignedDriverDetailsToUserRideRequest();
  }
  getDriverLocationUpdatesAtRealTime(){

    LatLng oldLatLng =  LatLng(0,0);

    streamSubscriptionDriverLivePosition = Geolocator.getPositionStream().listen((Position position){
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;

      LatLng latLngLiveDriverPosition = LatLng(onlineDriverCurrentPosition!.latitude,onlineDriverCurrentPosition!.longitude);

      Marker animatingMarker = Marker(
        markerId: const MarkerId("AnimatedMarker"),
        position: latLngLiveDriverPosition,
        icon: iconAnimatedMarker!,
        infoWindow: const InfoWindow(title: "This is your position"),
      );

      setState(() {
        CameraPosition cameraPosition = CameraPosition(target: latLngLiveDriverPosition, zoom:18);
        newTripGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setOfMarkers.removeWhere((element) => element.markerId.value == "AnimatedMarker");
        setOfMarkers.add(animatingMarker);
      });

      oldLatLng = latLngLiveDriverPosition;
      updateDurationTimeAtRealTime();

      //updating driver  location at real time in database
      Map driverLatLngDataMap = {
        "latitude": onlineDriverCurrentPosition!.latitude.toString(),
        "longitude": onlineDriverCurrentPosition!.longitude.toString(),
      };
      FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("driverLocation").set(driverLatLngDataMap);
    });
  }

  updateDurationTimeAtRealTime() async{
    if(isRequestDirectionDetails== false) {
      isRequestDirectionDetails = true;

      if(onlineDriverCurrentPosition == null){
        return;
      }

      var originLatLng = LatLng(onlineDriverCurrentPosition!.latitude,onlineDriverCurrentPosition!.longitude);

      var destinationLatLng;

      if(rideRequestStatus == "accepted"){
        destinationLatLng = widget.userRideRequestDetails!.originLatLng;
      }
      else {
        destinationLatLng = widget.userRideRequestDetails!.destinationLatLng;
      }
      var directionInformation = await AssistantMethods.obtainOriginToDestinationDirection(originLatLng,destinationLatLng);

      if(directionInformation != null){
        setState(() {
          durationFromOriginToDestination = directionInformation.duration_text!;
        });
      }
      isRequestDirectionDetails =false;
    }
  }


  createDriverIconMarker() {
    if (iconAnimatedMarker == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "image/416612.png").then((value) {
        iconAnimatedMarker = value;
      });
    }
  }

  saveAssignedDriverDetailsToUserRideRequest() {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!);

    Map driverLocationDataMap = {
      "latitude": driverCurrentPosition!.latitude.toString(),
      "longitude": driverCurrentPosition!.longitude.toString(),
    };
    if (databaseReference.child("driverId") != "waiting") {
      databaseReference.child("driverLocation").set(driverLocationDataMap);

      databaseReference.child("status").set("accepted");
      databaseReference.child("driverId").set(onlineDriverData!.id);
      databaseReference.child("driverName").set(onlineDriverData!.name);
      databaseReference.child("driverPhone").set(onlineDriverData!.phone);
      databaseReference.child("ratings").set(onlineDriverData!.ratings);
      databaseReference.child("Ambulance_Details").set(
          onlineDriverData!.Ambulance_Model.toString() + " " +
              onlineDriverData!.Ambulance_Number.toString());
      saveRideRequestIdToDriverHistory();
    }
    else {
      Fluttertoast.showToast(msg: "This ride is always accepted by another driver. \n reloading the App");
      Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
    }
  }
  saveRideRequestIdToDriverHistory(){
    DatabaseReference tripHistoryRef = FirebaseDatabase.instance.ref().child("drivers").child(fAuth.currentUser!.uid).child("tripHistory");

    tripHistoryRef.child(widget.userRideRequestDetails!.rideRequestId!).set(true);
  }
  endTripNow() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ProgressDialog(message: "Please wait....",)
    );
    //get the tripDirectionDetails = distance travelled
    var currentDriverPositionLatLng = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);
    var tripDirectionDetails = await AssistantMethods.obtainOriginToDestinationDirection(currentDriverPositionLatLng, widget.userRideRequestDetails!.originLatLng!);

    //fare amount
    double totalFareAmount =AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetails);

    FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("fareAmount").set(totalFareAmount.toString());

    FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set("ended");

    Navigator.pop(context);

    //display fare amount in dialog box
    showDialog(
        context: context,
        builder: (BuildContext context) => FareAmountCollectionDialog(
          totalFareAmount: totalFareAmount,
        )
    );

    //save fare amount to driver total earnings
    saveFareAmountToDriverEarnings(totalFareAmount);
  }
  saveFareAmountToDriverEarnings(double totalFareAmount) {
    FirebaseDatabase.instance.ref().child("drivers").child(fAuth.currentUser!.uid).child("earnings").once().then((snap) {
      if (snap.snapshot.value != null) {
        double oldEarnings = double.parse(snap.snapshot.value.toString());
        double driverTotalEarnings = totalFareAmount = oldEarnings;

        FirebaseDatabase.instance.ref().child("drivers").child(fAuth.currentUser!.uid).child("earnings").set(driverTotalEarnings.toString());
      }
      else {
        FirebaseDatabase.instance.ref().child("drivers").child(fAuth.currentUser!.uid).child("earnings").set(totalFareAmount.toString());
      }
    });
  }

      @override
  Widget build(BuildContext context) {
    createDriverIconMarker();

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [

          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition:_kGooglePlex,
            markers:setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated:(GoogleMapController controller){
              _controllerGoogleMap.complete(controller);
              newTripGoogleMapController= controller;
              if(darkTheme==true){
                setState(() {
                  blackThemeGoogleMap(newTripGoogleMapController);
                });
              }


              setState(() {
                mapPadding=350;
              });

              var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude,driverCurrentPosition!.longitude);
              var userPickUpLatLng = widget.userRideRequestDetails!.originLatLng;

              drawPolyLineFromOriginToDestination(driverCurrentLatLng,userPickUpLatLng!,darkTheme);
              getDriverLocationUpdatesAtRealTime();
            },

          ),
        Positioned(
        bottom: 0,
        left:0,
        right: 0,
        child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
        decoration: BoxDecoration(
        color: darkTheme ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
         BoxShadow(
        color: Colors.white,
        blurRadius: 18,
        spreadRadius: 0.5,
        offset: Offset(0.6,0.6),

        )
        ]
        ),
        child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
        children:[
        Text(durationFromOriginToDestination,
        style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: darkTheme ? Colors.amber.shade400 : Colors.black,
        ),
        ),
          const SizedBox(height: 10,),

          Divider(thickness: 1,color: darkTheme ? Colors.amber.shade400 : Colors.grey,),
          const SizedBox(height: 10,),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.userRideRequestDetails!.userName!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: darkTheme ? Colors.amber.shade400 : Colors.black,
                ),
              ),
        IconButton(onPressed: () {},
        icon: Icon(Icons.phone,
        color: darkTheme ? Colors.amber.shade400: Colors.black,
        ),
        )
            ],
        ),
          const SizedBox(height: 10,),

          Row(
            children: [
            Image.asset("images/start.png",
            width: 30,
            height: 30,
          ),
        const SizedBox(width: 10,),

        Expanded(
        child:Container(
        child: Text(widget.userRideRequestDetails!.originAddress!,
        style: TextStyle(
        fontSize: 16,
        color: darkTheme ? Colors.amberAccent : Colors.black,
        ),
        ),
        )
        )
        ],
        ),
          const SizedBox(height: 10,),

          Row(
            children: [
              Image.asset("images/destination.png",
                width: 30,
                height: 30,
              ),

              const SizedBox(width: 10,),

              Expanded(child:
              Container(
                child: Text(
                  widget.userRideRequestDetails!.destinationAddress!,
                  style: TextStyle(
                    fontSize: 16,
                    color: darkTheme ? Colors.amberAccent : Colors.black,
                  ),
                ),
              )
              )
            ],
          ),
          const SizedBox(height: 10,),

          Divider(
            thickness: 1,
            color: darkTheme ? Colors.amber.shade400 : Colors.grey,
          ),
          SizedBox(height: 10,),

          ElevatedButton.icon(
            onPressed:() async {
              if(rideRequestStatus == "accepted") {
                rideRequestStatus = "arrived";
                FirebaseDatabase.instance.ref().child("All Ride Requests")
                    .child(widget.userRideRequestDetails!.rideRequestId!).child("status")
                    .set(rideRequestStatus);

                setState(() {
                  buttonTitle = "Let's Go";
                  buttonColor = Colors.lightGreen;
                });
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => ProgressDialog(message: "loading..",)
                );
                await drawPolyLineFromOriginToDestination(
                    widget.userRideRequestDetails!.originLatLng!,
                    widget.userRideRequestDetails!.destinationLatLng!,
                    darkTheme);

                Navigator.pop(context);
              }
              //[User has been picked from the user's current location] - Let's Go Button
              else if(rideRequestStatus == "arrived"){
                rideRequestStatus = "ontrip";

                FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set(rideRequestStatus);

                setState(() {
                  buttonTitle = "End Trip";
                  buttonColor = Colors.red;
                });
              }
              //[user/driver has reached the drop-off location] - End trip button
              else if(rideRequestStatus == "ontrip"){
                endTripNow();
              }



            },
            icon: Icon(Icons.directions_car,color: darkTheme ? Colors.black : Colors.white, size: 25,),
            label: Text(
              buttonTitle!,
              style: TextStyle(
                color: darkTheme? Colors.black:Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        ),

        ),
      ),
        ),
        ),
        ],
      ),
    );
  }
}
