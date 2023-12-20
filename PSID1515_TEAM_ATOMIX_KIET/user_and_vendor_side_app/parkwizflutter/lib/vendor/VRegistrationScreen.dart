import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'VLoginScreen.dart';
import 'VHomeScreen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parkwizflutter/model/vendor_model.dart';

class VendorRegistrationScreen extends StatefulWidget {
  const VendorRegistrationScreen({Key? key}) : super(key: key);

  @override
  _VendorRegistrationScreenState createState() =>
      _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen> {
  final _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();

  final facilityNameEditingController = TextEditingController();
  final ownerNameEditingController = TextEditingController();
  final emailEditingController = TextEditingController();
  final maxCapacityEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
  final confirmPasswordEditingController = TextEditingController();
  final currentFilledEditingController = TextEditingController();
  final addressEditingController = TextEditingController();
  final aadhaarEditingController = TextEditingController();
  final bikeCapacityEditingController = TextEditingController();
  final carCapacityEditingController = TextEditingController();
  final bikeBasePriceEditingController = TextEditingController();
  final carBasePriceEditingController = TextEditingController();
  final vendorTypeEditingController = TextEditingController(text: 'Commercial Parking');

  @override
  Widget build(BuildContext context) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;


    //first name field
    final facilityNameField =  Material( 
      child:TextFormField(
      autofocus: false,
      controller: facilityNameEditingController,
      keyboardType: TextInputType.text,
      //validator: () {},
      onSaved: (value) 
      {
        facilityNameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.account_circle),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Facility Name",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          )
      )
    ),
    );

 //last name field
    final ownerNameField = Material( 
      child:TextFormField(
      autofocus: false,
      controller: ownerNameEditingController,
      keyboardType: TextInputType.text,
      //validator: () {},
      onSaved: (value) 
      {
        ownerNameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.account_circle),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Owner Name",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          )
      )
    ),
    );
   
      //email field
    final emailField = Material( 
      child:TextFormField(
      autofocus: false,
      controller: emailEditingController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if(value!.isEmpty)
        {
          return("Please Enter your Email");
        }
        // reg exp for email veri
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9+_.-]+.[a-z]").hasMatch(value))
        {
          return ("Please enter a valid email");
        }
        return null;
      },
      onSaved: (value) 
      {
        emailEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.mail),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Email",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          )
      )
    ),
    );

