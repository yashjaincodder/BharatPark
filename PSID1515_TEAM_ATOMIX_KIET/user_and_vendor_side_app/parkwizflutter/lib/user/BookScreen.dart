import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:parkwizflutter/model/vendor_model.dart';
import 'package:parkwizflutter/razorpay.dart';
import 'PremiumScreen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parkwizflutter/model/user_model.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
class BookScreen extends StatefulWidget {
  final String vid;

  const BookScreen({super.key, required this.vid});

  @override
  // ignore: library_private_types_in_public_api
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  VendorModel? vendor;
 int selectedVehiclePrice = 0; 
  String selectedVehicleType = '';
  String? imageUrl;
  double L = 46.5;
  double k = 6.50;
  double t0 = 0.71;
 User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
 final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  bool showRadioButtons = false;
  bool _isListening = false;
  String _transcription = '';

  @override

  @override
  void initState() {
    super.initState();
         _initSpeechRecognition();
    // Fetch data from Firestore using vid
     FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
   
    FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.vid)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      if (documentSnapshot.exists) {
        // Document exists in Firestore
        setState(() {
          vendor = VendorModel.fromMap(documentSnapshot.data()!);

           getImageUrl();
        });
      } else {
        // Document does not exist in Firestore
        print('Document does not exist on the database');
      }
    }).catchError((error) {
      print('Error getting document: $error');
    });
   Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        showRadioButtons = true;
      });
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
  
void _updateSelectedVehicle() {
  if (_transcription == 'car') {
    setState(() {
      selectedVehicleType = 'car';
      selectedVehiclePrice = int.parse('${vendor!.carBasePrice}');
    });
  } else if (_transcription == 'bike') {
    setState(() {
      selectedVehicleType = 'bike';
      selectedVehiclePrice = int.parse('${vendor!.bikeBasePrice}');
    });
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
            _transcription = result.recognizedWords.toLowerCase();
            _updateSelectedVehicle();
            selectedVehicleType = _transcription;
          });
          // Refresh the value of _isListening after completion
          _isListening = false;
        },
        listenFor: const Duration(seconds: 5),
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


 Future<void> getImageUrl() async {
    try {
      String fileName = '${vendor!.vid}.jpg';
      String storagePath = 'vendors/${vendor!.vid}/images/$fileName';

      final ref = FirebaseStorage.instance.ref().child(storagePath);

      // Get the download URL
      final url = await ref.getDownloadURL();

      setState(() {
        imageUrl = url;
      });
    } catch (e) {
      print('Error getting image URL: $e');
    }
  }
// You can set it to the default value you want


// ...

String _getLeastFilledHour() {
  if (vendor != null && vendor!.leastFilledDate != null) {
    // Convert timestamp to DateTime
    DateTime leastFilledDateTime =
        (vendor!.leastFilledDate as Timestamp).toDate();

    // Format DateTime to display in 12-hour format with AM/PM
    return DateFormat('h a').format(leastFilledDateTime);
  } else {
    return 'N/A';
  }
}

