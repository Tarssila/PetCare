
import 'package:flutter/material.dart';

import 'home_pet.dart';
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  PageController _pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
  }


  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.deepOrange,
          primaryColor: Colors.white,
          textTheme: Theme.of(context).textTheme.copyWith(
            caption: TextStyle(color: Colors.white)
          )
        ),
        child: BottomNavigationBar(
          currentIndex: _page,
          onTap: (p){
            _pageController.animateToPage(
                p,
                duration: Duration(milliseconds: 500),
                curve: Curves.ease
            );
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.pets),
              title: Text("Meus Pets")
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                title: Text("Calendário")
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                title: Text("Configurações")
            )
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (p){
          setState(() {
            _page = p;
          });
        },
        children: <Widget>[
          HomePet(),
          Container(color: Colors.pink,),
          Container(color: Colors.orange,)
        ],
      ),
    );
  }
}
