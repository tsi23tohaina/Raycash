from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from werkzeug.utils import secure_filename

app = Flask(__name__)
CORS(app)  # Permet à l'APK de communiquer avec le PC

# Configuration du dossier de stockage des images
UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

@app.route('/test', methods=['GET'])
def test_connection():
    """Route simple pour tester si le téléphone voit le PC"""
    return jsonify({
        "status": "online",
        "message": "Connexion établie avec le serveur Raycash !",
        "location": "Antananarivo"
    })

@app.route('/predict', methods=['POST'])
def predict_waste():
    """Route pour recevoir l'image et simuler l'IA"""
    if 'image' not in request.files:
        return jsonify({"error": "Aucune image reçue"}), 400
    
    file = request.files['image']
    if file.filename == '':
        return jsonify({"error": "Nom de fichier vide"}), 400

    # Sauvegarde de l'image sur le PC
    filename = secure_filename(file.filename)
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(filepath)

    # SIMULATION DE L'IA (On remplacera cela par ton modèle plus tard)
    # Imaginons que ton modèle détecte une bouteille plastique
    prediction = {
        "label": "Bouteille en Plastique",
        "recyclable": True,
        "points": 10,
        "conseil": "Veuillez retirer le bouchon avant de recycler."
    }
    
    print(f"Image reçue et sauvegardée : {filename}")
    return jsonify(prediction)

if __name__ == '__main__':
    # host='0.0.0.0' permet l'accès via le Wi-Fi
    app.run(host='0.0.0.0', port=5000, debug=True)