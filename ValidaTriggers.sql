/* =========================================================
   ARCHIVO: validaTriggers.sql
   PROYECTO: Aseguradora "El Buen Retiro"
   DESCRIPCI�N: Script para validar triggers
   FECHA: 2025-11-29
   ========================================================= */

USE [SEGUROS]
GO


/* =========================================================
   CS3 � TR_COT_TIPO_validaEdadVida
   Valida edad m�xima para seguros de vida
   ========================================================= */
PRINT '=========================================';
PRINT 'CS3 - TR_COT_TIPO_validaEdadVida';
PRINT '=========================================';

DECLARE 
    @statusP       NUMERIC(5,0),
    @idTipoVida    NUMERIC(5,0),
    @edadMax       INT,
    @hoy           DATE,
    @fechaNacJoven DATE,
    @fechaNacViejo DATE,
    @idColonia     NUMERIC(5,0),
    @numEmpleado   NUMERIC(4,0),
    @idClienteJoven NUMERIC(5,0),
    @idClienteViejo NUMERIC(5,0),
    @cotJoven      NUMERIC(6,0),
    @cotViejo      NUMERIC(6,0);

SELECT TOP 1 @idColonia = id_colonia FROM CLIENTE.COLONIA ORDER BY id_colonia;
SELECT TOP 1 @numEmpleado = numEmpleado FROM TRABAJADOR.CORREDOR ORDER BY numEmpleado;

IF @idColonia IS NULL OR @numEmpleado IS NULL
BEGIN
    PRINT 'No hay datos m�nimos (COLONIA o CORREDOR) para probar CS3.';
    GOTO Fin_CS3;
END;

SELECT @statusP = status_cotizacion_id 
FROM COTIZACION.STATUS_COTIZACION 
WHERE activo = 'P';

IF @statusP IS NULL
BEGIN
    INSERT INTO COTIZACION.STATUS_COTIZACION(activo) VALUES('P');
    SET @statusP = SCOPE_IDENTITY();
END;

SELECT TOP 1 
    @idTipoVida = sv.id_tipoSeguro,
    @edadMax    = sv.edadMaxContratacion
FROM SEGURO.SEGURO_VIDA sv
ORDER BY sv.id_tipoSeguro;

IF @idTipoVida IS NULL
BEGIN
    PRINT 'No existe ning�n SEGURO_VIDA para probar CS3.';
    GOTO Fin_CS3;
END;

SET @hoy = CAST(GETDATE() AS DATE);
SET @fechaNacJoven = DATEADD(YEAR, -(@edadMax - 5), @hoy);
SET @fechaNacViejo = DATEADD(YEAR, -(@edadMax + 10), @hoy);

-- Cliente joven (v�lido)
INSERT INTO CLIENTE.CLIENTE(
    curp, tipo, fechaNacimiento,
    nombre, aMaterno, aPaterno,
    id_colonia, numEmpleado
)
VALUES(
    'TESTCURPVIDAJOV001', 'N', @fechaNacJoven,
    'TestVidaJoven', 'CS3', 'Cliente',
    @idColonia, @numEmpleado
);
SELECT @idClienteJoven = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'TESTCURPVIDAJOV001';

-- Cliente viejo (*error)
INSERT INTO CLIENTE.CLIENTE(
    curp, tipo, fechaNacimiento,
    nombre, aMaterno, aPaterno,
    id_colonia, numEmpleado
)
VALUES(
    'TESTCURPVIDAVIEJ01', 'N', @fechaNacViejo,
    'TestVidaViejo', 'CS3', 'Cliente',
    @idColonia, @numEmpleado
);
SELECT @idClienteViejo = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'TESTCURPVIDAVIEJ01';

-- Cotizaci�n joven (OK)
INSERT INTO COTIZACION.COTIZACION(
    estadoActual, fechaCotizacion,
    montoEstimadoPrima, fechaVenOferta,
    recordatorio, status_cotizacion_id,
    id_cliente
)
VALUES(
    'P', @hoy,
    5000, DATEADD(DAY, 30, @hoy),
    'Cotizacion test CS3 joven',
    @statusP,
    @idClienteJoven
);
SET @cotJoven = SCOPE_IDENTITY();

