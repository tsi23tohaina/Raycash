# 🌀 RayCash : Reverse Vending Machine (RVM) Intelligente

**RayCash** est un projet de station de collecte automatisée qui transforme les déchets recyclables en valeur monétaire. Contrairement à une poubelle classique, cette machine "achète" les déchets triés aux citoyens, fonctionnant sur le principe du **Reverse Vending** (Automate de Déconsignation).

---

## 🎯 Le Concept : Reverse Vending

L'idée est simple : l'utilisateur rend un contenant (bouteille, canette) et la machine lui rend une consigne sous forme de points convertibles en argent ou bons d'achat.

1.  **Insertion** : L'utilisateur dépose le déchet dans l'automate.
2.  **Reconnaissance** : Une IA identifie le matériau et vérifie sa recyclabilité.
3.  **Tri** : Le déchet est dirigé vers le bac de stockage approprié.
4.  **Récompense** : Le compte de l'utilisateur est crédité instantanément.

---

## 🏗️ Architecture Technique du Système

Le projet repose sur une synergie entre le matériel, l'intelligence artificielle et une interface mobile.

### 🔵 Interface de Contrôle (ESP32)
Le microcontrôleur simule les capteurs et les actuateurs d'une RVM réelle.
* **Actionneur** : Bouton poussoir pour simuler l'ouverture/fermeture de la trappe ou le déclenchement du dépôt.
* **Feedback** : Buzzer pour confirmer la prise en compte du déchet par un signal sonore.
* **Connectivité** : Envoie les signaux de commande au serveur central via Wi-Fi (HTTP POST).

### 🟢 Intelligence Artificielle (Serveur Flask)
Le moteur de reconnaissance visuelle et le centre de communication.
* **Modèle** : TensorFlow Lite optimisé pour une inférence rapide sur PC/Edge.
* **Classes** : Aluminium, Plastique (PET), Verre, Papier/Carton.
* **Temps Réel** : Communication bidirectionnelle via **WebSockets (Socket.IO)** pour piloter l'application mobile instantanément.

### 🔴 Interface Utilisateur (Flutter)
L'écran de bord de la machine et le portefeuille numérique de l'utilisateur.
* **Scan Auto** : La capture d'image est déclenchée à distance par les signaux de l'ESP32.
* **Portefeuille** : Affiche en temps réel les points accumulés et le cumul d'argent gagné durant la session.

---

## 🔄 Flux de l'Utilisateur (User Flow)

1.  **Identification** : L'utilisateur s'approche de la borne avec son application ouverte.
2.  **Démarrage** : Un appui sur le bouton physique de la machine lance la session (le bouton de l'app passe au rouge).
3.  **Analyse** : La caméra analyse le déchet. Si une canette d'aluminium est détectée, le système valide 50 points.
4.  **Calcul des Gains** :
    * **1 déchet plastique** = 40 Pts.
    * **1 déchet aluminium** = 50 Pts.
    * *Note : La conversion monétaire est définie dynamiquement par l'administrateur.*
5.  **Paiement** : À la fin de la session (second appui sur le bouton), le total est transféré sur le compte **RayCash** de l'utilisateur.

---

## 🌍 Impact Environnemental & Social

RayCash apporte une réponse technologique concrète aux défis écologiques à Madagascar :

* **Réduction de la pollution** : Incitation directe à ne plus jeter de plastique ou d'aluminium dans les rues.
* **Soutien financier** : Création d'une source de revenus complémentaire pour les citoyens via l'économie circulaire.
* **Data** : Collecte de statistiques précises sur le volume de recyclage par quartier pour optimiser la collecte.

---

## 🛠️ Installation Rapide

1.  **Clonez** les dépôts (Flutter, Flask, ESP32).
2.  **Serveur** : Lancez `main.py` sur votre PC (Python 3.x).
3.  **Matériel** : Téléversez le code `.ino` sur l'ESP32 après avoir configuré le Wi-Fi et l'IP du serveur.
4.  **Mobile** : Installez l'APK sur le smartphone.
5.  **Réseau** : Connectez tous les appareils sur le **même point d'accès Wi-Fi**.

Fin