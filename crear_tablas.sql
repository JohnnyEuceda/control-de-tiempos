
-- =========================================
--  TABLAS DE CATÁLOGOS BASE
-- =========================================

-- 1. Se crea la tabla tipos_licencia
CREATE TABLE tipos_licencia (
    id_tipo_licencia SERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE
);

-- 2. Se crea la tabla tipos_camiones
CREATE TABLE tipos_camiones (
    id_tipo_camion SERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE
);

-- 3. Se crea la tabla tipos_combustibles
CREATE TABLE tipos_combustibles (
    id_tipo_combustible SERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE
);

-- 4. Se crea la tabla capacidades_camiones
CREATE TABLE capacidades_camiones (
    id_capacidad_camion SERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE
);

-- 5. Se crea la tabla marcas_vehiculos
CREATE TABLE marcas_vehiculos (
    id_marca_vehiculo SERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE
);

-- 6. Se crea la tabla tipos_distribucion
CREATE TABLE tipos_distribucion (
    id_tipo_distribucion SERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE
);

-- 7. Se crea la tabla tipos_asignacion
CREATE TABLE tipos_asignacion (
    id_tipo_asignacion SERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE
);

-- 8. Se crea la tabla zonas
CREATE TABLE zonas (
    id_zona SERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE
);

-- 9. Se crea la tabla tipos_sitios
CREATE TABLE tipos_sitios (
    id_tipo_sitio SERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE
);

-- 10. Se crea la tabla ciudades
CREATE TABLE ciudades (
    id_ciudad SERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE
);

-- =========================================
--  TABLAS CON DEPENDENCIAS
-- =========================================

