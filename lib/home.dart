// import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';

class HomePage extends StatefulWidget {
  final VoidCallback signOut;
  const HomePage(this.signOut, {super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  signOut() {
    setState(() {
      widget.signOut();
    });
  }

  int _currentIndex = 0, _selectedIndex = 0;

  PageController? _pageController;

  int? id = 0 ;
  String email = "", firstName = "", lastName = "";

  getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getInt("id");
      email = prefs.getString("email")??'';
      firstName = prefs.getString("firstName")??'';
      lastName = prefs.getString("lastName")??'';
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(14, 29, 48, 1),        
        actions: <Widget>[
          IconButton(
            onPressed: () {
              
            },
            icon: const Icon(Icons.shopping_cart_rounded),
          ),
          IconButton(
            onPressed: () {
              
            },
            icon: const Icon(Icons.notifications_active_outlined ),
          ),
          IconButton(
            onPressed: () {
              signOut();
            },
            icon: const Icon(Icons.logout_rounded),
          )
        ],
        
      ),
      drawer: Drawer(
        shadowColor: Colors.white70,
        backgroundColor: Colors.white60,
        width: 240,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(14, 29, 48, 1),
              ),
              child: Text('Drawer Header', style: TextStyle(color: Colors.white),),
            ),
            ListTile(
              title: const Text('Tab 1'),
              selected: _selectedIndex == 0,
              onTap: () {
                // Update the state of the app
                _onItemTapped(0);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Tab 2'),
              selected: _selectedIndex == 1,
              onTap: () {
                // Update the state of the app
                _onItemTapped(1);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Tab 3'),
              selected: _selectedIndex == 2,
              onTap: () {
                // Update the state of the app
                _onItemTapped(2);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            Container(color: const Color.fromARGB(255, 110, 174, 203),),
            Container(color: const Color.fromARGB(255, 167, 86, 81),),
            Container(color: const Color.fromARGB(255, 90, 130, 91),),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: doSomething,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        showElevation: true,
        itemCornerRadius: 24,
        curve: Curves.easeIn,
        backgroundColor:const Color.fromRGBO(14, 29, 48, 1),
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController?.jumpToPage(index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            title: const Text('Home'),
            icon: const Icon(Icons.home),
            activeColor: Colors.white,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            title: const Text('Order History'),
            icon: const Icon(Icons.apps),
            activeColor: Colors.white,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            title: const Text('Settings'),
            icon: const Icon(Icons.settings),
            activeColor: Colors.white,
            textAlign: TextAlign.center,
          ),
        ],
      )
      
    );
  }
}