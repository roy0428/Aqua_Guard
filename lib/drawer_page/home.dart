import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const Example(path: 'assets/example1.png'),
    const Example(path: 'assets/example2.png'),
    const Example(path: 'assets/example3.png'),
    const Example(path: 'assets/example4.png'),
    const Example(path: 'assets/example5.png'),
    const Example(path: 'assets/example6.png'),
  ];

  List<BottomNavigationBarItem> getBottomNavBarItems() {
    return List.generate(
        6,
        (index) => const BottomNavigationBarItem(
              icon: Icon(Icons.circle),
              label: '',
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 53, 58, 83),
        title: const Text('Project Guide'),
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
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          },
          type: BottomNavigationBarType.fixed,
          items: getBottomNavBarItems()),
    );
  }
}

class Example extends StatelessWidget {
  final String path;
  const Example({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Image.asset(path),
                ))));
  }
}
