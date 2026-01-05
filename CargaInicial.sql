USE SEGUROS;
GO

/* =========================================================
   1. CAT�LOGOS DE UBICACI�N (ESTADO, CIUDAD, COLONIA)
   ========================================================= */

DECLARE 
    @idEdo1 NUMERIC(5,0),
    @idEdo2 NUMERIC(5,0),
    @idEdo3 NUMERIC(5,0);

INSERT CLIENTE.ESTADO(estado) VALUES ('Ciudad de M�xico');
SET @idEdo1 = SCOPE_IDENTITY();

INSERT CLIENTE.ESTADO(estado) VALUES ('Estado de M�xico');
SET @idEdo2 = SCOPE_IDENTITY();

INSERT CLIENTE.ESTADO(estado) VALUES ('Jalisco');
SET @idEdo3 = SCOPE_IDENTITY();

DECLARE 
    @idCd1 NUMERIC(5,0),
    @idCd2 NUMERIC(5,0),
    @idCd3 NUMERIC(5,0);

INSERT CLIENTE.CIUDAD(ciudad, id_estado) VALUES ('CDMX',        @idEdo1);
SET @idCd1 = SCOPE_IDENTITY();

INSERT CLIENTE.CIUDAD(ciudad, id_estado) VALUES ('Naucalpan',   @idEdo2);
SET @idCd2 = SCOPE_IDENTITY();

INSERT CLIENTE.CIUDAD(ciudad, id_estado) VALUES ('Guadalajara', @idEdo3);
SET @idCd3 = SCOPE_IDENTITY();

DECLARE 
    @idCol1 NUMERIC(5,0),
    @idCol2 NUMERIC(5,0),
    @idCol3 NUMERIC(5,0);

INSERT CLIENTE.COLONIA(colonia, cp, id_ciudad)
VALUES ('Centro Hist�rico', '06000', @idCd1);
SET @idCol1 = SCOPE_IDENTITY();

INSERT CLIENTE.COLONIA(colonia, cp, id_ciudad)
VALUES ('Ciudad Sat�lite', '53100', @idCd2);
SET @idCol2 = SCOPE_IDENTITY();

INSERT CLIENTE.COLONIA(colonia, cp, id_ciudad)
VALUES ('Providencia', '44630', @idCd3);
SET @idCol3 = SCOPE_IDENTITY();


/* =========================================================
   2. TRABAJADORES: 10 EMPLEADOS (5 CORREDORES, 5 AJUSTADORES)
   ========================================================= */

DECLARE 
    @emp1 NUMERIC(4,0),
    @emp2 NUMERIC(4,0),
    @emp3 NUMERIC(4,0),
    @emp4 NUMERIC(4,0),
    @emp5 NUMERIC(4,0),
    @emp6 NUMERIC(4,0),
    @emp7 NUMERIC(4,0),
    @emp8 NUMERIC(4,0),
    @emp9 NUMERIC(4,0),
    @emp10 NUMERIC(4,0);

INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion)
VALUES ('C', 'Juan',    'P�rez',   'L�pez',    '2022-01-10');
SET @emp1 = SCOPE_IDENTITY();

INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion)
VALUES ('C', 'Mar�a',   'Garc�a',  'Ram�rez',  '2021-03-15');
SET @emp2 = SCOPE_IDENTITY();

INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion)
VALUES ('C', 'Carlos',  'Hern�ndez','Ruiz',    '2020-07-01');
SET @emp3 = SCOPE_IDENTITY();

INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion)
VALUES ('C', 'Ana',     'L�pez',   'Mart�nez', '2019-09-23');
SET @emp4 = SCOPE_IDENTITY();

INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion)
VALUES ('C', 'Diego',   'S�nchez', 'N��ez',    '2023-02-05');
SET @emp5 = SCOPE_IDENTITY();

INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion)
VALUES ('A', 'Luis',    'Torres',  'Flores',   '2021-11-11');
SET @emp6 = SCOPE_IDENTITY();

INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion)
VALUES ('A', 'Sof�a',   'Ram�rez', 'Ortiz',    '2020-05-30');
SET @emp7 = SCOPE_IDENTITY();

INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion)
VALUES ('A', 'Pedro',   'Vargas',  'Jim�nez',  '2018-04-19');
SET @emp8 = SCOPE_IDENTITY();

INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion)
VALUES ('A', 'Valeria', 'Flores',  'G�mez',    '2022-06-08');
SET @emp9 = SCOPE_IDENTITY();

INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion)
VALUES ('A', 'Jorge',   'Morales', 'Cruz',     '2019-12-01');
SET @emp10 = SCOPE_IDENTITY();

INSERT TRABAJADOR.CORREDOR(numEmpleado, claveSupervisor, porcentajeComision, zona, cedulaProf)
VALUES (@emp1, NULL, 15, 'Zona Centro',     'ABC1234');

INSERT TRABAJADOR.CORREDOR(numEmpleado, claveSupervisor, porcentajeComision, zona, cedulaProf)
VALUES (@emp2, @emp1, 12, 'Zona Norte',     'DEF5678');

INSERT TRABAJADOR.CORREDOR(numEmpleado, claveSupervisor, porcentajeComision, zona, cedulaProf)
VALUES (@emp3, @emp1, 10, 'Zona Sur',       'GHI9012');

INSERT TRABAJADOR.CORREDOR(numEmpleado, claveSupervisor, porcentajeComision, zona, cedulaProf)
VALUES (@emp4, @emp1, 11, 'Zona Poniente',  'JKL3456');

INSERT TRABAJADOR.CORREDOR(numEmpleado, claveSupervisor, porcentajeComision, zona, cedulaProf)
VALUES (@emp5, @emp1, 13, 'Zona Oriente',   'MNO7890');

