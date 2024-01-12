
import 'package:flutter/material.dart';
import 'package:medicab_usersapp/mainScreens/profile_screen.dart';
import 'package:medicab_usersapp/mainScreens/trip_history.dart';

import '../global/global.dart';
import '../splashScreen/splash_screen.dart';
class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      child: Drawer(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 50, 0, 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Container(
          padding: const EdgeInsets.all(30),
          decoration: const BoxDecoration(
            color: Colors.lightBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),

                   const SizedBox(height: 20,),

                   Text(userModelCurrentInfo!.name!,
                   style:TextStyle(
                     fontWeight: FontWeight.bold,
                     fontSize: 20,
                   ),),


                   const SizedBox(height: 10,),

                 GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (c)=>const ProfileScreen()));
                },
                   child: const Text(
                "Edit Profile",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                     fontSize: 15,
                      color: Colors.blue,
                ),
                     ),
                  ),

    const SizedBox(height: 30,),

    GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (c)=>const TripsHistoryScreen()));

        },
        child: const Text("Your Trips", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),)
    ),

    const SizedBox(height: 15,),

    const Text("Payments", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),

    const SizedBox(height: 15,),

    const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),

    const SizedBox(height: 15,),

    const Text("Promos", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),

    const SizedBox(height: 15,),

    const Text("Help", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),

    const SizedBox(height: 15,),

    const Text("Free Trips", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),

    const SizedBox(height: 15,),



    ],
    ),
    GestureDetector(
    onTap: () {
    fAuth.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
    },
    child: const Text(
    "Logout",
    style: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
   color: Colors.red,
    ),
    ),
    ),
    ],
    ),
    ),
    ),
    );
  }
}