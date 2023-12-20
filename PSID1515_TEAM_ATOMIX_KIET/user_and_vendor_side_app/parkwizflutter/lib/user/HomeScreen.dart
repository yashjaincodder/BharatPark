import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parkwizflutter/model/user_model.dart';
import 'package:parkwizflutter/widgets/custom_app_bar.dart';
import 'package:parkwizflutter/model/vendor_model.dart';
import 'SearchPlaceScreen.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'RecommendScreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'CardScreen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Set<Circle> circles = {};

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
 final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts flutterTts = FlutterTts();

  bool _isListening = false;
  String _transcription = '';

  @override
  void initState() {
    super.initState();
        _initSpeechRecognition();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
       Future.delayed(const Duration(milliseconds: 3800), () {
      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          // Add MapScreen to the widget tree
          _showMapScreen = true;
        });
      }
    });
  }
  void _initSpeechRecognition() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );

    if (!available) {
      print('Speech recognition not available');
    }
  }
  void _listen() async {
    if (!_isListening) {
      bool isAvailable = await _speechToText.initialize();
      if (isAvailable) {
        setState(() {
          _isListening = true;
        });
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _transcription = result.recognizedWords;
            });
            // Refresh the value of _isListening after completion
            _isListening = false;
          },
          listenFor: Duration(seconds: 5),
        );
      }
    }
  }
   void _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.speak(text);
  }

  bool _showMapScreen = false;
  @override

  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
       backgroundColor: const Color.fromARGB(255, 254, 251, 251),
     appBar: const CustomAppBar(customHeight: 62,),
     body: CustomScrollView(
       physics: const ClampingScrollPhysics(),
       slivers: <Widget>[
    
         
         _buildHeader(screenHeight),
         _buildBody(screenHeight),
       
         
       ],
       
    
       
       )
       
        );
  }

  SliverToBoxAdapter _buildHeader(double screenHeight)
{
  return SliverToBoxAdapter(
    child: Container(
      padding:const EdgeInsets.all(1.0),
    
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
SizedBox(
            height: 90,
           child: 
RichText(
  text: TextSpan(
    children: [
      TextSpan(
        text: '  \nView ',
        style: GoogleFonts.poppins(
          textStyle: const TextStyle(
            fontSize: 22,
            color: Colors.black, // Customize the color
          ),
        ),
      ),
      TextSpan(
        text: 'Parking Area',
        style: GoogleFonts.montserrat(
          textStyle: const TextStyle(
            fontSize: 24,
            color: Colors.red,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      TextSpan(
        text: ' Near You!',
        style: GoogleFonts.openSans(
          textStyle: const TextStyle(
            fontSize: 22,
            color: Colors.black, // Customize the color
          ),
        ),
      ),
    ],
  ),
),
    
          ),
            
        Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your other widgets here
            if (_showMapScreen)
           // ignore: prefer_const_constructors
           MapScreen(), 
            // Other widgets
          ],
        ),
      ),
          SizedBox(height: screenHeight*0.01),
          
        ],
      ),
      ),
      
  );
}

  SliverToBoxAdapter _buildBody (double screenHeight) {
  return SliverToBoxAdapter(
   

    child: Container(

      padding: const EdgeInsets.all(20.0),
      child: Column(
        
        crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
  
           ElevatedButton(
          
            onPressed: _handlePressButton,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // Background color
              foregroundColor: Colors.black, // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0), // Adjust the border radius
                side: const BorderSide(color: Color.fromARGB(255, 4, 49, 117), width: 2.0), // Add border with a different color
              ),
              padding: const EdgeInsets.all(16.0), // Padding around the button
              minimumSize: const Size(double.infinity, 60.0), // Full width and increased height
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.search,
                  size: 29.0,
                ), // Add your desired icon
                const SizedBox(width: 8.0), // Adjust the spacing between icon and text
                Text(
                  "SEARCH DESTINATION",
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18.0, // Adjust the font size
                    ),
                  ),
                ),
              ],
            ),
          ),
                 
        const SizedBox(height: 20.0),
        Row(
        children: <Widget>[
       
            Text(
            'PARK YOUR VEHICLE NOW!',
            style: GoogleFonts.kanit(
              textStyle: const TextStyle(
                color: Color.fromARGB(255, 10, 2, 119),
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
      const SizedBox(height: 19),
        ],
        ),
        const SizedBox(height: 19),
   const SizedBox(
  height: 250, // Set the desired height
  width: 300,  // Set the desired width
  child:  CardScreen(), // Wrap CardScreen in a Container
),
          
            const Row(children: <Widget>[]),
   
     
         const Row(children: <Widget>[

         
         ],)]
         )
         )
  );
}


 

  Future<void> _handlePressButton() async {
    _listen();
    await Future.delayed(Duration(seconds: 5));
    print(_transcription);
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: onError,
        startText: _transcription,
        language: 'en',
        strictbounds: false,
        types: [""],
        decoration: InputDecoration(
        hintText: 'Search',
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.white))),
        components: [Component(Component.country,"ind")]);

  _speak("Choose the first option");
    displayPrediction(p!,homeScaffoldKey.currentState);
  }

  void onError(PlacesAutocompleteResponse response){

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Message',
        message: response.errorMessage!,
        contentType: ContentType.failure,
      ),
    ));

    // homeScaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(response.errorMessage!)));
  }
