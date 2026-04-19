import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high, // Haute résolution pour tes analyses
      enableAudio: true,
    );

    try {
      await _controller!.initialize();
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint("Erreur caméra: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Calcul du ratio pour l'affichage plein écran sans déformation
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Scaffold(
      appBar: AppBar(title: const Text("Capture Vidéo")),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
              ),
            ),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Bouton Play / Start Recording
          IconButton.filled(
            onPressed: _isRecording ? null : _startVideo,
            icon: const Icon(Icons.play_arrow),
          ),
          // Bouton Stop
          IconButton.filled(
            onPressed: _isRecording ? _stopVideo : null,
            icon: const Icon(Icons.stop)
           
          ),
          // Bouton Photo
          IconButton.filledTonal(
            onPressed: _takePhoto,
            icon: const Icon(Icons.camera_alt),
          ),
          // Bouton Save (Simulation)
          IconButton.filledTonal(
            onPressed: () => _showMsg("Données sauvegardées"),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
    );
  }

  Future<void> _startVideo() async {
    await _controller!.startVideoRecording();
    setState(() => _isRecording = true);
  }

  Future<void> _stopVideo() async {
    final file = await _controller!.stopVideoRecording();
    setState(() => _isRecording = false);
    _showMsg("Vidéo enregistrée : ${file.name}");
  }

  Future<void> _takePhoto() async {
    final file = await _controller!.takePicture();
    _showMsg("Photo capturée : ${file.name}");
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}