final vendorTypeField = Material(
  child: DropdownButtonFormField<String>(
    value: vendorTypeEditingController.text,
    onChanged: (String? newValue) {
      vendorTypeEditingController.text = newValue!;
    },
    items: const [
      DropdownMenuItem(
        value: 'Commercial Parking',
        child: Text('Commercial Parking'),
      ),
      DropdownMenuItem(
        value: 'Residential Parking',
        child: Text('Residential Parking'),
      ),
      DropdownMenuItem(
        value: 'Off Street Parking',
        child: Text('Off Street Parking'),
      ),
    ],
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.directions_car),
      contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      hintText: "Vendor Type",
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),
);
      //password field
    final passwordField = Material( 
      child:TextFormField(
      autofocus: false,
      controller: passwordEditingController,
      obscureText: true,
      validator: (value) {
        RegExp regex = RegExp(r'^.{6,}$');
        if(value!.isEmpty)
        {
          return("Password is Required");
        }
        if(!regex.hasMatch(value))
        {
          return("Please Enter Valid Password (Min 6 char)");
        }
        return null;
      },
      onSaved: (value) 
      {
        passwordEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.vpn_key),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Password",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          )
      )
    ),
    );

        //confirm password field
    final confirmPasswordField = Material( 
      child:TextFormField(
      autofocus: false,
      controller: confirmPasswordEditingController,
      obscureText: true,
      
      validator: (value) {
        if(confirmPasswordEditingController.text != passwordEditingController.text)
        {
          return("Password dont Match");
        }
        return null;
      },
      onSaved: (value) 
      {
        confirmPasswordEditingController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.vpn_key),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Confirm Password",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          )
      )
    ),
    );

    //bikeCapacity field
    final bikeCapacityField = Material(
      child: TextFormField(
        autofocus: false,
        controller: bikeCapacityEditingController,
        keyboardType: TextInputType.number,
        onSaved: (value) {
          bikeCapacityEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.motorcycle),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Bike Capacity",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );

    //carCapacity field
    final carCapacityField = Material(
      child: TextFormField(
        autofocus: false,
        controller: carCapacityEditingController,
        keyboardType: TextInputType.number,
        onSaved: (value) {
          carCapacityEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.car_repair),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Car Capacity",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );

    //bikeBasePrice field
    final bikeBasePriceField = Material(
      child: TextFormField(
        autofocus: false,
        controller: bikeBasePriceEditingController,
        keyboardType: TextInputType.number,
        onSaved: (value) {
          bikeBasePriceEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.money),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Bike Base Price",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );

    //carBasePrice field
    final carBasePriceField = Material(
      child: TextFormField(
        autofocus: false,
        controller: carBasePriceEditingController,
        keyboardType: TextInputType.number,
        onSaved: (value) {
          carBasePriceEditingController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.money),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Car Base Price",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );

// Aadhaar field
final aadhaarField = Material(
  child: TextFormField(
    autofocus: false,
    controller: aadhaarEditingController,
    keyboardType: TextInputType.text,
    onSaved: (value) {
      aadhaarEditingController.text = value!;
    },
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.credit_card),
      contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      hintText: "Aadhaar",
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),
);

// Address field
final addressField = Material(
  child: TextFormField(
    autofocus: false,
    controller: addressEditingController,
    keyboardType: TextInputType.text,
    onSaved: (value) {
      addressEditingController.text = value!;
    },
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.location_on),
      contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      hintText: "Address",
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),
);
    //sign up button
    final signUpButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: const Color.fromARGB(255, 69, 136, 229),
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          signUp(emailEditingController.text, passwordEditingController.text);
        },
        child: const Text(
          "Sign Up",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    // ... (Existing code)

return Center(
  child: SizedBox(
    width: double.infinity,
    height: double.infinity,
    child: Container(
      padding: EdgeInsets.fromLTRB(0 * fem, 20* fem, 0 * fem, 0 * fem),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 69, 136, 229),
      ),
      child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(24 * fem, 0 * fem, 0 * fem, 10 * fem),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
               child: SizedBox(
                      width: 200 * fem,
                      height: 200 * fem,
                      child: Image.asset(
                        'assets/userNew.png',
                        width: 200 * fem,
                        height: 200 * fem,
                      ),
                    ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0 * fem, 10 * fem, 0 * fem, 0 * fem),
            width: 461 * fem,
           
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff000000)),
              color: const Color(0xffffffff),
              borderRadius: BorderRadius.circular(60 * fem),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x3f000000),
                  offset: Offset(0 * fem, 4 * fem),
                  blurRadius: 2 * fem,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(10 * fem, 0 * fem, 0 * fem, 10 * fem),

                  child: Center(
                    child: Column(
                      children: [
                 SizedBox(
  width: double.infinity,
  height: 43 * fem,
  child: Text(
    'REGISTER NOW',
    textAlign: TextAlign.center,
    style: GoogleFonts.hind(
        
      textStyle: const TextStyle(
        color: Color.fromARGB(255, 54, 3, 70),
        fontSize: 30,
      ),
    ),
  ),
),
                    
                        Container(
                          padding: EdgeInsets.all(16*fem),
                     
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const SizedBox(height: 20),
                                facilityNameField,
                                const SizedBox(height: 20),
                                ownerNameField,
                                const SizedBox(height: 20),
                                emailField,
                                const SizedBox(height: 20),
                                vendorTypeField,
                                const SizedBox(height: 20),
                                passwordField,
                                const SizedBox(height: 20),
                                confirmPasswordField,
                                const SizedBox(height: 20),
                                addressField,
                                const SizedBox(height: 20),
                                aadhaarField,
                                const SizedBox(height: 20),
                                bikeCapacityField,
                                const SizedBox(height: 20),
                                carCapacityField,
                                const SizedBox(height: 20),
                                bikeBasePriceField,
                                const SizedBox(height: 20),
                                carBasePriceField,
                                const SizedBox(height: 20),
                                signUpButton,
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const VendorLoginScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    " Vendor Sign In",
                                    style: TextStyle(
                                      color: Color(0xff2a364e),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
  ),
);


  }

  // ... (Existing code)

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {postDetailsToFirestore()})
          // ignore: body_might_complete_normally_catch_error
          .catchError((e) {
        Fluttertoast.showToast(msg: e!.message);
      });
    }
  }

  Future<Position> getLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print("Error getting location: $e");
      throw Exception("Error getting location");
    }
  }

    Future<void> postDetailsToFirestore() async {
    try {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      User? vendor = _auth.currentUser;

      if (vendor == null) {
        throw Exception("User not signed in");
      }

      Position position = await getLocation();
      GeoPoint location = GeoPoint(position.latitude, position.longitude);

   int bikeCapacity = int.tryParse(bikeCapacityEditingController.text) ?? 0;
    int carCapacity = int.tryParse(carCapacityEditingController.text) ?? 0;
    int bikeBasePrice = int.tryParse(bikeBasePriceEditingController.text) ?? 0;
    int carBasePrice = int.tryParse(carBasePriceEditingController.text) ?? 0;

    VendorModel vendorModel = VendorModel(
      vid: vendor.uid,
      email: vendor.email,
      facilityName: facilityNameEditingController.text,
      ownerName: ownerNameEditingController.text,
      location: location,
      address: addressEditingController.text,
      aadhaar: aadhaarEditingController.text,
      bikeCapacity: bikeCapacity,
      carCapacity: carCapacity,
      bikeBasePrice: bikeBasePrice,
      carBasePrice: carBasePrice,
      vendorType: vendorTypeEditingController.text,
      
    );


      await firebaseFirestore
          .collection("vendors")
          .doc(vendor.uid)
          .set(vendorModel.toMap());

      Fluttertoast.showToast(msg: "Account created Successfully!");

      Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(builder: (context) => const VendorHomeScreen()),
        (route) => false,
      );
    } catch (e) {
      print("Error during registration: $e");
      Fluttertoast.showToast(msg: "Error during registration");
    }
  }
}