-- Cotizaci�n viejo (falla)
INSERT INTO COTIZACION.COTIZACION(
    estadoActual, fechaCotizacion,
    montoEstimadoPrima, fechaVenOferta,
    recordatorio, status_cotizacion_id,
    id_cliente
)
VALUES(
    'P', @hoy,
    6000, DATEADD(DAY, 30, @hoy),
    'Cotizacion test CS3 viejo',
    @statusP,
    @idClienteViejo
);
SET @cotViejo = SCOPE_IDENTITY();


PRINT 'CS3: Insertando COTIZACION_TIPO_SEGURO v�lido (cliente joven)...';

INSERT INTO COTIZACION.COTIZACION_TIPO_SEGURO(
    id_tipoSeguro, numCotizacion
)
VALUES(
    @idTipoVida, @cotJoven
);

PRINT '   OK: Trigger CS3 permiti� la relaci�n para cliente joven.';

PRINT 'CS3: Insertando COTIZACION_TIPO_SEGURO inv�lido (cliente viejo, edad > edadMax)...';

BEGIN TRY
    INSERT INTO COTIZACION.COTIZACION_TIPO_SEGURO(
        id_tipoSeguro, numCotizacion
    )
    VALUES(
        @idTipoVida, @cotViejo
    );
    PRINT '   ERROR: El trigger TR_COT_TIPO_validaEdadVida NO se dispar�.';
END TRY
BEGIN CATCH
    PRINT '   Mensaje del trigger CS3 -> ' + ERROR_MESSAGE();
END CATCH;


Fin_CS3:
PRINT 'Fin de pruebas CS3.';
GO


/* =========================================================
   TR_PAGO_recalculaSaldo
   Recalcula saldoPendiente en funci�n de los pagos
   ========================================================= */
PRINT '=========================================';
PRINT 'TR_PAGO_recalculaSaldo';
PRINT '=========================================';

DECLARE
    @statusP2        NUMERIC(5,0),
    @idClientePago   NUMERIC(5,0),
    @idColonia2      NUMERIC(5,0),
    @numEmpleado2    NUMERIC(4,0),
    @cotPago         NUMERIC(6,0),
    @idTipoVidaPago  NUMERIC(5,0),
    @idPolPago       NUMERIC(10,0),
    @hoy2            DATE;

SET @hoy2 = CAST(GETDATE() AS DATE);

SELECT @statusP2 = status_cotizacion_id FROM COTIZACION.STATUS_COTIZACION WHERE activo = 'P';
IF @statusP2 IS NULL
BEGIN
    INSERT INTO COTIZACION.STATUS_COTIZACION(activo) VALUES('P');
    SET @statusP2 = SCOPE_IDENTITY();
END;

SELECT TOP 1 @idTipoVidaPago = id_tipoSeguro 
FROM SEGURO.SEGURO_VIDA
ORDER BY id_tipoSeguro;

IF @idTipoVidaPago IS NULL
BEGIN
    PRINT 'No existe SEGURO_VIDA, no se puede probar TR_PAGO_recalculaSaldo.';
    GOTO Fin_Pago;
END;

SELECT TOP 1 @idColonia2 = id_colonia FROM CLIENTE.COLONIA ORDER BY id_colonia;
SELECT TOP 1 @numEmpleado2 = numEmpleado FROM TRABAJADOR.CORREDOR ORDER BY numEmpleado;

IF @idColonia2 IS NULL OR @numEmpleado2 IS NULL
BEGIN
    PRINT 'No hay datos m�nimos (COLONIA/CORREDOR) para probar TR_PAGO_recalculaSaldo.';
    GOTO Fin_Pago;
END;

INSERT INTO CLIENTE.CLIENTE(
    curp, tipo, fechaNacimiento,
    nombre, aMaterno, aPaterno,
    id_colonia, numEmpleado
)
VALUES(
    'TESTCURPPAGOS00001', 'N', '1990-01-01',
    'Cliente', 'Pagos', 'Test',
    @idColonia2, @numEmpleado2
);
SELECT @idClientePago = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'TESTCURPPAGOS00001';

