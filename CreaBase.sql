/* =========================================================
   ARCHIVO: CreaBase.sql
   PROYECTO: Aseguradora "El Buen Retiro"
   DESCRIPCI�N: Descripcion : Creacion de la base de datos, creacion y definicion de esquemas, tablas,
                 procedimientos almacenados, funciones, disparadores y vistas.
   FECHA: 2025-11-29
   ========================================================= */

CREATE DATABASE [SEGUROS]
GO
USE [SEGUROS]
GO


/* ============================
   CREATE SCHEMAS
   ============================ */
CREATE SCHEMA CLIENTE;
GO
CREATE SCHEMA TRABAJADOR;
GO
CREATE SCHEMA COTIZACION;
GO
CREATE SCHEMA SEGURO;
GO
CREATE SCHEMA POLIZA;
GO

/* ============================
   TRABAJADOR.EMPLEADO
   ============================ */
CREATE TABLE TRABAJADOR.EMPLEADO(
    numEmpleado       NUMERIC(4,0) IDENTITY (1,1),
    tipo              CHAR(1)      NOT NULL,
    nombre            VARCHAR(40)  NOT NULL,
    aPaterno          VARCHAR(40)  NOT NULL,
    aMaterno          VARCHAR(40)  NOT NULL,
    fechaContratacion DATE         NOT NULL,
    CONSTRAINT PK_EMPLEADO PRIMARY KEY (numEmpleado),
    -- CS14: C=corredor, A=ajustador
    CONSTRAINT CK_EMPLEADO_tipo CHECK (tipo IN ('C','A'))
);
GO

/* ============================
   TRABAJADOR.AJUSTADOR
   ============================ */
CREATE TABLE TRABAJADOR.AJUSTADOR(
    numEmpleado NUMERIC(4,0),
    CONSTRAINT PK_AJUSTADOR PRIMARY KEY (numEmpleado),
    CONSTRAINT FK_AJUSTADOR_EMPLEADO FOREIGN KEY (numEmpleado)
        REFERENCES TRABAJADOR.EMPLEADO(numEmpleado)
);
GO

/* ============================
   TRABAJADOR.CORREDOR
   ============================ */
CREATE TABLE TRABAJADOR.CORREDOR(
    numEmpleado        NUMERIC(4,0),
    claveSupervisor    NUMERIC(4,0) NULL,
    porcentajeComision DECIMAL(5,0) NOT NULL,
    zona               VARCHAR(30)  NOT NULL,
    cedulaProf         VARCHAR(7)   NOT NULL,
    CONSTRAINT PK_CORREDOR PRIMARY KEY (numEmpleado),
    CONSTRAINT FK_CORREDOR_EMPLEADO FOREIGN KEY (numEmpleado)
        REFERENCES TRABAJADOR.EMPLEADO(numEmpleado),
    CONSTRAINT FK_CORREDOR_SUPERVISOR FOREIGN KEY (claveSupervisor)
        REFERENCES TRABAJADOR.CORREDOR(numEmpleado),
    CONSTRAINT UQ_CORREDOR_cedulaProf UNIQUE (cedulaProf),
    CONSTRAINT CK_CEDULAPROF CHECK (LEN(cedulaProf)=7)
);
GO

/* ============================
   CLIENTE.ESTADO
   ============================ */
CREATE TABLE CLIENTE.ESTADO(
    id_estado NUMERIC(5,0) IDENTITY (1,1),
    estado    VARCHAR(40)  NOT NULL,
    CONSTRAINT PK_ESTADO PRIMARY KEY (id_estado)
);
GO

/* ============================
   CLIENTE.CIUDAD
   ============================ */
CREATE TABLE CLIENTE.CIUDAD(
    id_ciudad NUMERIC(5,0) IDENTITY (1,1),
    ciudad    VARCHAR(40)  NOT NULL,
    id_estado NUMERIC(5,0) NOT NULL,
    CONSTRAINT PK_CIUDAD PRIMARY KEY (id_ciudad),
    CONSTRAINT FK_CIUDAD_ESTADO FOREIGN KEY (id_estado)
        REFERENCES CLIENTE.ESTADO(id_estado)
);
GO

