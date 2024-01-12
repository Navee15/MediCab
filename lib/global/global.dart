import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:medicab_drivers/models/driver_data.dart';
import 'package:audioplayers/audioplayers.dart';
import '../Models/usermodel.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentUser;

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;
AudioPlayer audioPlayer=AudioPlayer as AudioPlayer;

Position? driverCurrentPosition;

UserModel? userModelCurrentInfo;
String? driverVehicleType ="";

String userDropOffAddress ="";
String titleStarsRating="";
DriverData? onlineDriverData=DriverData();

