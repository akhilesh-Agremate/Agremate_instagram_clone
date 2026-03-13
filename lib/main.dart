import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';                     // Added Firebase init
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/ui/login_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();                           // Required before Firebase.initializeApp
//   await Firebase.initializeApp();                                      // Firebase must be initialized
//   runApp(const MyApp());
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDoR1k2l-SPxTNFdtPKBFx3z-76bH7FK54",
        appId: "1:920050251982:web:your_web_app_id", // You'll need to find your Web App ID in Firebase Console
        messagingSenderId: "920050251982",
        projectId: "instagramclone-97a0f",
        storageBucket: "instagramclone-97a0f.appspot.com",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final _repository = Repository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.black,
        primaryIconTheme: const IconThemeData(color: Colors.black),
        primaryTextTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Colors.black,
            fontFamily: "Aveny",
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.black),
        ),
      ),
      home: FutureBuilder<User?>(
        future: _repository.getCurrentUser(),
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {   // Show loader while waiting
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const InstaHomeScreen();                            // Added const
          }
          return const LoginScreen();                                  // Added const
        },
      ),
    );
  }
}