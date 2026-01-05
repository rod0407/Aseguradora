/* =========================================================
   ARCHIVO: informes.sql
   PROYECTO: Aseguradora "El Buen Retiro"
   DESCRIPCI�N: Script para generaci�n de informes
                y estad�sticas mediante Store Procedures.
   FECHA: 2025-11-29
   ========================================================= */

USE [SEGUROS];
GO

--INFORMES--

/* =========================================================
   1. Polizas activas por corredor
   ========================================================= */
CREATE OR ALTER PROCEDURE pa_Informe_PolizasActivasPorCorredor
AS
BEGIN
    SELECT 
        E.nombre + ' ' + E.aPaterno AS [Nombre Corredor],
        C.nombre + ' ' + C.aPaterno + ' ' + ISNULL(C.aMaterno,'') AS [Nombre Cliente],
        P.numPoliza,
        P.fechaFinVig
    FROM POLIZA.POLIZA P
    JOIN TRABAJADOR.CORREDOR Co ON P.numEmpleado = Co.numEmpleado
    JOIN TRABAJADOR.EMPLEADO E ON Co.numEmpleado = E.numEmpleado
    JOIN COTIZACION.COTIZACION Cot ON P.numCotizacion = Cot.numCotizacion
    JOIN CLIENTE.CLIENTE C ON Cot.id_cliente = C.id_cliente
    WHERE P.activo = 1
    ORDER BY E.aPaterno, P.fechaFinVig;
END;
GO

/* =========================================================
   2. Total de Primas vendidas por cada Corredor en el �ltimo trimestre
   ========================================================= */
CREATE OR ALTER PROCEDURE pa_Informe_VentasTrimestreCorredor
AS
BEGIN
    SELECT 
        E.nombre + ' ' + E.aPaterno AS [Nombre Corredor],
        COUNT(P.id_poliza) AS [P�lizas Vendidas],
        FORMAT(ISNULL(SUM(P.montoPrimaTotal), 0), 'C', 'es-MX') AS [Total Vendido (MXN)]
    FROM TRABAJADOR.CORREDOR Co
    JOIN TRABAJADOR.EMPLEADO E ON Co.numEmpleado = E.numEmpleado
    LEFT JOIN POLIZA.POLIZA P ON Co.numEmpleado = P.numEmpleado 
        AND P.fechaIniVig >= DATEADD(QUARTER, -1, GETDATE())
    GROUP BY E.numEmpleado, E.nombre, E.aPaterno
    ORDER BY SUM(P.montoPrimaTotal) DESC;
END;
GO


/* =========================================================
   3. Informe de Cotizaciones Pendientes de los �ltimos 60 d�as, agrupadas por tipo
   ========================================================= */
CREATE OR ALTER PROCEDURE pa_Informe_CotizacionesPendientes
AS
BEGIN
    SELECT 
        TS.descripcion AS [Tipo de Seguro],
        Cot.numCotizacion,
        Cot.fechaCotizacion,
        Cli.nombre + ' ' + Cli.aPaterno AS [Cliente],
        FORMAT(Cot.montoEstimadoPrima, 'C', 'es-MX') AS [Monto Estimado]
    FROM COTIZACION.COTIZACION Cot
    JOIN CLIENTE.CLIENTE Cli ON Cot.id_cliente = Cli.id_cliente
    JOIN COTIZACION.COTIZACION_TIPO_SEGURO CTS ON Cot.numCotizacion = CTS.numCotizacion
    JOIN SEGURO.TIPO_SEGURO TS ON CTS.id_tipoSeguro = TS.id_tipoSeguro
    WHERE Cot.estadoActual = 'P' 
      AND Cot.fechaCotizacion >= DATEADD(DAY, -60, GETDATE())
    ORDER BY TS.descripcion, Cot.fechaCotizacion;
END;
GO


/* =========================================================
   4. Relaci�n de Clientes con Seguro de Vida Y Seguro de Retiro 
   Clientes con m�ltiples productos
   ========================================================= */
