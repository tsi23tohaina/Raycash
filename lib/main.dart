import 'package:flutter/material.dart';
import 'screens/camera_screen.dart';
import 'screens/data_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ReycashApp());
}

class ReycashApp extends StatelessWidget {
  const ReycashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReyCash',
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
  String _currentIP = "192.168.1.104"; // IP par défaut
  List<Map> _scannedItems = []; // Liste de tous les déchets scannés dans la session

  // Fonction pour changer l'IP (appelée depuis le menu caché)
  void _updateIP(String newIP) {
    setState(() {
      _currentIP = newIP;
    });
  }

  // Ajoute un déchet à la liste
  void _addResult(Map result) {
    setState(() {
      _scannedItems.add(result);
    });
  }

  // Réinitialise la session
  void _resetSession() {
    setState(() {
      _scannedItems.clear();
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      CameraScreen(
        onResult: _addResult, 
        serverIP: _currentIP, 
        onIPUpdate: _updateIP
      ),
      DataScreen(
        items: _scannedItems, 
        onReset: _resetSession,
        serverIP: _currentIP,
      )
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.teal,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scanner'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Session'),
        ],
      ),
    );
  }
}