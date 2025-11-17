use Reservaciones
go

-- Primera vista
CREATE VIEW Vista_Clientes_Activos AS
SELECT
    id_cliente, nombre, apellido, email, telefono
FROM
    Clientes
WHERE
    -- Excluir clientes llamados Luis
    nombre <> 'Luis' 
    --Teléfono de al menos 10 dígitos 
    AND LEN(telefono) >= 10 
WITH CHECK OPTION; 
GO
-- Comprobacion
SELECT * FROM Vista_Clientes_Activos;

UPDATE Vista_Clientes_Activos
SET telefono = '3002000000'
WHERE id_cliente = 1;

SELECT id_cliente, nombre, telefono FROM Vista_Clientes_Activos WHERE id_cliente = 1;

-- Segunda vista
CREATE VIEW Vista_Detalle_Reservas AS
SELECT
    R.id_reserva,
    C.nombre + ' ' + C.apellido AS Nombre_Cliente,
    H.numero AS Numero_Habitacion,
    H.tipo AS Tipo_Habitacion,
    R.fecha_entrada,
    R.fecha_salida,
    DATEDIFF(day, R.fecha_entrada, R.fecha_salida) AS Noches_Reservadas, -- Columna Calculada
    H.precio_noche,
    R.estado_reserva,
    -- Cálculo del costo base (no incluye servicios)
    (DATEDIFF(day, R.fecha_entrada, R.fecha_salida) * H.precio_noche) AS Costo_Estancia_Base
FROM
    Reservas R
INNER JOIN
    Clientes C ON R.id_cliente = C.id_cliente
INNER JOIN
    Habitaciones H ON R.id_habitacion = H.id_habitacion;
GO
-- Comprobacion
SELECT * FROM Vista_Detalle_Reservas