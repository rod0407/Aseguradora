/* =========================================================
   ARCHIVO: DML.sql
   PROYECTO: Aseguradora "El Buen Retiro"
   DESCRIPCI�N: Script para crear funciones y 
                procedimientos almacenados
   FECHA: 2025-11-29
*/


USE [SEGUROS];
GO


--PROCEDIMIENTOS ALMACENADOS--

/* =========================================================
   1) REGISTRO DE UN PAGO A UNA POLIZA
   ========================================================= */

		
CREATE OR ALTER PROCEDURE POLIZA.sp_RegistrarPagoPoliza
    @id_poliza   NUMERIC(10,0),
    @montoPagado DECIMAL(6,0),
    @fechaPago   DATE,
    @metodoPago  BIT 
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        DECLARE @numPago NUMERIC(5,0);
        IF NOT EXISTS (SELECT 1 FROM POLIZA.POLIZA WHERE id_poliza = @id_poliza)
        BEGIN
             RAISERROR('La p�liza especificada no existe.', 16, 1);
             ROLLBACK TRAN;
             RETURN;
        END
        SELECT @numPago = ISNULL(MAX(numPago), 0) + 1
        FROM POLIZA.PAGO
        WHERE id_poliza = @id_poliza;
        INSERT INTO POLIZA.PAGO (
            id_poliza,
            numPago,
            saldoPendiente, 
            montoPagado,
            fechaPago,
            metodoPago
        )
        VALUES (
            @id_poliza,
            @numPago,
            0,
            @montoPagado,
            @fechaPago,
            @metodoPago
        );

        COMMIT TRAN;
        SELECT
            p.id_poliza,
            p.numPago,
            p.montoPagado,
            p.saldoPendiente AS NuevoSaldoPendiente
        FROM POLIZA.PAGO p
        WHERE p.id_poliza = @id_poliza
          AND p.numPago = @numPago;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;

        DECLARE @msg  NVARCHAR(4000) = ERROR_MESSAGE(),
                @sevr INT = ERROR_SEVERITY(),
                @st   INT = ERROR_STATE();

        RAISERROR(@msg, @sevr, @st);
    END CATCH;
END;
GO


/* =========================================================
   2) ALTA DE UN CLIENTE CON COTIZACI�N
   ========================================================= */


CREATE OR ALTER PROCEDURE CLIENTE.sp_AltaCliente
    @curp            CHAR(18),
    @tipo            CHAR(1),
    @fechaNacimiento DATE,
    @nombre          VARCHAR(40),
    @aPaterno        VARCHAR(40),
    @aMaterno        VARCHAR(40) = NULL,
    @estado          VARCHAR(40),
    @ciudad          VARCHAR(40),
    @colonia         VARCHAR(40),
    @cp              CHAR(5),
    @numEmpleadoCorredor NUMERIC(4,0),
    @estadoActual        CHAR(1),
    @montoEstimadoPrima  DECIMAL(6,0),
    @fechaVenOferta      DATE,
    @recordatorio        VARCHAR(60) = NULL
AS
BEGIN
    DECLARE @id_estado NUMERIC(5,0), @id_ciudad NUMERIC(5,0), @id_colonia NUMERIC(5,0),
            @id_cliente NUMERIC(5,0), @status_id NUMERIC(5,0), @numCot NUMERIC(6,0);

    BEGIN TRY
        BEGIN TRAN;

        SELECT @id_estado = id_estado FROM CLIENTE.ESTADO WHERE estado = @estado;
        IF @id_estado IS NULL BEGIN INSERT INTO CLIENTE.ESTADO(estado) VALUES(@estado); SET @id_estado = SCOPE_IDENTITY(); END

        SELECT @id_ciudad = id_ciudad FROM CLIENTE.CIUDAD WHERE ciudad = @ciudad AND id_estado = @id_estado;
        IF @id_ciudad IS NULL BEGIN INSERT INTO CLIENTE.CIUDAD(ciudad, id_estado) VALUES(@ciudad, @id_estado); SET @id_ciudad = SCOPE_IDENTITY(); END

        SELECT @id_colonia = id_colonia FROM CLIENTE.COLONIA WHERE colonia = @colonia AND id_ciudad = @id_ciudad;
        IF @id_colonia IS NULL BEGIN INSERT INTO CLIENTE.COLONIA(colonia, cp, id_ciudad) VALUES(@colonia, @cp, @id_ciudad); SET @id_colonia = SCOPE_IDENTITY(); END

        INSERT INTO CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
        VALUES(@curp, @tipo, @fechaNacimiento, @nombre, @aMaterno, @aPaterno, @id_colonia, @numEmpleadoCorredor);

        SELECT @id_cliente = id_cliente FROM CLIENTE.CLIENTE WHERE curp = @curp;

        SELECT @status_id = status_cotizacion_id FROM COTIZACION.STATUS_COTIZACION WHERE activo = @estadoActual;
        IF @status_id IS NULL BEGIN INSERT INTO COTIZACION.STATUS_COTIZACION(activo) VALUES(@estadoActual); SET @status_id = SCOPE_IDENTITY(); END

        INSERT INTO COTIZACION.COTIZACION(estadoActual, fechaCotizacion, montoEstimadoPrima, fechaVenOferta, recordatorio, status_cotizacion_id, id_cliente)
        VALUES(@estadoActual, CAST(GETDATE() AS date), @montoEstimadoPrima, @fechaVenOferta, @recordatorio, @status_id, @id_cliente);
        SET @numCot = SCOPE_IDENTITY();

        COMMIT TRAN;

        SELECT @id_cliente AS id_cliente_generado, @numCot AS numCotizacion_generada;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO


