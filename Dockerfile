# Usamos una imagen de Python pequeña
FROM python:3.11-slim

# Directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiamos la lista de librerías e instalamos
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiamos el resto de archivos (nuestro script)
COPY . .

# Comando que se ejecuta al iniciar el contenedor
CMD ["python", "prueba_supabase.py"]