-- 11. Se crea la tabla modelos_vehiculos
CREATE TABLE modelos_vehiculos (
    id_modelo_vehiculo SERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    id_marca_vehiculo INT NOT NULL,
    CONSTRAINT fk_modelo_marca FOREIGN KEY (id_marca_vehiculo)
        REFERENCES marcas_vehiculos(id_marca_vehiculo)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

-- 12. Se crea la tabla empresas
CREATE TABLE empresas (
    id_empresa SERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE,
    telefono VARCHAR(9) NOT NULL,
    observaciones TEXT,
    estado BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_tel_empresa CHECK (
        telefono ~ '^[0-9]{8}$' OR telefono ~ '^[0-9]{4}-[0-9]{4}$'
    )
);

-- 13. Se crea la tabla personas
CREATE TABLE personas (
    id_persona SERIAL PRIMARY KEY,
    dni VARCHAR(15) NOT NULL UNIQUE,
    nombre1 VARCHAR(30) NOT NULL,
    nombre2 VARCHAR(30),
    apellido1 VARCHAR(30) NOT NULL,
    apellido2 VARCHAR(30),
    telefono VARCHAR(9) NOT NULL,
    estado BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_dni CHECK (
        dni ~ '^[0-9]{13}$' OR dni ~ '^[0-9]{4}-[0-9]{4}-[0-9]{5}$'
    ),
    CONSTRAINT chk_tel CHECK (
        telefono ~ '^[0-9]{8}$' OR telefono ~ '^[0-9]{4}-[0-9]{4}$'
    )
);

-- 14. Se crea la tabla sitios
CREATE TABLE sitios (
    id_sitio SERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE,
    id_tipo_sitio INT NOT NULL,
    id_ciudad INT NOT NULL,
    latitud DECIMAL(10,2),
    longitud DECIMAL(10,2),
    estado BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_sitio_tipo FOREIGN KEY (id_tipo_sitio)
        REFERENCES tipos_sitios(id_tipo_sitio)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,
    CONSTRAINT fk_sitio_ciudad FOREIGN KEY (id_ciudad)
        REFERENCES ciudades(id_ciudad)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
);

-- 15. Se crea la tabla empleados
CREATE TABLE empleados (
    id_empleado SERIAL PRIMARY KEY,
    codigo_empleado VARCHAR(30) NOT NULL UNIQUE,
    id_persona INT NOT NULL,
    id_sitio INT NOT NULL,
    CONSTRAINT fk_emp_persona FOREIGN KEY (id_persona)
        REFERENCES personas(id_persona)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_emp_sitio FOREIGN KEY (id_sitio)
        REFERENCES sitios(id_sitio)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
);
-- 16. Se crea la tabla puertos
CREATE TABLE puertos (
    id_puerto SERIAL PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE,
    id_sitio INT NOT NULL,
    CONSTRAINT fk_puerto_sitio FOREIGN KEY (id_sitio)
        REFERENCES sitios(id_sitio)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 17. Se crea la tabla motoristas
CREATE TABLE motoristas (
    id_motorista SERIAL PRIMARY KEY,
    id_persona INT NOT NULL,
    id_tipo_licencia INT NOT NULL,
    id_empresa INT NOT NULL,
    CONSTRAINT fk_mot_persona FOREIGN KEY (id_persona)
        REFERENCES personas(id_persona)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_mot_licencia FOREIGN KEY (id_tipo_licencia)
        REFERENCES tipos_licencia(id_tipo_licencia)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,
    CONSTRAINT fk_mot_empresa FOREIGN KEY (id_empresa)
        REFERENCES empresas(id_empresa)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
);

-- 18. Se crea la tabla operadores_carga
CREATE TABLE operadores_carga (
    id_operario SERIAL PRIMARY KEY,
    dia_libre VARCHAR(30),
    observaciones TEXT,
    id_empleado INT NOT NULL,
    
    CONSTRAINT fk_operario_empleado FOREIGN KEY (id_empleado)
        REFERENCES empleados(id_empleado)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 19. Se crea la tabla encargados
CREATE TABLE encargados (
    id_encargado SERIAL PRIMARY KEY,
    usuario VARCHAR(30) NOT NULL UNIQUE,
    contrasenia VARCHAR(30) NOT NULL,
    id_empleado INT NOT NULL,
    
    CONSTRAINT fk_encargado_empleado FOREIGN KEY (id_empleado)
        REFERENCES empleados(id_empleado)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 20. Se crea la tabla camiones
CREATE TABLE camiones (
    id_camion SERIAL PRIMARY KEY,
    numero_registro VARCHAR(30) NOT NULL UNIQUE,
    placa VARCHAR(30) NOT NULL UNIQUE,
    numero_serie VARCHAR(30) NOT NULL UNIQUE,
    anio_camion INT NOT NULL CHECK (anio_camion > 1980),
    estado BOOLEAN NOT NULL DEFAULT TRUE,
    id_empresa INT NOT NULL,
    id_marca_vehiculo INT NOT NULL,
    id_modelo_vehiculo INT NOT NULL,
    id_tipo_camion INT NOT NULL,
    id_capacidad_camion INT NOT NULL,
    id_tipo_combustible INT NOT NULL,
    
    CONSTRAINT chk_placa CHECK (placa ~ '^[A-Z]{3}-[0-9]{4}$'),
    CONSTRAINT fk_cam_empresa FOREIGN KEY (id_empresa)
        REFERENCES empresas(id_empresa)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,
    CONSTRAINT fk_cam_marca FOREIGN KEY (id_marca_vehiculo)
        REFERENCES marcas_vehiculos(id_marca_vehiculo)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,
    CONSTRAINT fk_cam_modelo FOREIGN KEY (id_modelo_vehiculo)
        REFERENCES modelos_vehiculos(id_modelo_vehiculo)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_cam_tipo FOREIGN KEY (id_tipo_camion)
        REFERENCES tipos_camiones(id_tipo_camion)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,
    CONSTRAINT fk_cam_cap FOREIGN KEY (id_capacidad_camion)
        REFERENCES capacidades_camiones(id_capacidad_camion)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,
    CONSTRAINT fk_cam_comb FOREIGN KEY (id_tipo_combustible)
        REFERENCES tipos_combustibles(id_tipo_combustible)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
);

-- 21. Se crea la tabla rutas
CREATE TABLE rutas (
    id_ruta SERIAL PRIMARY KEY,
    numero_ruta INT NOT NULL UNIQUE,
    id_zona INT NOT NULL,
    distancia_max DECIMAL(10,2) CHECK (distancia_max >= 0),
    id_tipo_distribucion INT NOT NULL,
    id_sitio INT NOT NULL,
    CONSTRAINT fk_ruta_zona FOREIGN KEY (id_zona)
        REFERENCES zonas(id_zona)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,
    CONSTRAINT fk_ruta_tipo FOREIGN KEY (id_tipo_distribucion)
        REFERENCES tipos_distribucion(id_tipo_distribucion)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,
    CONSTRAINT fk_ruta_sitio FOREIGN KEY (id_sitio)
        REFERENCES sitios(id_sitio)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
-- 22. Se crea la tabla asignaciones
CREATE TABLE asignaciones (
    id_asignacion SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    id_camion INT NOT NULL,
    id_motorista INT NOT NULL,
    id_ruta INT NOT NULL,
    id_tipo_asignacion INT NOT NULL,
    
    CONSTRAINT fk_asig_camion FOREIGN KEY (id_camion)
        REFERENCES camiones(id_camion)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_asig_motorista FOREIGN KEY (id_motorista)
        REFERENCES motoristas(id_motorista)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,
    CONSTRAINT fk_asig_ruta FOREIGN KEY (id_ruta)
        REFERENCES rutas(id_ruta)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,
    CONSTRAINT fk_asig_tipo FOREIGN KEY (id_tipo_asignacion)
        REFERENCES tipos_asignacion(id_tipo_asignacion)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
);

-- 23. Se crea la tabla cargas
CREATE TABLE cargas (
    id_carga SERIAL PRIMARY KEY,
    inicio_carga TIMESTAMP NOT NULL,
    fin_carga TIMESTAMP NOT NULL,
    libraje DECIMAL(10,2) CHECK (libraje >= 0),
    observaciones TEXT,
    id_asignacion INT NOT NULL,
    id_puerto INT NOT NULL,
    id_encargado INT NOT NULL,
    
    CONSTRAINT chk_tiempo CHECK (fin_carga > inicio_carga),
    
    CONSTRAINT fk_carga_asig FOREIGN KEY (id_asignacion)
        REFERENCES asignaciones(id_asignacion)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_carga_puerto FOREIGN KEY (id_puerto)
        REFERENCES puertos(id_puerto)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,
    CONSTRAINT fk_carga_encargado FOREIGN KEY (id_encargado)
        REFERENCES encargados(id_encargado)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
);

-- 24. Se crea la tabla turnos
CREATE TABLE turnos (
    id_turno SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    observaciones TEXT,
    id_sitio INT NOT NULL,
   
    CONSTRAINT fk_turno_sitio FOREIGN KEY (id_sitio)
        REFERENCES sitios(id_sitio)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
-- 25. Se crea la tabla turnos_operarios
CREATE TABLE turnos_operarios (
    id_turno_operario SERIAL PRIMARY KEY,
    id_turno INT NOT NULL,
    id_operario INT NOT NULL,
    CONSTRAINT fk_to_turno FOREIGN KEY (id_turno)
        REFERENCES turnos(id_turno)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_to_operario FOREIGN KEY (id_operario)
        REFERENCES operadores_carga(id_operario)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