INSERT TRABAJADOR.AJUSTADOR(numEmpleado) VALUES (@emp6);
INSERT TRABAJADOR.AJUSTADOR(numEmpleado) VALUES (@emp7);
INSERT TRABAJADOR.AJUSTADOR(numEmpleado) VALUES (@emp8);
INSERT TRABAJADOR.AJUSTADOR(numEmpleado) VALUES (@emp9);
INSERT TRABAJADOR.AJUSTADOR(numEmpleado) VALUES (@emp10);


/* =========================================================
   3. STATUS DE COTIZACI�N
   ========================================================= */

DECLARE 
    @stPend  NUMERIC(5,0),
    @stAprob NUMERIC(5,0),
    @stRech  NUMERIC(5,0);

INSERT COTIZACION.STATUS_COTIZACION(activo) VALUES ('P'); 
SET @stPend = SCOPE_IDENTITY();

INSERT COTIZACION.STATUS_COTIZACION(activo) VALUES ('A'); 
SET @stAprob = SCOPE_IDENTITY();

INSERT COTIZACION.STATUS_COTIZACION(activo) VALUES ('R'); 
SET @stRech = SCOPE_IDENTITY();


/* =========================================================
   4. TIPOS DE SEGURO (AUTO, VIDA, RETIRO) Y DETALLES
   ========================================================= */

DECLARE 
    @tipoAuto   NUMERIC(5,0),
    @tipoVida   NUMERIC(5,0),
    @tipoRetiro NUMERIC(5,0);

INSERT SEGURO.TIPO_SEGURO(
    esAuto, esVida, esRetiro,
    claveSeguro, descripcion,
    montoAseguradoMinimo, vigenciaMinima, nomProducto
)
VALUES (
    1, 0, 0,
    1001, 'Seguro de Auto B�sico',
    100000, 12, 'Auto B�sico'
);
SET @tipoAuto = SCOPE_IDENTITY();

INSERT SEGURO.SEGURO_AUTO(id_tipoSeguro, coberturaBasica)
VALUES (@tipoAuto, 'Responsabilidad civil y da�os materiales');

INSERT SEGURO.TIPO_SEGURO(
    esAuto, esVida, esRetiro,
    claveSeguro, descripcion,
    montoAseguradoMinimo, vigenciaMinima, nomProducto
)
VALUES (
    0, 1, 0,
    2001, 'Seguro de Vida Individual',
    50000, 12, 'Vida Cl�sico'
);
SET @tipoVida = SCOPE_IDENTITY();
INSERT SEGURO.SEGURO_VIDA(id_tipoSeguro, edadMaxContratacion, clave)
VALUES (@tipoVida, 40 , 'VIDA1');

INSERT SEGURO.TIPO_SEGURO(
    esAuto, esVida, esRetiro,
    claveSeguro, descripcion,
    montoAseguradoMinimo, vigenciaMinima, nomProducto
)
VALUES (
    0, 0, 1,
    3001, 'Plan de Retiro',
    30000, 60, 'Retiro Plus'
);
SET @tipoRetiro = SCOPE_IDENTITY();

INSERT SEGURO.SEGURO_RETIRO(id_tipoSeguro, clave, edadRetiro, aportacionMinMensual)
VALUES (@tipoRetiro, 'RET01', 65, 2000);

INSERT SEGURO.BENEFICIARIO(
    porcentaje, parentesco, nombre, aPaterno, aMaterno, id_tipoSeguro
)
VALUES 
    (60, 'H', 'Luis', 'P�rez',  'G�mez',  @tipoVida),
    (40, 'H', 'Ana',  'P�rez',  'G�mez',  @tipoVida);


/* =========================================================
   5. CLIENTES (20) + EMAIL + TEL�FONO
   ========================================================= */

DECLARE
    @cli1 NUMERIC(5,0), @cli2 NUMERIC(5,0), @cli3 NUMERIC(5,0), @cli4 NUMERIC(5,0), @cli5 NUMERIC(5,0),
    @cli6 NUMERIC(5,0), @cli7 NUMERIC(5,0), @cli8 NUMERIC(5,0), @cli9 NUMERIC(5,0), @cli10 NUMERIC(5,0),
    @cli11 NUMERIC(5,0), @cli12 NUMERIC(5,0), @cli13 NUMERIC(5,0), @cli14 NUMERIC(5,0), @cli15 NUMERIC(5,0),
    @cli16 NUMERIC(5,0), @cli17 NUMERIC(5,0), @cli18 NUMERIC(5,0), @cli19 NUMERIC(5,0), @cli20 NUMERIC(5,0);

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0001', 'N', '1990-05-10', 'Ricardo', 'L�pez', 'Garc�a', @idCol1, @emp1);
SELECT @cli1 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0001';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0002', 'N', '1988-08-22', 'Patricia', 'Ram�rez', 'Santos', @idCol1, @emp2);
SELECT @cli2 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0002';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0003', 'N', '1995-03-15', 'H�ctor', 'Cruz', 'Mart�nez', @idCol1, @emp3);
SELECT @cli3 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0003';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0004', 'N', '1992-11-30', 'Fernanda', 'Flores', 'Luna', @idCol1, @emp4);
SELECT @cli4 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0004';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0005', 'N', '1985-01-05', 'Alejandro', 'Mendoza', 'Reyes', @idCol1, @emp5);
SELECT @cli5 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0005';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0006', 'N', '1998-07-18', 'Paola', 'Castro', 'Vega', @idCol1, @emp1);
SELECT @cli6 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0006';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0007', 'N', '1993-09-09', 'Miguel', 'Rojas', 'Silva', @idCol1, @emp2);
SELECT @cli7 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0007';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0008', 'N', '1991-02-14', 'Daniela', 'Nava', 'Paredes', @idCol2, @emp3);
SELECT @cli8 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0008';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0009', 'N', '1994-10-01', 'Javier', 'Luna', 'Moreno', @idCol2, @emp4);
SELECT @cli9 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0009';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0010', 'N', '1999-12-25', 'Adriana', 'Ponce', 'Serrano', @idCol2, @emp5);
SELECT @cli10 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0010';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0011', 'M', '2000-01-01', 'Empresa Uno SA', '', 'De CV', @idCol2, @emp1);
SELECT @cli11 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0011';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0012', 'M', '2000-01-01', 'Empresa Dos SA', '', 'De CV', @idCol2, @emp2);
SELECT @cli12 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0012';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0013', 'N', '1987-06-06', 'Carolina', 'Herrera', 'Campos', @idCol3, @emp3);
SELECT @cli13 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0013';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0014', 'N', '1989-04-03', 'Ra�l', 'Rosales', 'Ibarra', @idCol3, @emp4);
SELECT @cli14 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0014';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0015', 'N', '1996-03-20', 'Andrea', 'Quintana', 'Sol�s', @idCol3, @emp5);
SELECT @cli15 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0015';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0016', 'N', '1997-08-08', 'Emilio', 'Escobar', 'Delgado', @idCol3, @emp1);
SELECT @cli16 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0016';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0017', 'N', '1990-09-19', 'Beatriz', 'Hidalgo', 'Su�rez', @idCol3, @emp2);
SELECT @cli17 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0017';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0018', 'N', '1992-01-30', 'Mauricio', 'Paz', 'Oviedo', @idCol3, @emp3);
SELECT @cli18 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0018';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0019', 'M', '2000-01-01', 'Empresa Tres SA', '', 'De CV', @idCol1, @emp4);
SELECT @cli19 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0019';