CREATE OR ALTER PROCEDURE pa_Informe_ClientesVidaYRetiro
AS
BEGIN
    
    SELECT DISTINCT C.id_cliente, C.nombre, C.aPaterno
    FROM CLIENTE.CLIENTE C
    JOIN COTIZACION.COTIZACION Cot ON C.id_cliente = Cot.id_cliente
    JOIN POLIZA.POLIZA P ON Cot.numCotizacion = P.numCotizacion
    JOIN SEGURO.TIPO_SEGURO TS ON P.id_tipoSeguro = TS.id_tipoSeguro
    WHERE TS.esVida = 1 AND P.activo = 1
    
    INTERSECT
    
    SELECT DISTINCT C.id_cliente, C.nombre, C.aPaterno
    FROM CLIENTE.CLIENTE C
    JOIN COTIZACION.COTIZACION Cot ON C.id_cliente = Cot.id_cliente
    JOIN POLIZA.POLIZA P ON Cot.numCotizacion = P.numCotizacion
    JOIN SEGURO.TIPO_SEGURO TS ON P.id_tipoSeguro = TS.id_tipoSeguro
    WHERE TS.esRetiro = 1 AND P.activo = 1;
END;
GO


/* =========================================================
   5. Listado de Pagos Pendientes
   ========================================================= */
CREATE OR ALTER PROCEDURE pa_Informe_PagosPendientes
AS
BEGIN
    SELECT 
        P.numPoliza,
        TS.nomProducto,
        Cli.nombre + ' ' + Cli.aPaterno AS Cliente,
        FORMAT(P.montoPrimaTotal - ISNULL((SELECT SUM(montoPagado) FROM POLIZA.PAGO WHERE id_poliza = P.id_poliza),0), 'C', 'es-MX') AS [Saldo Pendiente],
        P.fechaFinVig AS [Vence P�liza]
    FROM POLIZA.POLIZA P
    JOIN SEGURO.TIPO_SEGURO TS ON P.id_tipoSeguro = TS.id_tipoSeguro
    JOIN COTIZACION.COTIZACION Cot ON P.numCotizacion = Cot.numCotizacion
    JOIN CLIENTE.CLIENTE Cli ON Cot.id_cliente = Cli.id_cliente
    WHERE (P.montoPrimaTotal - ISNULL((SELECT SUM(montoPagado) FROM POLIZA.PAGO WHERE id_poliza = P.id_poliza),0)) > 0;
END;
GO


/* =========================================================
   6. Reporte de Siniestros del mes anterior
   ========================================================= */
CREATE OR ALTER PROCEDURE pa_Informe_SiniestrosMesAnterior
AS
BEGIN
    DECLARE @InicioMes DATE = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0);
    DECLARE @FinMes DATE = DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0));

    SELECT 
        TS.descripcion AS [Tipo Seguro Afectado],
        COUNT(S.numSiniestro) AS [Cantidad Siniestros],
        FORMAT(AVG(S.montoIndem), 'C', 'es-MX') AS [Monto Indemnizaci�n Promedio]
    FROM POLIZA.SINIESTRO S
    JOIN POLIZA.POLIZA P ON S.id_poliza = P.id_poliza
    JOIN SEGURO.TIPO_SEGURO TS ON P.id_tipoSeguro = TS.id_tipoSeguro
    WHERE S.fecha BETWEEN @InicioMes AND @FinMes
    GROUP BY TS.descripcion;
END;
GO


/* =========================================================
   7. Concentrado de Veh�culos asegurados por Marca y Modelo
   ========================================================= */
CREATE OR ALTER PROCEDURE pa_Informe_VehiculosMarcaModelo
AS
BEGIN
    SELECT 
        A.marca,
        A.modelo,
        COUNT(A.id_auto) AS [Total Asegurados]
    FROM POLIZA.AUTO A
    JOIN POLIZA.POLIZA P ON A.id_auto = P.id_auto
    WHERE P.activo = 1
    GROUP BY A.marca, A.modelo
    ORDER BY [Total Asegurados] DESC;
END;
GO



--ESTAD�STICAS--


/* =========================================================
   1. N�mero total de Clientes activos
   ========================================================= */