Widget _buildPriceComparisonText() {
  if (vendor!.carBasePrice! * 1.4 <= dynamicprice(vendor!.carBasePrice!.toInt())) {
    return Column(
      children: [
        const Text(
          'Prices are way too high due to traffic, here are better timings for you  : ',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.red,
          ),
        ),
        
        const SizedBox(height: 8), // Add some space between the two Text widgets
        Text(
          'AROUND ${_getLeastFilledHour()}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.green,
          ),
        ),
      ],
    );
  } else {
    return const SizedBox.shrink(); // Return an empty widget if the condition is not met
  }
}

  @override
  Widget build(BuildContext context) {

    // Check if vendor is null or not

double baseWidth = 360;
double fem = MediaQuery.of(context).size.width / baseWidth;
double ffem = fem * 0.97;
    // _listen();
    // print(_transcription);
    // _speak('Are You parking Car or Bike?');
     Future.delayed(const Duration(seconds: 7));
return Scaffold(
  body: SingleChildScrollView(
    child: Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xffecf4f4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         SizedBox(
               width: double.infinity,
            height: 420 * fem,
                child: imageUrl != null
                    ? Image.network(imageUrl!, fit: BoxFit.cover)
                    : const Placeholder(), // You can replace Placeholder with a loading indicator
              ),
          Padding(
            padding: EdgeInsets.all(20 * fem),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vendor!.facilityName}',
                  style: TextStyle(
                    fontSize: 18 * ffem,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff2a364e),
                  ),
                ),
                SizedBox(height: 8 * fem),
                Text(
                  '${vendor!.address}',
                  style: TextStyle(
                    fontSize: 14 * ffem,
                    fontWeight: FontWeight.w300,
                    color: const Color(0xff0f0f0f),
                  ),
                ),
                SizedBox(height: 20 * fem),
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 14 * ffem,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff2a364e),
                  ),
                ),
                  SizedBox(height: 8 * fem),
                    _buildPriceComparisonText(),
            SizedBox(height: 8 * fem),
                 Text(
                  '',
                  style: TextStyle(
                    fontSize: 14 * ffem,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff2a364e),
                  ),
                ),
                SizedBox(height: 8 * fem),
                
                
                if(showRadioButtons)  ////////////////////////////////////////////////////////
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
           
                  children: [
                    Text(
                      'FOUR WHEELER',
                      style: TextStyle(
                        fontSize: 14 * ffem,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff2a364e),
                      ),
                    ),
      Row(
        
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
                 Radio(
          value: int.parse('${vendor!.carBasePrice}'),
          groupValue: selectedVehiclePrice,
          onChanged: (int? value) {
            setState(() {
            selectedVehiclePrice = value!;
      selectedVehicleType = 'car';
            });
          },
        ),
                    Text(
                      '₹ ${dynamicprice(vendor!.carBasePrice!.toInt())}    ',
                      style: TextStyle(
                        fontSize: 14 * ffem,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff2a364e),
                      ),
                    ),
                    
                       const Icon(
              Icons.directions_car, // Use the discount icon you prefer
             
              color: Colors.black, // Customize the icon color
            ),
        ]
      )
                  ],
                ),
                SizedBox(height: 2 * fem),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TWO WHEELER',
                      style: TextStyle(
                        fontSize: 14 * ffem,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff2a364e),
                      ),
                    ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                          Radio(
          value: int.parse('${vendor!.bikeBasePrice}'),
          groupValue: selectedVehiclePrice,
          onChanged: (int? value) {
            setState(() {
              selectedVehiclePrice = value!;
                selectedVehicleType = 'bike'; 
            });
          },
        ),
                    Text(
                      '₹ ${dynamicprice(vendor!.bikeBasePrice!.toInt())}    ',
                      style: TextStyle(
                        fontSize: 14 * ffem,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff2a364e),
                      ),
                    ),

                            const Icon(
              Icons.directions_bike, // Use the discount icon you prefer
             
              color: Colors.black, // Customize the icon color
            ),
                        ],)
                  ],
                ),
                SizedBox(height: 20 * fem),
                Center(
  child: Container(
    margin: EdgeInsets.fromLTRB(4 * fem, 0 * fem, 0 * fem, 0 * fem),
    width: 306 * fem,
    height: 52 * fem,
    child: ElevatedButton(
      onPressed: () {
        // Add your logic here
        if (selectedVehiclePrice!=0){
       Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RazorPayIntegration(selectedVehiclePrice: dynamicprice(selectedVehiclePrice), vid: widget.vid,  vehicleType: selectedVehicleType,)),
    );
        }
        else{
           Fluttertoast.showToast(
      msg: "Choose one option",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black.withOpacity(0.8),
      textColor: Colors.white,
      fontSize: 16.0,
    );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xfff5c116),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9 * fem),
        ),
      ),
      child: Text(
        'BOOK NOW',
        style: TextStyle(
          fontSize: 24 * ffem,
          fontWeight: FontWeight.w400,
          color: const Color(0xfffffdfd),
        ),
      ),
    ),
  ),
),

                SizedBox(height: 12 * fem),
            Center(
  child: TextButton(
    onPressed: () { 
  Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PremiumScreen()),
    );
    },
    style: TextButton.styleFrom(padding: EdgeInsets.zero),
    child: Text(
      'Upgrade to Premium Membership for Exclusive Parking Benefits!',
      style: TextStyle(
        fontSize: 10 * ffem,
        fontWeight: FontWeight.w300,
        color: const Color(0xff0f0f0f),
      ),
    ),
  ),
),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);

  }
int dynamicprice(int selectedVehiclePrice) {
  // Given parameters
  double L = 46.5;
  double k = 6.50;
  double t0 = 0.71;
  double occupancy = double.parse('${vendor!.currentFilled}')/double.parse('${vendor!.maxCapacity}');
  
   double exponentialTerm = exp(-k * (occupancy - t0));
  double currentPrice = L / (1 + exponentialTerm) + selectedVehiclePrice;
  if (loggedInUser.subscription == 'Basic'){
    return currentPrice.toInt();
  }
  else if(loggedInUser.subscription == 'Premium'){
   return (currentPrice*0.9).toInt();
  }
    return currentPrice.toInt();
  }
}