INSERT CLIENTE.CLIENTE(curp, tipo, fechaNacimiento, nombre, aMaterno, aPaterno, id_colonia, numEmpleado)
VALUES ('AAAA000000AAAA0020', 'M', '2000-01-01', 'Empresa Cuatro SA', '', 'De CV', @idCol1, @emp5);
SELECT @cli20 = id_cliente FROM CLIENTE.CLIENTE WHERE curp = 'AAAA000000AAAA0020';


/* =========================================================
   6. COTIZACIONES 10
   ========================================================= */

DECLARE
    @cot1 NUMERIC(6,0), @cot2 NUMERIC(6,0), @cot3 NUMERIC(6,0), @cot4 NUMERIC(6,0),
    @cot5 NUMERIC(6,0), @cot6 NUMERIC(6,0), @cot7 NUMERIC(6,0), @cot8 NUMERIC(6,0),
    @cot9 NUMERIC(6,0), @cot10 NUMERIC(6,0);

INSERT COTIZACION.COTIZACION(
    estadoActual, fechaCotizacion, montoEstimadoPrima,
    fechaVenOferta, recordatorio, status_cotizacion_id, id_cliente
)
VALUES ('A', '2025-10-01', 12000, '2025-12-01', 'Renovar antes de vencer', @stAprob, @cli1);
SET @cot1 = SCOPE_IDENTITY();

INSERT COTIZACION.COTIZACION(
    estadoActual, fechaCotizacion, montoEstimadoPrima,
    fechaVenOferta, recordatorio, status_cotizacion_id, id_cliente
)
VALUES ('A', '2025-09-15',  9500, '2025-11-15', 'Confirmar aceptaci�n', @stAprob, @cli2);
SET @cot2 = SCOPE_IDENTITY();

INSERT COTIZACION.COTIZACION(
    estadoActual, fechaCotizacion, montoEstimadoPrima,
    fechaVenOferta, recordatorio, status_cotizacion_id, id_cliente
)
VALUES ('A', '2025-08-20', 80000, '2025-10-20', 'Revisi�n p�liza de vida', @stAprob, @cli3);
SET @cot3 = SCOPE_IDENTITY();

INSERT COTIZACION.COTIZACION(
    estadoActual, fechaCotizacion, montoEstimadoPrima,
    fechaVenOferta, recordatorio, status_cotizacion_id, id_cliente
)
VALUES ('A', '2025-07-10', 60000, '2025-09-10', 'Enviar documentaci�n vida', @stAprob, @cli4);
SET @cot4 = SCOPE_IDENTITY();

INSERT COTIZACION.COTIZACION(
    estadoActual, fechaCotizacion, montoEstimadoPrima,
    fechaVenOferta, recordatorio, status_cotizacion_id, id_cliente
)
VALUES ('A', '2025-06-05', 30000, '2025-08-05', 'Plan retiro anual', @stAprob, @cli5);
SET @cot5 = SCOPE_IDENTITY();

INSERT COTIZACION.COTIZACION(
    estadoActual, fechaCotizacion, montoEstimadoPrima,
    fechaVenOferta, recordatorio, status_cotizacion_id, id_cliente
)
VALUES ('A', '2025-05-25', 40000, '2025-07-25', 'Plan retiro mensual', @stAprob, @cli6);
SET @cot6 = SCOPE_IDENTITY();

INSERT COTIZACION.COTIZACION(
    estadoActual, fechaCotizacion, montoEstimadoPrima,
    fechaVenOferta, recordatorio, status_cotizacion_id, id_cliente
)
VALUES ('P', '2025-11-05', 11000, '2026-01-05', 'Pendiente respuesta cliente', @stPend, @cli7);
SET @cot7 = SCOPE_IDENTITY();

INSERT COTIZACION.COTIZACION(
    estadoActual, fechaCotizacion, montoEstimadoPrima,
    fechaVenOferta, recordatorio, status_cotizacion_id, id_cliente
)
VALUES ('R', '2025-09-01', 9000, '2025-11-01', 'Rechazada por cliente', @stRech, @cli8);
SET @cot8 = SCOPE_IDENTITY();

