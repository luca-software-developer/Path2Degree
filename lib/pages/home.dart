import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path2degree/main.dart';
import 'package:path2degree/pages/categorie.dart';
import 'package:path2degree/pages/dashboard.dart';
import 'package:path2degree/pages/diari.dart';
import 'package:path2degree/pages/esami.dart';
import 'package:path2degree/pages/impostazioni.dart';
import 'package:path2degree/pages/informazioni.dart';
import 'package:path2degree/pages/statistiche.dart';
import 'package:share_plus/share_plus.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final _pageViewController = PageController(initialPage: 2);
  int _selectedIndex = 2;
  static const List<String> _widgetTitles = <String>[
    'Categorie',
    'Statistiche',
    'Dashboard',
    'Diari',
    'Esami'
  ];
  static const List<Widget> _widgetOptions = <Widget>[
    Categorie(),
    Statistiche(),
    Dashboard(),
    Diari(),
    Esami()
  ];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageViewController.animateToPage(_selectedIndex,
          duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(_widgetTitles[_selectedIndex],
                style: Theme.of(context).textTheme.displaySmall),
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () {
                    _controller.reset();
                    _controller.forward();
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
          ),
          drawer: Drawer(
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _controller.value * 2 * pi,
                                child: Image.asset(
                                  'assets/images/icon.png',
                                ),
                              );
                            },
                          ),
                        ),
                        Text(
                          Path2Degree.title,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Il mio Path2Degree',
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7)),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home_rounded),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.school_rounded),
                  title: const Text('Esami'),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedIndex = 4;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.book_rounded),
                  title: const Text('Diari'),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedIndex = 3;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.area_chart_rounded),
                  title: const Text('Statistiche'),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.category_rounded),
                  title: const Text('Categorie'),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Altro',
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7)),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.settings_rounded),
                  title: const Text('Impostazioni'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const Impostazioni()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_rounded),
                  title: const Text('Condividimi'),
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(
                      "Scarica ora l'app \"Path2Degree\", un vero upgrade per la gestione dei tuoi esami universitari!",
                      subject: "Scarica ora l'app \"Path2Degree\"",
                      sharePositionOrigin:
                          (context.findRenderObject() as RenderBox)
                                  .localToGlobal(Offset.zero) &
                              (context.findRenderObject() as RenderBox).size,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_rounded),
                  title: const Text('Informazioni'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const Informazioni()));
                  },
                ),
              ],
            ),
          ),
          body: PageView(
            controller: _pageViewController,
            children: _widgetOptions,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.category_rounded),
                  label: 'Categorie',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.area_chart_rounded),
                  label: 'Statistiche',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book_rounded),
                  label: 'Diari',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.school_rounded),
                  label: 'Esami',
                ),
              ],
              currentIndex: _selectedIndex,
              unselectedItemColor: Theme.of(context).colorScheme.onSurface,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              showUnselectedLabels: true,
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