/* ============================
   CLIENTE.COLONIA
   ============================ */
CREATE TABLE CLIENTE.COLONIA(
    id_colonia NUMERIC(5,0) IDENTITY (1,1),
    colonia    VARCHAR(40)  NOT NULL,
    cp         CHAR(5)      NOT NULL,
    id_ciudad  NUMERIC(5,0) NOT NULL,
    CONSTRAINT PK_COLONIA PRIMARY KEY (id_colonia),
    CONSTRAINT FK_COLONIA_CIUDAD FOREIGN KEY (id_ciudad)
        REFERENCES CLIENTE.CIUDAD(id_ciudad)
);
GO

/* ============================
   CLIENTE.CLIENTE
   ============================ */
CREATE TABLE CLIENTE.CLIENTE(
    id_cliente      NUMERIC(5,0) IDENTITY (1,1),
    curp            CHAR(18)     NOT NULL,
    tipo            CHAR(1)      NOT NULL,
    fechaNacimiento DATE         NOT NULL,
    nombre          VARCHAR(40)  NOT NULL,
    aMaterno        VARCHAR(40)  NULL,
    aPaterno        VARCHAR(40)  NOT NULL,
    id_colonia      NUMERIC(5,0) NOT NULL,
    numEmpleado     NUMERIC(4,0) NOT NULL,
    CONSTRAINT PK_CLIENTE PRIMARY KEY (id_cliente),
    CONSTRAINT UQ_CLIENTE_curp UNIQUE (curp),
    CONSTRAINT FK_CLIENTE_COLONIA FOREIGN KEY (id_colonia)
        REFERENCES CLIENTE.COLONIA(id_colonia),
    CONSTRAINT FK_CLIENTE_CORREDOR FOREIGN KEY (numEmpleado)
        REFERENCES TRABAJADOR.CORREDOR(numEmpleado),
    CONSTRAINT CK_CURP CHECK (LEN(curp)=18),
    -- CS6: N/M
    CONSTRAINT CK_CLIENTE_tipo CHECK (tipo IN ('N','M')),
    -- CS7
	edad AS
			DATEDIFF(YEAR, fechaNacimiento, CAST(GETDATE() AS date))
			- CASE
				  WHEN DATEADD(
						   YEAR,
						   DATEDIFF(YEAR, fechaNacimiento, GETDATE()),
						   fechaNacimiento) > CAST(GETDATE() AS date)
				  THEN 1 ELSE 0
			  END
);
GO

/* ============================
   CLIENTE.EMAIL
   ============================ */
CREATE TABLE CLIENTE.EMAIL(
    id_email   NUMERIC(5,0) IDENTITY (1,1),
    email      VARCHAR(60)  NOT NULL,
    id_cliente NUMERIC(5,0) NOT NULL,
    CONSTRAINT PK_EMAIL PRIMARY KEY (id_email),
    CONSTRAINT FK_EMAIL_CLIENTE FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE.CLIENTE(id_cliente)
);
GO

/* ============================
   CLIENTE.TELEFONO
   ============================ */
