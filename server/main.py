import os
import numpy as np
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from flask_socketio import SocketIO, emit # Importation ajoutée
import tensorflow as tf
from PIL import Image
import io
import time

app = Flask(__name__)
CORS(app)
# Initialisation de SocketIO
socketio = SocketIO(app, cors_allowed_origins="*") 

# --- CONFIGURATION ---
MODEL_PATH = "models/model.tflite"
LABEL_PATH = "models/labels.txt"
UPLOAD_FOLDER = "uploads"

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

# --- CHARGEMENT DE L'IA ---
labels = []
interpreter = None
input_details = None
output_details = None
input_shape = None

try:
    if os.path.exists(LABEL_PATH):
        with open(LABEL_PATH, 'r') as f:
            labels = [line.strip() for line in f.readlines()]
    else:
        labels = ["Aluminium", "Plastique", "Verre", "Papier", "Carton", "Inconnu"]

    interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    input_shape = input_details[0]['shape']
    
    print(f"✅ Serveur ReyCash prêt !")
    print(f"📊 Classes détectées : {labels}")
except Exception as e:
    print(f"❌ ERREUR INITIALISATION : {e}")

# --- ROUTES ---

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(UPLOAD_FOLDER, filename)

# NOUVELLE ROUTE : Pour recevoir le signal de l'ESP32
@app.route('/esp_signal', methods=['POST'])
def esp_signal():
    data = request.json
    action = data.get("action") # "START" ou "STOP"
    print(f"📢 Signal ESP32 reçu : {action}")
    
    # On envoie l'ordre à Flutter instantanément via WebSocket
    socketio.emit('command_from_esp', {'action': action})
    return jsonify({"status": "signal_relayed"}), 200

# ROUTE EXISTANTE : Prédiction IA (appelée par Flutter)
@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({"error": "Aucune image reçue"}), 400
    
    file = request.files['image']
    try:
        timestamp = int(time.time())
        filename = f"capture_{timestamp}.jpg"
        filepath = os.path.join(UPLOAD_FOLDER, filename)
        
        image_bytes = file.read()
        img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
        img.save(filepath)

        img_resized = img.resize((input_shape[1], input_shape[2]))
        img_array = np.array(img_resized, dtype=np.uint8) 
        img_array = np.expand_dims(img_array, axis=0)

        interpreter.set_tensor(input_details[0]['index'], img_array)
        interpreter.invoke()
        
        output_data = interpreter.get_tensor(output_details[0]['index'])[0]
        
        if output_data.dtype == np.uint8:
            output_data = output_data / 255.0
            
        best_index = np.argmax(output_data)
        confidence = float(output_data[best_index])

        if confidence > 0.45 and best_index < len(labels):
            label = labels[best_index]
        else:
            label = "Inconnu"

        print(f"🎯 [{timestamp}] {label} ({confidence:.2%})")

        return jsonify({
            "label": label,
            "confidence": f"{confidence*100:.1f}%",
            "image_url": f"/uploads/{filename}"
        })

    except Exception as e:
        print(f"🔥 Erreur : {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # TRÈS IMPORTANT : Utiliser socketio.run pour activer le mode temps réel
    socketio.run(app, host='0.0.0.0', port=5000, debug=False, use_reloader=False)