INSERT INTO COTIZACION.COTIZACION(
    estadoActual, fechaCotizacion,
    montoEstimadoPrima, fechaVenOferta,
    recordatorio, status_cotizacion_id,
    id_cliente
)
VALUES(
    'A', @hoy2,
    9000, DATEADD(DAY, 30, @hoy2),
    'Cotizaci�n para prueba de pagos',
    @statusP2,
    @idClientePago
);
SET @cotPago = SCOPE_IDENTITY();

INSERT INTO COTIZACION.COTIZACION_TIPO_SEGURO(
    id_tipoSeguro, numCotizacion
)
VALUES(
    @idTipoVidaPago, @cotPago
);


INSERT INTO POLIZA.POLIZA(
    activo, fechaIniVig, numPoliza, fechaFinVig,
    montoPrimaTotal,
    id_auto, id_tipoSeguro,
    numCotizacion, numEmpleado
)
VALUES(
    1, @hoy2, 'VIDA-P-TEST', DATEADD(YEAR, 5, @hoy2),
    9000,
    NULL, @idTipoVidaPago,
    @cotPago, @numEmpleado2
);
SET @idPolPago = SCOPE_IDENTITY();

PRINT 'TR_PAGO_recalculaSaldo: P�liza de prueba creada con montoPrimaTotal=9000.';
PRINT '   id_poliza de prueba = ' + CAST(@idPolPago AS VARCHAR(20));

PRINT 'TR_PAGO_recalculaSaldo: Insertando primer pago de 3000...';
INSERT INTO POLIZA.PAGO(
    id_poliza, numPago, saldoPendiente,
    montoPagado, fechaPago, metodoPago
)
VALUES(
    @idPolPago, 1, 0,
    3000, DATEADD(DAY, 5, @hoy2), 1
);

PRINT '   Despu�s del primer pago, saldoPendiente esperado = 6000.';
SELECT * FROM POLIZA.PAGO WHERE id_poliza = @idPolPago;

PRINT 'TR_PAGO_recalculaSaldo: Insertando segundo pago de 2000...';
INSERT INTO POLIZA.PAGO(
    id_poliza, numPago, saldoPendiente,
    montoPagado, fechaPago, metodoPago
)
VALUES(
    @idPolPago, 2, 0,
    2000, DATEADD(DAY, 35, @hoy2), 0
);

PRINT '   Despu�s del segundo pago, saldoPendiente esperado = 4000.';
SELECT * FROM POLIZA.PAGO WHERE id_poliza = @idPolPago;

PRINT 'TR_PAGO_recalculaSaldo: Eliminando segundo pago...';
DELETE FROM POLIZA.PAGO
WHERE id_poliza = @idPolPago AND numPago = 2;

PRINT '   Despu�s de eliminar el segundo pago, saldoPendiente esperado = 6000.';
SELECT * FROM POLIZA.PAGO WHERE id_poliza = @idPolPago;


Fin_Pago:
PRINT 'Fin de pruebas TR_PAGO_recalculaSaldo.';
GO


/* =========================================================
   CS10 � TR_BENEFICIARIO_max5
   M�ximo 5 beneficiarios por seguro de vida
   ========================================================= */
PRINT '=========================================';
PRINT 'CS10 - TR_BENEFICIARIO_max5';
PRINT '=========================================';

DECLARE
    @idTipoVidaCS10 NUMERIC(5,0);

SELECT TOP 1 @idTipoVidaCS10 = id_tipoSeguro
FROM SEGURO.SEGURO_VIDA
ORDER BY id_tipoSeguro;

IF @idTipoVidaCS10 IS NULL
BEGIN
    PRINT 'No hay SEGURO_VIDA para probar CS10.';
    GOTO Fin_CS10;
END;

PRINT 'CS10: Usando id_tipoSeguro (vida) = ' + CAST(@idTipoVidaCS10 AS VARCHAR(10));

