import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medicab_drivers/Assistants/request_assistant.dart';

import 'package:provider/provider.dart';



import '../Models/direction_details_info.dart';
import '../Models/directions.dart';
import '../Models/usermodel.dart';
import '../global/Map_key.dart';
import '../global/global.dart';
import '../infoHandler/app_info.dart';
import '../models/trip_history_model.dart';

class AssistantMethods{
  static void readcurrentOnlineuserInfo() async
  {
    currentUser = fAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentUser!.uid);

    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

  static Future<String> searchAddressforGeographicCoordinates(Position position,context) async{
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = " ";

    var requestResponse = await RequestAssistant.recieveRequest(apiUrl);

    if(requestResponse != "Error occurred,Failed. No Response.") {
     humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickupAddress =Directions();
      userPickupAddress.locationLatitude=position.latitude;
      userPickupAddress.locationLongitude=position.longitude;
      userPickupAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context,listen:false).updatePickUpLocationAddress(userPickupAddress);
    }
    return humanReadableAddress;
  }
  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirection(LatLng originPosition,LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    var responseDirectionApi = await RequestAssistant.recieveRequest(urlOriginToDestinationDirectionDetails);

    // if(responseDirectionApi == "Error Occurred. Failed. No Response"){
    //  return null;
   // }
    DirectionDetailsInfo directionDetailsInfo=DirectionDetailsInfo();
    directionDetailsInfo.e_point=responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text=responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value=responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text=responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value=responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;

  }
   static pauseLiveLocationUpdates(){
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(fAuth.currentUser!.uid);
   }
  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){
    double timeTravelledFareAmountPerMinute = (directionDetailsInfo.duration_value! / 60) * 0.1;
    double distanceTravelledFareAmountPerKilometer = (directionDetailsInfo.duration_value! / 1000) * 0.1;

    double totalFareAmount = timeTravelledFareAmountPerMinute + distanceTravelledFareAmountPerKilometer;
    double locationCurrencyTotalFare = totalFareAmount + 20;

    if(driverVehicleType == "Bike"){
      double resultFareAmount = ((locationCurrencyTotalFare.truncate()) * 1.5);
      resultFareAmount;
    }

    else if(driverVehicleType == "Ambulance") {
      double resultFareAmount = ((locationCurrencyTotalFare.truncate()) * 2);
      resultFareAmount;
    }
    else{
      return locationCurrencyTotalFare.truncate().toDouble();
    }

    return locationCurrencyTotalFare.truncate().toDouble();
  }
  //retrieve the trips keys for online user
  //trip key = ride request key
  static void readTripKeysForOnlineDriver(context){
    FirebaseDatabase.instance.ref().child("All Ride Requests").orderByChild("driverId").equalTo(fAuth.currentUser!.uid).once().then((snap){
      if(snap.snapshot.value != null){
        Map keysTripsId = snap.snapshot.value as Map;

        //count total number trips and share it with Provider
        int overAllTripCounter = keysTripsId.length;
        Provider.of<AppInfo>(context, listen: false).updateOverAllTripCounter(overAllTripCounter);

        //share trips keys with Provider
        List<String> tripsKeysList = [];
        keysTripsId.forEach((key, value) {
          tripsKeysList.add(key);
        });
        Provider.of<AppInfo>(context, listen: false).updateOverAllTripKeys(tripsKeysList);

      //get trips keys data - read trips complete information
      readTripsHistoryInformation(context);
    }
    });
  }

  static void readTripsHistoryInformation(context){
    var tripsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripsKeysLIst;

    for(String eachKey in tripsAllKeys){
      FirebaseDatabase.instance.ref().child("All Ride Requests").child(eachKey).once().then((snap){
        var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);

        if((snap.snapshot.value as Map)["status"]  == "ended"){
          Provider.of<AppInfo>(context, listen: false).updateOverAllTripsHistoryInformation(eachTripHistory);
        }
      });
    }
  }

  //read Driver Earnings
  static void readDriverEarnings(context){
    FirebaseDatabase.instance.ref().child("drivers").child(fAuth.currentUser!.uid).child("earnings").once().then((snap){
      if(snap.snapshot.value != null){
        String driverEarnings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false).updateDriverTotalEarnings(driverEarnings);
      }
    });

    readTripKeysForOnlineDriver(context);
  }

  static void readDriverRatings(context){
    FirebaseDatabase.instance.ref().child("drivers").child(fAuth.currentUser!.uid).child("ratings").once().then((snap) {
      if (snap.snapshot.value != null) {
        String driverRatings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false).updateDriverAverageRatings(driverRatings);
      }
    });
    }

}
