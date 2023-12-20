import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'user/LoginScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:firebase_storage/firebase_storage.dart';

Future<void> main() async {
   ErrorWidget.builder = (FlutterErrorDetails details) => const Scaffold(
    body: Center(
      child: Text('')
    ),
  );
  await dotenv.load(fileName: "assets/.env"  );
  WidgetsFlutterBinding.ensureInitialized();
   
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // FirebaseStorage storage = FirebaseStorage.instance;
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
      
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const UserLoginScreen(),
    );
  }
}
