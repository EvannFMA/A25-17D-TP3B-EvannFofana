-- 02_BO_15_gestion_emprunts_pkg.pkb

CREATE OR REPLACE PACKAGE BODY BO.gestion_emprunts_pkg IS
    FUNCTION est_disponible_fct (
        i_livres_id          IN NUMBER,
        o_date_retour_prevue OUT DATE
    ) RETURN boolean
    IS
        v_emprunt_en_cours NUMBER;
    BEGIN
        -- Vérifier si le livre est déjà emprunté
        SELECT COUNT(*), MAX(DATE_RETOUR_PREVU)
        INTO v_emprunt_en_cours, o_date_retour_prevue
        FROM bo.EMPRUNTS
        WHERE LIVRES_ID = i_livres_id
          AND DATE_RETOUR IS NULL;  -- Le livre est emprunté et n'a pas encore été retourné

        -- Si un emprunt est en cours, le livre n'est pas disponible
        IF v_emprunt_en_cours > 0 THEN
            RAISE e_livre_indisponible;  -- Lancer l'exception de livre indisponible
            RETURN FALSE;
        ELSE
            -- Le livre est disponible
            RETURN TRUE;
        END IF;
    EXCEPTION
        WHEN e_livre_indisponible THEN
            DBMS_OUTPUT.PUT_LINE('Le livre est actuellement indisponible.');
            RETURN FALSE;
        WHEN OTHERS THEN
            RETURN TRUE;
    END;
    
    FUNCTION rechercher_livre_fct (
        io_livres_id IN OUT NUMBER
    ) RETURN t_info_livre
    IS
        r_info_livre t_info_livre;
    BEGIN
        -- Rechercher le livre et ses informations associées
        SELECT l.ID, l.TITRE, l.ISBN, a.NOM_AUTEUR, l.MAISON_EDITION, l.ANNEE_PUBLICATION,
               l.LANGAGE, s.NOM, g.NOM_GENRE
        INTO r_info_livre.ID, r_info_livre.TITRE, r_info_livre.ISBN, r_info_livre.AUTEUR,
             r_info_livre.EDITEUR, r_info_livre.ANNEE, r_info_livre.LANGUE, r_info_livre.SECTION,
             r_info_livre.GENRE
        FROM bo.LIVRES l
        JOIN bo.AUTEURS a ON l.AUTEURS_ID = a.ID
        JOIN bo.SECTIONS s ON l.SECTIONS_ID = s.ID
        JOIN bo.GENRES g ON l.GENRES_ID = g.ID
        WHERE l.ID = io_livres_id;

        RETURN r_info_livre;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            io_livres_id := 0;  -- Livre non trouvé
            RETURN NULL;
    END;
    
    PROCEDURE emprunter_livre_prc (
        i_membres_id IN NUMBER,
        i_livres_id  IN NUMBER   
    )
    IS
        v_disponible BOOLEAN;
        v_date_retour DATE;
        v_livres_id NUMBER;
        v_livre_info t_info_livre;
    BEGIN
        -- Vérifier si le membre a des pénalités impayées
        IF est_penalites_impayees_fct(i_membres_id) THEN
            DBMS_OUTPUT.PUT_LINE('Le membre a des pénalités impayées et ne peut pas emprunter.');
            RETURN;
        END IF;

        -- Il faut que je transfere le contenu de l'id a une autre variable car i_livres_id ne peut pas être modifié
        v_livres_id := i_livres_id;
        v_livre_info := rechercher_livre_fct(v_livres_id);

        -- Vérifier si le livre est disponible
        v_disponible := est_disponible_fct(i_livres_id, v_date_retour);

        IF v_disponible THEN
            -- Si le livre est disponible, enregistrer l'emprunt
            INSERT INTO bo.EMPRUNTS (LIVRES_ID, MEMBRES_ID, DATE_EMPRUNT, DATE_RETOUR)
            VALUES (i_livres_id, i_membres_id, SYSDATE, NULL);  -- Date de retour est NULL au début
            DBMS_OUTPUT.PUT_LINE('Le livre a été emprunté avec succès.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Le livre n''est pas disponible à l''emprunt. Date de retour prévue: ' || v_date_retour);
        END IF;
    END;
    
    PROCEDURE retourner_livre_prc (
        i_membres_id IN NUMBER,
        i_livres_id  IN NUMBER    
    )
    IS
        v_date_retour DATE := SYSDATE;  -- Date actuelle pour la date de retour
        v_retard NUMBER;                -- Variable pour calculer le retard
        v_penalite NUMBER := 0;         -- Variable pour stocker le montant des pénalités
        v_date_retour_prevu DATE;       -- Variable pour stocker la date de retour prévue
    BEGIN
        -- Récupérer la date de retour prévue pour le livre
        SELECT DATE_EMPRUNT + INTERVAL '21' DAY
        INTO v_date_retour_prevu
        FROM bo.EMPRUNTS
        WHERE MEMBRES_ID = i_membres_id
          AND LIVRES_ID = i_livres_id
          AND DATE_RETOUR IS NULL;

        -- Calculer le retard si le livre est retourné après la date prévue
        IF v_date_retour > v_date_retour_prevu THEN
            -- Retard en jours
            v_retard := v_date_retour - v_date_retour_prevu;
            -- Calculer la pénalité, ici un exemple simple avec 1 $ par jour de retard
            v_penalite := v_retard * 1;  -- Tu peux ajuster la logique de calcul selon tes besoins
            DBMS_OUTPUT.PUT_LINE('Pénalité pour retard : ' || v_penalite || ' $');
        END IF;

        -- Mise à jour de la date de retour du livre
        UPDATE bo.EMPRUNTS
        SET DATE_RETOUR = v_date_retour
        WHERE MEMBRES_ID = i_membres_id
          AND LIVRES_ID = i_livres_id
          AND DATE_RETOUR IS NULL;  -- S'assurer que le livre n'a pas déjà été retourné

        -- Vérifier si l'update a été effectué
        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Aucun emprunt trouvé ou le livre a déjà été retourné.');
        ELSE
            -- Si l'emprunt a été mis à jour, afficher un message
            DBMS_OUTPUT.PUT_LINE('Le livre avec ID ' || i_livres_id || ' a été retourné par le membre ' || i_membres_id);
            -- Afficher la pénalité (si applicable)
            IF v_penalite > 0 THEN
                DBMS_OUTPUT.PUT_LINE('Le membre doit payer une pénalité de ' || v_penalite || ' $');
            END IF;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            -- Gestion des erreurs
            DBMS_OUTPUT.PUT_LINE('Erreur lors du retour du livre. Détails de l''erreur : ' || SQLERRM);
    END;

    FUNCTION calculer_penalite_membre (
        i_membres_id IN NUMBER
    ) RETURN NUMBER
    IS
        penalite_total NUMBER := 0;
    BEGIN
        -- Calcul des pénalités en fonction de la date de retour dépassée
        SELECT SUM(NVL((SYSDATE - DATE_RETOUR_PREVU) * 1, 0))  -- Pénalité d'un certain montant par jour de retard
        INTO penalite_total
        FROM bo.EMPRUNTS
        WHERE MEMBRES_ID = i_membres_id
          AND DATE_RETOUR IS NULL
          AND SYSDATE > DATE_RETOUR_PREVU;  -- Le retour est en retard

        RETURN penalite_total;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END;

    FUNCTION est_penalites_impayees_fct (
        i_membres_id IN NUMBER
    ) RETURN boolean
    IS
        penalite NUMBER;
    BEGIN
        -- Calculer les pénalités pour ce membre
        penalite := calculer_penalite_membre(i_membres_id);

        -- Si des pénalités sont trouvées, on lève l'exception
        IF penalite > 0 THEN
            RAISE e_penalites_impayees;
        END IF;

        -- Si aucune pénalité, le membre peut emprunter
        RETURN FALSE;
    EXCEPTION
        WHEN e_penalites_impayees THEN
            RETURN TRUE;
        WHEN OTHERS THEN
            RETURN FALSE;
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