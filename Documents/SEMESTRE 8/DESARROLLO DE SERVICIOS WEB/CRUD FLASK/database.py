from pymongo import MongoClient
import certifi
MONGO_URI='mongodb://localhost:27017/'
co=certifi.where()

def dbConection():
    try:
        client=MongoClient(MONGO_URI,tlsCAFile=co)
        db=client["db_products_app"]
    except ConnectionError:
        print('Error de conexion con la base de datos')
    return db
