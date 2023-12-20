import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkwizflutter/model/vendor_model.dart';



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
    await queryNearbyFacilities(position);

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
      markers.add(
        Marker(
          markerId: MarkerId("${vendor.facilityName}"),
          position: LatLng(vendor.location!.latitude, vendor.location!.longitude),
          infoWindow: InfoWindow(
            title: vendor.facilityName,
            snippet: "Owner: ${vendor.ownerName}, Capacity: ${vendor.maxCapacity}",
          ),
        ),
      );
    }

    // Print details of facilities within the radius
    // print("Nnnnnnnnnnnnnnearby Facilities within $radiusInMeters meters:");

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

bool isLocationWithinRadius(
    double userLat, double userLng, double facilityLat, double facilityLng, double radius) {
  double distance = Geolocator.distanceBetween(userLat, userLng, facilityLat, facilityLng);
  return distance <= radius;
}

  @override
  Widget build(BuildContext context) {
    return SizedBox(
     width: 300.0, // Set the width of your container
      height: 200.0, 
      child: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(0.0, 0.0), // Default to (0.0, 0.0)
          zoom: 10.0,
        ),
        markers: markers,
      ),
    );
  }
}
