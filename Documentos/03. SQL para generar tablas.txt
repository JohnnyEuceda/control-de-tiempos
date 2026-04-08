
-- =========================================
--  TABLAS CATALOGOS BASE
-- =========================================

--0. Se crea la tabla dias_semana
create table dias_semana (
    id_dia_semana serial primary key,
    nombre varchar(20) not null unique
);

-- 1. Se crea la tabla tipos_licencia
create table tipos_licencia (
    id_tipo_licencia serial primary key,
    nombre varchar(30) not null unique
);

-- 2. Se crea la tabla tipos_camiones
create table tipos_camiones (
    id_tipo_camion serial primary key,
    nombre varchar(30) not null unique
);

-- 3. Se crea la tabla tipos_combustibles
create table tipos_combustibles (
    id_tipo_combustible serial primary key,
    nombre varchar(30) not null unique
);

-- 4. Se crea la tabla capacidades_camiones
create table capacidades_camiones (
    id_capacidad_camion serial primary key,
    nombre varchar(30) not null unique
);

-- 5. Se crea la tabla marcas_camiones
create table marcas_camiones (
    id_marca_camion serial primary key,
    nombre varchar(30) not null unique
);

-- 6. Se crea la tabla tipos_distribucion
create table tipos_distribucion (
    id_tipo_distribucion serial primary key,
    nombre varchar(30) not null unique
);

-- 7. Se crea la tabla tipos_asignacion
create table tipos_asignacion (
    id_tipo_asignacion serial primary key,
    nombre varchar(30) not null unique
);

-- 8. Se crea la tabla zonas
create table zonas (
    id_zona serial primary key,
    nombre varchar(30) not null unique
);

-- 9. Se crea la tabla tipos_centros_distribucion
create table tipos_centros_distribucion (
    id_tipo_centro_distribucion serial primary key,
    nombre varchar(30) not null unique
);

-- 10. Se crea la tabla paises
create table paises (
    id_pais serial primary key,
    nombre varchar(30) not null unique
);

-- =========================================
--  tablas con dependencias
-- =========================================

-- 11. Se crea la tabla departamentos
create table departamentos (
    id_departamento serial primary key,
    nombre varchar(30) not null,
    id_pais int not null,
    constraint fk_pais foreign key (id_pais)
        references paises(id_pais)
        on delete restrict 
        on update restrict,
    constraint uq_departamento_pais unique (nombre, id_pais)
);

-- 12. Se crea la tabla ciudades
create table ciudades (
    id_ciudad serial primary key,
    nombre varchar(30) not null,
    id_departamento int not null,
    constraint fk_departamento foreign key (id_departamento)
        references departamentos(id_departamento)
        on delete restrict 
        on update restrict,
    constraint uq_ciudad_depto unique (nombre,id_departamento)
);

-- 13. Se crea la tabla modelos_camiones
create table modelos_camiones (
    id_modelo_camion serial primary key,
    nombre varchar(30) not null,
    id_marca_camion int not null,
    constraint fk_modelo_marca foreign key (id_marca_camion)
        references marcas_camiones(id_marca_camion)
        on delete restrict 
        on update restrict,
    --No se puede repetir el modelo dentro de la marca
    constraint uq_modelo_por_marca unique(nombre, id_marca_camion)
);

-- 14. Se crea la tabla empresas
create table empresas (
    id_empresa serial primary key,
    nombre varchar(30) not null unique,
    telefono varchar(9) not null,
    observaciones text,
    estado boolean not null default true,
    constraint chk_tel_empresa check (
        telefono ~ '^[0-9]{8}$' or telefono ~ '^[0-9]{4}-[0-9]{4}$'
    )
);

-- 15. Se crea la tabla personas
create table personas (
    id_persona serial primary key,
    dni varchar(15) not null unique,
    nombre1 varchar(30) not null,
    nombre2 varchar(30),
    apellido1 varchar(30) not null,
    apellido2 varchar(30),
    telefono varchar(9) not null,
    estado boolean not null default true,
    constraint chk_dni check (
        dni ~ '^[0-9]{13}$' or dni ~ '^[0-9]{4}-[0-9]{4}-[0-9]{5}$'
    ),
    constraint chk_tel check (
        telefono ~ '^[0-9]{8}$' or telefono ~ '^[0-9]{4}-[0-9]{4}$'
    )
);