/* =========================================================
   3. REGISTRAR UNA COTIZACI�N
   ========================================================= */
CREATE OR ALTER PROCEDURE COTIZACION.sp_RegistrarCotizacion
    @id_cliente         NUMERIC(5,0),
    @id_tipoSeguro      NUMERIC(5,0),
    @montoEstimado      DECIMAL(6,0),
    @diasVigenciaOferta INT,
    @recordatorio       VARCHAR(60) = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;
            
            DECLARE @idStatus NUMERIC(5,0);
            DECLARE @numCotGenerada NUMERIC(6,0);

            SELECT @idStatus = status_cotizacion_id 
            FROM COTIZACION.STATUS_COTIZACION 
            WHERE activo = 'P';

            INSERT INTO COTIZACION.COTIZACION(
                estadoActual, fechaCotizacion, montoEstimadoPrima, 
                fechaVenOferta, recordatorio, status_cotizacion_id, id_cliente
            )
            VALUES (
                'P', CAST(GETDATE() AS DATE), @montoEstimado, 
                DATEADD(DAY, @diasVigenciaOferta, GETDATE()), 
                @recordatorio, @idStatus, @id_cliente
            );

            SET @numCotGenerada = SCOPE_IDENTITY();

            INSERT INTO COTIZACION.COTIZACION_TIPO_SEGURO(id_tipoSeguro, numCotizacion)
            VALUES (@id_tipoSeguro, @numCotGenerada);

        COMMIT TRAN;
        PRINT 'Cotizaci�n #' + CAST(@numCotGenerada AS VARCHAR) + ' registrada exitosamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* =========================================================
   4. REGISTRAR UN SEGURO DE VIDA
   ========================================================= */
CREATE OR ALTER PROCEDURE SEGURO.sp_RegistrarSeguroVida
    @claveSeguro    NUMERIC(5,0),
    @nomProducto    VARCHAR(40),
    @descripcion    VARCHAR(60),
    @montoMinimo    DECIMAL(6,0),
    @vigenciaMinMeses NUMERIC(2,0),
    @edadMaxContratacion NUMERIC(2,0),
    @claveInterna   VARCHAR(10)
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;
            DECLARE @newId NUMERIC(5,0);

            INSERT INTO SEGURO.TIPO_SEGURO(
                esAuto, esVida, esRetiro, claveSeguro, descripcion, 
                montoAseguradoMinimo, vigenciaMinima, nomProducto
            )
            VALUES (0, 1, 0, @claveSeguro, @descripcion, @montoMinimo, @vigenciaMinMeses, @nomProducto);
            
            SET @newId = SCOPE_IDENTITY();

            INSERT INTO SEGURO.SEGURO_VIDA(id_tipoSeguro, edadMaxContratacion, clave)
            VALUES (@newId, @edadMaxContratacion, @claveInterna);

        COMMIT TRAN;
        PRINT 'Seguro de Vida "' + @nomProducto + '" registrado.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* =========================================================
   5. REGISTRAR UN SEGURO DE AUTO
   ========================================================= */