CREATE TABLE CLIENTE.TELEFONO(
    id_telefono NUMERIC(5,0)  IDENTITY (1,1),
    telefono    NUMERIC(10,0) NOT NULL,
    id_cliente  NUMERIC(5,0)  NOT NULL,
    CONSTRAINT PK_TELEFONO PRIMARY KEY (id_telefono),
    CONSTRAINT FK_TELEFONO_CLIENTE FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE.CLIENTE(id_cliente),
    CONSTRAINT CK_TELEFONO CHECK (telefono LIKE 
    '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);
GO

/* ============================
   COTIZACION.STATUS_COTIZACION
   ============================ */
CREATE TABLE COTIZACION.STATUS_COTIZACION(
    status_cotizacion_id NUMERIC(5,0) IDENTITY (1,1),
    activo               CHAR(1)      NOT NULL
	--CS18
        CONSTRAINT DF_STATUS_activo DEFAULT 'P',
    CONSTRAINT PK_STATUS_COTIZACION PRIMARY KEY (status_cotizacion_id),
    CONSTRAINT CK_STATUS_COTIZACION_codigo CHECK (activo IN ('P','A','R'))
);
GO

/* ============================
   COTIZACION.COTIZACION
   ============================ */
CREATE TABLE COTIZACION.COTIZACION(
    numCotizacion        NUMERIC(6,0) IDENTITY (1,1),
    estadoActual         CHAR(1)      NOT NULL,
    fechaCotizacion      DATE         NOT NULL,
    montoEstimadoPrima   DECIMAL(6,0) NOT NULL,
    fechaVenOferta       DATE         NOT NULL,
    recordatorio         VARCHAR(60)  NULL,
    status_cotizacion_id NUMERIC(5,0) NOT NULL,
    id_cliente           NUMERIC(5,0) NOT NULL,
    CONSTRAINT PK_COTIZACION PRIMARY KEY (numCotizacion),
    CONSTRAINT FK_COTIZACION_STATUS FOREIGN KEY (status_cotizacion_id)
        REFERENCES COTIZACION.STATUS_COTIZACION(status_cotizacion_id),
    CONSTRAINT FK_COTIZACION_CLIENTE FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE.CLIENTE(id_cliente),
    -- CS5:
    CONSTRAINT CK_COTIZACION_estado CHECK (estadoActual IN ('A','P','R'))
);
GO

/* ============================
   SEGURO.TIPO_SEGURO
   ============================ */
CREATE TABLE SEGURO.TIPO_SEGURO(
    id_tipoSeguro        NUMERIC(5,0) IDENTITY (1,1),
    esAuto               BIT          NOT NULL,
    esVida               BIT          NOT NULL,
    esRetiro             BIT          NOT NULL,
    claveSeguro          NUMERIC(5, 0)      NOT NULL,
    descripcion          VARCHAR(60)  NOT NULL,
    montoAseguradoMinimo DECIMAL(6,0) NOT NULL,
    vigenciaMinima       NUMERIC(2,0) NOT NULL,
    nomProducto          VARCHAR(40)  NOT NULL,
    CONSTRAINT PK_TIPO_SEGURO PRIMARY KEY (id_tipoSeguro),
    CONSTRAINT UQ_TIPOSEGURO_claveSeguro UNIQUE (claveSeguro),
    -- CS9 ES EN MESES:
    CONSTRAINT CK_TIPOSEGURO_vigenciaMinima_meses CHECK (vigenciaMinima >= 1)
);
GO

/* ============================
   COTIZACION.COTIZACION_TIPO_SEGURO
   ============================ */
CREATE TABLE COTIZACION.COTIZACION_TIPO_SEGURO(
    id_tipoSeguro NUMERIC(5,0),
    numCotizacion NUMERIC(6,0) NOT NULL,
    CONSTRAINT PK_COT_TIPO PRIMARY KEY (id_tipoSeguro, numCotizacion),
    CONSTRAINT FK_COT_TIPO_SEGURO FOREIGN KEY (id_tipoSeguro)
        REFERENCES SEGURO.TIPO_SEGURO(id_tipoSeguro),
    CONSTRAINT FK_COT_TIPO_COTIZACION FOREIGN KEY (numCotizacion)
        REFERENCES COTIZACION.COTIZACION(numCotizacion)
);
GO

/* ============================
   SEGURO.SEGURO_AUTO
   ============================ */
CREATE TABLE SEGURO.SEGURO_AUTO(
    id_tipoSeguro   NUMERIC(5,0),
    coberturaBasica VARCHAR(60)  NOT NULL,
    CONSTRAINT PK_SEGURO_AUTO PRIMARY KEY (id_tipoSeguro),
    CONSTRAINT FK_SEGURO_AUTO_TIPO FOREIGN KEY (id_tipoSeguro)
        REFERENCES SEGURO.TIPO_SEGURO(id_tipoSeguro)
);
GO

/* ============================
   SEGURO.SEGURO_VIDA
   ============================ */
CREATE TABLE SEGURO.SEGURO_VIDA(
    id_tipoSeguro       NUMERIC(5,0),
    edadMaxContratacion NUMERIC(2,0) NOT NULL,
    clave               VARCHAR(10)  NOT NULL,
    CONSTRAINT PK_SEGURO_VIDA PRIMARY KEY (id_tipoSeguro),
    CONSTRAINT FK_SEGURO_VIDA_TIPO FOREIGN KEY (id_tipoSeguro)
        REFERENCES SEGURO.TIPO_SEGURO(id_tipoSeguro)
);
GO

/* ============================
   SEGURO.SEGURO_RETIRO
   ============================ */
CREATE TABLE SEGURO.SEGURO_RETIRO(
    id_tipoSeguro        NUMERIC(5,0),
    clave                VARCHAR(10)  NOT NULL,
    edadRetiro           NUMERIC(3,0) NOT NULL,
    aportacionMinMensual DECIMAL(6,0) NOT NULL,
    CONSTRAINT PK_SEGURO_RETIRO PRIMARY KEY (id_tipoSeguro),
    CONSTRAINT FK_SEGURO_RETIRO_TIPO FOREIGN KEY (id_tipoSeguro)
        REFERENCES SEGURO.TIPO_SEGURO(id_tipoSeguro)
);
GO

/* ============================
   SEGURO.BENEFICIARIO
   ============================ */
CREATE TABLE SEGURO.BENEFICIARIO(
    id_beneficiario NUMERIC(5,0) IDENTITY (1,1),
    porcentaje      DECIMAL(3,0) NOT NULL,
    parentesco      CHAR(1)      NOT NULL,
    nombre          VARCHAR(40)  NOT NULL,
    aPaterno        VARCHAR(40)  NOT NULL,
    aMaterno        VARCHAR(40)  NULL,
    id_tipoSeguro   NUMERIC(5,0) NOT NULL,
    CONSTRAINT PK_BENEFICIARIO PRIMARY KEY (id_beneficiario),
    CONSTRAINT FK_BENEFICIARIO_SEGURO_VIDA FOREIGN KEY (id_tipoSeguro)
        REFERENCES SEGURO.SEGURO_VIDA(id_tipoSeguro),
    CONSTRAINT CK_PORCENTAJE CHECK (porcentaje<=100),
    -- CS13: P/M/E/H
    CONSTRAINT CK_BENEFICIARIO_parentesco CHECK (parentesco IN ('P','M','E','H'))
);
GO

/* ============================
   POLIZA.AUTO
   ============================ */
CREATE TABLE POLIZA.AUTO(
    id_auto        NUMERIC(6,0)   IDENTITY (1,1),
    numeroSerie    VARCHAR(20)    NOT NULL,
    matricula      VARCHAR(7)     NOT NULL,
    anio           NUMERIC(4,0)   NOT NULL,
    modelo         VARCHAR(30)    NOT NULL,
    marca          VARCHAR(30)    NOT NULL,
    valorComercial DECIMAL(8,0)   NOT NULL,
    CONSTRAINT PK_AUTO PRIMARY KEY (id_auto),
    CONSTRAINT UQ_AUTO_numeroSerie UNIQUE (numeroSerie)
);
GO

/* ============================
   POLIZA.POLIZA
   ============================ */
CREATE TABLE POLIZA.POLIZA(
    id_poliza       NUMERIC(10,0) IDENTITY (1,1),
    activo          BIT           NOT NULL
        --CS16
		CONSTRAINT DF_POLIZA_activo DEFAULT 1,
    fechaIniVig     DATE          NOT NULL,
    numPoliza       VARCHAR(12)   NOT NULL,
    fechaFinVig     DATE          NOT NULL,
    montoPrimaTotal DECIMAL(6,0)  NOT NULL,
    id_auto         NUMERIC(6,0)  NULL,
    id_tipoSeguro   NUMERIC(5,0)  NOT NULL,
    numCotizacion   NUMERIC(6,0)  NOT NULL,
    numEmpleado     NUMERIC(4,0)  NOT NULL,
    CONSTRAINT PK_POLIZA PRIMARY KEY (id_poliza),
    CONSTRAINT UQ_POLIZA_numPoliza UNIQUE (numPoliza),
    CONSTRAINT FK_POLIZA_CORREDOR FOREIGN KEY (numEmpleado)
        REFERENCES TRABAJADOR.CORREDOR(numEmpleado),
    CONSTRAINT FK_POLIZA_AUTO FOREIGN KEY (id_auto)
        REFERENCES POLIZA.AUTO(id_auto),
    CONSTRAINT FK_POLIZA_COT_TIPO FOREIGN KEY (id_tipoSeguro, numCotizacion)
        REFERENCES COTIZACION.COTIZACION_TIPO_SEGURO(id_tipoSeguro, numCotizacion),
    -- CS1:
    CONSTRAINT CK_POLIZA_montoPrimaTotal_pos CHECK (montoPrimaTotal > 0),
    -- CS2:
    CONSTRAINT CK_POLIZA_vigencia CHECK (fechaFinVig > fechaIniVig)
);
GO

/* ============================
   POLIZA.PAGO
   ============================ */
CREATE TABLE POLIZA.PAGO(
    id_poliza      NUMERIC(10,0),
    numPago        DECIMAL(5,0)  NOT NULL,
    saldoPendiente DECIMAL(6,0)  NOT NULL,
    montoPagado    DECIMAL(6,0)  NOT NULL,
    fechaPago      DATE          NOT NULL,
    metodoPago     BIT           NOT NULL,
    CONSTRAINT PK_PAGO PRIMARY KEY (id_poliza, numPago),
    CONSTRAINT FK_PAGO_POLIZA FOREIGN KEY (id_poliza)
        REFERENCES POLIZA.POLIZA(id_poliza),
    -- CS12:
    CONSTRAINT CK_PAGO_numPago_inicio CHECK (numPago >= 1),
    -- CS17:
    CONSTRAINT CK_PAGO_metodoPago CHECK (metodoPago IN (0,1))
);
GO


/* ============================
   POLIZA.SINIESTRO
   ============================ */
CREATE TABLE POLIZA.SINIESTRO(
    numSiniestro   NUMERIC(6,0)  IDENTITY (1,1),
    fecha          DATETIME      NOT NULL,
    lugarSiniestro VARCHAR(60)   NOT NULL, 
    -- CS8 dias transcurridos:
    diasTranscurridos AS DATEDIFF(DAY, CAST(fecha AS date),
                 CAST(GETDATE() AS date)),
    causa          VARCHAR(80)   NOT NULL,
    montoIndem     DECIMAL(6,0)  NOT NULL,
    id_poliza      NUMERIC(10,0) NOT NULL,
    numEmpleado    NUMERIC(4,0)  NOT NULL,
    CONSTRAINT PK_SINIESTRO PRIMARY KEY (numSiniestro),
    CONSTRAINT FK_SINIESTRO_AJUSTADOR FOREIGN KEY (numEmpleado)
        REFERENCES TRABAJADOR.AJUSTADOR(numEmpleado),
    CONSTRAINT FK_SINIESTRO_POLIZA FOREIGN KEY (id_poliza)
        REFERENCES POLIZA.POLIZA(id_poliza)
);
GO

/* ============================
   POLIZA.HISTORICO_POLIZA
   ============================ */
CREATE TABLE POLIZA.HISTORICO_POLIZA(
    id_historico_status_poliza NUMERIC(5,0)   IDENTITY (1,1),
    activo                      BIT           NOT NULL,
    fechaIniVig                 DATE          NOT NULL,
    numPoliza                   VARCHAR(12)   NOT NULL,
    fechaEstatus                DATE          NOT NULL,
    fechaFinVig                 DATE          NOT NULL,
    montoPrimaTotal             DECIMAL(6,0)  NOT NULL,
    id_poliza                   NUMERIC(10,0) NOT NULL,
    CONSTRAINT PK_HISTORICO_POLIZA PRIMARY KEY (id_historico_status_poliza),
    CONSTRAINT FK_HISTORICO_POLIZA_POLIZA FOREIGN KEY (id_poliza)
        REFERENCES POLIZA.POLIZA(id_poliza),
    CONSTRAINT CK_POLIZA_montoPrimaTotal CHECK (montoPrimaTotal > 0),
    CONSTRAINT CK_POLIZA_vigenciaHistorico CHECK (fechaFinVig > fechaIniVig)
);
GO

/* ============================
   COTIZACION.HISTORICO_STATUS_COTIZACION
   ============================ */
CREATE TABLE COTIZACION.HISTORICO_STATUS_COTIZACION(
    historico_status_cotizacion NUMERIC(10,0) IDENTITY (1,1),
    numCotizacion               NUMERIC(6,0)  NOT NULL,
    fechaCotizacion             DATE          NOT NULL,
    estadoAnterior              CHAR(1)       NOT NULL,
    montoEstimadoPrima          DECIMAL(10,0) NOT NULL,
    fechaVenOferta              DATE          NOT NULL,
    recordatorio                VARCHAR(60)   NOT NULL,
    fechaCambio                 DATE          NOT NULL,
    status_cotizacion_id        NUMERIC(5,0)  NOT NULL,
    CONSTRAINT PK_HIST_STATUS_COT PRIMARY KEY (historico_status_cotizacion),
    CONSTRAINT FK_HIST_COT_COTIZACION FOREIGN KEY (numCotizacion)
        REFERENCES COTIZACION.COTIZACION(numCotizacion),
    CONSTRAINT FK_HIST_COT_STATUS FOREIGN KEY (status_cotizacion_id)
        REFERENCES COTIZACION.STATUS_COTIZACION(status_cotizacion_id),
    --CS5:
    CONSTRAINT CK_HISTORICO_COTIZACION_status CHECK (estadoAnterior IN ('P','A','R'))
);
GO


--IMPLEMENTAMOS LOS TRIGGERS DE LAS CONSIDERACIONES SEMANTICAS QUE NO SE PUEDEN CUMPLIR CON CHECK--

--CS3:
CREATE OR ALTER TRIGGER TR_COT_TIPO_validaEdadVida
ON COTIZACION.COTIZACION_TIPO_SEGURO
AFTER INSERT, UPDATE
AS
BEGIN

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN COTIZACION.COTIZACION c
            ON c.numCotizacion = i.numCotizacion
        JOIN CLIENTE.CLIENTE cl
            ON cl.id_cliente = c.id_cliente
        JOIN SEGURO.TIPO_SEGURO ts
            ON ts.id_tipoSeguro = i.id_tipoSeguro
        JOIN SEGURO.SEGURO_VIDA sv
            ON sv.id_tipoSeguro = ts.id_tipoSeguro
        WHERE ts.esVida = 1
          AND (
                DATEDIFF(YEAR, cl.fechaNacimiento, GETDATE())
                - CASE 
                    WHEN DATEADD(YEAR, DATEDIFF(YEAR, cl.fechaNacimiento, GETDATE()), cl.fechaNacimiento) > GETDATE()
                    THEN 1 ELSE 0
                  END
              ) > sv.edadMaxContratacion
    )
    BEGIN
        RAISERROR(
          'La edad del cliente excede la edad maxima de contratacion para Seguro Vida.',
          16, 1
        );
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO


-- CS4
CREATE OR ALTER TRIGGER TR_PAGO_recalculaSaldo
ON POLIZA.PAGO
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    ;WITH PolizasAfectadas AS (
        SELECT id_poliza FROM inserted
        UNION
        SELECT id_poliza FROM deleted
    ),

    SumaPagos AS (
        SELECT  pg.id_poliza,
                SUM(pg.montoPagado) AS totalPagado
        FROM POLIZA.PAGO pg
        JOIN PolizasAfectadas pa
          ON pa.id_poliza = pg.id_poliza
        GROUP BY pg.id_poliza
    )

    UPDATE pg
    SET pg.saldoPendiente = p.montoPrimaTotal - sp.totalPagado
    FROM POLIZA.PAGO   pg
    JOIN PolizasAfectadas pa
      ON pa.id_poliza = pg.id_poliza
    JOIN SumaPagos sp
      ON sp.id_poliza = pg.id_poliza
    JOIN POLIZA.POLIZA p
      ON p.id_poliza = pg.id_poliza;
END;
GO

--CS10
CREATE OR ALTER TRIGGER SEGURO.TR_BENEFICIARIO_max5 
ON SEGURO.BENEFICIARIO
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT b.id_tipoSeguro
        FROM SEGURO.BENEFICIARIO b
        WHERE b.id_tipoSeguro IN (SELECT DISTINCT id_tipoSeguro FROM inserted)
        GROUP BY b.id_tipoSeguro
        HAVING COUNT(*) > 5
    )
    BEGIN
        RAISERROR(
          'CS10: Un seguro de vida no puede tener mas de 5 beneficiarios.',
          16, 1
        );
        ROLLBACK TRANSACTION;
        RETURN;
