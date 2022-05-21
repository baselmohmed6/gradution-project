import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/screens/chat_screen.dart';
import 'package:my_chat_app/screens/registration_screen.dart';
import 'package:my_chat_app/screens/signin_screen.dart';
import 'package:my_chat_app/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        title: 'MessageMe app',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        // home: myHomePage(),
        initialRoute: WelcomeScreen.screenRoute,
        // _auth.currentUser != null
        //     ? ChatScreen.screenRoute
        //     : WelcomeScreen.screenRoute,
        routes: {
          WelcomeScreen.screenRoute: (context) => WelcomeScreen(),
          SignInScreen.screenRoute: (context) => SignInScreen(),
          RegistrationScreen.screenRoute: (context) => RegistrationScreen(),
          ChatScreen.screenRoute: (context) => ChatScreen(),
          // myHomePage.screenRoute: (context) => myHomePage(),
        });
  }
}
