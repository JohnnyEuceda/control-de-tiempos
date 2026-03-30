import os
from dotenv import load_dotenv
from supabase import create_client

# Carga las variables del archivo .env
load_dotenv()

url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")

supabase = create_client(url, key)
# ... el resto de tu código de insertar() sigue igual

from supabase import create_client


def insertar():
    print("Intentando conectar con Supabase...")
    res = supabase.table("pruebas").insert({"nombre": "Marcel"}).execute()
    print("¡Respuesta de la base de datos!", res.data)

if __name__ == "__main__":
    insertar()