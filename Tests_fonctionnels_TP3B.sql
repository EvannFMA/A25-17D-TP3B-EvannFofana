-- Tests_fonctionnels_TP3B.sql
-- Pour que les 'dbms_output.put_line' s'affichent en SQL*PLUS
set serveroutput on;

--****************** CURSEUR | ARCHIVER_ANNEE_FCT ******************
--Effacer les tables d'archives
ALTER SESSION SET CURRENT_SCHEMA = bo;

DECLARE
    CURSOR C_TABLES_ARCHIVES IS
    SELECT
        TABLE_NAME
    FROM
        USER_TABLES
    WHERE
        TABLE_NAME LIKE 'EMPRUNTS_ARCHIVE_%';
BEGIN
    FOR REC IN C_TABLES_ARCHIVES LOOP
        EXECUTE IMMEDIATE 'drop table '
                          || REC.TABLE_NAME;
        DBMS_OUTPUT.PUT_LINE('Table '
                             || REC.TABLE_NAME
                             || ' supprimée.');
    END LOOP;
END;
/
-- ARCHIVER_ANNEE_FCT
DECLARE
    NB_MOIS NUMBER DEFAULT 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 1 : Archiver une année inexistante [2019]');
    NB_MOIS := BO.gestion_emprunts_pkg.archiver_annee_fct('2019');

    DBMS_OUTPUT.PUT_LINE('NB_MOIS (devrait être 0) : ' || NB_MOIS);

    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : Archiver année existante [2020]');
    NB_MOIS := BO.gestion_emprunts_pkg.archiver_annee_fct('2020');

    DBMS_OUTPUT.PUT_LINE('NB_MOIS (devrait être ?) : ' || NB_MOIS);

    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 3 : Archiver année existante [2021]');
    NB_MOIS := BO.gestion_emprunts_pkg.archiver_annee_fct('2021');

    DBMS_OUTPUT.PUT_LINE('NB_MOIS (devrait être ?) : ' || NB_MOIS);
END;
/


--****************** DÉCLENCHEUR | CODIFICATION_MEMBRE_BI_TRG ******************
-- Se fait automatiquement. Faire un test avec une nouvelle insertion de membre et l'Afficher pour vérifier.
Prompt ****************** DÉCLENCHEUR | CODIFICATION_MEMBRE_BI_TRG ******************
Prompt *** CAS DE TEST no. 1 : Devrait avoir un code membre généré automatiquement
ALTER SESSION SET CURRENT_SCHEMA = employe01;

INSERT INTO bo.MEMBRES (
    PRENOM, NOM, GENRE, DATE_NAISSANCE, COURRIEL, ADRESSE_LIGNE1, ADRESSE_LIGNE2,
    VILLE, PROVINCE, CODE_POSTAL, PAYS, TELEPHONE, DATE_DEBUT_MEMBRE, STATUT_MEMBRE, THEME_PREFERE
) VALUES (
    'Jean', 'Dupont', 'M', TO_DATE('1980-01-01', 'YYYY-MM-DD'), 'jean.dupont@example.com', '1 rue Exemple', NULL,
    'Québec', 'Québec', 'G1A1A1', 'Canada', '418-123-4567', TO_DATE('2023-12-12', 'YYYY-MM-DD'), 'Actif', 'Aventure'
);

SELECT * FROM bo.MEMBRES WHERE ID = (SELECT MAX(ID) FROM bo.MEMBRES);
ROLLBACK;
/


--****************** DÉCLENCHEUR | SUPPRESSION_MEMBRE_BD_TRG ******************
--Membre sans emprunt = supprimé
Prompt ****************** DÉCLENCHEUR | SUPPRESSION_MEMBRE_BD_TRG ******************
Prompt *** CAS DE TEST no. 1 : Membre sans emprunt, devrait être supprimé

DELETE FROM BO.MEMBRES WHERE COURRIEL = 'tetienne13@cam.ac.uk';
ROLLBACK;
SELECT * FROM BO.MEMBRES WHERE COURRIEL = 'tetienne13@cam.ac.uk';
/