INSERT COTIZACION.COTIZACION(
    estadoActual, fechaCotizacion, montoEstimadoPrima,
    fechaVenOferta, recordatorio, status_cotizacion_id, id_cliente
)
VALUES ('P', '2025-08-01', 50000, '2025-10-01', 'Revisi�n financiera', @stPend, @cli9);
SET @cot9 = SCOPE_IDENTITY();

INSERT COTIZACION.COTIZACION(
    estadoActual, fechaCotizacion, montoEstimadoPrima,
    fechaVenOferta, recordatorio, status_cotizacion_id, id_cliente
)
VALUES ('R', '2025-07-01', 70000, '2025-09-01', 'Riesgo alto', @stRech, @cli10);
SET @cot10 = SCOPE_IDENTITY();

INSERT COTIZACION.COTIZACION_TIPO_SEGURO(id_tipoSeguro, numCotizacion)
VALUES
    (@tipoAuto,   @cot1),
    (@tipoAuto,   @cot2),
    (@tipoVida,   @cot3),
    (@tipoVida,   @cot4),
    (@tipoRetiro, @cot5),
    (@tipoRetiro, @cot6),
    (@tipoAuto,   @cot7),
    (@tipoVida,   @cot8),
    (@tipoRetiro, @cot9),
    (@tipoAuto,   @cot10); 


/* =========================================================
   7. AUTOS PARA P�LIZAS DE AUTO
   ========================================================= */

DECLARE
    @auto1 NUMERIC(6,0),
    @auto2 NUMERIC(6,0),
    @auto3 NUMERIC(6,0);

INSERT POLIZA.AUTO(numeroSerie, matricula, anio, modelo, marca, valorComercial)
VALUES ('SERIEAUTO001', 'ABC1234', 2020, 'Versa',   'Nissan', 180000);
SET @auto1 = SCOPE_IDENTITY();

INSERT POLIZA.AUTO(numeroSerie, matricula, anio, modelo, marca, valorComercial)
VALUES ('SERIEAUTO002', 'XYZ5678', 2019, 'Jetta',   'VW',     220000);
SET @auto2 = SCOPE_IDENTITY();

INSERT POLIZA.AUTO(numeroSerie, matricula, anio, modelo, marca, valorComercial)
VALUES ('SERIEAUTO003', 'LMN9101', 2021, 'Corolla', 'Toyota', 250000);
SET @auto3 = SCOPE_IDENTITY();


/* =========================================================
   8. P�LIZAS (AUTO, VIDA, RETIRO)
   ========================================================= */

DECLARE
    @pol1 NUMERIC(10,0),
    @pol2 NUMERIC(10,0),
    @pol3 NUMERIC(10,0),
    @pol4 NUMERIC(10,0),
    @pol5 NUMERIC(10,0),
    @pol6 NUMERIC(10,0);

INSERT POLIZA.POLIZA(
    activo, fechaIniVig, numPoliza, fechaFinVig,
    montoPrimaTotal, id_auto, id_tipoSeguro,
    numCotizacion, numEmpleado
)
VALUES (
    1, '2025-11-15', 'POL-AUTO-001', '2026-11-14',
    12000, @auto1, @tipoAuto,
    @cot1, @emp1
);
SET @pol1 = SCOPE_IDENTITY();

INSERT POLIZA.POLIZA(
    activo, fechaIniVig, numPoliza, fechaFinVig,
    montoPrimaTotal, id_auto, id_tipoSeguro,
    numCotizacion, numEmpleado
)
VALUES (
    1, '2025-10-01', 'POL-AUTO-002', '2026-09-30',
    9500, @auto2, @tipoAuto,
    @cot2, @emp2
);
SET @pol2 = SCOPE_IDENTITY();

INSERT POLIZA.POLIZA(
    activo, fechaIniVig, numPoliza, fechaFinVig,
    montoPrimaTotal, id_auto, id_tipoSeguro,
    numCotizacion, numEmpleado
)
VALUES (
    1, '2025-09-01', 'POL-VIDA-001', '2030-08-31',
    80000, NULL, @tipoVida,
    @cot3, @emp3
);
SET @pol3 = SCOPE_IDENTITY();

INSERT POLIZA.POLIZA(
    activo, fechaIniVig, numPoliza, fechaFinVig,
    montoPrimaTotal, id_auto, id_tipoSeguro,
    numCotizacion, numEmpleado
)
VALUES (
    0, '2020-01-01', 'POL-VIDA-002', '2025-12-31',
    60000, NULL, @tipoVida,
    @cot4, @emp4
);
SET @pol4 = SCOPE_IDENTITY();

INSERT POLIZA.POLIZA(
    activo, fechaIniVig, numPoliza, fechaFinVig,
    montoPrimaTotal, id_auto, id_tipoSeguro,
    numCotizacion, numEmpleado
)
VALUES (
    1, '2025-01-01', 'POL-RET-001', '2045-12-31',
    30000, NULL, @tipoRetiro,
    @cot5, @emp5
);
SET @pol5 = SCOPE_IDENTITY();

INSERT POLIZA.POLIZA(
    activo, fechaIniVig, numPoliza, fechaFinVig,
    montoPrimaTotal, id_auto, id_tipoSeguro,
    numCotizacion, numEmpleado
)
VALUES (
    1, '2024-06-01', 'POL-RET-002', '2044-05-31',
    40000, NULL, @tipoRetiro,
    @cot6, @emp1
);
SET @pol6 = SCOPE_IDENTITY();


/* =========================================================
   9. PAGOS (DISPARADOR CS4: REC�LCULO DE saldoPendiente)
   ========================================================= */

