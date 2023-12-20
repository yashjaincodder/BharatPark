import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:parkwizflutter/model/vendor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkwizflutter/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class QrCodeScreen extends StatefulWidget {
  final String orderId;
  final String vid;
  final String vehicleType;

  QrCodeScreen({super.key, required this.orderId, required this.vid, required this.vehicleType}) {
    print('QrCodeScreen created with orderId: $orderId');
  }

  @override
  // ignore: library_private_types_in_public_api
  _QrCodeScreenState createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
    VendorModel? vendor;
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
 void initState() {
    super.initState();
    // Fetch data from Firestore using vid
    Future.wait([
      FirebaseFirestore.instance.collection('vendors').doc(widget.vid).get(),
      FirebaseFirestore.instance.collection("users").doc(user!.uid).get(),
    ]).then((List<DocumentSnapshot<Map<String, dynamic>>> snapshots) {
      if (snapshots[0].exists) {
        // Document exists in Firestore
        setState(() {
          vendor = VendorModel.fromMap(snapshots[0].data()!);
        });
      } else {
        // Document does not exist in Firestore
        print('Vendor document does not exist on the database');
      }

      if (snapshots[1].exists) {
        // Document exists in Firestore
        loggedInUser = UserModel.fromMap(snapshots[1].data()!);
      } else {
        // Document does not exist in Firestore
        print('User document does not exist on the database');
      }
     // Update the sub-document with VehicleType field
      FirebaseFirestore.instance
          .collection("vendors")
          .doc(widget.vid)
          .collection("orderId")
          .doc(widget.orderId)
          .update({
        'VehicleType': widget.vehicleType,
      }).catchError((error) {
        print('Error updating VehicleType: $error');
      });
      setState(() {});
    }).catchError((error) {
      print('Error getting documents: $error');
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Receipt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            QrImageView(
              data: widget.orderId,
              version: QrVersions.auto,
              size: 200.0, // Adjust the size as needed
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Your receipt is generated!',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Please show this to our ParkWizard at your chosen parking spot.',
              textAlign: TextAlign.center,
            ),
        
            const SizedBox(height: 24.0),
          ElevatedButton(
  onPressed: () async {
    // Add navigation logic here
      openGoogleMapsNavigation(vendor!.location!.latitude, vendor!.location!.longitude);
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green, // Set the background color
   foregroundColor: Colors.white, // Set the text color
    minimumSize: const Size(double.infinity, 48), // Make the button wider
  ),
  child: const Text('Navigate Now'),
),

          ],
        ),
      ),
    );
  }
    void openGoogleMapsNavigation(double latitude, double longitude) async {
    String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      // Handle if the launch fails
      print('Could not launch Google Maps');
    }
  }
}
