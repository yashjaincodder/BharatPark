import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parkwizflutter/model/vendor_model.dart';
import 'package:parkwizflutter/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'BookScreen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';

List<List<dynamic>> toDoRecommendationArraySorted = [];
String recommendedVid = "-1";

class RecommendScreen extends StatefulWidget {
  final List<VendorModel> facilitiesWithinRadius;
  final String selectedAddress;

  const RecommendScreen(
      {required this.facilitiesWithinRadius, required this.selectedAddress});

  @override
  _RecommendScreenState createState() => _RecommendScreenState();
}

class _RecommendScreenState extends State<RecommendScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  Position? userLocation;
  VendorModel? vendor;

  @override
  void initState() {
    super.initState();

    // Get the user's current location
    Geolocator.getCurrentPosition().then((position) {
      setState(() {
        userLocation = position;
      });
    });

    // Fetch user data from Firestore
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data() as Map<String, dynamic>);
      setState(() {});
    });

    _calculateRecommendation();
  }

  Future<int> getDirections(
      double originLat,
      double originLng,
      double destinationLat,
      double destinationLng,
      String apiKey,
      ) async {
    final String apiUrl = 'https://maps.googleapis.com/maps/api/directions/json';

    try {
      final response = await http.get(
        Uri.parse('$apiUrl?origin=$originLat,$originLng&destination=$destinationLat,$destinationLng&mode=driving&key=$apiKey'),
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> data = json.decode(response.body);

        // Check for any errors in the response
        if (data['status'] == 'OK') {
          // Extract the duration in traffic
          int durationValue = data['routes'][0]['legs'][0]['duration_in_traffic']['value'];

          // Use the duration information as needed in your application
          return durationValue;
        } else {
          print('Error in directions API response: ${data['status']}');
          return 0;
        }
      } else {
        print('Error in API request. Status code: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error making API request: $e');
      return 0;
    }
  }

  Future<void> _fetchOccupancyFromFirebase(dynamic vendorId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .collection("vendors")
          .doc(vendorId)
          .get();

      if (documentSnapshot.exists) {
        setState(() {
          vendor = VendorModel.fromMap(documentSnapshot.data()!);
        });
        double occupancy= double.parse('${vendor!.currentFilled}') /
            double.parse('${vendor!.maxCapacity}');
            int traffic_weight= await getDirections(userLocation!.latitude,userLocation!.longitude,vendor!.location!.latitude,vendor!.location!.longitude,"AIzaSyCnrzRpGmGEEUlGwgvhRYXS3ugm1is4V7E");
            double traf=traffic_weight/(24*60);
            double final_weight=(occupancy+traf);
            toDoRecommendationArraySorted.add([vendorId,final_weight]);

      } else {
        print('Document does not exist on the database');
        toDoRecommendationArraySorted.add([vendorId, 0.0, vendor]); // You can return a default value or handle it as needed
      }
    } catch (error) {
      print('Error getting document: $error');
      toDoRecommendationArraySorted.add([vendorId, 0.0, vendor]);// You can return a default value or handle it as needed
    }
  }

  void _calculateRecommendation() async {
    for (int index = 0;
    index < widget.facilitiesWithinRadius.length;
    index++) {
      VendorModel vendor = widget.facilitiesWithinRadius[index];
      // Fetch the occupancy from Firebase
       await _fetchOccupancyFromFirebase(vendor.vid);
    }

    toDoRecommendationArraySorted.sort((b, a) => b[1].compareTo(a[1]));
    recommendedVid = toDoRecommendationArraySorted[0][0];

    setState(() {
      // Make sure to call setState to trigger a rebuild of the widget tree
    });
  }

  Widget wrapText(String text) {
    int maxCharacters = 32; // Set the maximum number of characters per line
    List<Widget> textWidgets = [];

    for (int i = 0; i < text.length; i += maxCharacters) {
      int endIndex = i + maxCharacters;
      if (endIndex > text.length) {
        endIndex = text.length;
      }
      String substring = text.substring(i, endIndex);
      textWidgets.add(Text(substring));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: textWidgets,
    );
  }
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
    // This code will run after the widget is built
    if (recommendedVid != "-1") {
      // Find the index of the recommended vendor in the list
      int recommendedIndex = widget.facilitiesWithinRadius
          .indexWhere((vendor) => vendor.vid == recommendedVid);

      if (recommendedIndex != -1) {
        // Scroll to the recommended vendor
        Scrollable.ensureVisible(
          context,
          alignment: 0.5, // You can adjust this value based on your UI
          duration: const Duration(milliseconds: 2500),
          curve: Curves.easeInOut,
        );

        // Trigger the tap event programmatically after a short delay
        Future.delayed(const Duration(milliseconds: 3000), () {
          ListTile tile = context.findRenderObject() as ListTile;
          tile.onTap!();
        });
      }
    }
  });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 92, 3, 92),
      ),
      body: Column(
        children: [
          Container(
            height: 190,
            width: double.infinity,
            color: const Color.fromARGB(255, 92, 3, 92),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    color: Color.fromARGB(255, 92, 3, 92),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.scaleDown,
                        image: AssetImage('assets/logo.png'),
                      ),
                    ),
                    width: 100,
                    height: 100,
                  ),
                ),
                Text(
                  '${loggedInUser.firstName} ${loggedInUser.lastName} ',
                  style: const TextStyle(fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  '${loggedInUser.subscription}  ',
                  style: const TextStyle(fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber),
                ),
                Text(
                  '${widget.selectedAddress}              ',
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: widget.facilitiesWithinRadius.length,
              itemBuilder: (context, index) {
                VendorModel vendor = widget.facilitiesWithinRadius[index];
                recommendedVid=toDoRecommendationArraySorted[0][0].toString();
                // Calculate distance if user location is available
                String distanceText = userLocation != null
                    ? '${_calculateDistance(
                    userLocation!, vendor.location?.latitude ?? 0,
                    vendor.location?.longitude ?? 0)} km away'
                    : '';
                // Check if the current vendor is recommended
                bool isRecommended = vendor.vid == recommendedVid;

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Row(
                      children: [
                        Text(
                          '${vendor.facilityName}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 68, 3, 80),
                          ),
                        ),
                        if (isRecommended)
                          Container(
                            margin: const EdgeInsets.only(left: 8.0),
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.red[300]!, Colors.red[500]!],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4.0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              "Recommended",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0, // Adjust the font size
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                    Icons.location_on, color: Colors.black),
                                const SizedBox(width: 2),
                                     wrapText('${vendor.address}'),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.people, color: Colors.black),
                                const SizedBox(width: 8),
                                Text('${vendor.maxCapacity}'),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("     ~"),
                                const SizedBox(width: 4),
                                if (userLocation != null) Text(distanceText),
                              ],
                            ),

                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                    Icons.motorcycle, color: Colors.black),
                                const SizedBox(width: 8),
                                Text('Rs.${vendor.bikeBasePrice}'),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                    Icons.car_repair, color: Colors.black),
                                const SizedBox(width: 8),
                                Text('Rs.${vendor.carBasePrice}'),
                              ],
                            ),

                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      if((loggedInUser.subscription! == "Basic" && vendor.currentFilled! < vendor.maxCapacity!*0.9) || (loggedInUser.subscription! == "Premium" && vendor.currentFilled! <= vendor.maxCapacity!)){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookScreen(vid: vendor.vid!),
                        ),
                      );
                      }else if((loggedInUser.subscription! == "Basic" && vendor.currentFilled! >= vendor.maxCapacity!*0.9) ){
                          Fluttertoast.showToast(
                          msg: "Slots are FULL, Try upgrading to premium",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black.withOpacity(0.8),
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _calculateDistance(Position userLocation, double facilityLat,
      double facilityLng) {
    double distanceInMeters = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      facilityLat,
      facilityLng,
    );
    double distanceInKm = (distanceInMeters / 1000);

    // Format the result to display two decimal places
    String formattedDistance = distanceInKm.toStringAsFixed(2);

    return double.parse(formattedDistance);
}


}