INSERT POLIZA.PAGO(id_poliza, numPago, saldoPendiente, montoPagado, fechaPago, metodoPago)
VALUES (@pol1, 1, 0, 4000, '2025-11-20', 1);

INSERT POLIZA.PAGO(id_poliza, numPago, saldoPendiente, montoPagado, fechaPago, metodoPago)
VALUES (@pol1, 2, 0, 4000, '2026-02-20', 1);

INSERT POLIZA.PAGO(id_poliza, numPago, saldoPendiente, montoPagado, fechaPago, metodoPago)
VALUES (@pol1, 3, 0, 4000, '2026-05-20', 1);

INSERT POLIZA.PAGO(id_poliza, numPago, saldoPendiente, montoPagado, fechaPago, metodoPago)
VALUES (@pol2, 1, 0, 3000, '2025-10-10', 0);

INSERT POLIZA.PAGO(id_poliza, numPago, saldoPendiente, montoPagado, fechaPago, metodoPago)
VALUES (@pol2, 2, 0, 3000, '2026-01-10', 0);

INSERT POLIZA.PAGO(id_poliza, numPago, saldoPendiente, montoPagado, fechaPago, metodoPago)
VALUES (@pol3, 1, 0, 80000, '2025-09-15', 1);


/* =========================================================
   10. SINIESTROS (USANDO AJUSTADORES)
   ========================================================= */

INSERT POLIZA.SINIESTRO(
    fecha, lugarSiniestro, causa, montoIndem, id_poliza, numEmpleado
)
VALUES (
    '2026-01-05 10:30', 'CDMX - Av. Reforma',
    'Colisi�n por alcance', 50000, @pol1, @emp6
);

INSERT POLIZA.SINIESTRO(
    fecha, lugarSiniestro, causa, montoIndem, id_poliza, numEmpleado
)
VALUES (
    '2027-03-10 08:15', 'Hospital Centro', 
    'Fallecimiento por enfermedad', 80000, @pol3, @emp7
);

INSERT POLIZA.SINIESTRO(
    fecha, lugarSiniestro, causa, montoIndem, id_poliza, numEmpleado
)
VALUES (
    '2026-08-20 22:45', 'Naucalpan - Perif�rico',
    'Robo total del veh�culo', 9000, @pol2, @emp8
);


/* =========================================================
   11. HIST�RICO DE P�LIZAS
   ========================================================= */

INSERT POLIZA.HISTORICO_POLIZA(
    activo, fechaIniVig, numPoliza, fechaEstatus,
    fechaFinVig, montoPrimaTotal, id_poliza
)
VALUES
    (1, '2025-11-15', 'POL-AUTO-001', '2025-11-15', '2026-11-14', 12000, @pol1),

    (1, '2025-10-01', 'POL-AUTO-002', '2025-10-01', '2026-09-30',  9500, @pol2),

    (0, '2020-01-01', 'POL-VIDA-002', '2025-12-31', '2025-12-31', 60000, @pol4),

    (1, '2025-01-01', 'POL-RET-001',  '2025-01-01', '2045-12-31', 30000, @pol5),

    (1, '2024-06-01', 'POL-RET-002',  '2024-06-01', '2044-05-31', 40000, @pol6);


/* =========================================================
   12. HIST�RICO DE STATUS DE COTIZACI�N
   ========================================================= */

INSERT COTIZACION.HISTORICO_STATUS_COTIZACION(
    numCotizacion, fechaCotizacion, estadoAnterior,
    montoEstimadoPrima, fechaVenOferta, recordatorio,
    fechaCambio, status_cotizacion_id
)
VALUES
    (@cot1, '2025-09-20', 'P', 12000, '2025-12-01',
     'Cliente solicit� ajuste de prima', '2025-09-25', @stAprob),

    (@cot2, '2025-09-01', 'P',  9500, '2025-11-15',
     'En espera de documentos', '2025-09-20', @stAprob),

    (@cot7, '2025-11-05', 'P', 11000, '2026-01-05',
     'Pendiente llamada seguimiento', '2025-11-20', @stPend),

    (@cot8, '2025-08-15', 'P',  9000, '2025-11-01',
     'Cliente rechaz� propuesta', '2025-09-01', @stRech);

DECLARE @emp11 NUMERIC(4,0), @emp12 NUMERIC(4,0), @emp13 NUMERIC(4,0), @emp14 NUMERIC(4,0), @emp15 NUMERIC(4,0);
DECLARE @emp16 NUMERIC(4,0), @emp17 NUMERIC(4,0), @emp18 NUMERIC(4,0), @emp19 NUMERIC(4,0), @emp20 NUMERIC(4,0);

INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion) VALUES ('C', 'Roberto', 'D�az', 'Mora', '2023-01-15'); SET @emp11 = SCOPE_IDENTITY();
INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion) VALUES ('C', 'Laura', 'Salinas', 'Cruz', '2023-03-20'); SET @emp12 = SCOPE_IDENTITY();
INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion) VALUES ('C', 'Fernando', 'Gil', 'R�os', '2023-05-10'); SET @emp13 = SCOPE_IDENTITY();
INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion) VALUES ('C', 'Gabriela', 'Soto', 'Meza', '2023-07-01'); SET @emp14 = SCOPE_IDENTITY();
INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion) VALUES ('C', 'Hugo', 'V�zquez', 'Lara', '2023-09-12'); SET @emp15 = SCOPE_IDENTITY();