CREATE OR ALTER PROCEDURE SEGURO.sp_RegistrarSeguroAuto
    @claveSeguro    NUMERIC(5,0),
    @nomProducto    VARCHAR(40),
    @descripcion    VARCHAR(60),
    @montoMinimo    DECIMAL(6,0),
    @vigenciaMinMeses NUMERIC(2,0),
    @coberturaBasica VARCHAR(60)
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;
            DECLARE @newId NUMERIC(5,0);

            INSERT INTO SEGURO.TIPO_SEGURO(
                esAuto, esVida, esRetiro, claveSeguro, descripcion, 
                montoAseguradoMinimo, vigenciaMinima, nomProducto
            )
            VALUES (1, 0, 0, @claveSeguro, @descripcion, @montoMinimo, @vigenciaMinMeses, @nomProducto);
            
            SET @newId = SCOPE_IDENTITY();

            INSERT INTO SEGURO.SEGURO_AUTO(id_tipoSeguro, coberturaBasica)
            VALUES (@newId, @coberturaBasica);

        COMMIT TRAN;
        PRINT 'Seguro de Auto "' + @nomProducto + '" registrado.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* =========================================================
   6. REGISTRAR UN SEGURO DE RETIRO (Nombre Corregido)
   ========================================================= */
CREATE OR ALTER PROCEDURE SEGURO.sp_RegistrarSeguroRetiro
    @claveSeguro    NUMERIC(5,0),
    @nomProducto    VARCHAR(40),
    @descripcion    VARCHAR(60),
    @montoMinimo    DECIMAL(6,0),
    @vigenciaMinMeses NUMERIC(2,0),
    @claveInterna   VARCHAR(10),
    @edadRetiro     NUMERIC(3,0),
    @aportacionMin  DECIMAL(6,0)
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;
            DECLARE @newId NUMERIC(5,0);

            INSERT INTO SEGURO.TIPO_SEGURO(
                esAuto, esVida, esRetiro, claveSeguro, descripcion, 
                montoAseguradoMinimo, vigenciaMinima, nomProducto
            )
            VALUES (0, 0, 1, @claveSeguro, @descripcion, @montoMinimo, @vigenciaMinMeses, @nomProducto);
            
            SET @newId = SCOPE_IDENTITY();

            INSERT INTO SEGURO.SEGURO_RETIRO(id_tipoSeguro, clave, edadRetiro, aportacionMinMensual)
            VALUES (@newId, @claveInterna, @edadRetiro, @aportacionMin);

        COMMIT TRAN;
        PRINT 'Seguro de Retiro "' + @nomProducto + '" registrado.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

/* =========================================================
   7. REGISTRAR UNA P�LIZA
   ========================================================= */
CREATE OR ALTER PROCEDURE POLIZA.sp_RegistrarPoliza
    @numPoliza       VARCHAR(12),
    @numCotizacion   NUMERIC(6,0),
    @numEmpleado     NUMERIC(4,0),
    @fechaInicio     DATE,
    @duracionMeses   INT,
    @montoPrimaTotal DECIMAL(6,0),
    @id_auto         NUMERIC(6,0) = NULL
AS
BEGIN
    BEGIN TRY
        DECLARE @idTipoSeguro NUMERIC(5,0);

        SELECT @idTipoSeguro = id_tipoSeguro 
        FROM COTIZACION.COTIZACION_TIPO_SEGURO 
        WHERE numCotizacion = @numCotizacion;

        INSERT INTO POLIZA.POLIZA(
            activo, fechaIniVig, numPoliza, fechaFinVig, 
            montoPrimaTotal, id_auto, id_tipoSeguro, 
            numCotizacion, numEmpleado
        )
        VALUES (
            1, @fechaInicio, @numPoliza, DATEADD(MONTH, @duracionMeses, @fechaInicio),
            @montoPrimaTotal, @id_auto, @idTipoSeguro,
            @numCotizacion, @numEmpleado
        );

        PRINT 'P�liza ' + @numPoliza + ' creada exitosamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

/* =========================================================
   8. REGISTRAR UN PAGO
   ========================================================= */
CREATE OR ALTER PROCEDURE POLIZA.sp_RegistrarPago
    @id_poliza   NUMERIC(10,0),
    @montoPagado DECIMAL(6,0),
    @metodoPago  BIT
AS
BEGIN
    BEGIN TRY
        DECLARE @numPago NUMERIC(5,0);
        
        SELECT @numPago = ISNULL(MAX(numPago), 0) + 1 
        FROM POLIZA.PAGO WHERE id_poliza = @id_poliza;

        INSERT INTO POLIZA.PAGO(
            id_poliza, numPago, saldoPendiente, montoPagado, fechaPago, metodoPago
        )
        VALUES(
            @id_poliza, @numPago, 0, @montoPagado, CAST(GETDATE() AS DATE), @metodoPago
        );

        PRINT 'Pago #' + CAST(@numPago AS VARCHAR) + ' registrado para la p�liza ID ' + CAST(@id_poliza AS VARCHAR);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