-- 16. Se crea la tabla centros_distribucion
create table centros_distribucion (
    id_centro_distribucion serial primary key,
    nombre varchar(30) not null,
    id_tipo_centro_distribucion int not null,
    id_pais int not null,
    id_departamento int not null,
    id_ciudad int not null,
    latitud decimal(9,6),
    longitud decimal(9,6),
    estado boolean not null default true,

    -- Llaves Foráneas Básicas
    constraint fk_centro_tipo foreign key (id_tipo_centro_distribucion)
        references tipos_centros_distribucion(id_tipo_centro_distribucion)
        on delete restrict
        on update restrict,
    constraint fk_centro_pais foreign key (id_pais)
        references paises(id_pais)
        on delete restrict
        on update restrict,
    constraint fk_centro_depto foreign key (id_departamento)
        references departamentos(id_departamento)
        on delete restrict
        on update restrict,
    constraint fk_centro_ciudad foreign key (id_ciudad)
        references ciudades(id_ciudad)
        on delete restrict
        on update restrict,

    -- Validación 1: nombre único por ciudad 
    constraint uq_nombre_centro_por_ciudad unique (nombre, id_ciudad)
);
-- validación 2: trigger para asegurar la jerarquía geográfica correcta 
create or replace function validar_geografia_centro() 
returns trigger as $$
begin -- 1. verificar que el departamento pertenezca al país seleccionado 
    if not exists ( 
        select 1 from departamentos 
        where id_departamento = new.id_departamento and id_pais = new.id_pais 
    ) then 
        raise exception 'El departamento seleccionado no pertenece al país elegido.'; 
    end if; 
    -- 2. verificar que la ciudad pertenezca al departamento seleccionado
    if not exists ( 
        select 1 from ciudades 
        where id_ciudad = new.id_ciudad and id_departamento = new.id_departamento 
        ) then 
            raise exception 'la ciudad seleccionada no pertenece al departamento elegido.'; 
        end if;

        return new;
end; 
$$ language plpgsql;
create trigger tg_validar_geografia_centro
before insert or update on centros_distribucion
for each row execute function validar_geografia_centro();


-- 17. Se crea la tabla empleados
create table empleados (
    id_empleado serial primary key,
    codigo_empleado varchar(30) not null unique,
    id_persona int not null unique,
    id_centro_distribucion int not null,
    constraint fk_emp_persona foreign key (id_persona)
        references personas(id_persona)
        on delete restrict 
        on update restrict,
    constraint fk_emp_centro foreign key (id_centro_distribucion)
        references centros_distribucion(id_centro_distribucion)
        on delete restrict
        on update restrict
);
-- 18. Se crea la tabla puertos
create table puertos (
    id_puerto serial primary key,
    nombre varchar(30) not null,
    id_centro_distribucion int not null,
    constraint fk_puerto_centro foreign key (id_centro_distribucion)
        references centros_distribucion(id_centro_distribucion)
        on delete cascade
        on update cascade,
    constraint uq_puerto_por_centro unique (nombre,id_centro_distribucion)
);

-- 19. Se crea la tabla motoristas
create table motoristas (
    id_motorista serial primary key,
    id_persona int not null unique,
    id_tipo_licencia int not null,
    id_empresa int not null,
    constraint fk_mot_persona foreign key (id_persona)
        references personas(id_persona)
        on delete restrict 
        on update restrict,
    constraint fk_mot_licencia foreign key (id_tipo_licencia)
        references tipos_licencia(id_tipo_licencia)
        on delete restrict
        on update restrict,
    constraint fk_mot_empresa foreign key (id_empresa)
        references empresas(id_empresa)
        on delete restrict
        on update restrict
);

-- 20. Se crea la tabla operadores_carga
create table operadores_carga (
    id_operario serial primary key,
    id_dia_libre int not null,
    observaciones text,
    id_empleado int not null unique,
    
    constraint fk_operario_empleado foreign key (id_empleado)
        references empleados(id_empleado)
        on delete restrict 
        on update restrict,
    constraint fk_dia_libre_operario foreign key (id_dia_libre)
        references dias_semana (id_dia_semana)
        on delete restrict 
        on update restrict
);

-- 21. Se crea la tabla encargados
create table encargados (
    id_encargado serial primary key,
    usuario varchar(30) not null unique,
    contrasenia varchar(255) not null,
    id_empleado int not null unique,
    
    constraint fk_encargado_empleado foreign key (id_empleado)
        references empleados(id_empleado)
        on delete restrict 
        on update restrict
);

