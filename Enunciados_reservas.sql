USE Reservaciones
go
-- Pimer enunciado
SELECT c.nombre, c.apellido, h.numero AS habitacion, 
       r.fecha_entrada, f.metodo_pago, f.total
FROM Clientes c
INNER JOIN Reservas r ON c.id_cliente = r.id_cliente
INNER JOIN Habitaciones h ON r.id_habitacion = h.id_habitacion
INNER JOIN Alquileres a ON r.id_reserva = a.id_reserva
INNER JOIN Facturacion f ON a.id_alquiler = f.id_alquiler;

-- Segundo enunciado
SELECT r.id_reserva, c.nombre, c.apellido, r.fecha_entrada, r.estado_reserva
FROM Reservas r
INNER JOIN Clientes c ON r.id_cliente = c.id_cliente
WHERE c.apellido LIKE 'G%'
GROUP BY r.id_reserva, c.nombre, c.apellido, r.fecha_entrada, r.estado_reserva
HAVING COUNT(r.id_reserva) >= 1
ORDER BY r.fecha_entrada ASC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;

-- Tercer enunciado
SELECT c.nombre, c.apellido, COUNT(r.id_reserva) AS total_reservas
FROM Clientes c
INNER JOIN Reservas r ON c.id_cliente = r.id_cliente
GROUP BY c.nombre, c.apellido
HAVING COUNT(r.id_reserva) >= 1;

-- Cuarto enunciado
SELECT c.nombre, c.apellido, f.id_factura, f.total
FROM Clientes c
LEFT JOIN Reservas r ON c.id_cliente = r.id_cliente
LEFT JOIN Alquileres a ON r.id_reserva = a.id_reserva
LEFT JOIN Facturacion f ON a.id_alquiler = f.id_alquiler;

--Quinto enunciado 
SELECT nombre, apellido
FROM Clientes
WHERE id_cliente IN (
    SELECT r.id_cliente
    FROM Reservas r
    INNER JOIN Alquileres a ON r.id_reserva = a.id_reserva
    INNER JOIN Facturacion f ON a.id_alquiler = f.id_alquiler
    WHERE f.estado = 'Pagada'
);

--Sexto enunciado
SELECT c.nombre, c.apellido
FROM Clientes c
WHERE EXISTS (
    SELECT 1 
    FROM Reservas r 
    WHERE r.id_cliente = c.id_cliente
);