CREATE OR ALTER PROCEDURE pa_Estadistica_TotalClientesActivos
AS
BEGIN
    SELECT COUNT(DISTINCT Cot.id_cliente) AS [Total Clientes Activos]
    FROM POLIZA.POLIZA P
    JOIN COTIZACION.COTIZACION Cot ON P.numCotizacion = Cot.numCotizacion
    WHERE P.activo = 1;
END;
GO


/* =========================================================
   2. N�mero de P�lizas Activas por Tipo de Seguro
   ========================================================= */
CREATE OR ALTER PROCEDURE pa_Estadistica_PolizasPorTipo
AS
BEGIN
    SELECT 
        TS.descripcion AS [Tipo Seguro],
        COUNT(P.id_poliza) AS [Total Activas]
    FROM POLIZA.POLIZA P
    JOIN SEGURO.TIPO_SEGURO TS ON P.id_tipoSeguro = TS.id_tipoSeguro
    WHERE P.activo = 1
    GROUP BY TS.descripcion;
END;
GO


/* =========================================================
   3. Promedio del Monto Asegurado por cada Tipo de Seguro 
   ========================================================= */
CREATE OR ALTER PROCEDURE pa_Estadistica_PromedioMontoPorTipo
AS
BEGIN
    SELECT 
        TS.descripcion AS [Tipo Seguro],
        FORMAT(AVG(P.montoPrimaTotal), 'C', 'es-MX') AS [Promedio Prima (Costo)]
    FROM POLIZA.POLIZA P
    JOIN SEGURO.TIPO_SEGURO TS ON P.id_tipoSeguro = TS.id_tipoSeguro
    GROUP BY TS.descripcion;
END;
GO


/* =========================================================
   4. Total de Ingresos por Primas del �ltimo mes
   ========================================================= */
CREATE OR ALTER PROCEDURE pa_Estadistica_IngresosMes
AS
BEGIN
    SELECT FORMAT(ISNULL(SUM(montoPagado),0), 'C', 'es-MX') AS [Ingresos Primas �ltimo Mes]
    FROM POLIZA.PAGO
    WHERE fechaPago >= DATEADD(MONTH, -1, GETDATE());
END;
GO


/* =========================================================
   5. N�mero de Siniestros reportados en el �ltimo a�o, por causa
   ========================================================= */
CREATE OR ALTER PROCEDURE pa_Estadistica_SiniestrosPorCausa
AS
BEGIN
    SELECT 
        causa,
        COUNT(*) AS [Total Siniestros]
    FROM POLIZA.SINIESTRO
    WHERE fecha >= DATEADD(YEAR, -1, GETDATE())
    GROUP BY causa
    ORDER BY [Total Siniestros] DESC;
END;
GO


/* =========================================================
   6. Distribuci�n de Clientes por Ciudad o Estado
   ========================================================= */
CREATE OR ALTER PROCEDURE pa_Estadistica_ClientesPorEstado
AS
BEGIN
    SELECT 
        E.estado,
        COUNT(C.id_cliente) AS [Num Clientes]
    FROM CLIENTE.CLIENTE C
    JOIN CLIENTE.COLONIA Col ON C.id_colonia = Col.id_colonia
    JOIN CLIENTE.CIUDAD Cd ON Col.id_ciudad = Cd.id_ciudad
    JOIN CLIENTE.ESTADO E ON Cd.id_estado = E.id_estado
    GROUP BY E.estado
    ORDER BY [Num Clientes] DESC;
END;
GO


/* =========================================================
   7. Top 5 de Corredores con mayor Monto Prima Total vendido
   ========================================================= */
CREATE OR ALTER PROCEDURE pa_Estadistica_Top5Corredores
AS
BEGIN
    SELECT TOP 5
        E.nombre + ' ' + E.aPaterno AS [Corredor],
        FORMAT(SUM(P.montoPrimaTotal), 'C', 'es-MX') AS [Total Vendido]
    FROM TRABAJADOR.CORREDOR C
    JOIN TRABAJADOR.EMPLEADO E ON C.numEmpleado = E.numEmpleado
    JOIN POLIZA.POLIZA P ON C.numEmpleado = P.numEmpleado
    GROUP BY E.nombre, E.aPaterno
    ORDER BY SUM(P.montoPrimaTotal) DESC;
END;
GO