-- 22. Se crea la tabla camiones
create table camiones (
    id_camion serial primary key,
    numero_registro varchar(30) not null unique,
    placa varchar(30) not null unique,
    numero_serie varchar(30) not null unique,
    anio_camion int not null check (anio_camion > 1980),
    estado boolean not null default true,
    id_empresa int not null,
    id_marca_camion int not null,
    id_modelo_camion int not null,
    id_tipo_camion int not null,
    id_capacidad_camion int not null,
    id_tipo_combustible int not null,
    
    constraint chk_placa check (placa ~ '^[A-Z]{3}-[0-9]{4}$'),
    constraint fk_cam_empresa foreign key (id_empresa)
        references empresas(id_empresa)
        on delete restrict
        on update restrict,
    constraint fk_cam_marca foreign key (id_marca_camion)
        references marcas_camiones(id_marca_camion)
        on delete restrict
        on update restrict,
    constraint fk_cam_modelo foreign key (id_modelo_camion)
        references modelos_camiones(id_modelo_camion)
        on delete restrict 
        on update restrict,
    constraint fk_cam_tipo foreign key (id_tipo_camion)
        references tipos_camiones(id_tipo_camion)
        on delete restrict
        on update restrict,
    constraint fk_cam_cap foreign key (id_capacidad_camion)
        references capacidades_camiones(id_capacidad_camion)
        on delete restrict
        on update restrict,
    constraint fk_cam_comb foreign key (id_tipo_combustible)
        references tipos_combustibles(id_tipo_combustible)
        on delete restrict
        on update restrict
);
-- función para validar que el modelo corresponda a la marca
create or replace function fn_validar_modelo_marca()
returns trigger as $$
begin
    -- verificamos si el modelo existe bajo esa marca en la tabla modelos_camiones
    if not exists (
        select 1 from modelos_camiones 
        where id_modelo_camion = new.id_modelo_camion 
        and id_marca_camion = new.id_marca_camion
    ) then
        raise exception 'Error: el modelo seleccionado no pertenece a la marca indicada';
    end if;

    return new;
end;
$$ language plpgsql;

-- trigger para la tabla camiones
create trigger tr_verificar_modelo_marca
before insert or update on camiones
for each row
execute function fn_validar_modelo_marca();

-- 23. Se crea la tabla rutas
create table rutas (
    id_ruta serial primary key,
    numero_ruta int not null unique,
    id_zona int not null,
    distancia_max decimal(10,2) check (distancia_max >= 0),
    id_tipo_distribucion int not null,
    id_centro_distribucion int not null,
    constraint fk_ruta_zona foreign key (id_zona)
        references zonas(id_zona)
        on delete restrict
        on update restrict,
    constraint fk_ruta_tipo foreign key (id_tipo_distribucion)
        references tipos_distribucion(id_tipo_distribucion)
        on delete restrict
        on update restrict,
    constraint fk_ruta_centro foreign key (id_centro_distribucion)
        references centros_distribucion(id_centro_distribucion)
        on delete restrict 
        on update restrict
);
-- 24. Se crea la tabla asignaciones
create table asignaciones (
    id_asignacion serial primary key,
    fecha date not null,
    id_camion int not null,
    id_motorista int not null,
    id_empresa int not null,
    id_ruta int not null,
    id_tipo_asignacion int not null,
    
    constraint fk_asig_camion foreign key (id_camion)
        references camiones(id_camion)
        on delete restrict 
        on update restrict,
    constraint fk_asig_motorista foreign key (id_motorista)
        references motoristas(id_motorista)
        on delete restrict
        on update restrict,
    constraint fk_asig_empresa foreign key (id_empresa)
        references empresas(id_empresa)
        on delete restrict
        on update restrict,
    constraint fk_asig_ruta foreign key (id_ruta)
        references rutas(id_ruta)
        on delete restrict
        on update restrict,
    constraint fk_asig_tipo foreign key (id_tipo_asignacion)
        references tipos_asignacion(id_tipo_asignacion)
        on delete restrict
        on update restrict
);
--Validar si el camion y motorista son de la misma empresa
create or replace function fn_validar_pertenencia_empresa()
returns trigger as $$
declare
    v_empresa_camion int;
    v_empresa_motorista int;