PRINT 'CS10: Insertando beneficiarios adicionales (hasta llegar a 5)...';

INSERT INTO SEGURO.BENEFICIARIO(
    porcentaje, parentesco,
    nombre, aPaterno, aMaterno,
    id_tipoSeguro
)
VALUES
    (0, 'E', 'BenfCS10_1', 'Test', NULL, @idTipoVidaCS10),
    (0, 'H', 'BenfCS10_2', 'Test', NULL, @idTipoVidaCS10),
    (0, 'H', 'BenfCS10_3', 'Test', NULL, @idTipoVidaCS10);

PRINT '   Beneficiarios actuales para este seguro de vida:';
SELECT id_tipoSeguro, COUNT(*) AS totalBenef, SUM(porcentaje) AS sumaPorcentaje
FROM SEGURO.BENEFICIARIO
WHERE id_tipoSeguro = @idTipoVidaCS10
GROUP BY id_tipoSeguro;

PRINT 'CS10: Intentando insertar un 6to beneficiario (esperamos error CS10)...';

BEGIN TRY
    INSERT INTO SEGURO.BENEFICIARIO(
        porcentaje, parentesco,
        nombre, aPaterno, aMaterno,
        id_tipoSeguro
    )
    VALUES(
        0, 'H', 'BenfCS10_6', 'Test', NULL,
        @idTipoVidaCS10
    );
    PRINT '   ERROR: El trigger TR_BENEFICIARIO_max5 NO se dispar�.';
END TRY
BEGIN CATCH
    PRINT '   Mensaje del trigger CS10 -> ' + ERROR_MESSAGE();
END CATCH;

PRINT 'CS10: Beneficiarios finales para este seguro de vida:';
SELECT id_tipoSeguro, COUNT(*) AS totalBenef, SUM(porcentaje) AS sumaPorcentaje
FROM SEGURO.BENEFICIARIO
WHERE id_tipoSeguro = @idTipoVidaCS10
GROUP BY id_tipoSeguro;

Fin_CS10:
PRINT 'Fin de pruebas CS10.';
GO


/* =========================================================
   CS11 � TR_BENEFICIARIO_suma100_estricto
   La suma de porcentajes debe ser exactamente 100
   ========================================================= */
PRINT '=========================================';
PRINT 'CS11 - TR_BENEFICIARIO_suma100_estricto';
PRINT '=========================================';

DECLARE
    @idTipoVidaCS11 NUMERIC(5,0),
    @idBenefCS11    NUMERIC(5,0);

SELECT TOP 1 @idTipoVidaCS11 = id_tipoSeguro
FROM SEGURO.SEGURO_VIDA
ORDER BY id_tipoSeguro;

IF @idTipoVidaCS11 IS NULL
BEGIN
    PRINT 'No hay SEGURO_VIDA para probar CS11.';
    GOTO Fin_CS11;
END;

PRINT 'CS11: Usando id_tipoSeguro (vida) = ' + CAST(@idTipoVidaCS11 AS VARCHAR(10));

PRINT 'CS11: Suma actual de porcentajes (debe ser 100 para que la BD est� consistente):';
SELECT id_tipoSeguro, COUNT(*) AS totalBenef, SUM(porcentaje) AS sumaPorcentaje
FROM SEGURO.BENEFICIARIO
WHERE id_tipoSeguro = @idTipoVidaCS11
GROUP BY id_tipoSeguro;

SELECT TOP 1 @idBenefCS11 = id_beneficiario
FROM SEGURO.BENEFICIARIO
WHERE id_tipoSeguro = @idTipoVidaCS11;

IF @idBenefCS11 IS NOT NULL
BEGIN
    PRINT 'CS11: Caso v�lido -> UPDATE solo del nombre de un beneficiario...';
    UPDATE SEGURO.BENEFICIARIO
    SET nombre = nombre + '_OK'
    WHERE id_beneficiario = @idBenefCS11;
    PRINT '   OK: Trigger permiti� la operaci�n (suma de porcentajes sigue = 100).';
END;

PRINT 'CS11: Caso inv�lido -> UPDATE del porcentaje (esperamos error CS11)...';

