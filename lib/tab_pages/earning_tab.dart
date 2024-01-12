import 'package:flutter/material.dart';
import 'package:medicab_drivers/global/global.dart';
import 'package:medicab_drivers/models/trip_history_model.dart';
import 'package:provider/provider.dart';

import '../infoHandler/app_info.dart';
import '../mainScreens/trips_history_screen.dart';

class EarningsTabPage extends StatefulWidget {
  const EarningsTabPage({super.key});

  @override
  State<EarningsTabPage> createState() => _EarningsTabPageState();
}

class _EarningsTabPageState extends State<EarningsTabPage> {
  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Container(
      color: darkTheme ? Colors.black : Colors.lightBlue,
      child: Column(
        children: [
          //earnings
          Container(
            color: darkTheme ? Colors.black : Colors.lightBlue,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  Text(
                    "Your Earnings: ",
                    style: TextStyle(
                      color: darkTheme ? Colors.amber.shade400 : Colors.black,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10,),

                  Text(
                    " ₹ " + Provider.of<AppInfo>(context, listen: false).driverTotalEarnings,
                    style: TextStyle(
                      color: darkTheme ? Colors.amber.shade400 : Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          ),

          //Total number of trips
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => TripsHistoryScreen()));
            },
            style: ElevatedButton.styleFrom(
                primary: Colors.white54
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Image.asset(
                    onlineDriverData!.Ambulance_type == "Ambulance" ? "images/2389124.webp"
                        :"images/biker.png",
                    scale: 2,
                  ),

                  const SizedBox(width: 10,),

                  const Text(
                    "Trips Completed",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),

                  Expanded(
                    child: Container(
                      child: Text(
                        Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList.length.toString(),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
