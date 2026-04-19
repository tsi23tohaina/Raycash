import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';

class CameraScreen extends StatefulWidget {
  final Function(Map?) onResult;
  const CameraScreen({super.key, required this.onResult});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _initCameraAndModel();
  }

  Future<void> _initCameraAndModel() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(cameras.first, ResolutionPreset.low, enableAudio: false);
    await _controller!.initialize();

    await Tflite.loadModel(
      model: "assets/models/model.tflite",
      labels: "assets/models/labels.txt",
      numThreads: 2, // Limite à 2 ou 4 maximum pour éviter le crash
      isAsset: true,
    );

    setState(() => _isInitialized = true);
  }

  Future<void> _analyzeNow() async {
  if (_isAnalyzing || _controller == null || !_controller!.value.isInitialized) return;
  
  setState(() => _isAnalyzing = true);

  try {
    // 1. Capture d'image
    final XFile image = await _controller!.takePicture();

    // 2. Lancement de l'IA dans un micro-delay pour laisser l'UI respirer
    await Future.delayed(const Duration(milliseconds: 100));

    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1,
      threshold: 0.5, // Un peu plus bas pour être plus flexible
      imageMean: 127.5,
      imageStd: 127.5,
    );

    if (recognitions != null && recognitions.isNotEmpty) {
      widget.onResult(recognitions[0]);
    } else {
      widget.onResult(null);
    }
    
  } catch (e) {
    print("Erreur critique : $e");
  } finally {
    if (mounted) setState(() => _isAnalyzing = false);
  }
}

  @override
  void dispose() {
    Tflite.close(); // LIBÈRE LA MÉMOIRE DE L'IA
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
          
          // Cadre de visée
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isAnalyzing ? Colors.orange : Colors.white.withOpacity(0.5), 
                  width: 3
                ),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          // Bouton unique en bas
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _analyzeNow,
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: _isAnalyzing ? Colors.grey : Colors.teal,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
                  ),
                  child: _isAnalyzing 
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Icon(Icons.auto_awesome, color: Colors.white, size: 35),
                ),
              ),
            ),
          ),
          
          if (_isAnalyzing)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: const Text("Analyse en cours...", style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 