/* =========================================================
   8. Porcentaje de Pagos Atrasados sobre el total de pagos esperados
   ========================================================= */
CREATE OR ALTER PROCEDURE pa_Estadistica_PorcentajeMorosidad
AS
BEGIN
    DECLARE @TotalPolizas FLOAT;
    DECLARE @PolizasConDeuda FLOAT;

    SELECT @TotalPolizas = COUNT(*) FROM POLIZA.POLIZA;
    
    SELECT @PolizasConDeuda = COUNT(*) 
    FROM POLIZA.POLIZA P
    WHERE (P.montoPrimaTotal - ISNULL((SELECT SUM(montoPagado) FROM POLIZA.PAGO WHERE id_poliza = P.id_poliza),0)) > 0;

    SELECT 
        CAST(@PolizasConDeuda AS INT) AS [P�lizas con Deuda],
        CAST(@TotalPolizas AS INT) AS [Total P�lizas],
        CAST((@PolizasConDeuda / NULLIF(@TotalPolizas,0) * 100) AS DECIMAL(5,2)) AS [Porcentaje Morosidad %];
END;
GO


/* =========================================================
   9. Edad promedio de los Asegurados en Seguros de Vida
   ========================================================= */
CREATE OR ALTER PROCEDURE pa_Estadistica_EdadPromedioVida
AS
BEGIN
    SELECT 
        AVG(DATEDIFF(YEAR, C.fechaNacimiento, GETDATE())) AS [Edad Promedio (A�os)]
    FROM CLIENTE.CLIENTE C
    JOIN COTIZACION.COTIZACION Cot ON C.id_cliente = Cot.id_cliente
    JOIN POLIZA.POLIZA P ON Cot.numCotizacion = P.numCotizacion
    JOIN SEGURO.TIPO_SEGURO TS ON P.id_tipoSeguro = TS.id_tipoSeguro
    WHERE TS.esVida = 1;
END;
GO


/* =========================================================
   10. Tasa de Renovaci�n de P�lizas
       (P�lizas renovadas vs. P�lizas que finalizaron vigencia)
   ========================================================= */
CREATE OR ALTER PROCEDURE pa_Estadistica_TasaRenovacion
AS
BEGIN
    DECLARE @Vencidas FLOAT;
    DECLARE @Renovadas FLOAT;

    SELECT @Vencidas = COUNT(*) FROM POLIZA.HISTORICO_POLIZA 
    WHERE fechaFinVig < GETDATE();

    SELECT @Renovadas = COUNT(DISTINCT HP.id_poliza)
    FROM POLIZA.HISTORICO_POLIZA HP
    JOIN POLIZA.POLIZA P_Old ON HP.id_poliza = P_Old.id_poliza 
    JOIN COTIZACION.COTIZACION Cot_Old ON P_Old.numCotizacion = Cot_Old.numCotizacion
    WHERE HP.fechaFinVig < GETDATE()
      AND EXISTS (
          SELECT 1 
          FROM POLIZA.POLIZA P_New
          JOIN COTIZACION.COTIZACION Cot_New ON P_New.numCotizacion = Cot_New.numCotizacion
          WHERE Cot_New.id_cliente = Cot_Old.id_cliente 
            AND P_New.id_tipoSeguro = P_Old.id_tipoSeguro 
            AND P_New.activo = 1 
            AND P_New.fechaIniVig >= HP.fechaFinVig 
      );

    SELECT 
        CAST(@Renovadas AS INT) AS [P�lizas Renovadas],
        CAST(@Vencidas AS INT) AS [P�lizas Vencidas (Hist�rico)],
        CAST((@Renovadas / NULLIF(@Vencidas,0) * 100) AS DECIMAL(5,2)) AS [Tasa Renovaci�n %];
END;
GO

PRINT '--- SCRIPT DE INFORMES Y ESTAD�STICAS CREADO CORRECTAMENTE ---';
GO



--VISTAS--


/* =========================================================
   1. VW_RESUMEN_POLIZAS_CLIENTES
   ========================================================= */

