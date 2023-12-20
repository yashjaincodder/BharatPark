import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final String phoneNumber = '807682732';
  final String email = 'parkwizauth@gmail.com';
  final String address = 'KIET Group of Institutions';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ParkWiz Support',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 55, 16, 132),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'We Assist You!',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 55, 16, 132),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'For any assistance or inquiries, feel free to reach out to us:',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              Image.asset(
                'assets/help.png', // Replace with your image asset path
                height: 300, // Set your desired height
                width: double.infinity, // Set your desired width
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.phone, color: Color.fromARGB(255, 55, 16, 132)),
                title: Text(
                  'Phone: $phoneNumber',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(color: Colors.black),
                  ),
                ),
                onTap: () {
                  launchUrlString('tel:$phoneNumber');
                },
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Color.fromARGB(255, 55, 16, 132)),
                title: Text(
                  'Email: $email',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(color: Colors.black),
                  ),
                ),
                onTap: () {
                  launchUrlString('mailto:$email');
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on, color: Color.fromARGB(255, 55, 16, 132)),
                title: Text(
                  'Address: $address',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Add an asset image
            ],
          ),
        ),
      ),
    );
  }
}
