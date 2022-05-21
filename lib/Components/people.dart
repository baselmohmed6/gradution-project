import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/Components/chat_details.dart';

// class people extends StatelessWidget {
//   const people({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Center(
//         child: Text('People Page'),
//       ),
//     );
//   }
// }

class People extends StatelessWidget {
  People({Key? key}) : super(key: key);
  var currentUser = FirebaseAuth.instance.currentUser?.uid;
  void callChatScreen(BuildContext context, String name, String uid) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chatdetails(
                  friendUserid: uid,
                  friendUsername: name,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('uid', isNotEqualTo: currentUser)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Something went Wrong "),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              appBar: AppBar(
                title: Text("Loading Page"),
              ),
              body: Container(
                  child: Center(
                child: Text(
                  "Waiting",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              )));
        }
        if (snapshot.hasData) {
          return CustomScrollView(
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: Text("People"),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  snapshot.data!.docs.map(
                    (DocumentSnapshot document) {
                      Map<String, dynamic>? data =
                          document.data() as Map<String, dynamic>;
                      return CupertinoListTile(
                        onTap: () =>
                            callChatScreen(context, data['name'], data['uid']),
                        title: Text(
                          data['name'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          data['status'],
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.italic),
                        ),
                      );
                    },
                  ).toList(),
                ),
              )
            ],
          );
        }
        return Container();
      },
    );
  }
}
