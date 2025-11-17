Create database Reservaciones 

-- Tabla Clientes
CREATE TABLE Clientes (
    id_cliente INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20) NOT NULL
);

-- Tabla Habitaciones
CREATE TABLE Habitaciones (
    id_habitacion INT PRIMARY KEY IDENTITY(1,1),
    numero VARCHAR(10) UNIQUE NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    capacidad INT NOT NULL CHECK (capacidad > 0),
    precio_noche DECIMAL(10,2) NOT NULL CHECK (precio_noche > 0),
    estado VARCHAR(50) NOT NULL DEFAULT 'Disponible'
        CHECK (estado IN ('Disponible','Ocupada','Mantenimiento'))
);

-- Tabla Reservas
CREATE TABLE Reservas (
    id_reserva INT PRIMARY KEY IDENTITY(1,1),
    id_cliente INT NOT NULL,
    id_habitacion INT NOT NULL,
    fecha_entrada DATE NOT NULL,
    fecha_salida DATE NOT NULL,
    estado_reserva VARCHAR(20) NOT NULL DEFAULT 'Activa'
        CHECK (estado_reserva IN ('Activa','Cancelada','Finalizada')),
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_habitacion) REFERENCES Habitaciones(id_habitacion)
        ON UPDATE CASCADE
);

-- Restricción de negocio: fecha_salida > fecha_entrada
ALTER TABLE Reservas
ADD CONSTRAINT chk_fechas_reserva CHECK (fecha_salida > fecha_entrada);

-- Tabla Servicios adicionales
CREATE TABLE Servicios_Adicionales (
    id_servicio INT PRIMARY KEY IDENTITY(1,1),
    nombre_servicio VARCHAR(100) NOT NULL UNIQUE,
    costo_servicio DECIMAL(10,2) NOT NULL CHECK (costo_servicio > 0)
);

-- Tabla relación Reserva-Servicios
CREATE TABLE Reserva_Servicios (
    id_reserva INT NOT NULL,
    id_servicio INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    PRIMARY KEY (id_reserva, id_servicio),
    FOREIGN KEY (id_reserva) REFERENCES Reservas(id_reserva)
        ON DELETE CASCADE,
    FOREIGN KEY (id_servicio) REFERENCES Servicios_Adicionales(id_servicio)
);

-- Tabla Alquileres
CREATE TABLE Alquileres (
    id_alquiler INT PRIMARY KEY IDENTITY(1,1),
    id_reserva INT NOT NULL UNIQUE, -- cada reserva solo tiene un alquiler
    fecha_checkin DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_checkout DATETIME,
    costo_total DECIMAL(10,2),
    pagado BIT DEFAULT 0,
    FOREIGN KEY (id_reserva) REFERENCES Reservas(id_reserva)
        ON DELETE CASCADE
);
--Tabla Facturacion
CREATE TABLE Facturacion (
    id_factura INT PRIMARY KEY IDENTITY(1,1),
    id_alquiler INT NOT NULL UNIQUE,  
    fecha_factura DATETIME NOT NULL DEFAULT GETDATE(),
    subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
    impuestos DECIMAL(10,2) NOT NULL CHECK (impuestos >= 0),
    total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
    metodo_pago VARCHAR(50) NOT NULL CHECK (metodo_pago IN ('Efectivo','Tarjeta','Transferencia')),
    estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente'
        CHECK (estado IN ('Pendiente','Pagada','Anulada')),
    FOREIGN KEY (id_alquiler) REFERENCES Alquileres(id_alquiler)
        ON DELETE CASCADE
);

-- Inserts Tabla Clientes 
INSERT INTO Clientes (nombre, apellido, email, telefono) VALUES 
('Ana', 'García', 'ana.garcia@email.com', '3046697757'), 
('Carlos', 'López', 'carlos.lopez@email.com', '301298465'), 
('María', 'Rodríguez', 'maria.rodriguez@email.com', '3025824315'), 
('Luis', 'Martínez', 'luis.martinez@email.com', '3023006250'), 
('Sofía', 'Pérez', 'sofia.perez@email.com', '3006559432'), 
('Diego', 'Sánchez', 'diego.sanchez@email.com', '3007002154'); 

-- Inserts Tabla Habitaciones 
INSERT INTO Habitaciones (numero, tipo, capacidad, precio_noche, estado) VALUES 
('101', 'Sencilla', 1, 80.000, 'Disponible'), 
('102', 'Doble', 2, 120.500, 'Disponible'), 
('201', 'Doble', 2, 120.500, 'Disponible'), 
('202', 'Suite', 4, 250.700, 'Ocupada'), 
('301', 'Sencilla', 1, 80.000, 'Mantenimiento'), 
('302', 'Doble', 2, 120.500, 'Disponible'); 

--Inserts Tabla Reservas 
INSERT INTO Reservas (id_cliente, id_habitacion, fecha_entrada, fecha_salida) VALUES 
(1, 1, '2025-10-20', '2025-10-23'), 
(2, 3, '2025-10-25', '2025-10-27'), 
(3, 2, '2025-11-01', '2025-11-05'), 
(4, 4, '2025-11-10', '2025-11-12'), 
(5, 6, '2025-12-01', '2025-12-03'), 
(6, 1, '2026-01-05', '2026-01-08'); 

--Inserts Tabla Servicios 
INSERT INTO Servicios_Adicionales (nombre_servicio, costo_servicio) VALUES 
('Desayuno Continental', 20.000), 
('Servicio de Lavandería', 25.000), 
('Acceso al Gimnasio', 15.000), 
('Servicio a la Habitación', 10.000), 
('Minibar', 30.000), 
('Cama Adicional', 15.000); 

--Inserts Tabla de Reserva de Servicios 
INSERT INTO Reserva_Servicios (id_reserva, id_servicio, cantidad) VALUES 
(1, 1, 2),  -- Reserva 1 pide 2 desayunos 
(1, 2, 1),  -- Reserva 1 pide 1 servicio de lavandería 
(3, 4, 1),  -- Reserva 3 pide 1 servicio a la habitación 
(4, 5, 1), 
(5, 1, 1), 
(6, 6, 1); 

-- Inserts Tabla Alquileres 
INSERT INTO Alquileres (id_reserva, fecha_checkin, fecha_checkout, costo_total, pagado) VALUES 
(1, '2025-10-20 15:00:00', '2025-10-23 11:00:00', 300.000, 1), 
(2, '2025-10-25 14:30:00', '2025-10-27 10:00:00', 250.000, 1), 
(3, '2025-11-01 16:00:00', '2025-11-05 11:30:00', 500.000, 0), 
(4, '2025-11-10 15:00:00', NULL, NULL, 0), 
(5, '2025-12-01 14:00:00', NULL, NULL, 0), 
(6, '2026-01-05 14:45:00', NULL, NULL, 0);

INSERT INTO Facturacion (id_alquiler, subtotal, impuestos, total, metodo_pago, estado) VALUES
(1, 300000, 57000, 357000, 'Tarjeta', 'Pagada'),
(2, 250000, 47500, 297500, 'Efectivo', 'Pagada'),
(3, 500000, 95000, 595000, 'Tarjeta', 'Pendiente');