CREATE OR ALTER PROCEDURE sp_RegistrarReserva
    @id_cliente INT,
    @id_habitacion INT,
    @fecha_entrada DATE,
    @fecha_salida DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar disponibilidad de la habitación
    IF EXISTS (
        SELECT 1
        FROM Reservas
        WHERE id_habitacion = @id_habitacion
          AND estado_reserva = 'Activa'
          AND (
                @fecha_entrada BETWEEN fecha_entrada AND fecha_salida OR
                @fecha_salida BETWEEN fecha_entrada AND fecha_salida
              )
    )
    BEGIN
        PRINT 'La habitación no está disponible en esas fechas.';
        RETURN;
    END;

    -- Insertar reserva
    INSERT INTO Reservas (id_cliente, id_habitacion, fecha_entrada, fecha_salida, estado_reserva)
    VALUES (@id_cliente, @id_habitacion, @fecha_entrada, @fecha_salida, 'Activa');

    PRINT 'Reserva registrada correctamente.';
END;
GO


----------------------------------- procedimiento 2 -------------------------------

CREATE OR ALTER PROCEDURE sp_GenerarFactura
    @id_alquiler INT,
    @metodo_pago VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @subtotal DECIMAL(10,2),
            @impuestos DECIMAL(10,2),
            @total DECIMAL(10,2);

    -- Obtener subtotal
    SELECT @subtotal = costo_total
    FROM Alquileres
    WHERE id_alquiler = @id_alquiler;

    IF @subtotal IS NULL
    BEGIN
        PRINT 'No existe el alquiler especificado.';
        RETURN;
    END;

    -- Calcular valores
    SET @impuestos = @subtotal * 0.19;
    SET @total = @subtotal + @impuestos;

    -- Registrar factura
    INSERT INTO Facturacion (id_alquiler, subtotal, impuestos, total, metodo_pago, estado)
    VALUES (@id_alquiler, @subtotal, @impuestos, @total, @metodo_pago, 'Pendiente');

    PRINT 'Factura generada correctamente.';
END;
GO





---------------------- Funciones ----------------------------

-------- funcion 1 -------------------------


CREATE OR ALTER FUNCTION fn_CostoTotalReserva (@id_reserva INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @costo_habitacion DECIMAL(10,2),
            @costo_servicios DECIMAL(10,2);

    SELECT @costo_habitacion =
        (DATEDIFF(day, fecha_entrada, fecha_salida) * H.precio_noche)
    FROM Reservas R
    INNER JOIN Habitaciones H ON R.id_habitacion = H.id_habitacion
    WHERE R.id_reserva = @id_reserva;

    SELECT @costo_servicios = SUM(RS.cantidad * SA.costo_servicio)
    FROM Reserva_Servicios RS
    INNER JOIN Servicios_Adicionales SA ON RS.id_servicio = SA.id_servicio
    WHERE RS.id_reserva = @id_reserva;

    RETURN ISNULL(@costo_habitacion, 0) + ISNULL(@costo_servicios, 0);
END;
GO




---------------------- funcion 2 -------------------


CREATE OR ALTER FUNCTION fn_ReservasActivasPorCliente (@id_cliente INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        R.id_reserva,
        H.numero AS Habitacion,
        R.fecha_entrada,
        R.fecha_salida,
        R.estado_reserva
    FROM Reservas R
    INNER JOIN Habitaciones H ON R.id_habitacion = H.id_habitacion
    WHERE R.id_cliente = @id_cliente
      AND R.estado_reserva = 'Activa'
);
GO
