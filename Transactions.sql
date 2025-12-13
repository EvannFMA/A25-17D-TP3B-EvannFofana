-- Transactions.sql
-- Pour que les 'dbms_output.put_line' s'affichent en SQL*PLUS
SET SERVEROUTPUT ON;

DECLARE
    total_amende NUMBER := 0;
    retard_jours NUMBER;
    amende_base  NUMBER := 0.25;
    amende_forfataire  NUMBER := 5.50;
    amende_etape_4 NUMBER := 2.25;
    amende_inflation NUMBER := 0.05;
    amende_gros_montant NUMBER := 300;

    -- Curseur pour sélectionner les membres en retard
    CURSOR c_retardataires IS
        SELECT DISTINCT MEMBRES_ID
        FROM bo.EMPRUNTS
        WHERE DATE_RETOUR IS NULL AND DATE_EMPRUNT < SYSDATE;

    -- Curseur pour les emprunts et le calcul des amendes
    CURSOR c_emprunts IS
        SELECT MEMBRES_ID, LIVRES_ID, DATE_EMPRUNT, DATE_RETOUR
        FROM bo.EMPRUNTS
        WHERE DATE_RETOUR IS NULL;

BEGIN
    -- Etape 1 : Initialiser les amendes des membres à 0
    UPDATE bo.MEMBRES
    SET MONTANT_AMENDE = 0;
    COMMIT;

    -- Etape 2 : Ajout d'une amende forfaitaire de 5,50$ pour chaque retardataire
    FOR rec IN c_retardataires LOOP
        UPDATE bo.MEMBRES
        SET MONTANT_AMENDE = MONTANT_AMENDE + amende_forfataire
        WHERE ID = rec.MEMBRES_ID;
    END LOOP;

    -- Etape 3 : Calcul des amendes par jour de retard (0,25$ par jour)
    SAVEPOINT avant_Etape_3;
    FOR rec_emprunt IN c_emprunts LOOP
        retard_jours := ROUND(SYSDATE - rec_emprunt.DATE_EMPRUNT);

        IF retard_jours > 0 THEN
            UPDATE bo.MEMBRES
            SET MONTANT_AMENDE = MONTANT_AMENDE + (retard_jours * amende_base)
            WHERE ID = rec_emprunt.MEMBRES_ID;
        END IF;
    END LOOP;

    -- Vérification si un membre a une amende >= 300$ (Etape 4)
    -- *** J'étais pas trop sur de comprendre l'énoncé puisqu'il dit d'annuler le calcul de l'étape 3 au complet,
    -- *** mais en même temps dit de seulement modifier les membres avec une amende de 300$ ou plus.
    -- *** Puisque ça laisserait des membres sans amendes j'ai fait en sorte que si il y a 1 membre avec 300$ ou plus,
    -- *** Toutes les amendes vont suivre le calcul de l'étape 4.
    SELECT MAX(MONTANT_AMENDE) INTO total_amende FROM bo.MEMBRES;

    IF total_amende >= amende_gros_montant THEN
        -- Etape 4 : Si une amende est >= 300$, on modifie le calcul à 2,25$ par livre
        ROLLBACK TO avant_Etape_3;
        UPDATE bo.MEMBRES m
        SET m.MONTANT_AMENDE = m.MONTANT_AMENDE + amende_etape_4 * (
                SELECT COUNT(*)
                FROM bo.EMPRUNTS e
                WHERE e.MEMBRES_ID = m.ID
                  AND e.DATE_RETOUR IS NULL
                  AND e.DATE_EMPRUNT < SYSDATE
              )
        WHERE EXISTS (
            SELECT 1
            FROM bo.EMPRUNTS e
            WHERE e.MEMBRES_ID = m.ID
              AND e.DATE_RETOUR IS NULL
              AND e.DATE_EMPRUNT < SYSDATE
        );

        COMMIT;
    ELSE
        -- Etape 5 : Sinon, on applique une augmentation de 5% sur toutes les amendes
        FOR rec_retardataire IN c_retardataires LOOP
            UPDATE bo.MEMBRES
            SET MONTANT_AMENDE = MONTANT_AMENDE * (1 + amende_inflation)
            WHERE ID = rec_retardataire.MEMBRES_ID;
        END LOOP;
        COMMIT;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Les amendes ont été mises à jour avec succès.');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Une erreur s''est produite. La transaction a été annulée, sauf pour l''étape 1.');
        RAISE;
END;
/
