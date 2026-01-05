/* =========================================================
   ARCHIVO: Seguridad.sql
   PROYECTO: Aseguradora "El Buen Retiro"
   DESCRIPCI�N: Script para crear roles y usuarios
   FECHA: 2025-11-29
   ========================================================= */

USE [SEGUROS];
GO

-- 1. Borramos usuarios de base de datos
IF EXISTS (SELECT name FROM sys.database_principals WHERE name = 'UserAdmin') DROP USER UserAdmin;
IF EXISTS (SELECT name FROM sys.database_principals WHERE name = 'UserGerente') DROP USER UserGerente;
IF EXISTS (SELECT name FROM sys.database_principals WHERE name = 'UserJefeCom') DROP USER UserJefeCom;
IF EXISTS (SELECT name FROM sys.database_principals WHERE name = 'UserJefeAgencia') DROP USER UserJefeAgencia;
IF EXISTS (SELECT name FROM sys.database_principals WHERE name = 'UserAsesor') DROP USER UserAsesor;
IF EXISTS (SELECT name FROM sys.database_principals WHERE name = 'UserCliente') DROP USER UserCliente;

-- 2. Borramos Logins del servidor
IF EXISTS (SELECT name FROM sys.server_principals WHERE name = 'UserAdmin') DROP LOGIN UserAdmin;
IF EXISTS (SELECT name FROM sys.server_principals WHERE name = 'UserGerente') DROP LOGIN UserGerente;
IF EXISTS (SELECT name FROM sys.server_principals WHERE name = 'UserJefeCom') DROP LOGIN UserJefeCom;
IF EXISTS (SELECT name FROM sys.server_principals WHERE name = 'UserJefeAgencia') DROP LOGIN UserJefeAgencia;
IF EXISTS (SELECT name FROM sys.server_principals WHERE name = 'UserAsesor') DROP LOGIN UserAsesor;
IF EXISTS (SELECT name FROM sys.server_principals WHERE name = 'UserCliente') DROP LOGIN UserCliente;

-- 3. Borramos Roles de base de datos
IF EXISTS (SELECT name FROM sys.database_principals WHERE name = 'Rol_Gerente') DROP ROLE Rol_Gerente;
IF EXISTS (SELECT name FROM sys.database_principals WHERE name = 'Rol_Jefe_Comercial') DROP ROLE Rol_Jefe_Comercial;
IF EXISTS (SELECT name FROM sys.database_principals WHERE name = 'Rol_Asesor_Comercial') DROP ROLE Rol_Asesor_Comercial;
IF EXISTS (SELECT name FROM sys.database_principals WHERE name = 'Rol_Jefe_Agencia') DROP ROLE Rol_Jefe_Agencia;
IF EXISTS (SELECT name FROM sys.database_principals WHERE name = 'Rol_Cliente') DROP ROLE Rol_Cliente;
IF EXISTS (SELECT name FROM sys.database_principals WHERE name = 'Rol_Administrador') DROP ROLE Rol_Administrador;
GO
/* =========================================================
   1. CREACI�N DE ROLES
   ========================================================= */
CREATE ROLE Rol_Gerente;
CREATE ROLE Rol_Jefe_Comercial;
CREATE ROLE Rol_Asesor_Comercial;
CREATE ROLE Rol_Jefe_Agencia;
CREATE ROLE Rol_Cliente;
CREATE ROLE Rol_Administrador;
GO

/* =========================================================
   2. ASIGNACI�N DE PERMISOS
   ========================================================= */

-- ROL CLIENTE
GRANT SELECT ON SCHEMA :: SEGURO TO Rol_Cliente;
GRANT SELECT ON CLIENTE.VW_RESUMEN_POLIZAS_CLIENTES TO Rol_Cliente;

-- ROL ASESOR COMERCIAL
GRANT SELECT, INSERT, UPDATE ON SCHEMA :: CLIENTE TO Rol_Asesor_Comercial;
GRANT EXECUTE ON OBJECT :: CLIENTE.sp_AltaCliente TO Rol_Asesor_Comercial;
GRANT SELECT, INSERT ON SCHEMA :: COTIZACION TO Rol_Asesor_Comercial;
GRANT SELECT ON SCHEMA :: SEGURO TO Rol_Asesor_Comercial;
GRANT SELECT, INSERT ON POLIZA.AUTO TO Rol_Asesor_Comercial;
GRANT SELECT, INSERT ON POLIZA.POLIZA TO Rol_Asesor_Comercial;
GRANT EXECUTE ON OBJECT :: POLIZA.sp_RegistrarPagoPoliza TO Rol_Asesor_Comercial;
GRANT SELECT ON CLIENTE.ESTADO TO Rol_Asesor_Comercial;
GRANT SELECT ON CLIENTE.CIUDAD TO Rol_Asesor_Comercial;
GRANT SELECT ON CLIENTE.COLONIA TO Rol_Asesor_Comercial;