Future<void> displayPrediction(Prediction p, ScaffoldState? currentState) async {
  try {
    GoogleMapsPlaces places = GoogleMapsPlaces(
      apiKey: kGoogleApiKey,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );
    _speak("Choose the first option");
    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;
    final address = detail.result.formattedAddress!;

    setState(() {});

    // Call this function with the coordinates obtained from displayPrediction
      oldqueryNearbyFacilities(lat, lng, address);
    // Print the coordinates
    print('Selected Location Coordinates: $lat, $lng');
  } catch (e) {
    print('Error retrieving coordinates: $e');
  }
}

Future<void> oldqueryNearbyFacilities(double lat, double lng, String address) async {
  try {
    // Set a radius for the query (adjust as needed)
    double radiusInMeters = 5000; // 5 kilometers

    // Create a GeoPoint representing the user's location
    GeoPoint userLocation = GeoPoint(lat, lng);

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
    List<VendorModel> facilitiesWithinRadius = nearbyFacilities
        .where((vendor) =>
            isLocationWithinRadius(
              lat,
              lng,
              vendor.location?.latitude ?? 0,
              vendor.location?.longitude ?? 0,
              radiusInMeters,
            ))
        .toList();

    // Print details of facilities within the radius
    print("Nearbyyyyyyyy Facilities within $radiusInMeters meters:");
 if (facilitiesWithinRadius.isEmpty) {
  // No nearby parking!
  Fluttertoast.showToast(
    msg: "No nearby parking!",
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: const Color.fromARGB(255, 3, 0, 0),
    textColor: Colors.white,
  );
  // You can also perform other actions here, update the UI, etc.
}else {
      // for (VendorModel vendor in facilitiesWithinRadius) {
      //   print("Facility Name: ${vendor.facilityName}");
      //   print("Owner Name: ${vendor.ownerName}");
      //   print("Max Capacity: ${vendor.maxCapacity}");
      //   print("Location: ${vendor.location?.latitude}, ${vendor.location?.longitude}");
      //   print("--------------");
      // }

     
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RecommendScreen(facilitiesWithinRadius: facilitiesWithinRadius, selectedAddress: address)),
      );
    }
  } catch (e) {
    print("Error querying nearby facilities: $e");
  }
}
bool isLocationWithinRadius(
    double userLat, double userLng, double facilityLat, double facilityLng, double radius) {
  double distance = Geolocator.distanceBetween(userLat, userLng, facilityLat, facilityLng);
  return distance <= radius;
}

}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});



  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  // ignore: unused_field
  late Position _userLocation;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }
Future<void> _getUserLocation() async {
  try {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied");
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Query nearby facilities
    await oldqueryNearbyFacilities(position);

    setState(() {
      _userLocation = position;
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15.0,
        ),
      );

      markers.add(
        Marker(
          markerId: const MarkerId("User Location"),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(
            title: "Your Location",
            snippet: "Lat: ${position.latitude}, Lng: ${position.longitude}",
          ),
        ),
      );
    });
  } catch (e) {
    print("Error getting user location: $e");
  }
}