����END
END;
GO

-- CS11
CREATE OR ALTER TRIGGER TR_BENEFICIARIO_suma100_estricto
ON SEGURO.BENEFICIARIO
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM SEGURO.BENEFICIARIO b
        JOIN (
            SELECT DISTINCT id_tipoSeguro FROM inserted
            UNION
            SELECT DISTINCT id_tipoSeguro FROM deleted
        ) s
            ON s.id_tipoSeguro = b.id_tipoSeguro
        GROUP BY b.id_tipoSeguro
        HAVING SUM(b.porcentaje) > 100  
            OR SUM(b.porcentaje) < 100  
    )
    BEGIN
        RAISERROR(
          'CS11: La suma de porcentajes de beneficiarios debe ser exactamente 100%% (no mayor ni menor).',
          16, 1
        );
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO


--CS15:
CREATE OR ALTER TRIGGER TR_POLIZA_validaAutoObligatorio
ON POLIZA.POLIZA
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN SEGURO.TIPO_SEGURO ts
            ON ts.id_tipoSeguro = i.id_tipoSeguro
        WHERE ts.esAuto = 1
          AND i.id_auto IS NULL
    )
    BEGIN
        RAISERROR(
          'CS15: Si el tipo de seguro es Auto, los datos del AUTO son obligatorios (id_auto no puede ser NULL).',
          16, 1
        );
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO


