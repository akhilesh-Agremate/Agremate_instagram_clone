import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _repository = Repository();                                     // var → final

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff8faf8),                      // Added const
        centerTitle: true,
        elevation: 1.0,
        title: SizedBox(
          height: 35.0,
          child: Image.asset("assets/insta_logo.png"),
        ),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () async {
            final user = await _repository.signIn();                   // async/await
            if (user != null) {
              await authenticateUser(user);
            } else {
              print("Error signing in");
            }
          },
          child: Container(
            width: 250.0,
            height: 50.0,
            decoration: BoxDecoration(
              color: const Color(0xFF4285F4),
              border: Border.all(color: Colors.black),
            ),
            child: Row(
              children: <Widget>[
                Image.asset('assets/google_icon.jpg'),
                const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    'Sign in with Google',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> authenticateUser(User user) async {                     // FirebaseUser → User
    print("Inside Login Screen -> authenticateUser");
    final isNewUser = await _repository.authenticateUser(user);

    if (!mounted) return;                                              // mounted check

    if (isNewUser) {
      print("New user — adding to db");
      await _repository.addDataToDb(user);
    } else {
      print("Existing user — skipping db write");
    }

    if (!mounted) return;                                              // mounted check after await
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const InstaHomeScreen(),
      ),
    );
  }
}