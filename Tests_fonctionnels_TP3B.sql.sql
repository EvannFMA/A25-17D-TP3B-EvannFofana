set serveroutput on;

--****************** CURSEUR | ARCHIVER_ANNEE_FCT ******************
--Effacer les tables d'archives
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


    DBMS_OUTPUT.PUT_LINE('NB_MOIS (devrait être ?) : ' || NB_MOIS);

    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : Archiver année existante [2020]');


    DBMS_OUTPUT.PUT_LINE('NB_MOIS (devrait être ?) : ' || NB_MOIS);

    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 3 : Archiver année existante [2021]');

    DBMS_OUTPUT.PUT_LINE('NB_MOIS (devrait être ?) : ' || NB_MOIS);
END;
/

--****************** DÉCLENCHEUR | CODIFICATION_MEMBRE_BI_TRG ******************
-- Se fait automatiquement. Faire un test avec une nouvelle insertion de membre et l'Afficher pour vérifier.
Prompt ****************** DÉCLENCHEUR | CODIFICATION_MEMBRE_BI_TRG ******************
Prompt *** CAS DE TEST no. 1 : Devrait avoir un code membre généré automatiquement

-- Insérer une nouvelle ligne avec vos coordonnées
-- ...

SELECT * FROM MEMBRES WHERE ID = (SELECT MAX(ID) FROM MEMBRES);
ROLLBACK;
/

--****************** DÉCLENCHEUR | SUPPRESSION_MEMBRE_BD_TRG ******************
--Membre sans emprunt = supprimé
Prompt ****************** DÉCLENCHEUR | SUPPRESSION_MEMBRE_BD_TRG ******************
Prompt *** CAS DE TEST no. 1 : Membre sans emprunt, devrait être supprimé

-- Faire une suppression

ROLLBACK;

-- Afficher le membre supprimé après ROLLBACK

/

--Membre avec emprunt, mais date de retour respectée, alors EMPRUNT du membre supprimé + MEMBRE supprimé
Prompt *** CAS DE TEST no. 2 : Membre avec emprunt, mais date de retour respectée, alors EMPRUNT du membre supprimé + MEMBRE supprimé

-- Faire une suppression

ROLLBACK;
-- Afficher le membre et l'emprunt supprimé après ROLLBACK

/

--Membre avec emprunt, mais date de retour non respectée, alors MEMBRE non supprimé
Prompt *** CAS DE TEST no. 3 : Membre avec emprunt, mais date de retour non respectée, alors MEMBRE non supprimé (ERREUR)

-- Faire une suppression

DBMS_OUTPUT.PUT_LINE('Membre X non supprimé, car il a des livres non retournés.');
ROLLBACK;
/

--****************** DÉCLENCHEUR | SUIVI_EMPRUNT_BI_BU_TRG ******************
--MEMBRE : no?
Prompt ****************** DÉCLENCHEUR | SUIVI_EMPRUNT_BI_BU_TRG ******************
Prompt *** CAS DE TEST no. 1 : Insertion d''un emprunt, alors I-#18
Prompt Nb emprunts jusqu''à maintenant
select count(*) from EMPRUNTS;
Prompt on insère un emprunt

--Insérer une emprunt ici

select * from EMPRUNTS; --Vérifier le code de suivi
rollback;
/

Prompt *** CAS DE TEST no. 2 : Mise à jour d''une date de retour NULL, alors R+Numéro de téléphone du membre
select * from EMPRUNTS;

--Faire un UPDATE

select * from EMPRUNTS; --Vérifier le code de suivi
rollback;
/

Prompt *** CAS DE TEST no. 3 : Mise à jour d''une date de retour, NON NULL alors aucun CODE_SUIVI avec téléphone
select * from EMPRUNTS;

--Faire un UPDATE

Prompt CODE_SUIVI doit être resté à I-#0
select * from EMPRUNTS; --Vérifier le code de suivi
rollback;
/

Prompt *** CAS DE TEST no. 4 : Mise à jour d''une date d''emprunt, Pas de changement, car c''est pas la date de RETOUR
select * from EMPRUNTS;

--Faire un UPDATE

Prompt CODE_SUIVI doit être resté à I-#0
select * from EMPRUNTS;
rollback;
/


--****************** RÔLES et permissions ******************
-- Observer les rôles et permissions (se connecter à BO)
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

PROMPT n''oubliez pas aussi de consulter le dossier OTHER USERS de l''utilisateur MEMBRE01, par exemple pour voir ce qu''il peut voir de BO
-- Vérifier aussi le dossier OTHER USERS -> BO