--CS19 asignacion-corredorAutomatico:
CREATE OR ALTER TRIGGER CLIENTE.TR_CLIENTE_AsignarCorredorAutomatico
ON CLIENTE.CLIENTE
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @DatosInsertar TABLE (
        curp CHAR(18), tipo CHAR(1), fechaNacimiento DATE,
        nombre VARCHAR(40), aMaterno VARCHAR(40), aPaterno VARCHAR(40),
        id_colonia NUMERIC(5,0), numEmpleado NUMERIC(4,0)
    );
    INSERT INTO @DatosInsertar
    SELECT 
        i.curp, i.tipo, i.fechaNacimiento, 
        i.nombre, i.aMaterno, i.aPaterno, 
        i.id_colonia,
        COALESCE(i.numEmpleado, (
            SELECT TOP 1 c.numEmpleado
            FROM TRABAJADOR.CORREDOR c
            WHERE c.zona = CASE 
                            WHEN (SELECT cp FROM CLIENTE.COLONIA WHERE id_colonia = i.id_colonia) LIKE '06%' THEN 'Zona Centro'
                            WHEN (SELECT cp FROM CLIENTE.COLONIA WHERE id_colonia = i.id_colonia) LIKE '53%' THEN 'Zona Norte'
                            ELSE 'Zona Centro'
                           END
        ), 1)
    FROM inserted i;
    INSERT INTO CLIENTE.CLIENTE(
        curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado
    )
    SELECT 
        curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado
    FROM @DatosInsertar;
END;
GO