import 'package:flutter/material.dart';

class Home_Page extends StatefulWidget {
  @override
  _Home_PageState createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();
  final List<Widget> _pages = [
    Example1(),
    Example2(),
    Example3(),
    Example4(),
    Example5(),
    Example6(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 53, 58, 83),
        title: Text('Project Guide'),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: '',
          ),
        ],
      ),
    );
  }
}

class Example1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Container(
                color: Colors.black,
                child: Padding(
                  padding: EdgeInsets.all(1.0),
                  child: Image.asset('assets/example1.png'),
                ))));
  }
}

class Example2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Container(
                color: Colors.black,
                child: Padding(
                  padding: EdgeInsets.all(1.0),
                  child: Image.asset('assets/example2.png'),
                ))));
  }
}

class Example3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Container(
                color: Colors.black,
                child: Padding(
                  padding: EdgeInsets.all(1.0),
                  child: Image.asset('assets/example3.png'),
                ))));
  }
}

class Example4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Container(
                color: Colors.black,
                child: Padding(
                  padding: EdgeInsets.all(1.0),
                  child: Image.asset('assets/example4.png'),
                ))));
  }
}

class Example5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Container(
                color: Colors.black,
                child: Padding(
                  padding: EdgeInsets.all(1.0),
                  child: Image.asset('assets/example5.png'),
                ))));
  }
}

class Example6 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Container(
                color: Colors.black,
                child: Padding(
                  padding: EdgeInsets.all(1.0),
                  child: Image.asset('assets/example6.png'),
                ))));
  }
}
