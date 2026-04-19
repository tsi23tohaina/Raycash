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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
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
  
  // On stocke le dernier résultat ici pour pouvoir le voir dans l'onglet "Fiche"
  Map? _lastResult;

  void _updateResult(Map? result) {
    setState(() {
      _lastResult = result;
      _currentIndex = 1; // Bascule automatiquement sur la fiche après scan
    });
  }

  @override
  Widget build(BuildContext context) {
    // Liste des pages mise à jour dynamiquement
    final List<Widget> _pages = [
      CameraScreen(onResult: _updateResult), 
      DataScreen(result: _lastResult)
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.teal,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scanner'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Fiche'),
        ],
      ),
    );
  }
}