BEGIN TRY
    UPDATE TOP (1) SEGURO.BENEFICIARIO
    SET porcentaje = porcentaje - 10 
    WHERE id_tipoSeguro = @idTipoVidaCS11;
    PRINT '   ERROR: El trigger TR_BENEFICIARIO_suma100_estricto NO se dispar�.';
END TRY
BEGIN CATCH
    PRINT '   Mensaje del trigger CS11 -> ' + ERROR_MESSAGE();
END CATCH;

PRINT 'CS11: Suma final de porcentajes (debe seguir en 100 por el rollback):';
SELECT id_tipoSeguro, COUNT(*) AS totalBenef, SUM(porcentaje) AS sumaPorcentaje
FROM SEGURO.BENEFICIARIO
WHERE id_tipoSeguro = @idTipoVidaCS11
GROUP BY id_tipoSeguro;

Fin_CS11:
PRINT 'Fin de pruebas CS11.';
GO


/* =========================================================
   CS15 � TR_POLIZA_validaAutoObligatorio
   Si es seguro de auto, id_auto NO puede ser NULL
   ========================================================= */
PRINT '=========================================';
PRINT 'CS15 - TR_POLIZA_validaAutoObligatorio';
PRINT '=========================================';

DECLARE
    @idTipoAutoCS15 NUMERIC(5,0),
    @idAutoCS15     NUMERIC(6,0),
    @idColonia15    NUMERIC(5,0),
    @numEmpleado15  NUMERIC(4,0),
    @idCliente15    NUMERIC(5,0),
    @statusP15      NUMERIC(5,0),
    @cotAuto15      NUMERIC(6,0),
    @hoy15          DATE;

SET @hoy15 = CAST(GETDATE() AS DATE);

SELECT TOP 1 @idTipoAutoCS15 = id_tipoSeguro
FROM SEGURO.TIPO_SEGURO
WHERE esAuto = 1
ORDER BY id_tipoSeguro;

IF @idTipoAutoCS15 IS NULL
BEGIN
    PRINT 'No existe TIPO_SEGURO de auto para probar CS15.';
    GOTO Fin_CS15;
END;

SELECT TOP 1 @idAutoCS15 = id_auto FROM POLIZA.AUTO ORDER BY id_auto;

IF @idAutoCS15 IS NULL
BEGIN
    INSERT INTO POLIZA.AUTO(
        numeroSerie, matricula, anio,
        modelo, marca, valorComercial
    )
    VALUES(
        'SERIECS15TEST001', 'CS15TEST', 2020,
        'ModeloCS15', 'MarcaCS15', 200000
    );
    SET @idAutoCS15 = SCOPE_IDENTITY();
END;

SELECT TOP 1 @idColonia15 = id_colonia FROM CLIENTE.COLONIA ORDER BY id_colonia;
SELECT TOP 1 @numEmpleado15 = numEmpleado FROM TRABAJADOR.CORREDOR ORDER BY numEmpleado;

IF @idColonia15 IS NULL OR @numEmpleado15 IS NULL
BEGIN
    PRINT 'No hay COLONIA/CORREDOR para probar CS15.';
    GOTO Fin_CS15;
END;

SELECT @statusP15 = status_cotizacion_id FROM COTIZACION.STATUS_COTIZACION WHERE activo = 'P';
IF @statusP15 IS NULL
BEGIN
    INSERT INTO COTIZACION.STATUS_COTIZACION(activo) VALUES('P');
    SET @statusP15 = SCOPE_IDENTITY();
END;

INSERT INTO CLIENTE.CLIENTE(
    curp, tipo, fechaNacimiento,
    nombre, aMaterno, aPaterno,
    id_colonia, numEmpleado
)
VALUES(
    'TESTCURPAUTOCS1501', 'N', '1992-02-02',
    'Cliente', 'Auto', 'CS15',
    @idColonia15, @numEmpleado15
);
SELECT @idCliente15 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'TESTCURPAUTOCS1501';

