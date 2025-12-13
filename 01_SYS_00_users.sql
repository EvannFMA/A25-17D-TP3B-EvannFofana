-- 01_SYS_00_users.sql
-- Pour que les 'dbms_output.put_line' s'affichent en SQL*PLUS
SET SERVEROUTPUT ON;

ALTER SESSION SET CURRENT_SCHEMA = sys;

-- Création des utilisateurs
DECLARE
    code_erreur    NUMBER;
    message_erreur VARCHAR2(255);
BEGIN
    FOR rec_user IN (SELECT username FROM dba_users WHERE username IN ('BO', 'EMPLOYE01', 'MEMBRE01')) LOOP
        EXECUTE IMMEDIATE 'DROP USER ' || rec_user.username || ' CASCADE';
    END LOOP;

    FOR rec_role IN (SELECT role FROM dba_roles WHERE role IN ('ROLE_SYSTEME', 'ROLE_BIBLIOTHECAIRE', 'ROLE_MEMBRE')) LOOP
        EXECUTE IMMEDIATE 'DROP ROLE ' || rec_role.role;
    END LOOP;
END;
/

-- Création des roles et gestion des permissions
CREATE USER bo IDENTIFIED BY bo QUOTA UNLIMITED ON users;
CREATE USER employe01 IDENTIFIED BY garneau;
CREATE USER membre01 IDENTIFIED BY lecture;

GRANT CREATE SESSION TO bo, employe01, membre01;

CREATE ROLE role_systeme;
CREATE ROLE role_bibliothecaire;
CREATE ROLE role_membre;

GRANT CONNECT TO role_systeme;
GRANT DBA TO role_systeme;

GRANT role_systeme TO bo;
/