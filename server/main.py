import os
import numpy as np
from flask import Flask, request, jsonify, render_template, send_from_directory
from flask_cors import CORS
import tensorflow as tf
from PIL import Image
import io
import time

app = Flask(__name__)
CORS(app)

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
    # On charge les 6 classes depuis ton fichier labels.txt
    if os.path.exists(LABEL_PATH):
        with open(LABEL_PATH, 'r') as f:
            labels = [line.strip() for line in f.readlines()]
    else:
        # Fallback si le fichier est absent
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

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(UPLOAD_FOLDER, filename)

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({"error": "Aucune image reçue"}), 400
    
    file = request.files['image']
    
    try:
        # 1. Sauvegarde propre
        timestamp = int(time.time())
        filename = f"capture_{timestamp}.jpg"
        filepath = os.path.join(UPLOAD_FOLDER, filename)
        
        image_bytes = file.read()
        img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
        img.save(filepath)

        # 2. Prétraitement UINT8
        img_resized = img.resize((input_shape[1], input_shape[2]))
        img_array = np.array(img_resized, dtype=np.uint8) 
        img_array = np.expand_dims(img_array, axis=0)

        # 3. Inférence
        interpreter.set_tensor(input_details[0]['index'], img_array)
        interpreter.invoke()
        
        output_data = interpreter.get_tensor(output_details[0]['index'])[0]
        
        # Conversion si UINT8
        if output_data.dtype == np.uint8:
            output_data = output_data / 255.0
            
        best_index = np.argmax(output_data)
        confidence = float(output_data[best_index])

        # 4. Logique de décision
        # On s'assure que l'index existe dans notre liste de labels
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
    # host='0.0.0.0' est INDISPENSABLE pour la connexion avec le téléphone
    app.run(host='0.0.0.0', port=5000, debug=False, use_reloader=False)