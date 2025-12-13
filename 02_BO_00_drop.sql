-- 02_BO_00_drop.sql
-- Pour que les 'dbms_output.put_line' s'affichent
SET SERVEROUTPUT ON;

ALTER SESSION SET CURRENT_SCHEMA = bo;

DECLARE
     CURSOR c_objects IS
        SELECT object_name, object_type
        FROM user_objects
        WHERE object_type IN ('SEQUENCE', 'TABLE')
        AND object_name NOT IN ('IND$', 'CONSTRAINTS', 'TRIGGER', 'PACKAGE BODY');

    nom_objet      VARCHAR2(50 CHAR);
    trouve         NUMBER;
    code_erreur    NUMBER;
    message_erreur VARCHAR2(255 CHAR);
BEGIN
    FOR obj IN c_objects LOOP
        nom_objet := obj.object_name;

        -- Gère la suppression de la séquence
        IF obj.object_type = 'SEQUENCE' THEN
            BEGIN
                SELECT COUNT(1) INTO trouve
                FROM user_sequences
                WHERE sequence_name = UPPER(nom_objet);

                IF trouve = 1 THEN
                    EXECUTE IMMEDIATE 'DROP SEQUENCE ' || nom_objet;
                    DBMS_OUTPUT.PUT_LINE('Séquence ' || nom_objet || ' supprimée.');
                ELSE
                    DBMS_OUTPUT.PUT_LINE('Séquence ' || nom_objet || ' non trouvée.');
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Erreur lors de la suppression de la séquence ' || nom_objet || ': ' || SQLERRM);
            END;
        -- Gère la suppression des tables
        ELSIF obj.object_type = 'TABLE' THEN
            BEGIN
                SELECT COUNT(1) INTO trouve
                FROM user_tables
                WHERE table_name = UPPER(nom_objet);

                IF trouve = 1 THEN
                    EXECUTE IMMEDIATE 'DROP TABLE ' || nom_objet || ' CASCADE CONSTRAINTS';
                    DBMS_OUTPUT.PUT_LINE('Table ' || nom_objet || ' supprimée.');
                ELSE
                    DBMS_OUTPUT.PUT_LINE('Table ' || nom_objet || ' non trouvée.');
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Erreur lors de la suppression de la table ' || nom_objet || ': ' || SQLERRM);
            END;
        END IF;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        code_erreur := SQLCODE;
        message_erreur := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || code_erreur || ' - ' || message_erreur);
END;
/
