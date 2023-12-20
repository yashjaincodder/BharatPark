import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:parkwizflutter/widgets/custom_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: use_key_in_widget_constructors
class OrderHistory extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
  if (user == null) {
  // Handle the case where the user is not logged in
  return const Scaffold(
    body: Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
      ),
    ),
  );
}

    return Scaffold(
      appBar: const CustomAppBar(customHeight: 62),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16), // Add space after the app bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[300], // Gray color for the banner
            child: Text(
              'USER HISTORY',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 15), // Add some space between the banner and the list
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .collection('orders')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No orders found.'),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var orderData = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                    // Customize the icons based on VehicleType
                    IconData vehicleIcon =
                        orderData['VehicleType'] == 'car' ? Icons.directions_car : Icons.directions_bike;

                    // Format DateTime
                    DateTime orderDateTime = orderData['DateTime'].toDate();
                    String formattedDateTime = DateFormat.yMMMMd().add_jm().format(orderDateTime);

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 254, 248, 254), // Replace with your desired color
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color.fromARGB(255, 55, 16, 132), width: 2),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.person_3_rounded),
                        title: Text(
                          orderData['Facility'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          formattedDateTime,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(vehicleIcon),
                            const SizedBox(width: 8),
                            Text(
                              '₹${orderData['selectedVehiclePrice']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Handle tile tap if needed
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
