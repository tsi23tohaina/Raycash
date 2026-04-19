import 'package:flutter/material.dart';

class DataScreen extends StatelessWidget {
  final Map? result; // On reçoit le résultat de l'IA

  const DataScreen({super.key, this.result});

  // Logique des points et noms propres
  Map<String, dynamic> _getWasteInfo(String label) {
    // Nettoyage du label (Teachable Machine ajoute souvent l'index devant "0 Aluminium")
    String cleanLabel = label.replaceAll(RegExp(r'[0-9]'), '').trim();

    switch (cleanLabel) {
      case "Aluminium":
        return {"points": 50, "color": Colors.orange, "name": "Aluminium"};
      case "Plastique":
        return {"points": 40, "color": Colors.blue, "name": "Plastique"};
      case "Verre":
        return {"points": 20, "color": Colors.green, "name": "Verre"};
      case "Papier/Carton":
        return {"points": 10, "color": Colors.brown, "name": "Papier / Carton"};
      default:
        return {"points": 0, "color": Colors.grey, "name": "Inconnu"};
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si result est nul (threshold non atteint), on force "Inconnu"
    final String label = result != null ? result!['label'] : "Inconnu";
    final double confidence = result != null ? result!['confidence'] * 100 : 0.0;
    final info = _getWasteInfo(label);

    return Scaffold(
      appBar: AppBar(title: const Text("Résultat de l'Analyse")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  children: [
                    Icon(
                      label == "Inconnu" ? Icons.help_outline : Icons.check_circle_outline,
                      size: 80,
                      color: info['color'],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      info['name'].toUpperCase(),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: info['color']),
                    ),
                    Text("Confiance : ${confidence.toStringAsFixed(1)}%"),
                    const Divider(height: 30),
                    _buildRow("Valeur :", "${info['points']} Points"),
                    _buildRow("Statut :", label == "Inconnu" ? "Non recyclable" : "Recyclable"),
                    const SizedBox(height: 20),
                    if (label != "Inconnu")
                      Text(
                        "Bravo ! Vous aidez à protéger l'environnement de Madagascar.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.replay),
              label: const Text("Scanner un autre déchet"),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}