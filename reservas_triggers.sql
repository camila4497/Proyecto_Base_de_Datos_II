USE Reservaciones
GO
-- Primer trigger
CREATE TRIGGER trg_ActualizarEstadoHabitacion
ON Reservas
AFTER INSERT
AS
BEGIN
    UPDATE H
    SET H.estado = 'Ocupada'
    FROM Habitaciones H
    INNER JOIN Inserted I ON H.id_habitacion = I.id_habitacion
    WHERE I.estado_reserva = 'Activa';
END;
GO
-- Comprobacion
SELECT id_habitacion, numero, estado
FROM Habitaciones
WHERE id_habitacion = 5;

INSERT INTO Reservas (id_cliente, id_habitacion, fecha_entrada, fecha_salida)
VALUES (6, 5, '2026-02-10', '2026-02-15');

SELECT id_habitacion, numero, estado
FROM Habitaciones
WHERE id_habitacion = 5;

-- Segundo trigger
CREATE TRIGGER trg_CalcularCostoTotal
ON Alquileres
INSTEAD OF INSERT
AS
BEGIN
    -- Calcular el costo de la habitación para la reserva
    SELECT 
        I.id_reserva,
        DATEDIFF(day, R.fecha_entrada, R.fecha_salida) AS dias_estancia,
        H.precio_noche,
        DATEDIFF(day, R.fecha_entrada, R.fecha_salida) * H.precio_noche AS costo_habitacion
    INTO #CostoHabitacion
    FROM Inserted I
    INNER JOIN Reservas R ON I.id_reserva = R.id_reserva
    INNER JOIN Habitaciones H ON R.id_habitacion = H.id_habitacion;

    -- Calcular el costo total de los servicios adicionales para la reserva
    SELECT
        RS.id_reserva,
        SUM(RS.cantidad * SA.costo_servicio) AS costo_servicios
    INTO #CostoServicios
    FROM Reserva_Servicios RS
    INNER JOIN Servicios_Adicionales SA ON RS.id_servicio = SA.id_servicio
    INNER JOIN Inserted I ON RS.id_reserva = I.id_reserva
    GROUP BY RS.id_reserva;

    -- Insert del nuevo registro de Alquiler con el costo  calculado
    INSERT INTO Alquileres (id_reserva, fecha_checkin, fecha_checkout, costo_total, pagado)
    SELECT
        I.id_reserva,
        I.fecha_checkin,
        I.fecha_checkout,
        CH.costo_habitacion + ISNULL(CS.costo_servicios, 0) AS costo_final_calculado, 
        I.pagado
    FROM Inserted I
    INNER JOIN #CostoHabitacion CH ON I.id_reserva = CH.id_reserva
    LEFT JOIN #CostoServicios CS ON I.id_reserva = CS.id_reserva;
    
    DROP TABLE #CostoHabitacion;
    DROP TABLE #CostoServicios;
END;
GO

-- Comprobacion
INSERT INTO Reserva_Servicios (id_reserva, id_servicio, cantidad)
VALUES (1002, 6, 1);
INSERT INTO Alquileres (id_reserva, fecha_checkin, pagado)
VALUES (1002, GETDATE(), 0);
SELECT *
FROM Alquileres
WHERE id_reserva = 1002;
