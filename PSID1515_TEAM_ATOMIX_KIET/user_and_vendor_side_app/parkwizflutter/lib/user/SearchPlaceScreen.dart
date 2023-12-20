import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkwizflutter/model/vendor_model.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({Key? key}) : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

const kGoogleApiKey = 'AIzaSyCnrzRpGmGEEUlGwgvhRYXS3ugm1is4V7E';
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  static const CameraPosition initialCameraPosition = CameraPosition(target: LatLng(37.42796, -122.08574), zoom: 14.0);

  Set<Marker> markersList = {};

  late GoogleMapController googleMapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        title: const Text("Search Your Destination"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            markers: markersList,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
            },
          ),
          ElevatedButton(onPressed: _handlePressButton, child: const Text("Search Places"))
        ],
      ),
    );
  }

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: onError,
       
        language: 'en',
        strictbounds: false,
        types: [""],
        decoration: InputDecoration(
            hintText: 'Search',
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.white))),
        components: [Component(Component.country,"ind")]);


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

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    

    setState(() {});

    googleMapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));


    // Call this function with the coordinates obtained from displayPrediction
      queryNearbyFacilities(lat, lng);
    // Print the coordinates
    print('Selected Location Coordinates: $lat, $lng');
  } catch (e) {
    print('Error retrieving coordinates: $e');
  }
}



Future<void> queryNearbyFacilities(double lat, double lng) async {
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
    // print("Nearby Facilities within $radiusInMeters meters:");

    for (VendorModel vendor in facilitiesWithinRadius) {
      print("Facility Name: ${vendor.facilityName}");
      // print("Owner Name: ${vendor.ownerName}");
      // print("Max Capacity: ${vendor.maxCapacity}");
      // print("Location: ${vendor.location?.latitude}, ${vendor.location?.longitude}");
      // print("--------------");
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