--ROL JEFE DE AGENCIA
GRANT SELECT, INSERT, UPDATE ON SCHEMA :: CLIENTE TO Rol_Jefe_Agencia;
GRANT SELECT, INSERT ON SCHEMA :: COTIZACION TO Rol_Jefe_Agencia;
GRANT SELECT ON SCHEMA :: SEGURO TO Rol_Jefe_Agencia;
GRANT SELECT, INSERT ON POLIZA.AUTO TO Rol_Jefe_Agencia;
GRANT SELECT, INSERT ON POLIZA.POLIZA TO Rol_Jefe_Agencia;
GRANT EXECUTE ON OBJECT :: CLIENTE.sp_AltaCliente TO Rol_Jefe_Agencia;
GRANT EXECUTE ON OBJECT :: POLIZA.sp_RegistrarPagoPoliza TO Rol_Jefe_Agencia;
GRANT SELECT ON TRABAJADOR.VW_DESEMPENO_CORREDORES TO Rol_Jefe_Agencia;
GRANT SELECT ON TRABAJADOR.fn_ReporteComisionesCorredor TO Rol_Jefe_Agencia;
GRANT SELECT ON SCHEMA :: TRABAJADOR TO Rol_Jefe_Agencia;

--ROL JEFE COMERCIAL
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA :: SEGURO TO Rol_Jefe_Comercial;
GRANT SELECT, INSERT, UPDATE ON POLIZA.AUTO TO Rol_Jefe_Comercial;
GRANT SELECT ON TRABAJADOR.VW_DESEMPENO_CORREDORES TO Rol_Jefe_Comercial;

--ROL GERENTE
GRANT SELECT ON TRABAJADOR.VW_DESEMPENO_CORREDORES TO Rol_Gerente;
GRANT SELECT ON POLIZA.VW_ESTADO_CUENTA_POLIZAS TO Rol_Gerente;
GRANT SELECT ON CLIENTE.VW_RESUMEN_POLIZAS_CLIENTES TO Rol_Gerente;
GRANT EXECUTE ON OBJECT :: POLIZA.fn_CalcularRentabilidadPoliza TO Rol_Gerente;
GRANT EXECUTE ON OBJECT :: CLIENTE.fn_ObtenerRiesgoCliente TO Rol_Gerente;

--LE DAMOS PREMISO DE EJECUTAR pa's PARA LOS INFORMES
GRANT EXECUTE ON OBJECT :: dbo.pa_Estadistica_TotalClientesActivos TO Rol_Gerente;
GRANT EXECUTE ON OBJECT :: dbo.pa_Estadistica_PolizasPorTipo TO Rol_Gerente;
GRANT EXECUTE ON OBJECT :: dbo.pa_Estadistica_PromedioMontoPorTipo TO Rol_Gerente;
GRANT EXECUTE ON OBJECT :: dbo.pa_Estadistica_IngresosMes TO Rol_Gerente;
GRANT EXECUTE ON OBJECT :: dbo.pa_Estadistica_SiniestrosPorCausa TO Rol_Gerente;
GRANT EXECUTE ON OBJECT :: dbo.pa_Estadistica_ClientesPorEstado TO Rol_Gerente;
GRANT EXECUTE ON OBJECT :: dbo.pa_Estadistica_Top5Corredores TO Rol_Gerente;
GRANT EXECUTE ON OBJECT :: dbo.pa_Estadistica_PorcentajeMorosidad TO Rol_Gerente;
GRANT EXECUTE ON OBJECT :: dbo.pa_Estadistica_EdadPromedioVida TO Rol_Gerente;
GRANT EXECUTE ON OBJECT :: dbo.pa_Estadistica_TasaRenovacion TO Rol_Gerente;

PRINT 'Permisos de ejecuci�n asignados correctamente al Rol_Gerente.';
GO

PRINT 'Permisos de ejecuci�n asignados correctamente al Rol_Gerente.';
GO

--ROL ADMINISTRADOR
GRANT ALTER ANY USER TO Rol_Administrador;
GRANT CONTROL ON DATABASE :: [SEGUROS] TO Rol_Administrador;
GO


/* =========================================================
   3. PROCEDIMIENTO PARA CREAR USUARIOS
   ========================================================= */
CREATE OR ALTER PROCEDURE sp_CrearLoginUsuario
    @usuario VARCHAR(50),       
    @contrasena VARCHAR(50),    
    @tipoRol VARCHAR(30),
    @idEntidad NUMERIC(10,0) = NULL
