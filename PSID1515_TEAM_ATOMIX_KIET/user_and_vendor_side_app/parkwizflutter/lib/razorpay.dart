// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'apiservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkwizflutter/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkwizflutter/user/QrCodeScreen.dart';
class RazorPayIntegration extends StatefulWidget {
    final int selectedVehiclePrice;
    final String vid;
      final String vehicleType;
  const RazorPayIntegration({super.key, required this.selectedVehiclePrice, required this.vid,  required this.vehicleType,});
  @override
  _RazorPayIntegrationState createState() => _RazorPayIntegrationState();
}

class _RazorPayIntegrationState extends State<RazorPayIntegration> {
  final Razorpay _razorpay = Razorpay(); // Instance of razor pay
  final razorPayKey = dotenv.get("RAZOR_KEY");
  final razorPaySecret = dotenv.get("RAZOR_SECRET");
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
   void initState() {
    super.initState();
    openSession(amount: widget.selectedVehiclePrice);
    initiateRazorPay();
      Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
     scheduleDailyEarningReset();
  }

  initiateRazorPay() {
    // To handle different events with previous functions
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    print('cccccccccccccccc');
    String orderId = response.orderId!; // Assuming the orderId is part of the response

  // Show the QR code screen
  showQrCodeScreen(orderId);
    saveOrderId(orderId);
    
  // Update Firestore based on vehicleType
  if (widget.vehicleType == 'car') {
    updateCurrentField('currentCarFilled');
  } else if (widget.vehicleType == 'bike') {
    updateCurrentField('currentBikeFilled');
  }
}

void updateCurrentField(String fieldName) {
  // Update the specified field in Firestore
  FirebaseFirestore.instance
      .collection('vendors')
      .doc(widget.vid)
      .update({
    fieldName: FieldValue.increment(1),
  }).then((value) {
    // Update the local state or perform any other actions
    print('$fieldName updated successfully.');
  }).catchError((error) {
    print('Error updating $fieldName: $error');
  });

FirebaseFirestore.instance
      .collection('vendors')
      .doc(widget.vid)
      .get()
      .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    if (documentSnapshot.exists) {
      int existingDailyEarning = documentSnapshot.data()?['dailyEarning'] ?? 0;

      // Add the successful payment amount to the existing value
      int successfulPaymentAmount = widget.selectedVehiclePrice; // Replace this with the actual payment amount
      int newDailyEarning = existingDailyEarning + successfulPaymentAmount;

      // Update the dailyEarning field in Firestore with the new total
      FirebaseFirestore.instance
          .collection('vendors')
          .doc(widget.vid)
          .update({'dailyEarning': newDailyEarning})
          .then((value) {
        print('Daily Earning updated successfully.');
      }).catchError((error) {
        print('Error updating dailyEarning: $error');
      });
    }
  });


   scheduleDailyEarningReset();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }

  openSession({required num amount}) {

    createOrder(amount: widget.selectedVehiclePrice).then((orderId) {
      print(orderId);
      
      if (orderId.toString().isNotEmpty) {
        var options = {
          'key': razorPayKey, // Razorpay API Key
          'amount': 1 * 100, // in the smallest currency sub-unit.
          'name': 'ParkWiz',
          'order_id': orderId, // Generate order_id using Orders API
          'description': 'Description for order', // Order Description to be shown in Razorpay page
          'timeout': 60, // in seconds
          'prefill': {
            'contact': '8076827832',
            'email': '${loggedInUser.email}',
          } // contact number and email id of user
        };
        _razorpay.open(options);
      } else {}
    });
  }

  createOrder({required num amount}) async {
    final myData = await ApiServices().razorPayApi(amount, "rcp_id_1");
    if (myData["status"] == "success") {
      print(myData);
      return myData["body"]["id"];
    } else {
      return "";
    }
  }



  @override
  void dispose() {
    _razorpay.clear(); // Clear the Razorpay instance when disposing of the widget
    super.dispose();

  }
  void showQrCodeScreen(String orderId) async {
      print('Navigating to QrCodeScreen with orderId: $orderId');
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => QrCodeScreen(orderId: orderId, vid: widget.vid, vehicleType: widget.vehicleType),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
 
    );
  }
  
  void saveOrderId(String orderId) async {
  // Use the orderId as the document ID for the subcollection 'orderId'
  await _firestore.collection('vendors').doc(widget.vid).collection('orderId').doc(orderId).set({
    'orderId': orderId,
  });

  // Optionally, retrieve all orderId documents to dynamically update the fields (if needed)
  QuerySnapshot orderIdQuery = await _firestore.collection('vendors').doc(widget.vid).collection('orderId').get();

  // Optionally, update the fields dynamically (if needed)
  Map<String, dynamic> updatedFields = {};
  orderIdQuery.docs.asMap().forEach((index, doc) {
    updatedFields['orderId${index + 1}'] = doc['orderId'];
  });

  // Optionally, update the document with the dynamically generated fields (if needed)
  await _firestore.collection('vendors').doc(widget.vid).update(updatedFields);

  // Clear the text field after saving
 DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('users').doc(user?.uid);
  DocumentSnapshot<Map<String, dynamic>> vendorSnapshot =
      await _firestore.collection('vendors').doc(widget.vid).get();

  if (vendorSnapshot.exists) {
    String facilityName = vendorSnapshot.data()?['facilityName'] ?? '';
     DateTime currentDateTime = DateTime.now();
   await userDocRef.collection('orders').doc(orderId).set({
    'Facility': facilityName, // Replace with the actual facility name
    'selectedVehiclePrice': widget.selectedVehiclePrice,
    'VehicleType': widget.vehicleType,
     'DateTime': currentDateTime.toUtc(),
  }).then((value) {
    print('Order details saved successfully.');
  }).catchError((error) {
    print('Error saving order details: $error');
  });
  }
}
void resetDailyEarning() {
  FirebaseFirestore.instance
      .collection('vendors')
      .doc(widget.vid)
      .update({'dailyEarning': 0})
      .then((value) {
    print('Daily Earning reset to 0.');
  }).catchError((error) {
    print('Error resetting dailyEarning: $error');
  });
}

void scheduleDailyEarningReset() {
  // Get the current date and time
  DateTime now = DateTime.now();

  // Calculate the time until the next midnight
  DateTime midnight = DateTime(now.year, now.month, now.day + 1);
  Duration timeUntilMidnight = midnight.difference(now);

  // Schedule the resetDailyEarning function to run at midnight
  Timer(timeUntilMidnight, () {
    resetDailyEarning();

    // Reschedule the function for the next day
    scheduleDailyEarningReset();
  });
}
}
