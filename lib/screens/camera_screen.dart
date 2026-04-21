import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  final Function(Map?) onResult;
  const CameraScreen({super.key, required this.onResult});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isAutoScanning = false;
  Timer? _timer;

  // REMPLACE PAR L'IP DE TON PC (Tape 'ipconfig' dans ton terminal PC)
  final String serverUrl = "http://192.168.1.104:5000/predict";

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(cameras.first, ResolutionPreset.medium, enableAudio: false);
    await _controller!.initialize();
    if (mounted) setState(() => _isInitialized = true);
  }

  // Fonction pour envoyer l'image au serveur Flask
  Future<void> _sendImageToServer() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile image = await _controller!.takePicture();
      
      var request = http.MultipartRequest('POST', Uri.parse(serverUrl));
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // On ajoute l'URL de l'image complète pour l'afficher dans DataScreen
        // On construit l'URL absolue car le serveur renvoie un chemin relatif
        data['full_image_url'] = "http://192.168.1.104:5000${data['image_url']}";
        widget.onResult(data);
      }
    } catch (e) {
      print("Erreur connexion serveur : $e");
    }
  }

  void _toggleAutoScan() {
    setState(() {
      _isAutoScanning = !_isAutoScanning;
    });

    if (_isAutoScanning) {
      // Démarre la capture toutes les 3 secondes
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _sendImageToServer();
      });
    } else {
      // Arrête le timer
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),
          
          // Viseur
          Center(
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: _isAutoScanning ? Colors.green : Colors.white, width: 3),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          // Bouton ON/OFF Auto-Scan
          Positioned(
            bottom: 40, left: 0, right: 0,
            child: Center(
              child: Column(
                children: [
                  Text(
                    _isAutoScanning ? "AUTO-SCAN ACTIF (3s)" : "MODE MANUEL",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _toggleAutoScan,
                    child: Container(
                      height: 80, width: 80,
                      decoration: BoxDecoration(
                        color: _isAutoScanning ? Colors.red : Colors.teal,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isAutoScanning ? Icons.stop : Icons.play_arrow,
                        color: Colors.white, size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}