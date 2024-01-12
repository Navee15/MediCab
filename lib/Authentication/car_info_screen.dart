import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:medicab_drivers/global/global.dart';
import 'package:medicab_drivers/splashScreen/splash_screen.dart';
class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({super.key});

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  TextEditingController AmbulanceModelTextEditingController =TextEditingController();
  TextEditingController AmbulanceNumberTextEditingController =TextEditingController();
  List<String> AmbulanceTypes=["Ambulance","Bike"];
  String? selectedAmbulanceType;

saveCarInfo(){
  Map driversAmbuInfoMap =
  {
    "Ambulance_Model":AmbulanceModelTextEditingController.text.trim(),
    "Ambulance_Number":AmbulanceNumberTextEditingController.text.trim(),
    "type":selectedAmbulanceType,
  };
  DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers");
  driversRef.child(currentUser!.uid).child("Ambulance_Details").set(driversAmbuInfoMap);
Fluttertoast.showToast(msg: "Ambulance details has been saved");
  Navigator.push(context, MaterialPageRoute(builder: (c)=>const MySplashScreen()));

}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){
        FocusScope.of(context).unfocus();
    },

      child:Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 24,),

                Padding(
                  padding:const EdgeInsets.all(20.0),
                  child: Image.asset("images/416612.png"),),
                const SizedBox(height: 24,),

                const Text("Ambulance Details",
                  style:TextStyle(
                    fontSize:26,
                    color:Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                    controller: AmbulanceModelTextEditingController,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                    decoration: const InputDecoration(
                      labelText: "AmbulanceModel",
                      hintText: "AmbulanceModel",

                      enabledBorder:UnderlineInputBorder(
                          borderSide: BorderSide(color:Colors.grey)
                      ),
                      focusedBorder:UnderlineInputBorder(
                          borderSide: BorderSide(color:Colors.grey)
                      ),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10
                      ),
                      labelStyle:TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),

                    )
                ),
                TextField(
                  controller: AmbulanceNumberTextEditingController,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                  decoration: const InputDecoration(
                    labelText: "Ambulance Number",
                    hintText: "Ambulance Number",

                    enabledBorder:UnderlineInputBorder(
                        borderSide: BorderSide(color:Colors.grey)
                    ),
                    focusedBorder:UnderlineInputBorder(
                        borderSide: BorderSide(color:Colors.grey)
                    ),
                    hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10
                    ),
                    labelStyle:TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),),),
                SizedBox(height: 20,),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    hintText: "please choose type",
                    prefixIcon: Icon(Icons.car_crash,color: Colors.grey,),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ))
                  ),
                    items: AmbulanceTypes.map((Ambulance) {
                      return DropdownMenuItem(child:Text(
                        Ambulance,
                        style: TextStyle(color: Colors.grey),
                      ) ,
                      value: Ambulance,
                      );
                    }).toList(),
                    onChanged:(newvalue){
                    setState(() {
                      selectedAmbulanceType=newvalue.toString();
                    });
                    } ),
                const SizedBox(height: 20,),
                ElevatedButton(onPressed: ()
                {
                  if(AmbulanceNumberTextEditingController.text.isNotEmpty &&
                      AmbulanceModelTextEditingController.text.isNotEmpty){
                    saveCarInfo();
                  }
                },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreenAccent,
                    ),
                    child: const Text(
                      "Next",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18,

                      ),
                    ))

              ],
            ),

          ),
        ),
      )
    );
    }

  }

