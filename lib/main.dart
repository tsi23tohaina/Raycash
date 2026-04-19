import 'package:flutter/material.dart';
import 'screens/camera_screen.dart';
import 'screens/data_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RaycashApp());
}

class RaycashApp extends StatelessWidget {
  const RaycashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Raycash Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const NavigationHub(),
    );
  }
}

class NavigationHub extends StatefulWidget {
  const NavigationHub({super.key});

  @override
  State<NavigationHub> createState() => _NavigationHubState();
}

class _NavigationHubState extends State<NavigationHub> {
  int _currentIndex = 0;
  final List<Widget> _pages = [const CameraScreen(), const DataScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Caméra'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Fiche'),
        ],
      ),
    );
  }
}