Future<void> oldqueryNearbyFacilities(Position userPosition) async {
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

    List<VendorModel> facilitiesWithinRadius = nearbyFacilities
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
    for (VendorModel vendor in facilitiesWithinRadius) {
      double lati=vendor.location!.latitude;
      double longi=vendor.location!.longitude;
      double pollutionLevel=await fetchPollutionData(lati,longi);
      print("rrrrrr$pollutionLevel");
    pollutionLevel = 115;
      Color markerColor;
      if (pollutionLevel < 50) {
        markerColor = Colors.green;
      } else if (pollutionLevel < 100) {
        markerColor = Colors.yellow;
      } else if (pollutionLevel < 150) {
        markerColor = Colors.orange;
      } else {
        markerColor = Colors.red;
      }
      double getHueFromColor(Color markerColor) {
        if (markerColor == Colors.red) {
          return BitmapDescriptor.hueRed;
        } else if (markerColor == Colors.blue) {
          return BitmapDescriptor.hueBlue;
        } else if (markerColor == Colors.green) {
          return BitmapDescriptor.hueGreen;
        } else {
          // You can define additional color mappings as needed
          return BitmapDescriptor.hueRed;
        }
      }
      markers.add(
        Marker(
          markerId: MarkerId("${vendor.facilityName}"),
          position: LatLng(vendor.location!.latitude, vendor.location!.longitude),
          infoWindow: InfoWindow(
            title: vendor.facilityName,
            snippet: "Occupancy: ${vendor.currentFilled} / ${vendor.maxCapacity}, Pollution: ${pollutionLevel}",
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(getHueFromColor(markerColor)),
        ),
        
      );

circles.add(
    Circle(
      circleId: CircleId("${vendor.facilityName}_circle"),
      center: LatLng(lati, longi),
      radius: 500.0, // 500 meters radius
      fillColor: markerColor.withOpacity(0.3), // Adjust the opacity as needed
      strokeWidth: 0,
),
);

    }

    // Print details of facilities within the radius
    // print("Nearby Ffffffffffffacilities within $radiusInMeters meters:");

    // for (VendorModel vendor in facilitiesWithinRadius) {
    //   print("Facility Name: ${vendor.facilityName}");
    //   print("Owner Name: ${vendor.ownerName}");
    //   print("Max Capacity: ${vendor.maxCapacity}");
    //   print("Location: ${vendor.location?.latitude}, ${vendor.location?.longitude}");
    //   print("--------------");
    // }
    
  } catch (e) {
    print("Error querying nearby facilities: $e");
  }
}

 Future<double> fetchPollutionData(double latitude, double longitude) async {
    final openAQApiKey = '0bf9517db0dbe6384e9c85f8c19168fcd1f3e24e4c392a2d51327ad9ff21e211';
    final endpoint = 'https://api.openaq.org/v2/measurements';

    final uri = Uri.parse(
      '$endpoint?coordinates=$latitude,$longitude&radius=1000&date_from=2023-01-01T00%3A00%3A00%2B00%3A00&parameter=pm25&limit=1',
    );

    try {
      final response = await http.get(
        uri,
        headers: {'apikey': openAQApiKey},
      );

    if (response.statusCode == 200) {
      // Parse the pollution data from the response
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> measurements = data['results'];

      if (measurements.isNotEmpty) {
        // Assuming you want to get the first measurement
        final Map<String, dynamic> firstMeasurement = measurements[0];
        final double pollutionValue = firstMeasurement['value'];

        // Update the map markers or overlays based on pollution data
        return pollutionValue;
      } else {
        return 0;
      }
    } else {
      // Handle errors
      return 0;
    }
    } catch (e) {
      // Handle other exceptions
      return 0;
    }
  }


bool isLocationWithinRadius(
    double userLat, double userLng, double facilityLat, double facilityLng, double radius) {
  double distance = Geolocator.distanceBetween(userLat, userLng, facilityLat, facilityLng);
  return distance <= radius;
}

  @override
  Widget build(BuildContext context) {
    return Container(
     width: double.infinity, // Set the width of your container
      height: 230.0, 
      decoration: BoxDecoration(
    border: Border.all(
      color: Colors.black.withOpacity(0.5), // Set the border color with opacity
      width: 2.0, // Set the border width
    ),
  ),
      child: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
          
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(0.0, 0.0), // Default to (0.0, 0.0)
          zoom: 7.0,
        ),
        markers: markers,
        circles: circles,
      ),
    
    );
  }
  
 
}