AS 
BEGIN
    DECLARE @sqlLogin NVARCHAR(MAX);
    DECLARE @sqlUser NVARCHAR(MAX);
    DECLARE @sqlRole NVARCHAR(MAX);
    DECLARE @CantGerentes INT;
    
    BEGIN TRY
        IF @tipoRol = 'GERENTE' BEGIN
            SELECT @CantGerentes = COUNT(*) FROM sys.database_role_members drm JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id WHERE r.name = 'Rol_Gerente';
            IF @CantGerentes >= 1 THROW 50005, 'ERROR: Ya existe un Gerente registrado.', 1;
        END

        IF @tipoRol IN ('ASESOR', 'JEFE_AGENCIA') BEGIN
            IF NOT EXISTS(SELECT 1 FROM TRABAJADOR.CORREDOR WHERE numEmpleado = @idEntidad) THROW 50006, 'ERROR: ID de Corredor no v�lido.', 1;
        END
        IF @tipoRol = 'CLIENTE' BEGIN
            IF NOT EXISTS(SELECT 1 FROM CLIENTE.CLIENTE WHERE id_cliente = @idEntidad) THROW 50008, 'ERROR: ID de Cliente no v�lido.', 1;
        END

        SET @sqlLogin = 'CREATE LOGIN ' + QUOTENAME(@usuario) + ' WITH PASSWORD = ''' + @contrasena + ''', DEFAULT_DATABASE = [SEGUROS], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF';
        EXEC(@sqlLogin);

        SET @sqlUser = 'CREATE USER ' + QUOTENAME(@usuario) + ' FOR LOGIN ' + QUOTENAME(@usuario);
        EXEC(@sqlUser);

        IF @tipoRol = 'ADMIN' SET @sqlRole = 'ALTER ROLE Rol_Administrador ADD MEMBER ' + QUOTENAME(@usuario);
        ELSE IF @tipoRol = 'GERENTE' SET @sqlRole = 'ALTER ROLE Rol_Gerente ADD MEMBER ' + QUOTENAME(@usuario);
        ELSE IF @tipoRol = 'JEFE_COMERCIAL' SET @sqlRole = 'ALTER ROLE Rol_Jefe_Comercial ADD MEMBER ' + QUOTENAME(@usuario);
        ELSE IF @tipoRol = 'JEFE_AGENCIA' SET @sqlRole = 'ALTER ROLE Rol_Jefe_Agencia ADD MEMBER ' + QUOTENAME(@usuario);
        ELSE IF @tipoRol = 'ASESOR' SET @sqlRole = 'ALTER ROLE Rol_Asesor_Comercial ADD MEMBER ' + QUOTENAME(@usuario);
        ELSE IF @tipoRol = 'CLIENTE' SET @sqlRole = 'ALTER ROLE Rol_Cliente ADD MEMBER ' + QUOTENAME(@usuario);
        
        EXEC(@sqlRole);
        PRINT '>> Usuario ' + @usuario + ' creado con rol ' + @tipoRol;

    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
        IF EXISTS (SELECT name FROM sys.server_principals WHERE name = @usuario) BEGIN
            SET @sqlLogin = 'DROP LOGIN ' + QUOTENAME(@usuario);
            EXEC(@sqlLogin);
        END
    END CATCH
END
GO


/* =========================================================
   4. CREACI�N DE USUARIOS DE PRUEBA
   ========================================================= */
PRINT '--- CREANDO USUARIOS ---';

EXEC sp_CrearLoginUsuario 'UserAdmin', 'Admin123!', 'ADMIN';
EXEC sp_CrearLoginUsuario 'UserGerente', 'Gerente123!', 'GERENTE';
EXEC sp_CrearLoginUsuario 'UserJefeCom', 'Comercial123!', 'JEFE_COMERCIAL';
EXEC sp_CrearLoginUsuario 'UserJefeAgencia', 'Agencia123!', 'JEFE_AGENCIA', 1;
EXEC sp_CrearLoginUsuario 'UserAsesor', 'Ventas123!', 'ASESOR', 11;
EXEC sp_CrearLoginUsuario 'UserCliente', 'Cliente123!', 'CLIENTE', 1;
EXEC sp_CrearLoginUsuario 'UserJefeCom2', 'Comercial123!', 'JEFE_COMERCIAL';
EXEC sp_CrearLoginUsuario 'UserJefeAgencia2', 'Agencia123!', 'JEFE_AGENCIA', 2;
EXEC sp_CrearLoginUsuario 'UserJefeAgencia3', 'Agencia123!', 'JEFE_AGENCIA', 3;
EXEC sp_CrearLoginUsuario 'UserAsesor2', 'Ventas123!', 'ASESOR', 12;
EXEC sp_CrearLoginUsuario 'UserAsesor3', 'Ventas123!', 'ASESOR', 13;
EXEC sp_CrearLoginUsuario 'UserAsesor4', 'Ventas123!', 'ASESOR', 14;
GO
PRINT '--- USUARIOS CREADOS EXITOSAMENTE ---';

/* =========================================================
   5. PERMISOS DE SERVIDOR
   ========================================================= */
USE master;
GO

PRINT '--- ASIGNANDO PERMISOS DE SERVIDOR AL ADMIN ---';
GRANT ALTER ANY LOGIN TO [UserAdmin];
GO

USE [SEGUROS];
GO
PRINT '--- FIN CORRECTO ---';