Prompt *** CAS DE TEST no. 2 : Membre avec emprunt, mais date de retour respectée, alors EMPRUNT du membre supprimé + MEMBRE supprimé
INSERT INTO bo.MEMBRES (
    PRENOM, NOM, GENRE, DATE_NAISSANCE, COURRIEL, ADRESSE_LIGNE1, ADRESSE_LIGNE2,
    VILLE, PROVINCE, CODE_POSTAL, PAYS, TELEPHONE, DATE_DEBUT_MEMBRE, STATUT_MEMBRE, THEME_PREFERE
) VALUES (
    'Pierre', 'Lemoine', 'M', TO_DATE('1985-04-05', 'YYYY-MM-DD'), 'pierre.lemoine@example.com', '3 rue Exemple', NULL,
    'Trois-Rivières', 'Québec', 'G9A3B3', 'Canada', '819-123-4568', TO_DATE('2023-11-10', 'YYYY-MM-DD'), 'Actif', 'Histoire'
);

INSERT INTO bo.EMPRUNTS (LIVRES_ID, MEMBRES_ID, DATE_EMPRUNT, DATE_RETOUR)
VALUES (18, (SELECT ID FROM bo.MEMBRES WHERE COURRIEL = 'pierre.lemoine@example.com'), TO_DATE('2023-11-01', 'YYYY-MM-DD'), TO_DATE('2023-11-15', 'YYYY-MM-DD'));

DELETE FROM bo.MEMBRES WHERE COURRIEL = 'pierre.lemoine@example.com';
ROLLBACK;

SELECT * FROM bo.MEMBRES WHERE COURRIEL = 'pierre.lemoine@example.com';
SELECT * FROM bo.EMPRUNTS WHERE MEMBRES_ID = (SELECT ID FROM bo.MEMBRES WHERE COURRIEL = 'pierre.lemoine@example.com');
/


Prompt *** CAS DE TEST no. 3 : Membre avec emprunt, mais date de retour non respectée, alors MEMBRE non supprimé (ERREUR)

INSERT INTO bo.MEMBRES (
    PRENOM, NOM, GENRE, DATE_NAISSANCE, COURRIEL, ADRESSE_LIGNE1, ADRESSE_LIGNE2,
    VILLE, PROVINCE, CODE_POSTAL, PAYS, TELEPHONE, DATE_DEBUT_MEMBRE, STATUT_MEMBRE, THEME_PREFERE
) VALUES (
    'Luc', 'Rochefort', 'M', TO_DATE('1992-07-10', 'YYYY-MM-DD'), 'luc.rochefort@example.com', '4 rue Exemple', NULL,
    'Québec', 'Québec', 'G1G4X4', 'Canada', '418-987-6543', TO_DATE('2023-12-01', 'YYYY-MM-DD'), 'Actif', 'Philosophie'
);

INSERT INTO bo.EMPRUNTS (LIVRES_ID, MEMBRES_ID, DATE_EMPRUNT, DATE_RETOUR)
VALUES (19, (SELECT ID FROM bo.MEMBRES WHERE COURRIEL = 'luc.rochefort@example.com'), TO_DATE('2023-10-01', 'YYYY-MM-DD'), NULL);

DELETE FROM bo.MEMBRES WHERE COURRIEL = 'luc.rochefort@example.com';
ROLLBACK;
SELECT * FROM bo.MEMBRES WHERE COURRIEL = 'luc.rochefort@example.com';
/


--****************** DÉCLENCHEUR | SUIVI_EMPRUNT_BI_BU_TRG ******************
Prompt ****************** DÉCLENCHEUR | SUIVI_EMPRUNT_BI_BU_TRG ******************
Prompt *** CAS DE TEST no. 1 : Insertion d''un emprunt, alors I-#18

SELECT COUNT(*) FROM bo.EMPRUNTS;

