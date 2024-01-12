import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medicab_drivers/global/global.dart';
import 'package:medicab_drivers/splashScreen/splash_screen.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({super.key});

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {

  final nameTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();

  DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");
  Future<void> showUserNameDialogAlert(BuildContext context, String name){

    nameTextEditingController.text =name;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: nameTextEditingController,
                  )
                ],
              ),
            ),
            actions:[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel", style: TextStyle(color: Colors.red),),
              ),

              TextButton(
                onPressed: () {
                  userRef.child(fAuth.currentUser!.uid).update({
                    "name": nameTextEditingController.text.trim(),
                  }).then((value){
                    nameTextEditingController.clear();
                    Fluttertoast.showToast(msg:"Update Successfully. \n Reload the app to see the changes");
                  }).catchError((errorMessage){
                    Fluttertoast.showToast(msg:"Error occurred. \n $errorMessage");
                  });
                  Navigator.pop(context);
                },
                child: const Text("ok", style: TextStyle(color: Colors.black),),
              ),

            ],
          );
        }
    );
  }

  Future<void> showUserPhoneDialogAlert(BuildContext context, String phone){

    phoneTextEditingController.text =phone;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: phoneTextEditingController,
                  )
                ],
              ),
            ),
            actions:[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel", style: TextStyle(color: Colors.red),),
              ),

              TextButton(
                onPressed: () {
                  userRef.child(fAuth.currentUser!.uid).update({
                    "phone": phoneTextEditingController.text.trim(),
                  }).then((value){
                    phoneTextEditingController.clear();
                    Fluttertoast.showToast(msg:"Update Successfully. \n Reload the app to see the changes");
                  }).catchError((errorMessage){
                    Fluttertoast.showToast(msg:"Error occurred. \n $errorMessage");
                  });
                  Navigator.pop(context);
                },
                child: const Text("ok", style: TextStyle(color: Colors.black),),
              ),

            ],
          );
        }
    );
  }


  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: darkTheme ? Colors.amber.shade400 : Colors.black,
            ),
          ),
          title: Text("Profile Screen",style: TextStyle(color:darkTheme ? Colors.amber.shade400 : Colors.black, fontWeight: FontWeight.bold),),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: ListView(
            padding: const EdgeInsets.all(0),
            children: [
        Center(
        child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
        child: Column(
            children: [
        Container(
        padding: const EdgeInsets.all(50),
        decoration: BoxDecoration(
          color: darkTheme ? Colors.amber.shade400 : Colors.lightBlue,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.person, color: darkTheme ? Colors.black :Colors.white,),
      ),

      const SizedBox(height: 30,),

    

      const Divider(
        thickness: 1,
      ),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${onlineDriverData!.name}",
            style: TextStyle(
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {
              showUserNameDialogAlert(context,onlineDriverData!.name!);
            },
            icon: Icon(
              Icons.edit,
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
            ),
          ),
        ],
      ),

      const Divider(
        thickness: 1,
      ),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${onlineDriverData!.phone}",
            style: TextStyle(
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {
              showUserNameDialogAlert(context,onlineDriverData!.phone!);
            },
            icon: Icon(
              Icons.edit,
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
            ),
          ),
        ],
      ),

      const Divider(
        thickness: 1,
      ),

      Text(onlineDriverData!.email!,
        style: TextStyle(
          color: darkTheme ? Colors.amber.shade400 : Colors.blue,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 20,),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${onlineDriverData!.Ambulance_Model}\n${onlineDriverData!.Ambulance_Number}",
            style: TextStyle(
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Image.asset(
            onlineDriverData!.Ambulance_type == "Ambulance" ? "images/2389124.webp"
            :"images/biker.png",
            scale: 2,
          ),
          ],
        ),


          const SizedBox(height: 20,),

          ElevatedButton(
            onPressed: () {
              fAuth.signOut();
              Navigator.push(context,MaterialPageRoute(builder: (c) => const MySplashScreen()));
            },
            style: ElevatedButton.styleFrom(
                primary: Colors.redAccent
            ),
            child: const Text("Log Out"),
          ),
        ],
      ),
      ),
    )

            ],
    ),
    ),
    );
    }
}
