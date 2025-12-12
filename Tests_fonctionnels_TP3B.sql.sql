set serveroutput on;


/************************************* Fait par ÉTUDIANT 1, à tester par ÉTUDIANT 2 *******************************************/
-- A. TEST FONCTIONNEL POUR est_penalites_impayees_fct
DECLARE
    ID_MEMBRE NUMBER;
    AMENDE_TOTAL NUMBER;
BEGIN
    -- LIVRES TOUS RETOURNÉS, SANS AMENDE À PAYER
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 1 : LIVRES TOUS RETOURNÉS, SANS AMENDE À PAYER');
    ID_MEMBRE := 7; -- Membre 7 : Aucune amende à payer
    AMENDE_TOTAL := est_penalites_impayees_fct(ID_MEMBRE);
    DBMS_OUTPUT.PUT_LINE('Amende totale pour le membre ' || ID_MEMBRE || ': ' || AMENDE_TOTAL);

    -- LIVRES TOUS RETOURNÉS, MAIS AVEC AMENDE À PAYER
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : LIVRES TOUS RETOURNÉS, MAIS AVEC AMENDE À PAYER');
    ID_MEMBRE := 8; -- Membre 8 : Amende à payer
    AMENDE_TOTAL := est_penalites_impayees_fct(ID_MEMBRE);
    DBMS_OUTPUT.PUT_LINE('Amende totale pour le membre ' || ID_MEMBRE || ': ' || AMENDE_TOTAL);

    -- LIVRE PAS TOUS RETOURNÉS, AVEC AMENDE À PAYER
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 3 : LIVRE PAS TOUS RETOURNÉS, AVEC AMENDE À PAYER');
    ID_MEMBRE := 9; -- Membre 9 : Livre non retourné et amende à payer
    AMENDE_TOTAL := est_penalites_impayees_fct(ID_MEMBRE);
    DBMS_OUTPUT.PUT_LINE('Amende totale pour le membre ' || ID_MEMBRE || ': ' || AMENDE_TOTAL);

    -- LIVRE PAS TOUS RETOURNÉS, MAIS SANS AMENDE À PAYER
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 4 : LIVRE PAS TOUS RETOURNÉS, MAIS SANS AMENDE À PAYER');
    ID_MEMBRE := 10; -- Membre 10 : Livre non retourné, mais sans amende
    AMENDE_TOTAL := est_penalites_impayees_fct(ID_MEMBRE);
    DBMS_OUTPUT.PUT_LINE('Amende totale pour le membre ' || ID_MEMBRE || ': ' || AMENDE_TOTAL);
END;
/

-- B. TEST FONCTIONNEL POUR emprunter_livre_prc
DECLARE
    ID_MEMBRE NUMBER;
    ID_LIVRE  NUMBER;
    VERIF     VARCHAR2(1000); -- Pratique pour afficher les dates lors de transactions
BEGIN
    -- EMPRUNT IMPOSSIBLE, CAR AMENDES
    DBMS_OUTPUT.PUT_LINE ('*** CAS DE TEST no. 1 : EMPRUNT IMPOSSIBLE, CAR AMENDES');
    ID_MEMBRE := 5; -- Membre avec amendes impayées
    ID_LIVRE := 15; -- Livre à emprunter
    emprunter_livre_prc(ID_MEMBRE, ID_LIVRE); -- Appeler la procédure

    ROLLBACK; -- Annuler les modifications pour revenir aux données d'origine

    -- LIVRE INEXISTANT
    DBMS_OUTPUT.PUT_LINE ('*** CAS DE TEST no. 2 : LIVRE INEXISTANT');
    ID_MEMBRE := 6; -- Membre valide
    ID_LIVRE := 9999; -- ID de livre inexistant
    emprunter_livre_prc(ID_MEMBRE, ID_LIVRE);

    ROLLBACK;

    -- LIVRE EXISTANT, MAIS DÉJÀ EMPRUNTÉ
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 3 : LIVRE EXISTANT, MAIS DÉJÀ EMPRUNTÉ');
    ID_MEMBRE := 7; -- Membre avec emprunt en cours
    ID_LIVRE := 5; -- Livre déjà emprunté
    emprunter_livre_prc(ID_MEMBRE, ID_LIVRE);

    ROLLBACK;

    -- CAS DE TEST no. 4 : ON PEUT EMPRUNTER LE LIVRE
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 4 : ON PEUT EMPRUNTER LE LIVRE');
    ID_MEMBRE := 8; -- Membre sans emprunts en cours
    ID_LIVRE := 10; -- Livre disponible
    emprunter_livre_prc(ID_MEMBRE, ID_LIVRE);

    ROLLBACK;
