import 'package:flutter/material.dart';

class DataScreen extends StatelessWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fiche Technique")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildFiche(),
            const SizedBox(height: 30),
            TextField(
              decoration: InputDecoration(
                labelText: "Envoyer cette fiche à (Email)",
                prefixIcon: const Icon(Icons.email),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {},
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiche() {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("PROJET RAYCASH - RAPPORT", 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const Divider(),
            const Text("Analyse du capteur : OK"),
            const Text("Volume détecté : 45L"),
            const Text("Type : Plastique recyclé"),
            const SizedBox(height: 20),
            const Center(child: Icon(Icons.qr_code_2, size: 100)),
          ],
        ),
      ),
    );
  }
}