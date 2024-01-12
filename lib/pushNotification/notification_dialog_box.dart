import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medicab_drivers/Assistants/assistant_methods.dart';
import 'package:medicab_drivers/global/global.dart';
import 'package:medicab_drivers/mainScreens/new_trip_screen.dart';
import 'package:medicab_drivers/models/user_ride_request_information.dart';

class NotificationDialogBox extends StatefulWidget {

  UserRideRequestInformation? userRideRequestDetails;

  NotificationDialogBox({this.userRideRequestDetails});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: darkTheme ? Colors.black : Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
                onlineDriverData!.Ambulance_type == "Ambulance" ? "images/416612.png"
                    : "images/biker.png"
            ),

            const SizedBox(height: 10,),

            //title
            Text("New Ride Request",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
              ),
            ),

            const SizedBox(height: 14,),

            Divider(
              height: 2,
              thickness: 2,
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
            ),

            Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset("images/start.png",
                          width: 30,
                          height: 30,
                        ),

                        const SizedBox(width: 10,),

                        Expanded(
                          child: Container(
                            child: Text(
                              widget.userRideRequestDetails!.originAddress!,
                              style: TextStyle(
                                fontSize: 16,
                                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 20,),

                    Row(
                      children: [
                        Image.asset("images/destination.png",
                          width: 30,
                          height: 30,
                        ),

                        const SizedBox(width: 10,),

                        Expanded(
                          child: Container(
                            child: Text(
                              widget.userRideRequestDetails!.destinationAddress!,
                              style: TextStyle(
                                fontSize: 16,
                                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
            ),

            Divider(
              height: 2,
              thickness: 2,
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
            ),

            //buttons for cancelling and accepting the ride request
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                       // audioPlayer.pause();
                       // audioPlayer.stop();
                      //  audioPlayer = AssetsAudioPlayer();

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        "Cancel".toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                  ),

                  const SizedBox(width: 20,),

                  ElevatedButton(
                      onPressed: () {
                      //  audioPlayer.pause();
                       // audioPlayer.stop();
                       // audioPlayer = AssetsAudioPlayer();
                        acceptRideRequest(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text(
                        "Accept".toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      )
                  )
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
  acceptRideRequest(BuildContext context){
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(fAuth.currentUser!.uid)
        .child("newRideStatus")
        .once()
        .then((snap) {
          if(snap.snapshot.value=="idle"){
            FirebaseDatabase.instance.ref().child("drivers").child(fAuth.currentUser!.uid).child("newRideStatus").set("accepted");

            AssistantMethods.pauseLiveLocationUpdates();
            //trip started now-send driver to new tripScreen
          Navigator.push(context, MaterialPageRoute(builder: (c)=>NewTripScreen(
            userRideRequestDetails: widget.userRideRequestDetails,
          )));
          }
          else {
            FirebaseDatabase.instance.ref().child("drivers").child(fAuth.currentUser!.uid).child("newRideStatus").set("accepted");
           // AssistantMethods.pauseLiveLocationUpdates();
            // Fluttertoast.showToast(msg: "This Ride Request do not exists");
            Navigator.push(context, MaterialPageRoute(builder: (c)=>NewTripScreen(
                userRideRequestDetails: widget.userRideRequestDetails,
            )));
          }
    });
  }
}
