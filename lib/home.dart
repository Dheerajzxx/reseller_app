import 'package:flutter/material.dart';
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
            onPressed: () { Navigator.pushNamed(context, 'cart'); },
            icon: const Icon(Icons.shopping_cart_rounded),
          ),
          IconButton(
            onPressed: () {},
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
        shape: const BeveledRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(3.0),
            bottomRight: Radius.circular(3.0),
          )
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(14, 29, 48, 0.941),
              ),
              // child: Text('Drawer Header', style: TextStyle(color: Colors.white),),
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(top: 30),
                    child: Image.asset('assets/PG_Logo.png',),                      
                  )
                ],
              ),
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
            // Orders
            Container(
              decoration: const BoxDecoration(
                color: Colors.white38,
              ),
              child: Column(
                children: <Widget>[
                  // Order History
                  SizedBox(
                    child: GestureDetector(
                      onTap: (){ Navigator.pushNamed(context, 'ordersList'); },
                      child: Container(
                        padding: const EdgeInsets.only(top: 30, bottom: 30),
                        margin: const EdgeInsets.all(20),                      
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(5.0, 5.0),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                            ),
                            BoxShadow(
                              color: Colors.white,
                              offset: Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('Order History', style: TextStyle(
                            fontSize: 25.0,
                          ),),
                        ),
                      ),
                    ),
                  ),
                  // Quick Order
                  SizedBox(
                    child: GestureDetector(
                      onTap: (){ Navigator.pushNamed(context, 'quickOrder'); },
                      child: Container(
                        padding: const EdgeInsets.only(top: 30, bottom: 30),
                        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(5.0, 5.0),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                            ),
                            BoxShadow(
                              color: Colors.white,
                              offset: Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('Quick Order', style: TextStyle(
                            fontSize: 25.0,
                          ),),
                        ),
                      ),
                    ),
                  ),
                  // Last Five Purchase
                  SizedBox(
                    child: GestureDetector(
                      onTap: (){ Navigator.pushNamed(context, 'lastFivePurchases'); },
                      child: Container(
                        padding: const EdgeInsets.only(top: 30, bottom: 30),
                        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(5.0, 5.0),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                            ),
                            BoxShadow(
                              color: Colors.white,
                              offset: Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('Last 5 Purchases', style: TextStyle(
                            fontSize: 25.0,
                          ),),
                        ),
                      ),
                    ),
                  ),
                  // Your Top 10
                  SizedBox(
                    child: GestureDetector(
                      onTap: (){ Navigator.pushNamed(context, 'yourTopTen'); },
                      child: Container(
                        padding: const EdgeInsets.only(top: 30, bottom: 30),
                        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(5.0, 5.0),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                            ),
                            BoxShadow(
                              color: Colors.white,
                              offset: Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('Your top 10', style: TextStyle(
                            fontSize: 25.0,
                          ),),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // Tickets
            Container(
              decoration: const BoxDecoration(
                color: Colors.white38,
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    child: Container(
                      padding: const EdgeInsets.only(top: 30, bottom: 30),
                      margin: const EdgeInsets.all(20),                      
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(5.0, 5.0),
                            blurRadius: 10.0,
                            spreadRadius: 2.0,
                          ),
                          BoxShadow(
                            color: Colors.white,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('Ask A Question', style: TextStyle(
                          fontSize: 25.0,
                        ),),
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Container(
                      padding: const EdgeInsets.only(top: 30, bottom: 30),
                      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(5.0, 5.0),
                            blurRadius: 10.0,
                            spreadRadius: 2.0,
                          ),
                          BoxShadow(
                            color: Colors.white,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('Question History', style: TextStyle(
                          fontSize: 25.0,
                        ),),
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Container(
                      padding: const EdgeInsets.only(top: 30, bottom: 30),
                      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(5.0, 5.0),
                            blurRadius: 10.0,
                            spreadRadius: 2.0,
                          ),
                          BoxShadow(
                            color: Colors.white,
                            offset: Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('Warranty Claim', style: TextStyle(
                          fontSize: 25.0,
                        ),),
                      ),
                    ),
                  ),
                  SizedBox(
                    child: GestureDetector(
                      onTap: (){},
                      child: Container(
                        padding: const EdgeInsets.only(top: 30, bottom: 30),
                        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(5.0, 5.0),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                            ),
                            BoxShadow(
                              color: Colors.white,
                              offset: Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('Warranty Claim History', style: TextStyle(
                            fontSize: 25.0,
                          ),),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
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
            title: const Text('Orders'),
            icon: const Icon(Icons.shopping_bag),
            activeColor: Colors.white,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            title: const Text('Tickets'),
            icon: const Icon(Icons.style),
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