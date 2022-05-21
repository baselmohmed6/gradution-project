import 'package:flutter/material.dart';
import 'package:my_chat_app/Components/people.dart';
import 'package:my_chat_app/Components/recent_chats.dart';

import '../screens/chat_screen.dart';

class myHomePage extends StatefulWidget {
  const myHomePage({Key? key}) : super(key: key);

  @override
  State<myHomePage> createState() => _myHomePageState();
}

class _myHomePageState extends State<myHomePage> {
  var screens = [
    Chats(),
    People(),
    ChatScreen(),
    Chats(),
  ];
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (index) => setState(() => this.index = index),
        height: 60,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_rounded),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt),
            selectedIcon: Icon(Icons.people_alt_rounded),
            label: 'People',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group_outlined),
            label: 'Group-Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.whatsapp_rounded),
            selectedIcon: Icon(Icons.whatsapp_outlined),
            label: 'Chats',
          ),
        ],
      ),
    );
  }
}