INSERT TRABAJADOR.CORREDOR(numEmpleado, claveSupervisor, porcentajeComision, zona, cedulaProf) VALUES (@emp11, @emp1, 10, 'Zona Norte', 'NUEVO11');
INSERT TRABAJADOR.CORREDOR(numEmpleado, claveSupervisor, porcentajeComision, zona, cedulaProf) VALUES (@emp12, @emp1, 11, 'Zona Sur', 'NUEVO12');
INSERT TRABAJADOR.CORREDOR(numEmpleado, claveSupervisor, porcentajeComision, zona, cedulaProf) VALUES (@emp13, @emp1, 12, 'Zona Este', 'NUEVO13');
INSERT TRABAJADOR.CORREDOR(numEmpleado, claveSupervisor, porcentajeComision, zona, cedulaProf) VALUES (@emp14, @emp1, 10, 'Zona Oeste', 'NUEVO14');
INSERT TRABAJADOR.CORREDOR(numEmpleado, claveSupervisor, porcentajeComision, zona, cedulaProf) VALUES (@emp15, @emp1, 13, 'Zona Centro', 'NUEVO15');

INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion) VALUES ('A', 'M�nica', 'Reyes', 'Paz', '2022-02-14'); SET @emp16 = SCOPE_IDENTITY();
INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion) VALUES ('A', '�scar', 'Nu�ez', 'Sol', '2022-04-20'); SET @emp17 = SCOPE_IDENTITY();
INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion) VALUES ('A', 'Patricia', 'Lara', 'Mar', '2022-06-30'); SET @emp18 = SCOPE_IDENTITY();
INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion) VALUES ('A', 'Ricardo', 'Pe�a', 'Luz', '2022-08-15'); SET @emp19 = SCOPE_IDENTITY();
INSERT TRABAJADOR.EMPLEADO(tipo, nombre, aPaterno, aMaterno, fechaContratacion) VALUES ('A', 'Sara', 'Mendez', 'Rio', '2022-10-01'); SET @emp20 = SCOPE_IDENTITY();

INSERT TRABAJADOR.AJUSTADOR(numEmpleado) VALUES (@emp16), (@emp17), (@emp18), (@emp19), (@emp20);

DECLARE @auto4 NUMERIC(6,0), @auto5 NUMERIC(6,0), @auto6 NUMERIC(6,0), @auto7 NUMERIC(6,0);

INSERT POLIZA.AUTO(numeroSerie, matricula, anio, modelo, marca, valorComercial) VALUES ('SERIEAUTO004', 'CAR-004', 2022, 'Civic', 'Honda', 350000); SET @auto4 = SCOPE_IDENTITY();
INSERT POLIZA.AUTO(numeroSerie, matricula, anio, modelo, marca, valorComercial) VALUES ('SERIEAUTO005', 'CAR-005', 2023, 'Mazda3', 'Mazda', 380000); SET @auto5 = SCOPE_IDENTITY();
INSERT POLIZA.AUTO(numeroSerie, matricula, anio, modelo, marca, valorComercial) VALUES ('SERIEAUTO006', 'CAR-006', 2021, 'Mustang', 'Ford', 750000); SET @auto6 = SCOPE_IDENTITY();
INSERT POLIZA.AUTO(numeroSerie, matricula, anio, modelo, marca, valorComercial) VALUES ('SERIEAUTO007', 'CAR-007', 2024, 'Aveo', 'Chevrolet', 210000); SET @auto7 = SCOPE_IDENTITY();

DECLARE @i INT = 1;
DECLARE @id_cliente_curr NUMERIC(5,0);
DECLARE @id_cot_new NUMERIC(6,0);
DECLARE @id_pol_new NUMERIC(10,0);
DECLARE @monto_prima MONEY = 24000; 
DECLARE @pago_parcial MONEY = 2000; 

DECLARE @autoFix1 NUMERIC(6,0), @autoFix2 NUMERIC(6,0);

INSERT POLIZA.AUTO(numeroSerie, matricula, anio, modelo, marca, valorComercial)
VALUES ('FIX-SERIE-01', 'FIX-001', 2018, 'Aveo', 'Chevrolet', 100000);
SET @autoFix1 = SCOPE_IDENTITY();

INSERT POLIZA.AUTO(numeroSerie, matricula, anio, modelo, marca, valorComercial)
VALUES ('FIX-SERIE-02', 'FIX-002', 2019, 'Vento', 'VW', 150000);
SET @autoFix2 = SCOPE_IDENTITY();

DECLARE @NuevasPolizas TABLE (idCliente NUMERIC(5,0), idTipo NUMERIC(5,0), idAuto NUMERIC(6,0), EsAuto BIT);

INSERT INTO @NuevasPolizas VALUES (@cli1, @tipoVida, NULL, 0), (@cli1, @tipoRetiro, NULL, 0);
INSERT INTO @NuevasPolizas VALUES (@cli2, @tipoVida, NULL, 0);
INSERT INTO @NuevasPolizas VALUES (@cli3, @tipoAuto, @auto4, 1); 
INSERT INTO @NuevasPolizas VALUES (@cli4, @tipoAuto, @auto5, 1);
INSERT INTO @NuevasPolizas VALUES (@cli5, @tipoAuto, @auto6, 1), (@cli5, @tipoVida, NULL, 0);
INSERT INTO @NuevasPolizas VALUES (@cli6, @tipoAuto, @auto7, 1);

INSERT INTO @NuevasPolizas VALUES 
(@cli7, @tipoVida, NULL, 0), (@cli7, @tipoRetiro, NULL, 0),
(@cli8, @tipoVida, NULL, 0), (@cli8, @tipoAuto, @autoFix1, 1),
(@cli9, @tipoRetiro, NULL, 0), (@cli9, @tipoVida, NULL, 0),
(@cli10, @tipoAuto, @autoFix2, 1), (@cli10, @tipoRetiro, NULL, 0);

DECLARE curPolReal CURSOR FOR SELECT idCliente, idTipo, idAuto FROM @NuevasPolizas;
DECLARE @c_cli NUMERIC(5,0), @c_tipo NUMERIC(5,0), @c_auto NUMERIC(6,0);

