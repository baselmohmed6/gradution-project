// import 'package:chattapp/Screens/Homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_chat_app/Components/home_page.dart';

class username extends StatelessWidget {
  username({Key? key}) : super(key: key);
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  void createuserinfirestore() {
    users
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        users.add({
          'name': _text.text,
          'email': FirebaseAuth.instance.currentUser!.email,
          'status': 'Available',
          'uid': FirebaseAuth.instance.currentUser!.uid
        });
      }
    }).catchError((error) {});
  }

  // DocumentReference users2 = FirebaseFirestore.instance
  //     .collection('users')
  //     .doc('RKZFQcHaiAOy57t9fQdk');

  // getUserInFireStore() {
  //   users
  //       .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
  //       .limit(1)
  //       .get()
  //       .then((QuerySnapshot querySnapshot) {
  //     if (querySnapshot.docs.isEmpty) {
  //       users.add({
  //         'name': _text.text,
  //         'phone': FirebaseAuth.instance.currentUser!.phoneNumber,
  //         'status': 'Available',
  //         'uid': FirebaseAuth.instance.currentUser!.uid
  //       });
  //     }
  //   }).catchError((error) {});
  // }

  testUserr() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
// Name, email address, and profile photo URL
      final name = user.displayName;
      final email = user.email;
      //final photoUrl = user.photoURL;

// Check if user's email is verified
      final emailVerified = user.emailVerified;

// The user's ID, unique to the Firebase project. Do NOT use this value to
// authenticate with your backend server, if you have one. Use
// User.getIdToken() instead.
      final uid = user.uid;
      print("$uid - $email");
    }
  }

  create_collection() async {
    FirebaseFirestore.instance.collection("users").add({
      "name": 'hi'
      //your data which will be added to the collection and collection will be created after this
    }).then((_) {
      print("collection created");
    }).catchError((_) {
      print("an error occured");
    });
    //CollectionReference audios=FirebaseFirestore.instance.collection("audios");
  }

  var _text = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Enter your name',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoTextField(
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
              maxLength: 15,
              controller: _text,
              keyboardType: TextInputType.name,
              autofillHints: <String>[AutofillHints.name],
            ),
          ),
          CupertinoButton.filled(
              child: Text('Continue'),
              onPressed: () {
                // testUserr();
                // getUserInFireStore();
                FirebaseAuth.instance.currentUser
                    ?.updateDisplayName(_text.text);
                createuserinfirestore();
                Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => myHomePage()));
              })
        ],
      ),
    );
  }
}
