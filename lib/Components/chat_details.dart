import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_9.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';

import 'package:flutter_speech/flutter_speech.dart';

class Chatdetails extends StatefulWidget {
  final friendUserid;
  final friendUsername;
  const Chatdetails({Key? key, this.friendUserid, this.friendUsername})
      : super(key: key);

  @override
  State<Chatdetails> createState() =>
      _ChatdetailsState(friendUserid, friendUsername);
}
const languages = const [

  const Language('English', 'en_US'),
];

class Language {
  final String name;
  final String code;

  const Language(this.name, this.code);
}

class _ChatdetailsState extends State<Chatdetails> {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  final friendUserid;
  final friendUsername;
  // ScrollController scrollController = ScrollController();
  var currentuserID = FirebaseAuth.instance.currentUser?.uid;
  var currentusername = FirebaseAuth.instance.currentUser?.displayName;
  bool isloading=false;
  var urlaudio;
  var _textcontroller = new TextEditingController();
  var _audiocontroller;
  bool isPlayingMsg = false, isRecording = false, isSending = false;
  var filepath;
  bool recognizing = false;
  bool recognizeFinished = false;
  
    late SpeechRecognition _speech;

  bool _speechRecognitionAvailable = false;
  bool _isListening = false;

  String transcription = '';

  //String _currentLocale = 'en_US';
  Language selectedLang = languages.first;
  _ChatdetailsState(this.friendUserid, this.friendUsername);

  @override
  void initState() {
    // TODO: implement initState
   activateSpeechRecognizer();
    super.initState();
    checkuser();
    // final fbm =FirebaseMessaging.instance;
    // fbm.getNotificationSettings();
    // FirebaseMessaging.onMessage.listen((event) { })
    
    
    
  }
   void activateSpeechRecognizer() {
    print('_MyAppState.activateSpeechRecognizer... ');
    _speech = SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech.setErrorHandler(errorHandler);
    _speech.activate('en_US').then((res) {
      setState(() => _speechRecognitionAvailable = res);
    });
   
  }
   
  var chatDocId;
  void checkuser() async {
    await chats
        .where('users', isEqualTo: {friendUserid: null, currentuserID: null})
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) async {
          if (querySnapshot.docs.isNotEmpty) {
            setState(() {
              chatDocId = querySnapshot.docs.single.id;
            });
            print(chatDocId);
          } else {
            await chats.add({
              'users': {currentuserID: null, friendUserid: null},
              'names': {
                currentuserID: FirebaseAuth.instance.currentUser?.displayName,
                friendUserid: friendUsername
              }
            }).then((value) {
              chatDocId = value;
            });
          }
        })
        .catchError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    final picon = isPlayingMsg ? Icons.stop : Icons.play_arrow;