begin
    -- 1. obtener la empresa dueña del camión
    select id_empresa into v_empresa_camion 
    from camiones 
    where id_camion = new.id_camion;

    -- 2. obtener la empresa a la que pertenece el motorista
    select id_empresa into v_empresa_motorista 
    from motoristas 
    where id_motorista = new.id_motorista;

    -- 3. validación A: ¿el camión es de la empresa de la asignación?
    if v_empresa_camion <> new.id_empresa then
        raise exception 'error: el camión seleccionado pertenece a otra empresa.';
    end if;

    -- 4. validación B: ¿el motorista es de la empresa de la asignación?
    if v_empresa_motorista <> new.id_empresa then
        raise exception 'error: el motorista seleccionado pertenece a otra empresa.';
    end if;

    return new;
end;
$$ language plpgsql;

-- el disparador para la tabla asignaciones
create trigger tr_validar_empresa_viaje
before insert or update on asignaciones
for each row
execute function fn_validar_pertenencia_empresa();



-- 25. Se crea la tabla cargas
create table cargas (
    id_carga serial primary key,
    inicio_carga timestamp not null,
    fin_carga timestamp not null,
    libraje decimal(10,2) check (libraje >= 0),
    observaciones text,
    id_asignacion int not null,
    id_puerto int not null,
    id_encargado int not null,
    
    constraint chk_tiempo check (fin_carga > inicio_carga),
    
    constraint fk_carga_asig foreign key (id_asignacion)
        references asignaciones(id_asignacion)
        on delete cascade 
        on update cascade,
    constraint fk_carga_puerto foreign key (id_puerto)
        references puertos(id_puerto)
        on delete restrict
        on update restrict,
    constraint fk_carga_encargado foreign key (id_encargado)
        references encargados(id_encargado)
        on delete restrict
        on update restrict
);

create or replace function fn_validar_puerto_centro_carga()
returns trigger as $$
declare
    v_centro_ruta int;
    v_centro_puerto int;
begin
    -- 1. buscamos el centro de distribución de la ruta asociada a la asignación
    select r.id_centro_distribucion into v_centro_ruta
    from asignaciones a
    join rutas r on a.id_ruta = r.id_ruta
    where a.id_asignacion = new.id_asignacion;

    -- 2. buscamos el centro de distribución al que pertenece el puerto
    select p.id_centro_distribucion into v_centro_puerto
    from puertos p
    where p.id_puerto = new.id_puerto;

    -- 3. comparamos los centros
    if v_centro_ruta <> v_centro_puerto then
        raise exception 'error: el puerto seleccionado no pertenece al centro de distribución de la ruta asignada.';
    end if;

    return new;
end;
$$ language plpgsql;

-- trigger para la tabla cargas
create trigger tr_validar_puerto_centro_carga
before insert or update on cargas
for each row
execute function fn_validar_puerto_centro_carga();



-- 26. se crea la tabla turnos
create table turnos (
    id_turno serial primary key,
    fecha date not null,
    observaciones text,
    id_centro_distribucion int not null,
   
    constraint fk_turno_centro foreign key (id_centro_distribucion)
        references centros_distribucion(id_centro_distribucion)
        on delete restrict 
        on update restrict,
    constraint uq_fecha_por_centro unique(fecha,id_centro_distribucion)
);
-- 27. se crea la tabla turnos_operarios
create table turnos_operarios (
    id_turno_operario serial primary key,
    id_turno int not null,
    id_operario int not null,
    constraint fk_to_turno foreign key (id_turno)
        references turnos(id_turno)
        on delete cascade
        on update cascade,
    constraint fk_to_operario foreign key (id_operario)
        references operadores_carga(id_operario)
        on delete cascade
        on update cascade,
    constraint uq_operario_por_turno unique(id_operario,id_turno)
);

--Validar que el operario sea del centro asignado al turno
create or replace function fn_validar_operario_centro_turno()
returns trigger as $$
declare
    v_centro_turno int;
    v_centro_empleado int;
begin
    -- 1. obtener el centro del turno
    select id_centro_distribucion into v_centro_turno
    from turnos where id_turno = new.id_turno;

    -- 2. obtener el centro del empleado (operario)
    select e.id_centro_distribucion into v_centro_empleado
    from operadores_carga oc
    join empleados e on oc.id_empleado = e.id_empleado
    where oc.id_operario = new.id_operario;

    -- 3. comparar
    if v_centro_turno <> v_centro_empleado then
        raise exception 'error: el operario no pertenece al centro de distribución de este turno.';
    end if;

    return new;
end;
$$ language plpgsql;

create trigger tr_validar_operario_centro_turno
before insert or update on turnos_operarios
for each row execute function fn_validar_operario_centro_turno();