/* =========================================================
   9. REGISTRAR UN SINIESTRO
   ========================================================= */
CREATE OR ALTER PROCEDURE POLIZA.sp_RegistrarSiniestro
    @id_poliza      NUMERIC(10,0),
    @fechaSiniestro DATETIME,
    @lugar          VARCHAR(60),
    @causa          VARCHAR(80),
    @montoIndem     DECIMAL(6,0),
    @id_ajustador   NUMERIC(4,0)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM TRABAJADOR.EMPLEADO WHERE numEmpleado = @id_ajustador AND tipo = 'A')
        BEGIN
             THROW 51000, 'El empleado especificado no es un Ajustador v�lido.', 1;
        END

        INSERT INTO POLIZA.SINIESTRO(
            fecha, lugarSiniestro, causa, montoIndem, id_poliza, numEmpleado
        )
        VALUES(
            @fechaSiniestro, @lugar, @causa, @montoIndem, @id_poliza, @id_ajustador
        );

        PRINT 'Siniestro registrado exitosamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT '=== PROCEDIMIENTOS ACTUALIZADOS CORRECTAMENTE ===';



--FUNCIONES--


/* =========================================================
   FUNCI�N 1: POLIZA.fn_CalcularRentabilidadPoliza
   Descripci�n: Calcula si una p�liza es rentable para la aseguradora. 
   (Total Pagado por el Cliente) - (Total Pagado en Siniestros).
   ========================================================= */

GO
CREATE OR ALTER FUNCTION POLIZA.fn_CalcularRentabilidadPoliza 
(
    @id_poliza NUMERIC(10,0)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Ingresos DECIMAL(10,2);
    DECLARE @Egresos  DECIMAL(10,2);
    DECLARE @Resultado DECIMAL(10,2);

    SELECT @Ingresos = ISNULL(SUM(montoPagado), 0)
    FROM POLIZA.PAGO
    WHERE id_poliza = @id_poliza;

    SELECT @Egresos = ISNULL(SUM(montoIndem), 0)
    FROM POLIZA.SINIESTRO
    WHERE id_poliza = @id_poliza;

    SET @Resultado = @Ingresos - @Egresos;

    RETURN @Resultado;
END;
GO


/* =========================================================
   FUNCI�N 2: CLIENTE.fn_ObtenerRiesgoCliente
   Descripci�n: Cuenta cu�ntos siniestros ha tenido un cliente
   en TODAS sus p�lizas hist�ricas.
   ========================================================= */

GO
CREATE OR ALTER FUNCTION CLIENTE.fn_ObtenerRiesgoCliente
(
    @id_cliente NUMERIC(5,0)
)
RETURNS INT
AS
BEGIN
    DECLARE @NumSiniestros INT;

    SELECT @NumSiniestros = COUNT(s.numSiniestro)
    FROM POLIZA.SINIESTRO s
    JOIN POLIZA.POLIZA p ON s.id_poliza = p.id_poliza
    JOIN COTIZACION.COTIZACION c ON p.numCotizacion = c.numCotizacion
    WHERE c.id_cliente = @id_cliente;

    RETURN @NumSiniestros;
END;
GO



/* =========================================================
   FUNCI�N 3: TRABAJADOR.fn_ReporteComisionesCorredor
   Descripci�n: Devuelve una tabla con las p�lizas vendidas por
   un corredor espec�fico y calcula cu�nto gan� de comisi�n
   por cada una.
   ========================================================= */

GO
CREATE OR ALTER FUNCTION TRABAJADOR.fn_ReporteComisionesCorredor
(
    @numEmpleado NUMERIC(4,0),
    @fechaInicio DATE,
    @fechaFin    DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.numPoliza,
        p.fechaIniVig,
        ts.nomProducto AS Producto,
        p.montoPrimaTotal AS CostoPoliza,
        c.porcentajeComision AS [Porcentaje (%)],
        
        CAST((p.montoPrimaTotal * c.porcentajeComision / 100.0) 
             AS DECIMAL(10,2)) AS ComisionGanada
             
    FROM TRABAJADOR.CORREDOR c
    JOIN POLIZA.POLIZA p ON c.numEmpleado = p.numEmpleado
    JOIN SEGURO.TIPO_SEGURO ts ON p.id_tipoSeguro = ts.id_tipoSeguro
    WHERE c.numEmpleado = @numEmpleado
      AND p.fechaIniVig BETWEEN @fechaInicio AND @fechaFin
);
GO