OPEN curPolReal;
FETCH NEXT FROM curPolReal INTO @c_cli, @c_tipo, @c_auto;

WHILE @@FETCH_STATUS = 0
BEGIN

    INSERT COTIZACION.COTIZACION(estadoActual, fechaCotizacion, montoEstimadoPrima, fechaVenOferta, recordatorio, status_cotizacion_id, id_cliente)
    VALUES ('A', '2025-01-10', @monto_prima, '2025-03-10', 'Generado masivamente', @stAprob, @c_cli);
    SET @id_cot_new = SCOPE_IDENTITY();

    INSERT COTIZACION.COTIZACION_TIPO_SEGURO(id_tipoSeguro, numCotizacion) VALUES (@c_tipo, @id_cot_new);

    INSERT POLIZA.POLIZA(activo, fechaIniVig, numPoliza, fechaFinVig, montoPrimaTotal, id_auto, id_tipoSeguro, numCotizacion, numEmpleado)
    VALUES (1, '2025-02-01', 'POL-EXTRA-' + CAST(@id_cot_new AS VARCHAR), '2026-02-01', @monto_prima, @c_auto, @c_tipo, @id_cot_new, @emp11);
    SET @id_pol_new = SCOPE_IDENTITY();

    DECLARE @k INT = 1;
    WHILE @k <= 5
    BEGIN
        INSERT POLIZA.PAGO(id_poliza, numPago, saldoPendiente, montoPagado, fechaPago, metodoPago)
        VALUES (@id_pol_new, @k, (@monto_prima - (@pago_parcial * @k)), @pago_parcial, DATEADD(MONTH, @k, '2025-02-01'), 1);
        SET @k = @k + 1;
    END

    FETCH NEXT FROM curPolReal INTO @c_cli, @c_tipo, @c_auto;
END
CLOSE curPolReal;
DEALLOCATE curPolReal;

-----------------------------------------------------------
-- 13. 4 VEH�CULOS CON 2 O 3 SINIESTROS DIFERENTES
-----------------------------------------------------------

DECLARE @pol_auto4 NUMERIC(10,0) = (SELECT TOP 1 id_poliza FROM POLIZA.POLIZA WHERE id_auto = @auto4);
DECLARE @pol_auto5 NUMERIC(10,0) = (SELECT TOP 1 id_poliza FROM POLIZA.POLIZA WHERE id_auto = @auto5);
DECLARE @pol_auto6 NUMERIC(10,0) = (SELECT TOP 1 id_poliza FROM POLIZA.POLIZA WHERE id_auto = @auto6);
DECLARE @pol_auto7 NUMERIC(10,0) = (SELECT TOP 1 id_poliza FROM POLIZA.POLIZA WHERE id_auto = @auto7);

-- Auto 4: 2 Siniestros
INSERT POLIZA.SINIESTRO(fecha, lugarSiniestro, causa, montoIndem, id_poliza, numEmpleado)
VALUES ('2025-03-15', 'Calle 10', 'Choque leve', 5000, @pol_auto4, @emp16);
INSERT POLIZA.SINIESTRO(fecha, lugarSiniestro, causa, montoIndem, id_poliza, numEmpleado)
VALUES ('2025-06-20', 'Calle 20', 'Rotura cristal', 2000, @pol_auto4, @emp17);

-- Auto 5: 3 Siniestros
INSERT POLIZA.SINIESTRO(fecha, lugarSiniestro, causa, montoIndem, id_poliza, numEmpleado)
VALUES ('2025-04-10', 'Avenida Central', 'Robo autopartes', 8000, @pol_auto5, @emp18);
INSERT POLIZA.SINIESTRO(fecha, lugarSiniestro, causa, montoIndem, id_poliza, numEmpleado)
VALUES ('2025-07-12', 'Estacionamiento', 'Golpe defensa', 3000, @pol_auto5, @emp19);
INSERT POLIZA.SINIESTRO(fecha, lugarSiniestro, causa, montoIndem, id_poliza, numEmpleado)
VALUES ('2025-09-01', 'Carretera', 'Pochadura', 1500, @pol_auto5, @emp20);

-- Auto 6: 2 Siniestros
INSERT POLIZA.SINIESTRO(fecha, lugarSiniestro, causa, montoIndem, id_poliza, numEmpleado)
VALUES ('2025-02-28', 'Centro', 'Vandalismo', 4500, @pol_auto6, @emp16);
INSERT POLIZA.SINIESTRO(fecha, lugarSiniestro, causa, montoIndem, id_poliza, numEmpleado)
VALUES ('2025-08-15', 'Norte', 'Granizo', 12000, @pol_auto6, @emp17);

-- Auto 7: 3 Siniestros
INSERT POLIZA.SINIESTRO(fecha, lugarSiniestro, causa, montoIndem, id_poliza, numEmpleado)
VALUES ('2025-05-05', 'Sur', 'Alcance', 6000, @pol_auto7, @emp18);
INSERT POLIZA.SINIESTRO(fecha, lugarSiniestro, causa, montoIndem, id_poliza, numEmpleado)
VALUES ('2025-08-08', 'Este', 'Faros rotos', 2500, @pol_auto7, @emp19);
INSERT POLIZA.SINIESTRO(fecha, lugarSiniestro, causa, montoIndem, id_poliza, numEmpleado)
VALUES ('2025-11-11', 'Oeste', 'Espejo roto', 1000, @pol_auto7, @emp20);

