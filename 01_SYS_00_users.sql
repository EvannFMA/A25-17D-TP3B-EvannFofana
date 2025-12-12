-- 01_SYS_00_users.sql
-- Pour que les 'dbms_output.put_line' s'affichent en SQL*PLUS
SET SERVEROUTPUT ON;

-- Se connecter à l'utilisateur SYS
ALTER SESSION SET CURRENT_SCHEMA = sys;

-- Création de l'utilisateur TP3A_2040791 et BO
DECLARE
    resultat       INTEGER;
    nom_schema_tp  sys.dba_users.username%type := 'TP3A_2040791';
    nom_schema_pw_tp VARCHAR2(20)                := 'garneau';
    nom_schema_bo  sys.dba_users.username%type := 'BO';
    nom_schema_pw_bo VARCHAR2(20)                := 'BO';
    code_erreur    NUMBER;
    message_erreur VARCHAR2(255);
BEGIN
    -- Vérification de l'existence de l'utilisateur TP3A_2040791 et suppression de celui-ci si oui
    SELECT COUNT(1)
    INTO resultat
    FROM sys.dba_users
    WHERE username = UPPER(nom_schema_tp);

    IF resultat = 1 THEN
        EXECUTE IMMEDIATE 'DROP USER ' || UPPER(nom_schema_tp) || ' CASCADE';
        DBMS_OUTPUT.PUT_LINE('Utilisateur ' || nom_schema_tp || ' supprimé.');
    END IF;

    -- Création l'utilisateur TP3A_2040791
    EXECUTE IMMEDIATE 'CREATE USER ' || nom_schema_tp || ' IDENTIFIED BY ' || nom_schema_pw_tp;
    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE TO ' || nom_schema_tp;
    DBMS_OUTPUT.PUT_LINE('Utilisateur ' || nom_schema_tp || ' créé.');

    -- Vérification de l'existence de l'utilisateur BO et suppression de celui-ci si oui
    SELECT COUNT(1)
    INTO resultat
    FROM sys.dba_users
    WHERE username = UPPER(nom_schema_bo);

    IF resultat = 1 THEN
        EXECUTE IMMEDIATE 'DROP USER ' || UPPER(nom_schema_bo) || ' CASCADE';
        DBMS_OUTPUT.PUT_LINE('Utilisateur ' || nom_schema_bo || ' supprimé.');
    END IF;

    -- Créer l'utilisateur BO
    EXECUTE IMMEDIATE 'CREATE USER ' || nom_schema_bo || ' IDENTIFIED BY ' || nom_schema_pw_bo;
    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE, DBA TO ' || nom_schema_bo;
    DBMS_OUTPUT.PUT_LINE('Utilisateur ' || nom_schema_bo || ' créé.');

    -- Ajouter des privilèges à TP3A_2040791 pour avoir accès au schéma BO

-- Gestion des erreurs
EXCEPTION
    WHEN OTHERS THEN
        CASE
            WHEN SQLCODE = -1940 THEN
                DBMS_OUTPUT.PUT_LINE('Vous devez vous déconnecter du schéma avant de pouvoir le supprimer. Connectez-vous à SYS et exécutez seulement cette partie.');
            ELSE
                code_erreur := SQLCODE;
                message_erreur := SQLERRM;
                DBMS_OUTPUT.PUT_LINE('Erreur: ' || code_erreur || ' - ' || message_erreur);
        END CASE;
END;
/