INSERT INTO COTIZACION.COTIZACION(
    estadoActual, fechaCotizacion,
    montoEstimadoPrima, fechaVenOferta,
    recordatorio, status_cotizacion_id,
    id_cliente
)
VALUES(
    'A', @hoy15,
    10000, DATEADD(DAY, 30, @hoy15),
    'Cotizaci�n auto CS15',
    @statusP15,
    @idCliente15
);
SET @cotAuto15 = SCOPE_IDENTITY();

INSERT INTO COTIZACION.COTIZACION_TIPO_SEGURO(
    id_tipoSeguro, numCotizacion
)
VALUES(
    @idTipoAutoCS15, @cotAuto15
);


PRINT 'CS15: Insertando p�liza de auto V�LIDA (con id_auto)...';

INSERT INTO POLIZA.POLIZA(
    activo, fechaIniVig, numPoliza, fechaFinVig,
    montoPrimaTotal,
    id_auto, id_tipoSeguro,
    numCotizacion, numEmpleado
)
VALUES(
    1, @hoy15, 'AUTO-CS15-OK', DATEADD(YEAR, 1, @hoy15),
    10000,
    @idAutoCS15, @idTipoAutoCS15,
    @cotAuto15, @numEmpleado15
);

PRINT '   OK: Trigger permiti� la p�liza de auto con id_auto NOT NULL.';

PRINT 'CS15: Insertando p�liza de auto INV�LIDA (id_auto = NULL, debe fallar)...';

BEGIN TRY
    INSERT INTO POLIZA.POLIZA(
        activo, fechaIniVig, numPoliza, fechaFinVig,
        montoPrimaTotal,
        id_auto, id_tipoSeguro,
        numCotizacion, numEmpleado
    )
    VALUES(
        1, @hoy15, 'AUTO-CS15-ERR', DATEADD(YEAR, 1, @hoy15),
        9000,
        NULL, @idTipoAutoCS15,
        @cotAuto15, @numEmpleado15
    );
    PRINT '   ERROR: El trigger TR_POLIZA_validaAutoObligatorio NO se dispar�.';
END TRY
BEGIN CATCH
    PRINT '   Mensaje del trigger CS15 -> ' + ERROR_MESSAGE();
END CATCH;

Fin_CS15:
PRINT 'Fin de pruebas CS15.';
GO


--CSasignacion-corredorAutomatico
PRINT '=========================================';
PRINT '7. Asignaci�n de Corredor por Zona (TR_CLIENTE_AsignarCorredorAutomatico)';
PRINT '=========================================';

DECLARE @idColoniaCentro NUMERIC(5,0);
SELECT TOP 1 @idColoniaCentro = id_colonia FROM CLIENTE.COLONIA WHERE cp = '06000';

IF @idColoniaCentro IS NULL
BEGIN
    PRINT 'ADVERTENCIA: No se encontr� colonia con CP 06000 para la prueba de asignaci�n.';
END
ELSE
BEGIN
    PRINT 'Insertando cliente SIN corredor...';
    
    INSERT INTO CLIENTE.CLIENTE (curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
    VALUES ('TEST999999HDFXXX01', 'N', '2000-01-01', 'Cliente', 'Prueba', 'Automatico', @idColoniaCentro, NULL);

    PRINT 'Verificando asignaci�n:';
    
    SELECT 
        C.nombre + ' ' + C.aPaterno AS Cliente,
        Col.cp AS CP_Cliente,
        E.nombre + ' ' + E.aPaterno AS Corredor_Asignado,
        Cor.zona AS Zona_Corredor
    FROM CLIENTE.CLIENTE C
    JOIN CLIENTE.COLONIA Col ON C.id_colonia = Col.id_colonia
    JOIN TRABAJADOR.EMPLEADO E ON C.numEmpleado = E.numEmpleado
    JOIN TRABAJADOR.CORREDOR Cor ON E.numEmpleado = Cor.numEmpleado
    WHERE C.curp = 'TEST999999HDFXXX01';
END

PRINT '=========================================';
PRINT 'FIN DE TODAS LAS PRUEBAS DE TRIGGERS';
PRINT '=========================================';
GO