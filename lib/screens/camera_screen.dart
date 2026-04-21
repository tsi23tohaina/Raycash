import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  final Function(Map) onResult;
  final String serverIP;
  final Function(String) onIPUpdate;

  const CameraScreen({
    super.key, 
    required this.onResult, 
    required this.serverIP, 
    required this.onIPUpdate
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isAutoScanning = false;
  bool _isProcessing = false;
  Timer? _timer;

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

  // MENU CACHÉ : Modifier l'IP
  void _showIPDialog() {
    TextEditingController _ipController = TextEditingController(text: widget.serverIP);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Config Serveur"),
        content: TextField(controller: _ipController, decoration: const InputDecoration(labelText: "IP du PC")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              widget.onIPUpdate(_ipController.text);
              Navigator.pop(context);
            }, 
            child: const Text("Sauver")
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndSend() async {
    if (_isProcessing || _controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isProcessing = true);
    try {
      final XFile image = await _controller!.takePicture();
      var request = http.MultipartRequest('POST', Uri.parse("http://${widget.serverIP}:5000/predict"));
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        data['full_image_url'] = "http://${widget.serverIP}:5000${data['image_url']}";
        widget.onResult(data);
      }
    } catch (e) {
      print("Erreur : $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _toggleScan() {
    setState(() => _isAutoScanning = !_isAutoScanning);
    if (_isAutoScanning) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_isAutoScanning) _captureAndSend();
      });
    } else {
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
              width: 260, height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: _isAutoScanning ? Colors.green : Colors.white, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Boutons
          Positioned(
            bottom: 40, left: 0, right: 0,
            child: Column(
              children: [
                GestureDetector(
                  onLongPress: _showIPDialog,
                  child: Text(
                    _isAutoScanning ? "AUTO-SCAN EN COURS..." : "PRÊT (Long pour IP)",
                    style: const TextStyle(color: Colors.white, backgroundColor: Colors.black45),
                  ),
                ),
                const SizedBox(height: 20),
                FloatingActionButton.large(
                  onPressed: _toggleScan,
                  backgroundColor: _isAutoScanning ? Colors.red : Colors.teal,
                  child: Icon(_isAutoScanning ? Icons.stop : Icons.play_arrow),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}