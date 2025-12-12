CREATE OR REPLACE PACKAGE BODY BO.gestion_emprunts_pkg AS
    FUNCTION est_disponible_fct (
        i_livres_id          IN NUMBER,
        o_date_retour_prevue OUT DATE
    ) RETURN boolean
    IS
    BEGIN
        null;
    EXCEPTION
        WHEN no_data_found THEN
            return true;
        WHEN e_livre_indisponible THEN
            return false;
    END;
    
    FUNCTION rechercher_livre_fct (
        io_livres_id IN OUT NUMBER
    ) RETURN t_info_livre
    IS
        r_info_livre t_info_livre;
    BEGIN
        return r_info_livre;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            io_livres_id := 0;
            return null;
    END;
    
    PROCEDURE emprunter_livre_prc (
        i_membres_id IN NUMBER,
        i_livres_id  IN NUMBER   
    )
    IS
        livre_id number := i_livres_id;
        date_retour_prevu date;
    BEGIN
        null;
    END;
    
    PROCEDURE retourner_livre_prc (
        i_membres_id IN NUMBER,
        i_livres_id  IN NUMBER    
    )
    IS
    BEGIN
        null;
    END;    
    
    FUNCTION est_penalites_impayees_fct (
        i_membres_id IN NUMBER
    ) RETURN boolean
    IS
        nb_penalites_impayees number;
    BEGIN       
        if nb_penalites_impayees > 0 then
            raise e_penalites_impayees;
        end if;

        return false;
    EXCEPTION
        WHEN e_penalites_impayees THEN
            return true;
    END;    
    
    PROCEDURE archiver_prc (
        i_annee_a_archiver in varchar2 default g_annee_courante,
        i_mois_a_archiver  in varchar2 default g_mois_courant
    )
    IS
        requete VARCHAR2(4000);
    BEGIN
        requete := 'CREATE TABLE bo.emprunts_archive_' || i_annee_a_archiver || i_mois_a_archiver ||
                   ' AS SELECT * FROM bo.emprunts WHERE EXTRACT(YEAR FROM date_emprunt) = ' || i_annee_a_archiver ||
                   ' AND EXTRACT(MONTH FROM date_emprunt) = ' || i_mois_a_archiver;
        EXECUTE IMMEDIATE requete;

        DBMS_OUTPUT.PUT_LINE('Table d''archive créée pour ' || i_annee_a_archiver || '-' || i_mois_a_archiver);
    END;
    
    FUNCTION archiver_annee_fct (
        i_annee_a_archiver in varchar2
    ) RETURN NUMBER
    IS
        nb_mois_archive NUMBER := 0;
        CURSOR c_mois_archive IS
            SELECT DISTINCT EXTRACT(MONTH FROM date_emprunt) AS mois
            FROM bo.emprunts
            WHERE EXTRACT(YEAR FROM date_emprunt) = i_annee_a_archiver;

        mois_en_cours NUMBER;
        tous_livres_retournes BOOLEAN;
    BEGIN
        OPEN c_mois_archive;
        LOOP
            FETCH c_mois_archive INTO mois_en_cours;
            EXIT WHEN c_mois_archive%NOTFOUND;
            SELECT CASE WHEN COUNT(*) > 0 THEN FALSE ELSE TRUE END
            INTO tous_livres_retournes
            FROM bo.emprunts
            WHERE EXTRACT(YEAR FROM date_emprunt) = i_annee_a_archiver
              AND EXTRACT(MONTH FROM date_emprunt) = mois_en_cours
              AND date_retour IS NULL;

            IF tous_livres_retournes THEN
                archiver_prc(i_annee_a_archiver, LPAD(mois_en_cours, 2, '0'));
                nb_mois_archive := nb_mois_archive + 1;
            END IF;
        END LOOP;

        CLOSE c_mois_archive;
        RETURN nb_mois_archive;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur dans l''archivage de l''année ' || i_annee_a_archiver);
            RETURN 0;
    END;

END gestion_emprunts_pkg;