//  List<String> list = [];
    return StreamBuilder<QuerySnapshot>(
      stream: chats
          .doc(chatDocId)
          .collection('messages')
          .orderBy('createdOn', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Something went wrong"),
          );
        }

        // if (snapshot.connectionState == ConnectionState.waiting) {
        //       return Scaffold(
        //       appBar: AppBar(
        //         title: Text("Loading Page"),
        //       ),
        //       body: Container(
        //           child: Center(
        //         child: Text(
        //           "Waiting",
        //           style: TextStyle(
        //             fontSize: 15,
        //           ),
        //         ),
        //       )));
        // }

        if (snapshot.hasData) {
          dynamic data;
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(friendUsername),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {},
                child: Icon(CupertinoIcons.phone),
              ),
              previousPageTitle: "Back",
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      reverse: true,
                      children: snapshot.data!.docs.map(
                        (DocumentSnapshot document) {
                          data = document.data()!;

                          print(data['msg']);
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: data['type'].toString() == 'audio'
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        top: 8,
                                        left: ((data['uid'] == currentuserID)
                                            ? 64
                                            : 10),
                                        right: ((data['uid'] == currentuserID)
                                            ? 10
                                            : 64)),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: (data['uid'] == currentuserID)
                                            ? Colors.greenAccent
                                            : Color.fromARGB(
                                                255, 250, 250, 250),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: GestureDetector(
                                          onTap: () {
                                            //    getFilePath();
                                            
                                            
                                            _loadFile(data['msg']);
                                           
                                          },
                                          onDoubleTap:(){
                                            stopRecord();
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(isPlayingMsg
                                                      ? Icons.play_arrow
                                                      : Icons.stop_rounded),
                                                  Text(
                                                    'Audio-${currentusername} to ${data['friendname']} ',
                                                    style:
                                                        TextStyle(fontSize: 10,color: Colors.black,),
                                                    maxLines: 10,
                                                  ),
                                                ],
                                              ),
                                              DefaultTextStyle( style: TextStyle(fontSize: 8,color: Color.fromARGB(255, 0, 0, 0),) , child:  Text(
                                                data['createdOn'] == null
                                                    ? DateTime.now().toString()
                                                    : data['createdOn']
                                                        .toDate()
                                                        .toString(),
                                               
                                              ))
                                             
                                            ],
                                          )),
                                    ),
                                  )
                                : ChatBubble(
                                    clipper: ChatBubbleClipper9(
                                      radius: 25,
                                      type: isSender(data['uid'].toString())
                                          ? BubbleType.sendBubble
                                          : BubbleType.receiverBubble,
                                    ),
                                    alignment:
                                        getAlignment(data['uid'].toString()),
                                    margin: EdgeInsets.only(top: 20),
                                    backGroundColor:
                                        isSender(data['uid'].toString())
                                            ? Color(0xFF08C187)
                                            : Color(0xffE7E7ED),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child:DefaultTextStyle(
                                                   style: TextStyle(fontSize: 18,
                                                        color: isSender(
                                                                data['uid']
                                                                    .toString())
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontStyle:
                                                            FontStyle.italic),
                                                child: Text(data['msg'],
                                                   
                                                    maxLines: 100,
                                                    softWrap: false,
                                                    overflow:
                                                        TextOverflow.ellipsis),)
                                              )
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                             DefaultTextStyle(
                                               style: TextStyle(
                                                    fontSize: 7,
                                                    color: isSender(data['uid']
                                                            .toString())
                                                        ? Colors.white
                                                        : Colors.black),
                                            child:  Text(
                                                data['createdOn'] == null
                                                    ? DateTime.now().toString()
                                                    : data['createdOn']
                                                        .toDate()
                                                        .toString(),
                                                
                                              ))
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: CupertinoTextField(
                            placeholder: "Write message....",
                            controller: _textcontroller,
                          ),
                        ),
                      ),
                      Container(
                          height: 40,
                          margin: EdgeInsets.fromLTRB(5, 5, 10, 5),
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color:
                                    isRecording ? Colors.white : Colors.black12,
                                spreadRadius: 4)
                          ], color: Colors.white, shape: BoxShape.circle),
                          child: GestureDetector(
                            onTap: () {
                              startRecord();
                              start();
                              setState(() {
                                isRecording = true;

                              });
                            },
                            onDoubleTap:() {
                              stopRecord();
 stop();
                              setState(() {
                                isRecording = false;
                              });
                            },
                            child: Container(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.mic,
                                  color: Color.fromARGB(255, 121, 204, 124),
                                  size: 20,
                                )),
                          )),
                      CupertinoButton(
                          child: Icon(Icons.send_sharp),
                          onPressed: () => sendMessage(_textcontroller.text))
                    ],
                  )
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  void sendMessage(String msg) {
    setState(() {
      isSending = true;
    });
    if (msg == '') return;
    if (msg == _textcontroller.text) {
      String chatDocId2 = chatDocId;
      chats.doc(chatDocId2).collection('messages').add({
        'createdOn': FieldValue.serverTimestamp(),
        'uid': currentuserID,
        'friendname': friendUsername,
        'msg': msg,
        "type": 'text'
      }).then((value) {
        _textcontroller.text = '';
      });
    } else {}
  }

  void sendAudioMessage(String audiomsg) async {
 
    if (audiomsg == '') return;
     _speech = SpeechRecognition();
    String chatDocId2 = chatDocId;
   
    
    chats.doc(chatDocId2).collection('messages').add({
      'createdOn': FieldValue.serverTimestamp(),
      'uid': currentuserID,
      'friendname': friendUsername,
      'msg': audiomsg,
      "type": 'audio',
      "convertedaudio":transcription,
    }).then((value) {
      setState(() {
        isSending = false;
      });
    });
  }

  bool isSender(String friend) {
    return friend == currentuserID;
  }

  Alignment getAlignment(friend) {
    if (friend == currentuserID) {
      return Alignment.topRight;
    }
    return Alignment.topLeft;
  }

  Future _loadFile(String url) async {
    final bytes = await readBytes(Uri.parse(url));
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/audio.mp3');

    await file.writeAsBytes(bytes);
    if (await file.exists()) {
      setState(() {
        recordFilePath = file.path;
        isPlayingMsg = true;
        print(isPlayingMsg);
      });
      await play();
      setState(() {
        isPlayingMsg = false;
        print(isPlayingMsg);
      });
    }
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      recordFilePath = await getFilePath();

      RecordMp3.instance.start(recordFilePath, (type) {
        setState(() {});
      });
    } else {}
    setState(() {});
  }

  void stopRecord() async {
    bool s = RecordMp3.instance.stop();
    if (s) {
      setState(() {
        isSending = true;
      });
      await uploadAudio();
      setState(() {
        isPlayingMsg = false;
      });
    }
  }

  var recordFilePath;
  Future<void> play() async {
    if (recordFilePath != null && File(recordFilePath).existsSync()) {
      AudioPlayer audioPlayer = AudioPlayer();
      await audioPlayer.play(
        recordFilePath,
        isLocal: true,
      );
    }
  }

  int i = 0;

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/messages";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + "/test_${i++}.mp3";
  }

  uploadAudio() async {
   
    final Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(
        'messages/audio{$currentusername${DateTime.now().toLocal().toString()}}.wav');

    UploadTask task = firebaseStorageRef.putFile(File(recordFilePath));

    var audioURL = await (await task).ref.getDownloadURL();
    String strVal = audioURL.toString();
    sendAudioMessage(strVal);
     
   
  }
   
  List<CheckedPopupMenuItem<Language>> get _buildLanguagesWidgets => languages
      .map((l) => CheckedPopupMenuItem<Language>(
            value: l,
            checked: selectedLang == l,
            child: Text(l.name),
          ))
      .toList();

  void _selectLangHandler(Language lang) {
    setState(() => selectedLang = lang);
  }
     void start() => _speech.activate(selectedLang.code).then((_) {
        return _speech.listen().then((result) {
          print('_MyAppState.start => result $result');
          setState(() {
            _isListening = result;
          });
        });
      });

  void cancel() =>
      _speech.cancel().then((_) => setState(() => _isListening = false));

  void stop() => _speech.stop().then((_) {
        setState(() => _isListening = false);
      });

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void onCurrentLocale(String locale) {
    print('_MyAppState.onCurrentLocale... $locale');
    setState(
        () => selectedLang = languages.firstWhere((l) => l.code == locale));
  }

  void onRecognitionStarted() {
    setState(() => _isListening = true);
  }

  void onRecognitionResult(String text) {
    print('_MyAppState.onRecognitionResult... $text');
    setState(() => transcription = text);
  }
 
 String onRecognitionComplete(String text) {
    print('_MyAppState.onRecognitionComplete... $text');
    setState(() => _isListening = false);
    return text;
  }

  void errorHandler() => activateSpeechRecognizer();
 


}

