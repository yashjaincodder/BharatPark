// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'dart:async';
import 'package:parkwizflutter/apiservice.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkwizflutter/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RazorPayIntegration extends StatefulWidget {

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
    openSession(amount: 120 );
    initiateRazorPay();
      Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
   
  }

  initiateRazorPay() {
    // To handle different events with previous functions
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds


  // Show the QR code screen
  print('Payment Success');
    updateSubscriptionInFirestore("Premium"); // Update subscription to "Premium"

    // Schedule a task to change the subscription to "Basic" after 2 minutes
    Timer(const Duration(days: 30), () {
      updateSubscriptionInFirestore("Basic");
    });
 
    
  // Update Firestore based on vehicleType

}



  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }

  openSession({required num amount}) {

    createOrder(amount: 120).then((orderId) {
      print(orderId);
      
      if (orderId.toString().isNotEmpty) {
        var options = {
          'key': razorPayKey, // Razorpay API Key
          'amount': 1 * 100, // in the smallest currency sub-unit.
          'name': 'ParkWiz',
          'order_id': orderId, // Generate order_id using Orders API
          'description': 'PREMIUM SUBSCRIPTION', // Order Description to be shown in Razorpay page
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


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
 
    );
  }
   Future<void> updateSubscriptionInFirestore(String subscriptionType) async {
    try {
      await _firestore.collection('users').doc(user!.uid).update({
        'subscription': subscriptionType,
      });
      print('Subscription updated to $subscriptionType');
    } catch (e) {
      print('Error updating subscription: $e');
    }
  }



}
