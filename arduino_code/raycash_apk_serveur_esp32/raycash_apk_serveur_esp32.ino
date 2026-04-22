#include <WiFi.h>
#include <HTTPClient.h>

// --- CONFIGURATION WI-FI ---
const char* ssid = "DESKTOP-1T7GA6N 9411";
const char* password = "sitraka12345";

// --- CONFIGURATION SERVEUR ---
// Remplace par l'IP de ton PC (celle que tu utilises dans Flutter)
const char* serverUrl = "http://192.168.1.104:5000/esp_signal"; 

// Définition des broches
const int pinBouton = 4;
const int pinBuzzer = 18;

// Variables d'état
int compteur = 0;
bool dernierEtatBouton = HIGH;
unsigned long dernierTempsDebounce = 0;
unsigned long delaiDebounce = 50; 

void setup() {
  Serial.begin(115200);
  
  pinMode(pinBouton, INPUT_PULLUP);
  pinMode(pinBuzzer, OUTPUT);

  // Connexion au Wi-Fi
  WiFi.begin(ssid, password);
  Serial.print("Connexion au Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWi-Fi connecté !");
  Serial.println("Système RecyCash prêt.");
}

void loop() {
  int lecture = digitalRead(pinBouton);

  if (lecture == LOW && dernierEtatBouton == HIGH && (millis() - dernierTempsDebounce) > delaiDebounce) {
    compteur++;
    dernierTempsDebounce = millis();

    if (compteur == 1) {
      Serial.println("Action: Démarrer");
      jouerSon(1000, 500); 
      envoyerSignalAServeur("START"); // Envoi au serveur
    } 
    else if (compteur == 2) {
      Serial.println("Action: Arrêter");
      jouerSon(500, 500);
      envoyerSignalAServeur("STOP");  // Envoi au serveur
      compteur = 0;
    }
  }
  dernierEtatBouton = lecture;
}

// Fonction pour communiquer avec Flask
void envoyerSignalAServeur(String action) {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    
    http.begin(serverUrl);
    http.addHeader("Content-Type", "application/json");

    // Création du JSON : {"action": "START"} ou {"action": "STOP"}
    String jsonPayload = "{\"action\":\"" + action + "\"}";
    
    int httpResponseCode = http.POST(jsonPayload);

    if (httpResponseCode > 0) {
      Serial.print("Réponse serveur : ");
      Serial.println(httpResponseCode);
    } else {
      Serial.print("Erreur d'envoi : ");
      Serial.println(httpResponseCode);
    }
    
    http.end();
  } else {
    Serial.println("Erreur : Wi-Fi déconnecté");
  }
}

void jouerSon(int frequence, int duree) {
  tone(pinBuzzer, frequence);
  delay(duree);
  noTone(pinBuzzer);
}