from flask import Flask,render_template,request,Response,jsonify,redirect,url_for
from pymongo import MongoClient
import os
import uuid

app = Flask(__name__)

# Conectar a MongoDB (puedes cambiar el URI si es necesario)
client = MongoClient('mongodb://localhost:27017/')
db = client['image_db']  # Base de datos donde se almacenarán las URLs
images_collection = db['images']  # Colección para almacenar las URLs de las imágenes

@app.route('/')
def home():
    return render_template('index.html')

# Directorio donde se guardarán las imágenes subidas
UPLOAD_FOLDER = 'uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

# Asegúrate de que solo se suban imágenes
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Función para verificar las extensiones de los archivos permitidos
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Ruta para cargar la imagen
@app.route('/upload', methods=['POST'])
def upload_image():
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400
    
    file = request.files['file']
    
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400
    
    if file and allowed_file(file.filename):
        # Generar un nombre único para el archivo usando uuid
        unique_filename = str(uuid.uuid4()) + os.path.splitext(file.filename)[1]
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], unique_filename)
        
        # Guardar el archivo en el servidor
        file.save(file_path)
        
        # Generar una URL única para la imagen
        image_url = f"http://127.0.0.1:5000/uploads/{unique_filename}"
        
        # Guardar la URL en MongoDB
        images_collection.insert_one({'filename': unique_filename, 'url': image_url})
        
        return jsonify({"message": "Image uploaded successfully", "url": image_url}), 200
    else:
        return jsonify({"error": "File type not allowed"}), 400

# Ruta para servir las imágenes desde el directorio 'uploads'
@app.route('/uploads/<filename>')
def serve_image(filename):
    return app.send_from_directory(app.config['UPLOAD_FOLDER'], filename)

if __name__ == '__main__':
    app.run(debug=True)