END;
/

-- C. TEST FONCTIONNEL POUR est_disponible_fct
DECLARE
    ID_LIVRE     NUMBER;
    RETOUR_PREVU DATE;
BEGIN
    -- LIVRE DISPONIBLE POUR EMPRUNT
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 1 : LIVRE DISPONIBLE POUR EMPRUNT');
    ID_LIVRE := 3; -- Livre disponible
    RETOUR_PREVU := est_disponible_fct(ID_LIVRE); -- Appeler la fonction
    DBMS_OUTPUT.PUT_LINE('Date de retour prévue pour le livre ' || ID_LIVRE || ': ' || RETOUR_PREVU);

    -- LIVRE DÉJÀ EMPRUNTÉ
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : LIVRE DÉJÀ EMPRUNTÉ');
    ID_LIVRE := 2; -- Livre déjà emprunté
    RETOUR_PREVU := est_disponible_fct(ID_LIVRE);
    DBMS_OUTPUT.PUT_LINE('Date de retour prévue pour le livre ' || ID_LIVRE || ': ' || RETOUR_PREVU);
END;
/

/************************************* Fait par ÉTUDIANT 2, à tester par ÉTUDIANT 1 *******************************************/
--D. TEST FONCTIONNEL POUR retourner_livre_prc
DECLARE
    ID_MEMBRE NUMBER;
    ID_LIVRE  NUMBER;
    VERIF     VARCHAR2(1000);
BEGIN
 
    -- RETOUR SANS AMENDES À PAYER
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 1 : RETOUR SANS AMENDES À PAYER');
    ID_MEMBRE := 6; -- Membre 6 : Aucune amende à payer
    ID_LIVRE := 18; -- Livre 18 : Livre à retourner

    ROLLBACK; -- Pour annuler les modifications de la transaction (retrouver les données d'origine)



    -- RETOUR AVEC AMENDES À PAYER
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : RETOUR AVEC AMENDES À PAYER');


    rollback;
END;
/

--E. TEST FONCTIONNEL POUR rechercher_livre_fct
DECLARE
    ID_LIVRE     NUMBER;
    REC_INFO_LIVRE BO.GESTION_EMPRUNTS_PKG.T_INFO_LIVRE;
BEGIN
 
    -- LIVRE EXISTANT
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 1 : LIVRE EXISTANT');


 

    -- LIVRE INEXISTANT
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : LIVRE INEXISTANT');


END;
/




--F.  TEST FONCTIONNEL POUR archiver_prc
DECLARE
    VERIF VARCHAR2(1000);
BEGIN
 
    -- Création EMPRUNTS_ARCHIVE_202012 (valeurs par défaut)
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 1 : Création de la table EMPRUNTS_ARCHIVE_202012 (valeurs par défaut)');

    
 
    -- Création EMPRUNTS_ARCHIVE_202104
    DBMS_OUTPUT.PUT_LINE('*** CAS DE TEST no. 2 : Création de la table EMPRUNTS_ARCHIVE_202104 (Avril 2024)');




    --drop table EMPRUNTS_ARCHIVE_202012;
    --drop table EMPRUNTS_ARCHIVE_202104;
END;
/