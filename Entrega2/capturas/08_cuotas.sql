-- ===========================================================================================
-- CAPTURA 02 - USUARIOS, CUOTAS, PERFILES Y CONEXIONES
-- Ejecutar como SYS.
-- ===========================================================================================

SET ECHO ON;
SET FEEDBACK ON;
SET LINESIZE 500;
SET PAGESIZE 520;

COLUMN username FORMAT A15;
COLUMN tablespace_name FORMAT A18;
COLUMN profile FORMAT A18;
COLUMN resource_name FORMAT A28;
COLUMN limite FORMAT A18;

PROMPT Usuario del proyecto
SELECT username,
       account_status,
       default_tablespace,
       temporary_tablespace,
       profile
FROM dba_users
WHERE username = 'ALUMNO';

PROMPT Cuotas actuales de ALUMNO
SELECT username,
       tablespace_name,
       ROUND(bytes / 1024 / 1024, 2)     AS usado_mb,
       ROUND(max_bytes / 1024 / 1024, 2) AS limite_mb
FROM dba_ts_quotas
WHERE username = 'ALUMNO'
ORDER BY tablespace_name;

PROMPT Limites del perfil
SELECT profile, resource_name, limit AS limite
FROM dba_profiles
WHERE profile = 'DEFAULT'
  AND resource_name IN ('SESSIONS_PER_USER',
                        'IDLE_TIME',
                        'CONNECT_TIME',
                        'FAILED_LOGIN_ATTEMPTS',
                        'PASSWORD_LIFE_TIME',
                        'PASSWORD_LOCK_TIME')
ORDER BY resource_name;

PROMPT Sesiones activas de ALUMNO
SELECT username,
       sid,
       serial#,
       status,
       program,
       machine
FROM v$session
WHERE username = 'ALUMNO'
ORDER BY sid;