CREATE OR ALTER VIEW CLIENTE.VW_RESUMEN_POLIZAS_CLIENTES
AS
SELECT 
    cli.id_cliente,
    CONCAT(cli.nombre, ' ', cli.aPaterno, ' ', ISNULL(cli.aMaterno, '')) AS NombreCliente,
    cli.curp,
    p.numPoliza,
    ts.descripcion AS TipoSeguro,
    ts.nomProducto,
    p.fechaIniVig,
    p.fechaFinVig,
    CASE WHEN p.activo = 1 THEN 'Activa' ELSE 'Inactiva' END AS EstatusPoliza,
    p.montoPrimaTotal
FROM CLIENTE.CLIENTE cli
    JOIN COTIZACION.COTIZACION c ON cli.id_cliente = c.id_cliente
    JOIN POLIZA.POLIZA p ON c.numCotizacion = p.numCotizacion
    JOIN SEGURO.TIPO_SEGURO ts ON p.id_tipoSeguro = ts.id_tipoSeguro;
GO


/* =========================================================
   2. VW_ESTADO_CUENTA_POLIZAS
   ========================================================= */

CREATE OR ALTER VIEW POLIZA.VW_ESTADO_CUENTA_POLIZAS
AS
SELECT 
    p.id_poliza,
    p.numPoliza,
    p.montoPrimaTotal AS CostoTotal,
    
    ISNULL((SELECT SUM(montoPagado) 
            FROM POLIZA.PAGO pg 
            WHERE pg.id_poliza = p.id_poliza), 0) AS TotalPagado,
            
    (p.montoPrimaTotal - ISNULL((SELECT SUM(montoPagado) 
                                 FROM POLIZA.PAGO pg 
                                 WHERE pg.id_poliza = p.id_poliza), 0)) AS SaldoPendiente,

    CAST(
        (ISNULL((SELECT SUM(montoPagado) 
                 FROM POLIZA.PAGO pg 
                 WHERE pg.id_poliza = p.id_poliza), 0) * 100.0 / p.montoPrimaTotal) 
    AS DECIMAL(5,2)) AS PorcentajePagado

FROM POLIZA.POLIZA p;
GO


/* =========================================================
   3. TRABAJADOR.VW_DESEMPENO_CORREDORES
   ========================================================= */

CREATE OR ALTER VIEW TRABAJADOR.VW_DESEMPENO_CORREDORES
AS
SELECT 
    e.numEmpleado,
    CONCAT(e.nombre, ' ', e.aPaterno, ' ', ISNULL(e.aMaterno, '')) AS NombreCorredor,
    c.zona,
    
    (SELECT COUNT(*) 
     FROM CLIENTE.CLIENTE cli 
     WHERE cli.numEmpleado = c.numEmpleado) AS ClientesEnCartera,

    COUNT(p.id_poliza) AS PolizasVendidas,
    ISNULL(SUM(p.montoPrimaTotal), 0) AS TotalVendidoMXN,
    ISNULL(SUM(p.montoPrimaTotal * (c.porcentajeComision / 100.0)), 0) AS ComisionesGeneradas

FROM TRABAJADOR.EMPLEADO e
    JOIN TRABAJADOR.CORREDOR c ON e.numEmpleado = c.numEmpleado
    LEFT JOIN POLIZA.POLIZA p ON c.numEmpleado = p.numEmpleado
GROUP BY 
    e.numEmpleado, 
    e.nombre, 
    e.aPaterno, 
    e.aMaterno, 
    c.zona, 
    c.porcentajeComision,
    c.numEmpleado 
;
GO


/* =========================================================
   PRUEBA DE LA VISTA
   ========================================================= */

PRINT '--- Consultando Vista: Desempe�o de Corredores (Ranking) ---';
SELECT * FROM TRABAJADOR.VW_DESEMPENO_CORREDORES
ORDER BY TotalVendidoMXN DESC;
GO

PRINT '--- Consultando Vista: Resumen de P�lizas por Cliente ---';
SELECT * FROM CLIENTE.VW_RESUMEN_POLIZAS_CLIENTES;

PRINT ' ';
PRINT '--- Consultando Vista: Estado de Cuenta Financiero ---';
SELECT * FROM POLIZA.VW_ESTADO_CUENTA_POLIZAS;
GO