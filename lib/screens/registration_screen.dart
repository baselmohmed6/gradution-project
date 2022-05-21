import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:my_chat_app/screens/username.dart';
import 'package:my_chat_app/widgets/my_button.dart';

class RegistrationScreen extends StatefulWidget {
  static const String screenRoute = 'registration_screen';

  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;

  late String email;
  late String password;
  var _text = TextEditingController();
  late String name;

  bool showSpinner = false;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 180,
                child: Image.asset('images/logo.png'),
              ),
              SizedBox(height: 20),
              // TextField(
              //   keyboardType: TextInputType.emailAddress,
              //   textAlign: TextAlign.center,
              //   controller: _text,
              //   onChanged: (value) {
              //     name = value;
              //   },
              //   decoration: const InputDecoration(
              //     hintText: 'Enter your name',
              //     contentPadding: EdgeInsets.symmetric(
              //       vertical: 10,
              //       horizontal: 20,
              //     ),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.all(
              //         Radius.circular(10),
              //       ),
              //     ),
              //     enabledBorder: OutlineInputBorder(
              //       borderSide: BorderSide(
              //         color: Colors.orange,
              //         width: 1,
              //       ),
              //       borderRadius: BorderRadius.all(
              //         Radius.circular(10),
              //       ),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderSide: BorderSide(
              //         color: Colors.blue,
              //         width: 2,
              //       ),
              //       borderRadius: BorderRadius.all(
              //         Radius.circular(10),
              //       ),
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 10),
              //SizedBox(height: 50),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Enter your Email',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.orange,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Enter your password',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.orange,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              MyButton(
                color: Colors.blue[800]!,
                title: 'register',
                onPressed: () async {
                  // createuserinfirestore();
                  print(email);
                  print(password);
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => username()),
                    );
                    // Navigator.pushNamed(context, ChatScreen.screenRoute);
                    setState(() {
                      showSpinner = false;
                    });
                  } catch (e) {
                    print(e);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void createuserinfirestore() {
  //   users
  //       .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
  //       .limit(1)
  //       .get()
  //       .then((QuerySnapshot querySnapshot) {
  //     if (querySnapshot.docs.isEmpty) {
  //       users.add({
  //         'name': _text.text,
  //         'email': FirebaseAuth.instance.currentUser!.email,
  //         'status': 'Available',
  //         'uid': FirebaseAuth.instance.currentUser!.uid
  //       });
  //     }
  //   }).catchError((error) {});
  // }
}
