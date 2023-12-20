import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkwizflutter/model/vendor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:parkwizflutter/user/ContactScreen.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  _VendorHomeScreenState createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  User? vendor = FirebaseAuth.instance.currentUser;
  VendorModel loggedInVendor = VendorModel();
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("vendors")
        .doc(vendor!.uid)
        .get()
        .then((value) {
      loggedInVendor = VendorModel.fromMap(value.data());
      setState(() {});
    });
      
  }

Future<void> _uploadImage() async {
  // Open image picker
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    File imageFile = File(pickedFile.path);
    String fileName = '${vendor!.uid}.jpg';
    String storagePath = 'vendors/${vendor!.uid}/images/$fileName';

    try {
      // Upload image to Firebase Storage
      await FirebaseStorage.instance.ref(storagePath).putFile(imageFile);

      // Optionally, you can save the image URL to Firestore for future retrieval
      String imageUrl = await FirebaseStorage.instance.ref(storagePath).getDownloadURL();

      // Display success message or perform additional logic
      print('Image uploaded successfully. Image URL: $imageUrl');
       Fluttertoast.showToast(
      msg: 'Image Uploaded Succesfully.',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green.withOpacity(0.8), // You can customize the background color
      textColor: Colors.white, // You can customize the text color
      fontSize: 16.0,
    );
    } catch (error) {
      // Handle errors
      print('Error uploading image: $error');
    }
  }
}
void updateLeastFilled() {
  DateTime now = DateTime.now();
  DateTime startTime = DateTime(now.year, now.month, now.day, 8, 0, 0);
  DateTime endTime = DateTime(now.year, now.month, now.day, 23, 0, 0);

  if ((loggedInVendor.currentFilled! < loggedInVendor.leastFilled!) &&
      (now.isAfter(startTime) && now.isBefore(endTime))) {
    // Update leastFilled and leastFilledDate
    loggedInVendor.leastFilled = loggedInVendor.currentBikeFilled;
    loggedInVendor.leastFilledDate = Timestamp.fromDate(now);

    // Increment changeCounter when the date changes
    if (loggedInVendor.lastVisitDate == null ||
        loggedInVendor.lastVisitDate?.toDate().day != now.day) {
      loggedInVendor.changeCounter = (loggedInVendor.changeCounter ?? 0) + 1;
    }

    // Update the changes to Firestore
    FirebaseFirestore.instance
        .collection("vendors")
        .doc(vendor!.uid)
        .update({
      'leastFilled': loggedInVendor.leastFilled,
      'leastFilledDate': loggedInVendor.leastFilledDate,
      'changeCounter': loggedInVendor.changeCounter,
    }).then((_) {
      // Update the local state to reflect the change
      setState(() {});
    }).catchError((error) {
      print("Error updating Firestore document: $error");
    });
  }
}

 Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    
    // Platform messages may fail, so we use a try/catch PlatformException.
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.QR,
    );
 
    await FirebaseFirestore.instance
        .collection("vendors")
        .doc(vendor!.uid)
        .collection("orderId")
        .doc(barcodeScanRes)
        .get()
        .then((orderSnapshot) async {
      if (orderSnapshot.exists) {
        // Your existing code...

        await FirebaseFirestore.instance
            .collection("vendors")
            .doc(vendor!.uid)
            .update({})
            .then((_) {
          // Update the local state to reflect the change
          setState(() {
          });

          // Check if it's a new day
          DateTime currentDate = DateTime.now();
          DateTime lastVisitDate =
              (loggedInVendor.lastVisitDate!.toDate())
                  .toLocal(); // Convert to local timezone

          if (currentDate.day != lastVisitDate.day ||
              currentDate.month != lastVisitDate.month ||
              currentDate.year != lastVisitDate.year) {
            // If it's a new day, reset TodayVisit to 1 and update lastVisitDate
            FirebaseFirestore.instance
                .collection("vendors")
                .doc(vendor!.uid)
                .update({
              'TodayVisit': 1,
              'lastVisitDate': FieldValue.serverTimestamp(),
            }).then((_) {
              // Update the local state to reflect the change
              setState(() {
                loggedInVendor.TodayVisit = 1;
                loggedInVendor.lastVisitDate = currentDate as Timestamp?;
              });
            }).catchError((error) {
              print("Error resetting TodayVisit: $error");
            });
          }
        }).catchError((error) {
          print("Error updating TodayVisit: $error");
        });

        // Your existing code...
      } else {
        Fluttertoast.showToast(
          msg: "ORDER ID NOT FOUND: \nEntry Chargeable as per Current Rate",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }).catchError((error) {
      print("Error checking orderId: $error");
    });
///////////////////////////////////////////////////////////


  await FirebaseFirestore.instance
      .collection("vendors")
      .doc(vendor!.uid)
      .collection("orderId")
      .doc(barcodeScanRes)
      .get()
      .then((orderSnapshot) async {
    if (orderSnapshot.exists) {
      // Check if EntryTime field exists
      bool entryTimeExists =
          orderSnapshot.data()?['EntryTime'] != null;

      // Get the current device time
      DateTime currentTime = DateTime.now();

      if (!entryTimeExists) {
        // If EntryTime field doesn't exist, create it and save the current time
        await FirebaseFirestore.instance
            .collection("vendors")
            .doc(vendor!.uid)
            .collection("orderId")
            .doc(barcodeScanRes)
            .update({
          'EntryTime': currentTime,
        });
 Fluttertoast.showToast(
      msg: 'TOKEN VERIFIED:\nProceed to Parking',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green, // You can customize the background color
      textColor: Colors.white, // You can customize the text color
      fontSize: 16.0,
    );
        await FirebaseFirestore.instance
            .collection("vendors")
            .doc(vendor!.uid)
              .update({
          'TodayVisit': FieldValue.increment(1),
        }).then((_) {
          // Update the local state to reflect the change
          setState(() {
            loggedInVendor.TodayVisit = (loggedInVendor.TodayVisit ?? 0) + 1; 
          });
        });

         await FirebaseFirestore.instance
            .collection("vendors")
            .doc(vendor!.uid)
            .update({
          'vehicleEntryRate': FieldValue.increment(1), // Increment the field by 1
        });
          Timer.periodic(Duration(minutes: 1), (timer) async { //SET timer here to control Dynamic Pricing as per Vehicle Entry Rate
          await FirebaseFirestore.instance
              .collection("vendors")
              .doc(vendor!.uid)
              .update({
            'vehicleEntryRate': 0, // Reset the field to 0
          });
          timer.cancel(); // Cancel the timer after resetting the value
        });

      } else {
        // If EntryTime field exists, perform the additional tasks
Timestamp entryTimeTimestamp = orderSnapshot.data()?['EntryTime'];
DateTime entryTime = entryTimeTimestamp.toDate();

        // Calculate the difference in hours
        int hoursDifference =
            currentTime.difference(entryTime).inHours;

        if (hoursDifference > 4) {
          // Show FlutterToast message
          Fluttertoast.showToast(
            msg: "Pay more!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );

          // Decrement the value of currentBikeFilled by on
        }

       Fluttertoast.showToast(
      msg: 'Session COMPLETE !',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blue, // You can customize the background color
      textColor: Colors.white, // You can customize the text color
      fontSize: 16.0,
    );
  // Decrement the value of currentBikeFilled by one
// Retrieve the value of VehicleType from Firestore
DocumentSnapshot<Map<String, dynamic>> orderSnapshotF = await FirebaseFirestore.instance
    .collection("vendors")
    .doc(vendor!.uid)
    .collection("orderId")
    .doc(barcodeScanRes)
    .get();

if (orderSnapshotF.exists) {
  String vehicleType = orderSnapshotF.data()?['VehicleType'];

  // Determine which field to decrement based on the value of VehicleType
  String fieldToUpdate;
  if (vehicleType == 'bike') {
    fieldToUpdate = 'currentBikeFilled';
      updateLeastFilled();
  } else if (vehicleType == 'car') {
    fieldToUpdate = 'currentCarFilled';
      updateLeastFilled();
  } else {
    // Handle other cases if needed
    return;
  }

  // Perform the decrement operation
  await FirebaseFirestore.instance
      .collection("vendors")
      .doc(vendor!.uid)
      .update({
        fieldToUpdate: FieldValue.increment(-1),
      }).then((_) {
        // Update the local state to reflect the change
        setState(() {
          if (fieldToUpdate == 'currentBikeFilled') {
            loggedInVendor.currentBikeFilled =
                (loggedInVendor.currentBikeFilled ?? 0) > 0
                    ? (loggedInVendor.currentBikeFilled ?? 0) - 1
                    : 0;
          } else if (fieldToUpdate == 'currentCarFilled') {
            loggedInVendor.currentCarFilled =
                (loggedInVendor.currentCarFilled ?? 0) > 0
                    ? (loggedInVendor.currentCarFilled ?? 0) - 1
                    : 0;
          }
        });
      }).catchError((error) {
        print("Error updating $fieldToUpdate: $error");
      });
}
   await FirebaseFirestore.instance
        .collection("vendors")
        .doc(vendor!.uid)
        .collection("orderId")
        .doc(barcodeScanRes)
        .delete()
        .then((value) {
      print("Sub-document deleted successfully");
    }).catchError((error) {
      print("Error deleting sub-document: $error");
    });
      }
    } else {
      print("Order ID not found");
    }
  }).catchError((error) {
    print("Error checking orderId: $error");
  });


     setState(() {
    textController.text = barcodeScanRes;
  });
  }
 void updateMonThurHour() {
    DateTime now = DateTime.now();
  DateTime dateTime = loggedInVendor.leastFilledDate!.toDate();
    if (loggedInVendor.lastVisitDate == null) {
      // Update MonThurHour only if lastVisitDate is null or the date has changed

      // Get the hour from leastFilledDate (or another timestamp field)
      String hourKey = DateFormat('HH').format(dateTime);

      // Update the MonThurHour map
      loggedInVendor.monThurHour ??= {}; // Initialize the map if it's null
      loggedInVendor.monThurHour![hourKey] = (loggedInVendor.monThurHour![hourKey] ?? 0) + 1;

      // Update the lastVisitDate
      loggedInVendor.lastVisitDate = now as Timestamp?;

      // TODO: Update other fields or push the changes to Firestore if needed
    }
  }

  // factory VendorModel.fromMap(map) {
  //   return VendorModel(
  //     // Other fields...
  //     monThurHour: map['MonThurHour'] != null
  //         ? Map<String, int>.from(map['MonThurHour'])
  //         : null,
  //     lastVisitDate: map['lastVisitDate'] != null
  //         ? (map['lastVisitDate'] as Timestamp).toDate()
  //         : null,
  //   );
  // }
  @override
  Widget build(BuildContext context) {
      bool isOffStreetParking = loggedInVendor.vendorType == 'Off Street Parking';
    return Scaffold(
      appBar: CustomAppBar(
        name: '${loggedInVendor.facilityName}',
        details: '${loggedInVendor.ownerName}',
          uploadImage: _uploadImage,
           isOffStreetParking: isOffStreetParking,
        onBlackListPressed: _openCameraAndUploadImage,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Part
            Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Heading
          const Text(
            "Welcome ParkWizard!",
            style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.w800,
              color: Color.fromARGB(255, 55, 20, 152), // Adjust the color as needed
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            "Let's get to work",
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Colors.black, // Adjust the color as needed
            ),
          ),
          const SizedBox(height: 30.0),
            Container(
            width: 200.0, // Adjust the width as needed
            height: 190.0, // Adjust the height as needed
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/wiz.png'), // Provide the path to your image
                fit: BoxFit.cover, // Adjust the BoxFit property as needed
              ),
              borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
            ),
          ),
          // Button with Icon
          ElevatedButton.icon(
            
            onPressed: () {
              // Add your logic for scanning here
           scanBarcodeNormal();
            },
            icon: const Icon(Icons.qr_code),
            label: const Text("SCAN NOW",
            style: TextStyle(
              fontSize: 20
            ),),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.blue, // Adjust the text color as needed
              shape: RoundedRectangleBorder(
              
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 16.0, // Increase the vertical padding
                horizontal: 32.0, // Increase the horizontal padding
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (isOffStreetParking)
                          ElevatedButton.icon(
                            onPressed: _openCameraAndUploadImage,
                            icon: const Icon(Icons.camera),
                            label: const Text("BLACKLIST",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.black, // Adjust the text color as needed
              shape: RoundedRectangleBorder(
              
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 10.0, // Increase the vertical padding
                horizontal: 22.0, // Increase the horizontal padding
              ),
            ),
                            // ...
                          ),
                 const SizedBox(height: 20.0),
        ],
      ),
    ),

            // Bottom Part 
            Container(
           
             
              height: MediaQuery.of(context).size.height * 0.5,
               decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                   topLeft: Radius.circular(20.0), 
                topRight: Radius.circular(20.0), 
              ), 
            color: Color.fromARGB(255, 55, 16, 132),
            ),
              child: Center(
                child:    Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                     Container(
      width: 150.0,
      height: 150.0,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 222, 214, 223).withOpacity(0.4),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text(
              'SLOTS FILLED',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 25.0),
           Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Icon(
      Icons.pie_chart,
      color: Color.fromARGB(255, 70, 243, 75),
    ),
     const SizedBox(width: 4.0), // Adjust the spacing as needed
    Text(
      '${loggedInVendor.currentFilled} / ${loggedInVendor.maxCapacity}',
      style:  const TextStyle(
        fontSize: 16.0,
        color: Colors.white,
      ),
    ),
  ],
),

          ],
        ),
      ),
    ),
                       Container(
      width: 150.0,
      height: 150.0,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 222, 214, 223).withOpacity(0.4),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child:  Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CURRENT RATE',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
           Row(
  children: [
    // Icon for car
    const Icon(
      Icons.directions_car,
      color: Color.fromARGB(255, 21, 4, 88),
    ),
    const SizedBox(width: 9.0), // Adjust the spacing as needed
    Text(
      '₹ ${dynamicprice(loggedInVendor.carBasePrice!.toInt())}',
      style: const TextStyle(
        fontSize: 16.0,
        color: Colors.white,
      ),
    ),
  ],
),
const SizedBox(height: 8.0), // Adjust the vertical spacing as needed
Row(
  children: [
    // Another icon with text
    const Icon(
      Icons.directions_bike,
      color: Color.fromARGB(255, 230, 207, 6),
    ),
    const SizedBox(width: 9.0), // Adjust the spacing as needed
    Text(
      '₹ ${dynamicprice(loggedInVendor.bikeBasePrice!.toInt())}',
      style: const TextStyle(
        fontSize: 16.0,
        color: Colors.white,
      ),
    ),
  ],
),

          ],
        ),
      ),
    ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                        Container(
      width: 150.0,
      height: 150.0,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 222, 214, 223).withOpacity(0.4),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DAILY EARNING',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15.0),
           
           Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Icon(
      Icons.currency_rupee_sharp,
      color: Colors.amber,
      size: 28,
    ),
    const SizedBox(width: 2.0), // Adjust the spacing as needed
    Text(
      ' ${loggedInVendor.dailyEarning}',
      style: const TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
  ],
),
          ],
        ),
      ),
    ),
                        Container(
      width: 150.0,
      height: 150.0,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 222, 214, 223).withOpacity(0.4),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TODAY\'s VISITS',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 11.0),
                    Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Icon(
      Icons.login,
      color: Colors.redAccent,
      size: 28,
    ),
    const SizedBox(width: 4.0), // Adjust the spacing as needed
    Text(
      ' ${loggedInVendor.TodayVisit}',
      style: const TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
  ],
),
          ],
        ),
      ),
    ),
                    ],
                  ),
                ],
              ),
            ),

              ),
            ),
          ],
        ),
      ),
    );
  }
  int dynamicprice(int selectedVehiclePrice) {
  // Given parameters
  double L = 46.5;
  double k = 6.50;
  double t0 = 0.71;
  double occupancy = double.parse('${loggedInVendor.currentFilled}')/double.parse('${loggedInVendor.maxCapacity}');
  
   double exponentialTerm = exp(-k * (occupancy - t0));
  double currentPrice = L / (1 + exponentialTerm) + selectedVehiclePrice;
  return currentPrice.toInt();

  }
  
  Future<void> _openCameraAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String fileName = '${DateTime.now().toLocal()}.jpg'; // Use current date and time for filename
      String storagePath = 'vendors/${vendor!.uid}/blacklist/$fileName';

      try {
        // Upload image to Firebase Storage
        await FirebaseStorage.instance.ref(storagePath).putFile(imageFile);

        // Display success message or perform additional logic
        print('Image uploaded successfully to $storagePath');
      } catch (error) {
        // Handle errors
        print('Error uploading image: $error');
      }
    }
  }

  // ...

}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String details;
   final VoidCallback uploadImage; 
     final bool isOffStreetParking;
  final VoidCallback? onBlackListPressed;
  const CustomAppBar({
    Key? key,
    required this.name,
    required this.details,
    required this.uploadImage,
    required this.isOffStreetParking,
    this.onBlackListPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 55, 16, 132),
      foregroundColor: Colors.white,
      title: const Text('ParkWiz'),
      actions: [
        PopupMenuButton(
          itemBuilder: (context) {
            return [
              PopupMenuItem(

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    Text(
                      details,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  title: const Text('ADD IMAGE'),
                  onTap: () {
                    // Add navigation logic for Option 1
                  uploadImage();
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  title: const Text('YOUR DETAILS'),
                  onTap: () {
                    // Add navigation logic for Option 2
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  title: const Text('SUPPORT'),
                  onTap: () {
                    // Add navigation logic for Option 
                    // 3
          Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ContactUsPage()),
    );
                  },
                ),
              ),
              
            ];
          },
        ),
         if (isOffStreetParking)
          IconButton(
            onPressed: onBlackListPressed,
            icon: const Icon(Icons.camera),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}