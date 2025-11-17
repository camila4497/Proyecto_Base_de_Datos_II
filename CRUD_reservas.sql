use Reservaciones
go

--Create
CREATE TABLE ClientesVIP (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    total_reservas INT
);

INSERT INTO ClientesVIP (id_cliente, nombre, apellido, total_reservas)
SELECT c.id_cliente, c.nombre, c.apellido, COUNT(r.id_reserva) AS total_reservas
FROM Clientes c
INNER JOIN Reservas r ON c.id_cliente = r.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido
HAVING COUNT(r.id_reserva) > 2;

--Read
SELECT c.nombre, c.apellido, h.numero AS habitacion, a.costo_total
FROM Clientes c
INNER JOIN Reservas r ON c.id_cliente = r.id_cliente
INNER JOIN Habitaciones h ON r.id_habitacion = h.id_habitacion
INNER JOIN Alquileres a ON r.id_reserva = a.id_reserva
WHERE a.pagado = 0;

--Update
UPDATE Facturacion
SET estado = 'Pagada'
WHERE id_alquiler IN (
    SELECT a.id_alquiler
    FROM Alquileres a
    INNER JOIN Reservas r ON a.id_reserva = r.id_reserva
    INNER JOIN Clientes c ON r.id_cliente = c.id_cliente
    WHERE c.nombre = 'Ana' AND c.apellido = 'García'
);

SELECT f.id_factura, f.estado, c.nombre, c.apellido
FROM Facturacion f
INNER JOIN Alquileres a ON f.id_alquiler = a.id_alquiler
INNER JOIN Reservas r ON a.id_reserva = r.id_reserva
INNER JOIN Clientes c ON r.id_cliente = c.id_cliente
WHERE c.nombre = 'Ana' AND c.apellido = 'García';

--Delete
DELETE FROM Reservas 
WHERE estado_reserva = 'Cancelada'
AND id_cliente IN (
    SELECT id_cliente 
    FROM Clientes 
    WHERE apellido = 'Pérez'
);


SELECT r.id_reserva, r.estado_reserva, c.nombre, c.apellido
FROM Reservas r
INNER JOIN Clientes c ON r.id_cliente = c.id_cliente
WHERE c.apellido = 'Pérez';
