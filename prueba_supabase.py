from supabase import create_client

url = "https://aqkzoxuzhoqueferheql.supabase.co"
key = "sb_publishable_-33um-_x5kjNd7dJM7tESw_9lHlK94x"
supabase = create_client(url, key)

def insertar():
    print("Intentando conectar con Supabase...")
    res = supabase.table("pruebas").insert({"nombre": "Marcel desde Docker"}).execute()
    print("¡Respuesta de la base de datos!", res.data)

if __name__ == "__main__":
    insertar()