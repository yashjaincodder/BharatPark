
// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parkwizflutter/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'PremiumRazor.dart';
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});


  @override
  
  _PremiumScreenState createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  Position? userLocation;

  @override
  void initState() {
    super.initState();

    // Get the user's current location
    Geolocator.getCurrentPosition().then((position) {
      setState(() {
        userLocation = position;
      });
    });

    // Fetch user data from Firestore
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data() as Map<String, dynamic>);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
  
    double baseWidth = 360;
double fem = MediaQuery.of(context).size.width / baseWidth;
double ffem = fem * 0.97;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 55, 16, 132),
      ),
      body:SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 145,
            width: double.infinity,
            color: const Color.fromARGB(255, 55, 16, 132),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    color: Color.fromARGB(255, 55, 16, 132),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.scaleDown,
                        image: AssetImage('assets/logo.png'),
                      ),
                    ),
                    width: 90,
                    height: 70,
                  ),
                ),
                Text(
                  '${loggedInUser.firstName} ${loggedInUser.lastName} ',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '${loggedInUser.subscription}  ',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amber),
                ),
            
              ],
            ),
          ),
         Container( /////////////////////////////////////////////////////////
  padding: EdgeInsets.fromLTRB(0*fem, 5*fem, 0*fem, 0*fem),
  width: double.infinity,
  decoration: const BoxDecoration(
    color: Color(0xffffe76d),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 3*fem),
        width: double.infinity,
        height: 50*fem,
        child: Stack(
          children: [
            Align(
              child: SizedBox(
                width: 32*fem,
                height: 0*fem,
                
              ),
            ),
            
            Align(
              child: SizedBox(
                width: 360*fem,
                height: 64*fem,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xffffe76d),
                  ),
                ),
              ),
            ),
            Center(
              child: Align(
                child: SizedBox(
                  width: 197*fem,
                  height: 48*fem,
                  child: Text(
                    'PREMIUM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        
                      fontSize: 32*ffem,
                      fontWeight: FontWeight.w700,
                      height: 1.5*ffem / fem,
                      color: const Color(0xff2a364e),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xffffffff),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(19.5*fem, 20*fem, 19.5*fem, 11*fem),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
               Container(
  margin: EdgeInsets.fromLTRB(40.5 * fem, 0 * fem, 58.5 * fem, 30 * fem),
  padding: EdgeInsets.fromLTRB(7 * fem, 7 * fem, 10 * fem, 7 * fem),
  width: double.infinity,
  decoration: BoxDecoration(
    color: const Color(0xffd9d9d9),
    borderRadius: BorderRadius.circular(23 * fem),
  ),
  child: Center(
    child: SizedBox(
      width: double.infinity,
      height: 245 * fem,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23 * fem),
          color: const Color(0xffffffff),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star, // Assuming you have the star icon available in your icon set
              size: 40 * fem, // Adjust the size as needed
              color: Colors.yellow, // Adjust the color as needed
            ),
            Text(
              'PREMIUM PERKS',
              style: TextStyle(
                fontSize: 24 * fem, // Adjust the size as needed
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 18 * fem),
            BulletText(
              text: 'Exclusive Benefits for the Premium customer.',
              fontSize: 13 * fem,
            ),
            BulletText(
              text: '10% discount on all your transactions throughout the month.',
              fontSize: 13 * fem,
            ),
            BulletText(
              text: 'Reserved SLOT benefits.',
              fontSize: 13 * fem,
            ),
          ],
        ),
      ),
    ),
  ),
),


                
                  Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'YOUR PLAN DETAILS:',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16 * ffem,
                          fontWeight: FontWeight.w700,
                          height: 1.2575 * ffem / fem,
                                            color: const Color(0xff000000),
                      ),
                    ),
                  ),

                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 13*fem),
              width: double.infinity,
              height: 62*fem,
              decoration: const BoxDecoration(
                color: Color(0xfff0f0ef),
              ),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                  
                      fontSize: 26*ffem,
                      fontWeight: FontWeight.w300,
                      height: 1.806640625*ffem / fem,
                      color: const Color(0xff000000),
                    ),
                    children: [
                      TextSpan(
                        text: 'Your current plan is',
                        style: TextStyle(
                     
                          fontSize: 26*ffem,
                          fontWeight: FontWeight.w300,
                          height: 1.2575*ffem / fem,
                          color: const Color(0xff000000),
                        ),
                      ),
                      TextSpan(
                        text: ' ${loggedInUser.subscription}.',
                        style: TextStyle(
                       
                          fontSize: 26*ffem,
                          fontWeight: FontWeight.w700,
                          height: 1.2575*ffem / fem,
                          color: const Color(0xff000000),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 37*fem,
              decoration: const BoxDecoration(
                color: Color(0xfff5d774),
              ),
              child: Center(
                child: Text(
                  'Avail premium features for exclusive benefits.',
                  style: TextStyle(
         
                    fontSize: 14*ffem,
                    fontWeight: FontWeight.w300,
                    height: 1.2575*ffem / fem,
                    color: const Color(0xff000000),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(27*fem, 16*fem, 27*fem, 26*fem),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 3*fem),
                    child: TextButton(
                      onPressed: () {
                              Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RazorPayIntegration()),
    );
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Container(
                        width: double.infinity,
                        height: 50*fem,
                        decoration: BoxDecoration(
                          color: const Color(0xff2a364e),
                          borderRadius: BorderRadius.circular(9*fem),
                        ),
                        child: Center(
                          child: Text(
                            ' GET PREMIUM NOW',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                     
                              fontSize: 24*ffem,
                              fontWeight: FontWeight.w400,
                              height: 1.2975*ffem / fem,
                              color: const Color(0xfffffdfd),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 5*fem, 0*fem),
                    child: Text(
                      'Rs . 120/month',
                      textAlign: TextAlign.center,
                      style: TextStyle(
              
                        fontSize: 14*ffem,
                        fontWeight: FontWeight.w300,
                        height: 1.2575*ffem / fem,
                        color: const Color(0xff000000),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),          
        ],
      ),
    ),
    );
  }

 
}
// Custom Widget for Bulleted Text
class BulletText extends StatelessWidget {
  final String text;
  final double fontSize;

  // ignore: use_key_in_widget_constructors
  const BulletText({required this.text, required this.fontSize});

  @override
  Widget build(BuildContext context) {
      double baseWidth = 360;
double fem = MediaQuery.of(context).size.width / baseWidth;


    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 12 * fem), // Adjust the space between bullet and text
        Icon(
          Icons.brightness_1, // Bullet icon
          size: 9 * fem, // Adjust the size as needed
        ),
        SizedBox(width: 10 * fem),
      Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize),
          ),
        ),
      ],
    );
  }
}