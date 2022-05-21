import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;
late User signedInUser; //this will give us the email

class ChatScreen extends StatefulWidget {
  static const String screenRoute = 'chat_screen';

  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageTextController = TextEditingController();
  // final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  // late User signedInUser; //this will give us the email
  String? messageText; //this will give us the message

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        signedInUser = user;
        print(signedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  // void getMessages() async {
  //   final messages = await _firestore.collection("messages").get();
  //   for (var message in messages.docs) {
  //     print(message.data());
  //   }
  // }

  void messageStreams() async {
    await for (var snapshot in _firestore.collection("messages").snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[900],
        title: Row(
          children: [
            Image.asset('images/logo.png', height: 25),
            const SizedBox(width: 10),
            const Text('MessageMe')
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              messageStreams();
              //getMessages();
              // _auth.signOut();
              // Navigator.pop(context);
            },
            icon: const Icon(Icons.download),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MessageStreamBuilder(), // StreamBuilder<QuerySnapshot>(
            //   stream: _firestore.collection("messages").snapshots(),
            //   builder: (context, snapshot) {
            //     List<messageLine> messageWidgets = [];
            //     if (!snapshot.hasData) {
            //       return Center(
            //           child: CircularProgressIndicator(
            //         backgroundColor: Colors.blue,
            //       ));
            //       //if no data in the snapshot..do
            //       //add here a spinner
            //     }
            //     final messages = snapshot.data!.docs;
            //     for (var message in messages) {
            //       final messageText = message.get(
            //           'text'); //the field in the document which contain the text message
            //       // final messageSender = message.get(
            //       //     'email'); //the field in the document which contain the sender email
            //       final messageWidget = messageLine(
            //         text: messageText,
            //         // sender: messageSender,
            //       );
            //       messageWidgets.add(messageWidget);
            //     }
            //
            //     return Expanded(
            //       child: ListView(
            //         padding: const EdgeInsets.symmetric(
            //             horizontal: 10, vertical: 20),
            //         children: messageWidgets,
            //       ),
            //     );
            //   },
            // ),
            Container(
              decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(
                color: Colors.orange,
                width: 2,
              ))),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.orange,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: MessageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        hintText: 'Write your message here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      MessageTextController.clear();
                      _firestore.collection("messages").add(
                          {'text': messageText, 'email': signedInUser.email});
                    },
                    child: Text(
                      'send',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStreamBuilder extends StatelessWidget {
  const MessageStreamBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection("messages").snapshots(),
      builder: (context, snapshot) {
        List<messageLine> messageWidgets = [];
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(
            backgroundColor: Colors.blue,
          ));
          //if no data in the snapshot..do
          //add here a spinner
        }
        final messages = snapshot.data!.docs;
        for (var message in messages) {
          final messageText = message.get(
              'text'); //the field in the document which contain the text message
          final messageSender = message.get(
              'email'); //the field in the document which contain the sender email
          final currentUser = signedInUser.email;

          //if (currentUser == messageSender) {}
          final messageWidget = messageLine(
              text: messageText,
              email: messageSender,
              isMe: currentUser == messageSender);
          messageWidgets.add(messageWidget);
        }

        return Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messageWidgets,
          ),
        );
      },
    );
  }
}

class messageLine extends StatelessWidget {
  const messageLine({this.text, this.email, required this.isMe, Key? key})
      : super(key: key);
  final String? email;
  final String? text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$email',
            style: TextStyle(fontSize: 13, color: Colors.yellow[900]),
          ),
          Material(
              elevation: 10,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
              color: Colors.blue[800],
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  '$text',
                  //'$text-$sender',
                  style: const TextStyle(fontSize: 15, color: Colors.white),
                ),
              )),
        ],
      ),
    );
  }
}