-----------------------------------------------------------
-- 14. 10 COTIZACIONES ADICIONALES (5 CON HISTORIAL DE PROPUESTAS)
-----------------------------------------------------------
DECLARE @cot_extra_start NUMERIC(6,0);
DECLARE @x INT = 1;
WHILE @x <= 10
BEGIN

    DECLARE @cli_target NUMERIC(5,0) = @cli10 + @x; 
    
    INSERT COTIZACION.COTIZACION(estadoActual, fechaCotizacion, montoEstimadoPrima, fechaVenOferta, recordatorio, status_cotizacion_id, id_cliente)
    VALUES ('P', '2025-12-01', 15000, '2026-02-01', 'Cotizaci�n Extra', @stPend, @cli_target);
    
    IF @x = 1 SET @cot_extra_start = SCOPE_IDENTITY(); 
    
    DECLARE @curr_cot_id NUMERIC(6,0) = SCOPE_IDENTITY();
    INSERT COTIZACION.COTIZACION_TIPO_SEGURO(id_tipoSeguro, numCotizacion) VALUES (@tipoAuto, @curr_cot_id);

    SET @x = @x + 1;
END

SET @x = 0;
WHILE @x < 5
BEGIN
    DECLARE @cot_hist_id NUMERIC(6,0) = @cot_extra_start + @x;
    
    INSERT COTIZACION.HISTORICO_STATUS_COTIZACION(numCotizacion, fechaCotizacion, estadoAnterior, montoEstimadoPrima, fechaVenOferta, recordatorio, fechaCambio, status_cotizacion_id)
    VALUES (@cot_hist_id, '2025-11-01', 'P', 14000, '2025-12-01', 'Propuesta inicial', '2025-11-15', @stPend);

    INSERT COTIZACION.HISTORICO_STATUS_COTIZACION(numCotizacion, fechaCotizacion, estadoAnterior, montoEstimadoPrima, fechaVenOferta, recordatorio, fechaCambio, status_cotizacion_id)
    VALUES (@cot_hist_id, '2025-11-16', 'P', 14500, '2025-12-15', 'Ajuste inflaci�n', '2025-11-30', @stPend);

    SET @x = @x + 1;
END
-----------------------------------------------------------
-- 15. 5 P�LIZAS CON AL MENOS 2 P�LIZAS ANTERIORES (HISTORIAL)
-----------------------------------------------------------

-- Historial para Poliza Auto 4
INSERT POLIZA.HISTORICO_POLIZA(activo, fechaIniVig, numPoliza, fechaEstatus, fechaFinVig, montoPrimaTotal, id_poliza)
VALUES (0, '2023-02-01', 'OLD-A4-23', '2024-02-01', '2024-02-01', 22000, @pol_auto4);
INSERT POLIZA.HISTORICO_POLIZA(activo, fechaIniVig, numPoliza, fechaEstatus, fechaFinVig, montoPrimaTotal, id_poliza)
VALUES (0, '2024-02-01', 'OLD-A4-24', '2025-02-01', '2025-02-01', 23000, @pol_auto4);

-- Historial para Poliza Auto 5
INSERT POLIZA.HISTORICO_POLIZA(activo, fechaIniVig, numPoliza, fechaEstatus, fechaFinVig, montoPrimaTotal, id_poliza)
VALUES (0, '2023-02-01', 'OLD-A5-23', '2024-02-01', '2024-02-01', 22000, @pol_auto5);
INSERT POLIZA.HISTORICO_POLIZA(activo, fechaIniVig, numPoliza, fechaEstatus, fechaFinVig, montoPrimaTotal, id_poliza)
VALUES (0, '2024-02-01', 'OLD-A5-24', '2025-02-01', '2025-02-01', 23000, @pol_auto5);

-- Historial para Poliza Auto 6
INSERT POLIZA.HISTORICO_POLIZA(activo, fechaIniVig, numPoliza, fechaEstatus, fechaFinVig, montoPrimaTotal, id_poliza)
VALUES (0, '2023-02-01', 'OLD-A6-23', '2024-02-01', '2024-02-01', 50000, @pol_auto6);
INSERT POLIZA.HISTORICO_POLIZA(activo, fechaIniVig, numPoliza, fechaEstatus, fechaFinVig, montoPrimaTotal, id_poliza)
VALUES (0, '2024-02-01', 'OLD-A6-24', '2025-02-01', '2025-02-01', 52000, @pol_auto6);

-- Historial para Poliza Auto 7
INSERT POLIZA.HISTORICO_POLIZA(activo, fechaIniVig, numPoliza, fechaEstatus, fechaFinVig, montoPrimaTotal, id_poliza)
VALUES (0, '2023-02-01', 'OLD-A7-23', '2024-02-01', '2024-02-01', 18000, @pol_auto7);
INSERT POLIZA.HISTORICO_POLIZA(activo, fechaIniVig, numPoliza, fechaEstatus, fechaFinVig, montoPrimaTotal, id_poliza)
VALUES (0, '2024-02-01', 'OLD-A7-24', '2025-02-01', '2025-02-01', 19000, @pol_auto7);

-- Historial para una 5ta p�liza
INSERT POLIZA.HISTORICO_POLIZA(activo, fechaIniVig, numPoliza, fechaEstatus, fechaFinVig, montoPrimaTotal, id_poliza)
VALUES (0, '2023-11-15', 'OLD-01-23', '2024-11-14', '2024-11-14', 10000, @pol1);
INSERT POLIZA.HISTORICO_POLIZA(activo, fechaIniVig, numPoliza, fechaEstatus, fechaFinVig, montoPrimaTotal, id_poliza)
VALUES (0, '2024-11-15', 'OLD-01-24', '2025-11-14', '2025-11-14', 11000, @pol1);

PRINT 'Carga complementaria finalizada con �xito.';
GO

select * from TRABAJADOR.AJUSTADOR
select * from TRABAJADOR.CORREDOR
select * from TRABAJADOR.EMPLEADO
where numEmpleado=11
select * from POLIZA.AUTO
select * from POLIZA.POLIZA