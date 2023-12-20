import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parkwizflutter/model/vendor_model.dart';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'BookScreen.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  List<VendorModel>? newfacilitiesWithinRadius;

  @override
  void initState() {
    super.initState();
    _getUserPosition();
  }

  Future<void> _getUserPosition() async {
  try {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied");
    }

    Position userPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await queryNearbyFacilities(userPosition);
  } catch (e) {
    print("Error getting user location: $e");
  }
}


  Future<void> queryNearbyFacilities(Position userPosition) async {
  try {
     // Request permission to access the device's location
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied");
    }

    // Get the current position (latitude and longitude)
    Position userPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Set a radius for the query (adjust as needed)
    double radiusInMeters = 5000; // 5 kilometers

    // Create a GeoPoint representing the user's location
    GeoPoint userLocation = GeoPoint(userPosition.latitude, userPosition.longitude);

    // Query nearby facilities within the specified radius
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("vendors")
        .where(
          "location",
          isGreaterThan: GeoPoint(
            userLocation.latitude - (radiusInMeters / 111.32 / 2),
            userLocation.longitude - (radiusInMeters / 111.32 / 2),
          ),
        )
        .where(
          "location",
          isLessThan: GeoPoint(
            userLocation.latitude + (radiusInMeters / 111.32 / 2),
            userLocation.longitude + (radiusInMeters / 111.32 / 2),
          ),
        )
        .get();

    // Process the query results
    List<VendorModel> nearbyFacilities = querySnapshot.docs
        .map((doc) => VendorModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    // Filter facilities within the specified radius
    double userLatitude = userPosition.latitude;
    double userLongitude = userPosition.longitude;

   newfacilitiesWithinRadius = nearbyFacilities
        .where((vendor) =>
            isLocationWithinRadius(
              userLatitude,
              userLongitude,
              vendor.location?.latitude ?? 0,
              vendor.location?.longitude ?? 0,
              radiusInMeters,
            ))
        .toList();

    // Add markers for each facility within the radius


    // Print details of facilities within the radius
    // print("Nearbyyyyyyyy Facilities within $radiusInMeters meters:");

    // for (VendorModel vendor in newfacilitiesWithinRadius!) {
    //   print("Facility Name: ${vendor.facilityName}");
    //   print("Owner Name: ${vendor.ownerName}");
    //   print("Max Capacity: ${vendor.maxCapacity}");
    //   print("Location: ${vendor.location?.latitude}, ${vendor.location?.longitude}");
    //   print("--------------");
    // }
       setState(() {
      newfacilitiesWithinRadius = newfacilitiesWithinRadius;
    });
//  print("Facilitiessssssssssssssss within radius: ${newfacilitiesWithinRadius!.length}");
  } catch (e) {
    print("Error querying nearby facilities: $e");
  }
}

bool isLocationWithinRadius(
    double userLat, double userLng, double facilityLat, double facilityLng, double radius) {
  double distance = Geolocator.distanceBetween(userLat, userLng, facilityLat, facilityLng);
  return distance <= radius;
}

  
Future<String> _getImageUrl(String vid) async {
  // Construct the path in Firebase Storage using the vendor's ID (vid) as the filename
  String filePath = 'vendors/$vid/images/$vid.jpg';

  // Retrieve the download URL for the image
  String downloadUrl = await FirebaseStorage.instance.ref(filePath).getDownloadURL();

  return downloadUrl;
}

 Widget buildCard(BuildContext context, VendorModel vendor) {
  return GestureDetector(
    onTap: () {
      // Navigate to the BookScreen when the card is tapped
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => BookScreen(vid: vendor.vid!),
      //   ),
      // );
    Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return BookScreen(vid: vendor.vid!);
                },
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));

                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 1500),
              ),
            );


    },
    child: Container(
      width: 130,
      height: 260,
      color: Colors.white,
      margin: const EdgeInsets.only(right: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Load image from Firebase Storage using the vendor's ID as the filename
          FutureBuilder(
            future: _getImageUrl(vendor.vid!),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                String imageUrl = snapshot.data ?? '';
                return Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                );
              } else {
                return const CircularProgressIndicator(
                  color: Colors.yellow,
                );
              }
            },
          ),
          const SizedBox(height: 8),
          Text(
            vendor.facilityName!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}


 @override
Widget build(BuildContext context) {
  return Scaffold(
 
    body: newfacilitiesWithinRadius != null
        ? newfacilitiesWithinRadius!.isNotEmpty
            ? SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: newfacilitiesWithinRadius!.length,
                  itemBuilder: (BuildContext context, int index) {
                    VendorModel vendor = newfacilitiesWithinRadius![index];
                    return buildCard(context, vendor);
                  },
                ),
              )
            : const Center(
                child: Text('No nearby facilities'),
              )
        : const Center(
            child: CircularProgressIndicator(), // Loading indicator while fetching data
          ),
  );
}

}