INSERT INTO BO.EMPRUNTS (LIVRES_ID, MEMBRES_ID, DATE_EMPRUNT, DATE_RETOUR)
VALUES (
    20,
    (SELECT ID FROM BO.MEMBRES WHERE COURRIEL = 'azuppa11@nbcnews.com'),
    SYSDATE,
    SYSDATE + 14
);

SELECT * FROM bo.EMPRUNTS WHERE ID = (SELECT MAX(ID) FROM BO.EMPRUNTS);
ROLLBACK;
/


Prompt *** CAS DE TEST no. 2 : Mise à jour d''une date de retour NULL, alors R+Numéro de téléphone du membre

SELECT * FROM bo.EMPRUNTS;

UPDATE BO.EMPRUNTS
SET DATE_RETOUR = NULL
WHERE ID = (SELECT MAX(ID) FROM BO.EMPRUNTS);

SELECT * FROM bo.EMPRUNTS WHERE ID = (SELECT MAX(ID) FROM BO.EMPRUNTS);
ROLLBACK;
/


Prompt *** CAS DE TEST no. 3 : Mise à jour d''une date de retour, NON NULL alors aucun CODE_SUIVI avec téléphone

SELECT * FROM bo.EMPRUNTS;

UPDATE BO.EMPRUNTS
SET DATE_RETOUR = SYSDATE + 10
WHERE ID = (SELECT MAX(ID) FROM BO.EMPRUNTS);

SELECT * FROM bo.EMPRUNTS WHERE ID = (SELECT MAX(ID) FROM BO.EMPRUNTS);
ROLLBACK;
/


Prompt *** CAS DE TEST no. 4 : Mise à jour d''une date d''emprunt, Pas de changement, car c''est pas la date de RETOUR

SELECT * FROM bo.EMPRUNTS;

UPDATE BO.EMPRUNTS
SET DATE_EMPRUNT = SYSDATE - 5
WHERE ID = (SELECT MAX(ID) FROM BO.EMPRUNTS);

SELECT * FROM bo.EMPRUNTS WHERE ID = (SELECT MAX(ID) FROM BO.EMPRUNTS);
ROLLBACK;
/

--****************** RÔLES et permissions ******************
-- Observer les rôles et permissions (se connecter à BO)
ALTER SESSION SET CURRENT_SCHEMA = bo;
Prompt Il faut se connecter à BO pour vérifier les rôles et permissions suivantes :
SELECT * FROM dba_roles where ROLE LIKE 'ROLE_%';
SELECT * FROM dba_role_privs WHERE grantee = 'ROLE_SYSTEME';
SELECT * FROM dba_role_privs WHERE grantee = 'ROLE_BIBLIOTHECAIRE';
SELECT * FROM dba_role_privs WHERE grantee = 'ROLE_MEMBRE';
SELECT * FROM dba_tab_privs where GRANTEE LIKE 'ROLE_%' order by grantee, TABLE_NAME;
/

Prompt Il faut se connecter à MEMBRE01 pour tester ceci, ensuite refaire pour EMPLOYE01 :
--tester la sélection ou suppression de livres pour
--(se connecter à MEMBRE01 et ensuite à EMPLOYE01)
ALTER SESSION SET CURRENT_SCHEMA = MEMBRE01;
SELECT * FROM BO.LIVRES;
SELECT * FROM BO.EMPRUNTS;
/
DELETE FROM BO.EMPRUNTS;
DELETE FROM BO.LIVRES;
DELETE FROM BO.SECTIONS;
DELETE FROM BO.GENRES;
DELETE FROM BO.AUTEURS;
DELETE FROM BO.MEMBRES;
ROLLBACK;
/

ALTER SESSION SET CURRENT_SCHEMA = EMPLOYE01;
SELECT * FROM BO.LIVRES;
SELECT * FROM BO.EMPRUNTS;
/
DELETE FROM BO.EMPRUNTS;
DELETE FROM BO.LIVRES;
DELETE FROM BO.SECTIONS;
DELETE FROM BO.GENRES;
DELETE FROM BO.AUTEURS;
DELETE FROM BO.MEMBRES;
ROLLBACK;
/