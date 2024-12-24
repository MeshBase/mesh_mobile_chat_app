import 'package:flutter/material.dart';
import 'package:mesh_mobile/common/widgets/search_bar.dart';
import 'package:mesh_mobile/features/chat/presentation/pages/chat_list_page.dart';
import 'package:mesh_mobile/features/nearby_users/presentation/pages/nearby_users_page.dart';
import 'package:mesh_mobile/features/search/presentation/pages/search_users_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedTabIndex = 0;

  // pages
  final List<Widget> _homePages = const [
    NearbyUsersPage(),
    ChatListPage(),
    SearchUsersPage(),
  ];

  final List<PreferredSizeWidget> _homePageAppBars = [
    AppBar(title: const SearchBarWidget()),
    AppBar(
      title: const Text("Chats"),
      actions: [
        // search and settings
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            print("Search button clicked");
          },
        ),

        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            print("Settings button clicked");
          },
        ),
      ],
    ),
    AppBar(title: const SearchBarWidget()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _homePageAppBars[_selectedTabIndex],
      body: _homePages[_selectedTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: "Nearby Users",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
        ],
        selectedItemColor: Colors.blue.shade900,
        onTap: (int index) {
          print("Bottom Nav index $index selected");
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),
    );
  }
}
