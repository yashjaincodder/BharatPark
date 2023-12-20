import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parkwizflutter/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'LoginScreen.dart';
import 'HomeScreen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
   final _auth =FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();

  final firstNameEditingController = TextEditingController();
  final lastNameEditingController = TextEditingController();
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
  final confirmPasswordEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;

    //first name field
    final firstNameField =  Material( 
      child:TextFormField(
      autofocus: false,
      controller: firstNameEditingController,
      keyboardType: TextInputType.text,
      //validator: () {},
      onSaved: (value) 
      {
        firstNameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.account_circle),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "First Name",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          )
      )
    ),
    );

  //last name field
    final lastNameField = Material( 
      child:TextFormField(
      autofocus: false,
      controller: lastNameEditingController,
      keyboardType: TextInputType.text,
      //validator: () {},
      onSaved: (value) 
      {
        lastNameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.account_circle),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Last Name",
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

        //sign up button    
    final signUpButton = Material(
    elevation: 5,
    borderRadius: BorderRadius.circular(30),
    color: const Color(0xff2a364e),
    child: MaterialButton(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      minWidth: MediaQuery.of(context).size.width,
      onPressed: () {
        signUp(emailEditingController.text , passwordEditingController.text);
      },
      child: const Text(
        "Sign Up",
        textAlign: TextAlign.center,
        style: TextStyle(
        fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
      )), 
      );

return Center(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          padding: EdgeInsets.fromLTRB(0 * fem, 20 * fem, 0 * fem, 0 * fem),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xff371084),
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
                          child: Align(
                            child: SizedBox(
        width: double.infinity,
        height: 43 * fem,
        child: Text(
          'CREATE NEW ACCOUNT',
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
              color: Color.fromARGB(255, 54, 3, 70),
              fontSize: 24,
              fontWeight: FontWeight.bold, // Adjust the font weight as needed
            ),
          ),
        ),
      ),
                          ),
                        ),
                      ),
                      Container(
                        
                        padding: EdgeInsets.all(16 * fem),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(height: 20 * fem),
                              firstNameField,
                              SizedBox(height: 15 * fem),
                              lastNameField,
                              SizedBox(height: 15 * fem),
                              emailField,
                              SizedBox(height: 15 * fem),
                              passwordField,
                              SizedBox(height: 15 * fem),
                              confirmPasswordField,
                              SizedBox(height: 20 * fem),
                              signUpButton,
                              SizedBox(height: 15 * fem),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const UserLoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  " Sign In",
                                  style: TextStyle(color: Color(0xff2a364e), fontWeight: FontWeight.w600, fontSize: 12),
                                ),
                              )
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
  
    void signUp(String email, String password) async
    {
      if (_formKey.currentState!.validate())
      {
        await _auth.createUserWithEmailAndPassword(email: email, password: password)
        .then((value) => {
          postDetailsToFirestore()

        }).catchError((e)
        // ignore: body_might_complete_normally_catch_error
        {
          Fluttertoast.showToast(msg: e!.message);
        });
      }
    }
    postDetailsToFirestore() async {
      // calling our Firebase
      // calling our user model
      //sending these values

      FirebaseFirestore firebaseFirestore =FirebaseFirestore.instance;
      User? user = _auth.currentUser;

      UserModel userModel = UserModel();

      // writin all values
      userModel.email = user!.email;
      userModel.uid = user.uid;
      userModel.firstName = firstNameEditingController.text;
      userModel.lastName = lastNameEditingController.text;

      await firebaseFirestore
      .collection("users")
      .doc(user.uid)
      .set(userModel.toMap());
      
    
    Fluttertoast.showToast(msg: "Account created Successfully !");
    // final docUser = FirebaseFirestore.instance
    //                   .collection('users')
    //                   .doc(user.uid);
  FirebaseFirestore.instance.collection('users').doc('your_document_id').update({
  'subscription': 'Basic',
});
    // ignore: use_build_context_synchronously
    Navigator.pushAndRemoveUntil(
    (context),
    MaterialPageRoute(builder: (context) => const HomeScreen()),
    (route) => false); 
    }
}

         
