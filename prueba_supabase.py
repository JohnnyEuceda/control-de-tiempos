import os
from dotenv import load_dotenv
from supabase import create_client

# Carga las variables del archivo .env
load_dotenv()

url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")
supabase = create_client(url, key)


def mostrar_datos():
    print("\n--- Datos actuales en Supabase ---")
    try:
        # Traemos todos los datos de la tabla 'pruebas'
        res = supabase.table("pruebas").select("*").execute()
        if res.data:
            for fila in res.data:
                print(f"ID: {fila['id']} | Nombre: {fila['nombre']}")
        else:
            print("La tabla está vacía.")
    except Exception as e:
        print(f"Error al leer: {e}")


def insertar_dato():
    nuevo_nombre = input("\n Escribe el nombre para agregar: ")
    if nuevo_nombre.strip():
        try:
            res = supabase.table("pruebas").insert({"nombre": nuevo_nombre}).execute()
            print(f"Guardado con éxito: {res.data}")
        except Exception as e:
            print(f"Error al insertar: {e}")
    else:
        print("El nombre no puede estar vacío.")

def menu():
    while True:
        print("\n==============================")
        print("   MENÚ DE PRUEBAS SUPABASE   ")
        print("==============================")
        print("1. Ver datos (SELECT)")
        print("2. Agregar dato (INSERT)")
        print("3. Salir")
        
        opcion = input("\nSelecciona una opción (1-3): ")

        if opcion == "1":
            mostrar_datos()
        elif opcion == "2":
            insertar_dato()
        elif opcion == "3":
            print("¡Nos vemos!")
            break
        else:
            print("Opción no válida, intenta de nuevo.")

if __name__ == "__main__":
    menu()