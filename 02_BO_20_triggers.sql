-- 02_BO_20_triggers.sql

-- Déclencheur qui s'active avant l'insertion d'un membre
CREATE OR REPLACE TRIGGER bo.MEMBRE_BI_TRG
BEFORE INSERT ON bo.MEMBRES
FOR EACH ROW
DECLARE
    code_membre VARCHAR2(12);
BEGIN
    -- Dual est une table bidon qui permet de lancer le SELECT sans FROM (Sinon erreur)
    SELECT 'BOQC' || LPAD(bo.code_membre_seq.NEXTVAL, 8, '0')
    INTO code_membre
    FROM dual;

    :NEW.CODE := code_membre;
END;
/

-- Déclencheur qui s'active avant la suppression d'un membre
CREATE OR REPLACE TRIGGER bo.MEMBRE_BD_TRG
BEFORE DELETE ON bo.MEMBRES
FOR EACH ROW
DECLARE
    non_retournes NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO non_retournes
    FROM bo.EMPRUNTS
    WHERE MEMBRES_ID = :OLD.ID AND DATE_RETOUR IS NULL;

    IF non_retournes > 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'Impossible de supprimer le membre. Des livres sont toujours en sa possession.');
    ELSE
        DELETE FROM bo.EMPRUNTS
        WHERE MEMBRES_ID = :OLD.ID;
    END IF;
END;
/

-- Déclencheur qui s'active avant l'insertion et avant la mise a jour d'un emprunt
CREATE OR REPLACE TRIGGER bo.EMPRUNT_BI_BU_TRG
BEFORE INSERT OR UPDATE ON bo.EMPRUNTS
FOR EACH ROW
DECLARE
    emprunts NUMBER;
BEGIN
    IF INSERTING THEN
        SELECT COUNT(*) + 1
        INTO emprunts
        FROM bo.EMPRUNTS;

        :NEW.code_suivi := 'I-#' || emprunts;

    ELSIF UPDATING AND :NEW.DATE_RETOUR IS NULL THEN
        SELECT 'R-' || TELEPHONE
        INTO :NEW.code_suivi
        FROM bo.MEMBRES
        WHERE ID = :NEW.MEMBRES_ID;
    END IF;
END;
/