//   uploadAudio() async {
//     final Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(
//         'messages/audio{$currentuserID${DateTime.now().toLocal().toString()}}.mp3');

//     UploadTask task = firebaseStorageRef.putFile(File(recordFilePath));

//     var audioURL = await (await task).ref.getDownloadURL();
//     String strVal = audioURL.toString();
//     sendAudioMessage(strVal);
//   }
// }

// class SoundRecorder {
//   FlutterSoundRecorder? _audioRecorder;
//   bool get isRecording => _audioRecorder!.isRecording;
//   bool isRecorderintialised = false;
//   Future init() async {
//     _audioRecorder = FlutterSoundRecorder();
//     final status = await Permission.microphone.request();
//     if (status != PermissionStatus.granted) {
//       throw RecordingPermissionException('Microphone permission');
//     }
//     await _audioRecorder!.openAudioSession();
//     isRecorderintialised = true;
//   }

//   void dispose() {
//     if (!isRecorderintialised) return;
//     _audioRecorder!.closeAudioSession();
//     _audioRecorder = null;
//     isRecorderintialised = false;
//   }

//   Future _record() async {
//     if (!isRecorderintialised) return;
//     await _audioRecorder?.startRecorder(toFile:mpath ,codec:Codec.aacMP4);
//   }

//   Future stop() async {
//     if (!isRecorderintialised) return;
//     await _audioRecorder?.stopRecorder();
//   }

//   Future toggleRecording() async {
//     if (_audioRecorder!.isStopped) {
//       await _record();
//     } else {
//       await stop();
//     }
//   }
// }

// class SoundPlayer {
//   FlutterSoundPlayer? _soundPlayer;
//   bool get isplaying => _soundPlayer!.isPlaying;
//   Future init() async {
//     _soundPlayer = FlutterSoundPlayer();
//     await _soundPlayer!.openAudioSession();
//   }

//   Future dispose() async {
//     _soundPlayer!.closeAudioSession();
//     _soundPlayer = null;
//   }

//   Future play(VoidCallback whenfinshed) async {
//     await _soundPlayer!.startPlayer(fromURI: mpath, whenFinished: whenfinshed);
//   }

//   Future stop() async {
//     await _soundPlayer!.stopPlayer();
//   }

//   Future toggleplaying({required VoidCallback whenfinished}) async {
//     if (_soundPlayer!.isStopped) {
//       await play(whenfinished);
//     } else {
//       await stop();
//     }
//   }
// }
