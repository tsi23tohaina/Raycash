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

# --- CONFIGURATION DES CHEMINS ---
MODEL_PATH = "models/model.tflite"
LABEL_PATH = "models/labels.txt"
UPLOAD_FOLDER = "uploads"

os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# --- CHARGEMENT DE L'IA ---
labels = []
interpreter = None
input_details = None
output_details = None
input_shape = None

try:
    with open(LABEL_PATH, 'r') as f:
        labels = [line.strip() for line in f.readlines()]
    
    interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
    interpreter.allocate_tensors()

    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    input_shape = input_details[0]['shape']
    print(f"✅ Modèle chargé avec succès. Type attendu : {input_details[0]['dtype']}")
    print(f"✅ Taille d'entrée : {input_shape[1]}x{input_shape[2]}")
except Exception as e:
    print(f"❌ ERREUR CHARGEMENT IA : {e}")

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(UPLOAD_FOLDER, filename)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({"error": "Aucune image reçue"}), 400
    
    file = request.files['image']
    
    try:
        # 1. Sauvegarde de l'image
        filename = f"capture_{int(time.time())}.jpg"
        filepath = os.path.join(UPLOAD_FOLDER, filename)
        
        image_bytes = file.read()
        img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
        img.save(filepath)

        # 2. Prétraitement pour modèle UINT8 (Correction ici)
        target_width = input_shape[1]
        target_height = input_shape[2]
        
        img_resized = img.resize((target_width, target_height))
        
        # On utilise uint8 car ton modèle est quantifié (UINT8)
        img_array = np.array(img_resized, dtype=np.uint8) 
        
        # On ajoute la dimension batch [1, H, W, 3]
        img_array = np.expand_dims(img_array, axis=0)

        # 3. Inférence
        interpreter.set_tensor(input_details[0]['index'], img_array)
        interpreter.invoke()
        
        # Récupération des scores
        output_data = interpreter.get_tensor(output_details[0]['index'])[0]
        
        # Si le modèle renvoie des entiers (0-255), on convertit en probabilité (0-1)
        if output_data.dtype == np.uint8:
            output_data = output_data / 255.0
            
        best_index = np.argmax(output_data)
        confidence = float(output_data[best_index])

        # 4. Résultat
        if confidence > 0.5:
            label = labels[best_index]
        else:
            label = "Inconnu"

        print(f"🎯 Prediction: {label} ({confidence:.2%})")

        return jsonify({
            "label": label,
            "confidence": f"{confidence*100:.1f}%",
            "image_url": f"/uploads/{filename}"
        })

    except Exception as e:
        print(f"🔥 Erreur Predict: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True, use_reloader=False)