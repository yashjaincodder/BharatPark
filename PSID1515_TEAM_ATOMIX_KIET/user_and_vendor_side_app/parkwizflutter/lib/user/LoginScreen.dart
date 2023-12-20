import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parkwizflutter/user/bottom_nav_screen.dart';
import 'package:parkwizflutter/vendor/VLoginScreen.dart';
import 'RegistrationScreen.dart';


class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _UserLoginScreenState createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
   // form key
  final _formKey = GlobalKey<FormState>();

  //editting controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // firebase
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {

       //email field 
    final emailField = Material(
      child: TextFormField(
      autofocus: false,
      controller: emailController,
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
        emailController.text = value!;
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
      child: TextFormField(
      autofocus: false,
      controller: passwordController,
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
        emailController.text = value!;
      },
      textInputAction: TextInputAction.done,
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
    final loginButton = Material(
    elevation: 5,
    borderRadius: BorderRadius.circular(30),
    color:const Color(0xff371084),
    child: MaterialButton(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      minWidth: MediaQuery.of(context).size.width,
      onPressed: () {
        signIn(emailController.text, passwordController.text);
      },
      child: const Text(
        "Login",
        textAlign: TextAlign.center,
        style: TextStyle(
        fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
      )), 
      );
      
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;

    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: EdgeInsets.fromLTRB(0 * fem, 150 * fem, 0 * fem, 0 * fem),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 55, 16, 132),
        ),
child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(40 * fem, 0 * fem, 30 * fem, 72 * fem),
              width: 326 * fem,
              height: 107 * fem,
              child: Image.asset(
                'assets/parking-app-39-1.png',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 441 * fem,
              height: 589 * fem,
              child: Stack(
                children: [
                  Positioned(
                    left: 0 * fem,
                    top: 0 * fem,
                    child: Align(
                      child: SizedBox(
                        width: 360 * fem,
                        height: 461 * fem,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60 * fem),
                            border: Border.all(color: const Color(0xff000000)),
                            color: const Color(0xffffffff),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x3f000000),
                                offset: Offset(0 * fem, 4 * fem),
                                blurRadius: 2 * fem,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                    Positioned(
                    // loginwxZ (17:30)
                    left: 113*fem,
                    top: 21.5*fem,
                    child: Center(
                      child: Align(
                        child: SizedBox(
                          width: 132*fem,
                          height: 59*fem,
                          child: const Text(
                            'LOGIN', style: TextStyle(color: Color.fromARGB(255, 54, 3, 70), fontSize: 30),
                            textAlign: TextAlign.center,
                           
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 44 * fem,
                    top: 94 * fem,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(1.03 * fem, 11.76 * fem, 21.03 * fem, 19.24 * fem),
                      width: 279 * fem,
                      height: 349 * fem,
              
                   color: Colors.transparent,
    
             
              child: Form(
                 key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

            

                  emailField,
                  const SizedBox(height: 30),

                  passwordField,
                  const SizedBox(height: 40),
                  
                  loginButton,
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
               
                      GestureDetector(onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrationScreen()
                        ));
                      },
                      child: const Text(" Sign Up   ", style: TextStyle(color: Color.fromARGB(255, 55, 16, 132), fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      ),
                       GestureDetector(onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const VendorLoginScreen()
                        ));
                      }, 
                      child: const Text("  Vendor Login", style: TextStyle(color: Color(0xff371084), fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      )
                    ])

                  ],
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
  
 void signIn(String email, String password) async
 {
  if (_formKey.currentState!.validate())
  {
    await _auth
    .signInWithEmailAndPassword(email: email, password: password).then((uid) => {
      Fluttertoast.showToast(msg: "Login Successful!"),
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const BottomNavScreen())),

    }).catchError((e)
    // ignore: body_might_complete_normally_catch_error
    {
      Fluttertoast.showToast(msg: e!.message);
    });
  }
 }
}
