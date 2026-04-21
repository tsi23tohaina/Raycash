import 'package:flutter/material.dart';

class DataScreen extends StatelessWidget {
  final List<Map> items;
  final VoidCallback onReset;
  final String serverIP;

  const DataScreen({
    super.key, 
    required this.items, 
    required this.onReset,
    required this.serverIP
  });

  // Logique des points simplifiée
  Map<String, dynamic> _getInfo(String label) {
    String clean = label.replaceAll(RegExp(r'[0-9]'), '').trim();
    if (clean == "Aluminium") return {"pts": 50, "color": Colors.orange};
    if (clean == "Plastique") return {"pts": 40, "color": Colors.blue};
    if (clean == "Verre") return {"pts": 20, "color": Colors.green};
    if (clean == "Papier" || clean == "Carton") return {"pts": 10, "color": Colors.brown};
    return {"pts": 0, "color": Colors.grey};
  }

  @override
  Widget build(BuildContext context) {
    int totalPoints = items.fold(0, (sum, item) => sum + (_getInfo(item['label'])['pts'] as int));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ma Récolte ReyCash"),
        actions: [IconButton(onPressed: onReset, icon: const Icon(Icons.delete_sweep, color: Colors.red))],
      ),
      body: items.isEmpty
          ? const Center(child: Text("Aucun déchet scanné. Commencez le scan !"))
          : Column(
              children: [
                // Résumé des points
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.teal.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total : ${items.length} objets", style: const TextStyle(fontSize: 18)),
                      Text("$totalPoints Points", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
                    ],
                  ),
                ),
                // Liste des images et labels
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final info = _getInfo(item['label']);
                      return ListTile(
                        leading: Image.network(item['full_image_url'], width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(item['label'].toUpperCase()),
                        subtitle: Text("Confiance : ${item['confidence']}"),
                        trailing: Text("+${info['pts']} pts", style: TextStyle(color: info['color'], fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
                // Section Email
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Entrez votre email",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: Colors.teal),
                        onPressed: () {
                          // Logique de simulation d'envoi
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Rapport envoyé à l'adresse indiquée !"))
                          );
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}